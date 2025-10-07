import Foundation
import AppKit
import QuartzCore

/// Effect where characters scatter radially from the center of the screen
class ScatterEffect: VisualEffect {
    var name: String { "Scatter" }

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

            // Random angle for scatter direction
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 300...800)

            let endX = centerX + cos(angle) * distance
            let endY = centerY + sin(angle) * distance

            // Animate with delay based on index
            let delay = Double(index) * 0.01

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 2.0
                    context.timingFunction = CAMediaTimingFunction(name: .easeOut)

                    textField.animator().frame.origin = CGPoint(x: endX, y: endY)
                    textField.animator().alphaValue = 0.0

                    // Add rotation for extra flair
                    textField.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    rotation.toValue = Double.random(in: -(.pi * 2)...(.pi * 2))
                    rotation.duration = 2.0
                    rotation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    textField.layer?.add(rotation, forKey: "rotation")
                }
            }
        }

        // Clean up after animation completes
        overlayWindow.scheduleCleanup(id: effectId, after: 2.5)
    }

    private func createTextField(with text: String) -> NSTextField {
        let textField = NSTextField(labelWithString: text)
        textField.font = NSFont.monospacedSystemFont(ofSize: 24, weight: .regular)
        textField.textColor = NSColor(calibratedRed: 0.2, green: 0.8, blue: 1.0, alpha: 1.0)
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.sizeToFit()
        textField.wantsLayer = true
        return textField
    }
}
