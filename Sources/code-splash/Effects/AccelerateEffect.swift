import Foundation
import AppKit
import QuartzCore

/// Each line of code flows in, accelerates, and shoots away.
class AccelerateEffect: VisualEffect {
    var name: String { "Accelerate" }

    private let linesInterval: CFTimeInterval = 1 / 4
    private let displayLines = 5

    private var id: UUID!
    private var baseSize: CGFloat = 22.0

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        id = overlayWindow.addEffectView(containerView)

        baseSize = contentView.bounds.height / 10.0

        let lines = selectRandomLines(text, lines: displayLines)
        let right = contentView.bounds.maxX
        let baseY = CGFloat.random(
            in: contentView.bounds
                .minY...(contentView.bounds.maxY - CGFloat(displayLines) * baseSize))
        let colorPair = Colors.shared.colorIndexPair();

        let startTime: CFTimeInterval = CACurrentMediaTime()
        var animatives: [Animative?] = []

        // create random order of 0...(lines.count-1)
        var order = Array(0..<lines.count).shuffled()
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime

            // create new views
            while elapsed >= Double(animatives.count) * self.linesInterval && !order.isEmpty {
                let index = order.removeFirst()
                let line = lines[index]
                let textField = TextFieldCache.shared.get(
                    line,
                    font: NSFont.monospacedSystemFont(ofSize: self.baseSize, weight: .regular),
                    color: Colors.shared.gradientColor(
                        at: CGFloat(index) / CGFloat(self.displayLines - 1), between: colorPair),
                    alpha: 1.0
                )
                textField.frame.origin = CGPoint(
                    x: right + 1,
                    y: baseY + CGFloat(self.displayLines - index - 1) * self.baseSize
                )
                containerView.addSubview(textField)
                animatives.append(
                    Animative(
                        textField, startTime: elapsed, bounds: contentView.bounds,
                        v0: -2200 * CGFloat.random(in: 0.8...1.2),
                        a1: 3800 * CGFloat.random(in: 0.8...1.2),
                        a2: -24000 * CGFloat.random(in: 0.8...1.2),
                        timeAcc: 0.5 * Double.random(in: 0.8...1.2)
                    )
                )
            }

            // animate each views
            var living = false
            for (index, animative) in animatives.enumerated() {
                if animative == nil { continue }
                living = true
                if !animative!.animate(elapsed: elapsed) {
                    animative!.view.removeFromSuperview()
                    TextFieldCache.shared.release(animative!.view)
                    animatives[index] = nil
                }
            }

            // all animations done
            if !living {
                timer.invalidate()
                self.stop()
            }
        }
    }

    private func stop() {
        overlayWindow.clearEffect(id: id)
    }

    private class Animative {
        let view: NSTextField
        let startTime: CFTimeInterval
        let bounds: CGRect

        var x: CGFloat = 0
        var v: CGFloat
        let v0: CGFloat
        let a1: CGFloat
        let a2: CGFloat
        let timeAcc: CFTimeInterval

        var accelerated = false
        var prev_time: CFTimeInterval = 0

        init(
            _ view: NSTextField, startTime: CFTimeInterval, bounds: CGRect, v0: CGFloat,
            a1: CGFloat, a2: CGFloat, timeAcc: CFTimeInterval
        ) {
            self.view = view
            self.startTime = startTime
            self.prev_time = startTime
            self.bounds = bounds
            self.v0 = v0
            self.v = v0
            self.a1 = a1
            self.a2 = a2
            self.timeAcc = timeAcc
        }

        func animate(elapsed: Double) -> Bool {
            let dTime = CGFloat(elapsed - prev_time)
            self.v = min(0, v + (accelerated ? a2 * dTime : a1 * dTime))
            self.x += v * dTime
            prev_time = elapsed

            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, x, 0, 0)
            view.layer?.transform = transform

            if !accelerated && timeAcc < elapsed - startTime {
                accelerated = true
            }

            return view.frame.maxX + x >= bounds.minX;
        }
    }
}
