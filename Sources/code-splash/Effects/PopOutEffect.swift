import Foundation
import AppKit
import QuartzCore

/// Effect where characters pop out sequentially, scaling up and fading
class PopOutEffect: VisualEffect {
    var name: String { "PopOut" }

    private let baseDuration: Double = 0.8
    private let lettersLimit = 360
    private let lettersInterval: CFTimeInterval = 1 / 60
    // total effect duration = baseDuration + lettersInterval * lettersLimit = 4.4s

    private var id: UUID!
    private var baseSize: CGFloat = 22.0

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        id = overlayWindow.addEffectView(containerView)

        baseSize = contentView.bounds.height / 10.0

        let characters = Array(text.prefix(lettersLimit))
        let centerX = contentView.bounds.midX
        let left = contentView.bounds.minX + 0.1 * contentView.bounds.width
        let right = contentView.bounds.maxX
        let colorPair = Colors.shared.colorIndexPair();

        let startTime: CFTimeInterval = CACurrentMediaTime()
        var animatives: [Animative?] = []

        var curX = left;
        var index = 0;
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime

            // create new views
            while elapsed > Double(animatives.count) * self.lettersInterval && index < characters.count {
                let char = characters[index]
                if !char.isWhitespace && char != "\n" {
                    let textField = TextFieldCache.shared.get(
                        String(char),
                        font: NSFont.monospacedSystemFont(ofSize: self.baseSize, weight: .regular),
                        color: Colors.shared.gradientColor(
                            at: CGFloat(index) / CGFloat(characters.count), between: colorPair),
                        alpha: 1.0
                    )
                    textField.frame.origin = CGPoint(
                        x: curX,
                        y: contentView.bounds.minY
                    )
                    containerView.addSubview(textField)
                    let vx = 0.3 * (curX - centerX) + CGFloat.random(in: -0.1...0.1)
                    let vy = 3000 + CGFloat.random(in: -30.0...30.0)
                    let va: CGFloat = CGFloat.random(in: -2.0...2.0)
                    animatives.append(
                        Animative(
                            textField, bounds: contentView.bounds, startTime: elapsed, vx: vx,
                            vy: vy, va: va)
                    )
                }
                curX += self.baseSize * 0.5;
                if char == "\n" {
                    curX = left;
                } else if curX >= right {
                    curX = left;
                    while index < characters.count && characters[index] != "\n" {
                        index += 1;
                    }
                } 
                index += 1;
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

        var y: CGFloat = 0
        var vx: CGFloat
        var vy: CGFloat
        let vz: CGFloat = 60
        let va: CGFloat
        let g: CGFloat = -1000 * 9.8
        let z0: CGFloat = 100

        var bounced = 0
        var prev_time: CFTimeInterval = 0

        init(
            _ view: NSTextField, bounds: CGRect, startTime: CFTimeInterval, vx: CGFloat,
            vy: CGFloat, va: CGFloat
        ) {
            self.view = view
            self.bounds = bounds
            self.startTime = startTime
            self.prev_time = startTime
            self.vx = vx
            self.vy = vy
            self.va = va
        }

        func animate(elapsed: Double) -> Bool {
            let localTime = elapsed - startTime
            self.vy += g * CGFloat(elapsed - prev_time)
            self.y += vy * CGFloat(elapsed - prev_time)
            let x: CGFloat = vx * localTime;
            let z: CGFloat = vz * localTime;
            let scale = z0 > z ? z0 / (z0 - z) : 0;
            prev_time = elapsed

            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, x, self.y, 0)
            transform = CATransform3DRotate(transform, va * localTime, 1, 0, 0)
            transform = CATransform3DScale(transform, scale, scale, 1)
            view.layer?.transform = transform
            view.layer?.opacity = Float((z0 - z) / z0)

            if bounced == 0 && view.frame.minY + y < bounds.minY && vy < 0 {
                self.vy = -self.vy * 0.5
                bounced += 1
            }

            return view.frame.minX + x < bounds.maxX && view.frame.maxX + x > bounds.minX
                && (view.frame.maxY + y > bounds.minY || vy >= 0 || bounced == 0)
                && scale > 0;
        }
    }
}
