import Foundation
import AppKit
import QuartzCore

/// Effect where characters burst out from the code.
class ScatterEffect: VisualEffect {
    var name: String { "Scatter" }

    private var id: UUID!
    private var baseSize: CGFloat = 22.0

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        id = overlayWindow.addEffectView(containerView)

        baseSize = contentView.bounds.height / 40.0

        let centerX = contentView.bounds.midX + CGFloat.random(in: -0.4...0.4) * contentView.bounds.width
        let centerY = contentView.bounds.midY + CGFloat.random(in: -0.2...0.2) * contentView.bounds.height
        let left = centerX - 0.14 * contentView.bounds.height
        let right = centerX + 0.14 * contentView.bounds.height
        let top = centerY - 0.2 * contentView.bounds.height
        let bottom = centerY + 0.2 * contentView.bounds.height
        let colorPair = Colors.shared.colorIndexPair();

        let startTime: CFTimeInterval = CACurrentMediaTime()
        var animatives: [Animative?] = []

        var curX = left;
        var curY = top;
        for char in text {
            if !char.isWhitespace && char != "\n" {
                let vx = 10.0 * (curX - centerX) + CGFloat.random(in: -10.0...10.0)
                let vy = 10.0 * (curY - centerY) + CGFloat.random(in: -10.0...10.0)
                let vz = CGFloat.random(in: 80.0...100.0)
                let va = CGFloat.random(in: -10.0...10.0)
                let textField = TextFieldCache.shared.get(
                    String(char),
                    font: NSFont.monospacedSystemFont(ofSize: self.baseSize * 3, weight: .regular),
                    color: Colors.shared.gradientColor(
                        at: (curY - top) / (bottom - top), between: colorPair),
                    alpha: 0.0
                )
                textField.frame.origin = CGPoint(
                    x: curX,
                    y: curY
                )
                containerView.addSubview(textField)
                animatives.append(
                    Animative(
                        textField, bounds: contentView.bounds, vx: vx, vy: vy,
                        vz: vz, va: va))
            }
            curX += baseSize * 0.5;
            if curX >= right || char == "\n" {
                curX = left;
                curY += baseSize;
            }
            if curY >= bottom {
                break;
            }
        }

        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime

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

    private struct Animative {
        let view: NSTextField

        let bounds: CGRect

        var vx: CGFloat
        var vy: CGFloat
        var vz: CGFloat
        var va: CGFloat
        let g: CGFloat = 500 * 9.8
        let z0: CGFloat = 100

        init(
            _ view: NSTextField, bounds: CGRect, vx: CGFloat,
            vy: CGFloat, vz: CGFloat, va: CGFloat
        ) {
            self.view = view
            self.bounds = bounds
            self.vx = vx
            self.vy = vy
            self.vz = vz
            self.va = va
        }

        func animate(elapsed: Double) -> Bool {
            let x: CGFloat = vx * elapsed;
            let y: CGFloat = -0.5 * g * elapsed * elapsed + vy * elapsed;
            let z: CGFloat = vz * elapsed;
            let scale = z0 > z ? z0 / (z0 - z) : 0;

            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, x, y, 0)
            transform = CATransform3DRotate(transform, va * elapsed, 0, 0, 1)
            transform = CATransform3DScale(transform, scale, scale, 1)
            view.layer?.transform = transform
            view.layer?.opacity = Float(min(1, elapsed / 0.05) * (z0 - z) / z0)

            return view.frame.minX + x < bounds.maxX && view.frame.maxX + x > bounds.minX
                && view.frame.minY + y < bounds.maxY && view.frame.maxY + y > bounds.minY
                && scale > 0;
        }
    }
}
