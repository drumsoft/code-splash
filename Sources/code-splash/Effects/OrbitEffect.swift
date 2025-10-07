import Foundation
import AppKit
import QuartzCore

/// Effect where characters orbit around the center while spiraling outward
class OrbitEffect: VisualEffect {
    var name: String { "Orbit" }

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else { return }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        let effectId = overlayWindow.addEffectView(containerView)

        let characters = Array(text.prefix(100)) // Limit to first 100 characters
        let centerX = contentView.bounds.midX
        let centerY = contentView.bounds.midY

        for (index, char) in characters.enumerated() {
            // Skip whitespace for cleaner effect
            if char.isWhitespace && char != "\n" { continue }

            let textField = createTextField(with: String(char))

            // Start position at center
            textField.frame.origin = CGPoint(
                x: centerX - textField.frame.width / 2,
                y: centerY - textField.frame.height / 2
            )

            containerView.addSubview(textField)

            // Each character starts at a different angle
            let startAngle = (Double(index) * 0.3)
            let delay = Double(index) * 0.02

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.animateOrbit(textField: textField,
                                centerX: centerX,
                                centerY: centerY,
                                startAngle: startAngle)
            }
        }

        // Clean up after animation completes
        overlayWindow.scheduleCleanup(id: effectId, after: 2.5)
    }

    private func animateOrbit(textField: NSTextField, centerX: CGFloat, centerY: CGFloat, startAngle: Double) {
        let duration = 2.0
        let rotations = 2.0 // Number of full rotations

        // Create keyframe animation for circular path with expanding radius
        let animation = CAKeyframeAnimation(keyPath: "position")
        let path = CGMutablePath()

        let steps = 60
        for step in 0...steps {
            let progress = Double(step) / Double(steps)
            let angle = startAngle + (progress * rotations * 2 * .pi)

            // Radius expands over time
            let radius = CGFloat(progress * 400)

            let x = centerX + cos(angle) * radius
            let y = centerY + sin(angle) * radius

            if step == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        animation.path = path
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        // Fade out animation
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.beginTime = CACurrentMediaTime() + duration * 0.5
        fadeOut.duration = duration * 0.5
        fadeOut.fillMode = .forwards
        fadeOut.isRemovedOnCompletion = false

        textField.layer?.add(animation, forKey: "orbit")
        textField.layer?.add(fadeOut, forKey: "fadeOut")
    }

    private func createTextField(with text: String) -> NSTextField {
        let textField = NSTextField(labelWithString: text)
        textField.font = NSFont.monospacedSystemFont(ofSize: 22, weight: .regular)
        textField.textColor = NSColor(calibratedRed: 0.4, green: 1.0, blue: 0.6, alpha: 1.0)
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.sizeToFit()
        textField.wantsLayer = true
        return textField
    }
}
