import Foundation
import AppKit
import QuartzCore

/// Effect where characters orbit around the center while spiraling outward
class OrbitEffect: VisualEffect {
    var name: String { "Orbit" }

    private let baseDuration: Double = 0.8
    private let lettersLimit = 120
    private let lettersInterval: CFTimeInterval = 0.03
    // total effect duration = baseDuration + lettersInterval * lettersLimit = 4.4s

    private var id: UUID!
    private var baseSize: CGFloat = 22.0

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        id = overlayWindow.addEffectView(containerView)

        baseSize = contentView.bounds.height / 20.0

        let characters = Array(compactText(text).prefix(lettersLimit))
        let centerX =
            contentView.bounds.midX + CGFloat.random(in: -0.3...0.3) * contentView.bounds.width
        let centerY =
            contentView.bounds.midY + CGFloat.random(in: -0.3...0.3) * contentView.bounds.height
        let colorPair = Colors.shared.colorIndexPair();

        let startTime: CFTimeInterval = CACurrentMediaTime()
        var animatives: [Animative?] = []

        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            let elapsed = CACurrentMediaTime() - startTime

            // create new views
            while elapsed > Double(animatives.count) * self.lettersInterval && animatives.count < characters.count {
                let index = animatives.count
                let char = characters[index]
                let textField = TextFieldCache.shared.get(
                    String(char),
                    font: NSFont.monospacedSystemFont(ofSize: self.baseSize, weight: .regular),
                    color: Colors.shared.gradientColor(at: CGFloat(index) / CGFloat(characters.count), between: colorPair),
                    alpha: 0.0
                )
                textField.frame.origin = CGPoint(
                    x: centerX - textField.frame.width / 2,
                    y: centerY - textField.frame.height / 2
                )
                containerView.addSubview(textField)
                animatives.append(Animative(textField, baseSize: self.baseSize, startTime: elapsed, duration: self.baseDuration))
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

    private struct Animative {
        let view: NSTextField
        let startTime: CFTimeInterval
        let baseSize: CGFloat
        let duration: CFTimeInterval

        init(_ view: NSTextField, baseSize: CGFloat, startTime: CFTimeInterval, duration: CFTimeInterval) {
            self.view = view
            self.startTime = startTime
            self.baseSize = baseSize
            self.duration = duration
        }

        func animate(elapsed: Double) -> Bool {
            let ratio = CGFloat((elapsed - startTime) / duration)
            if ratio > 1 { return false }
            var transform: CATransform3D = CATransform3DIdentity
            let msin = sin(.pi * ratio)
            transform = CATransform3DTranslate(
                transform, cos(.pi * ratio) * baseSize * 8, -msin * baseSize * 2, 0)
            transform = CATransform3DRotate(transform, .pi * (ratio - 0.5), 0, 1, 0)
            transform = CATransform3DScale(transform, msin + 1, msin + 1, 1)
            view.layer?.transform = transform
            view.layer?.opacity = 1 - Float(pow(2 * ratio - 1, 2))
            return true
        }
    }
}
