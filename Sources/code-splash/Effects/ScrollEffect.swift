import Foundation
import AppKit
import QuartzCore

/// An effect where a mass of code scrolls vertically at high speed.
class ScrollEffect: VisualEffect {
    var name: String { "Scroll" }

    private var id: UUID!
    private var baseSize: CGFloat = 22.0

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        id = overlayWindow.addEffectView(containerView)

        baseSize = contentView.bounds.height / 40.0

        let startTime: CFTimeInterval = CACurrentMediaTime()
        var animative: Animative? = nil

        let textField = TextFieldCache.shared.get(
            randomLineSubstring(text, lines: 100),
            font: NSFont.monospacedSystemFont(ofSize: self.baseSize * 3, weight: .regular),
            color: Colors.shared.randomColor(),
            alpha: 1.0
        )
        let scrollUp = Float.random(in: 0..<1) < 0.8
        let vy: CGFloat = (scrollUp ? 1 : -1) * max(2500, (textField.frame.height + contentView.frame.height) / 1.5)
        textField.frame.origin = CGPoint(
            x: contentView.bounds.minX + contentView.bounds.width * CGFloat.random(in: 0.05...0.5),
            y: scrollUp ? contentView.bounds.minY - textField.frame.height : contentView.bounds.maxY
        )
        containerView.addSubview(textField)
        animative = Animative(
            textField, bounds: contentView.bounds, colorIndexPair: Colors.shared.colorIndexPair(),
            vy: vy)

        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime
            if !animative!.animate(elapsed: elapsed) {
                animative!.view.removeFromSuperview()
                TextFieldCache.shared.release(animative!.view)
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
        let colorIndexPair: (Int, Int)
        var vy: CGFloat

        init(
            _ view: NSTextField, bounds: CGRect, colorIndexPair: (Int, Int), vy: CGFloat
        ) {
            self.view = view
            self.bounds = bounds
            self.colorIndexPair = colorIndexPair
            self.vy = vy
        }

        func animate(elapsed: Double) -> Bool {
            let y: CGFloat = vy * elapsed;
            let ratio = max(0, min(1, abs(y) / (bounds.height + view.frame.height)))

            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, y, 0)
            view.layer?.transform = transform
            view.textColor = Colors.shared.gradientColor(
                at: ratio, between: colorIndexPair)

            return (view.frame.minY + y < bounds.maxY || vy < 0)
                && (view.frame.maxY + y > bounds.minY || vy > 0);
        }
    }
}
