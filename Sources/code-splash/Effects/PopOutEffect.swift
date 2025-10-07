import Foundation
import AppKit
import QuartzCore

/// Effect where characters pop out sequentially, scaling up and fading
class PopOutEffect: VisualEffect {
    var name: String { "PopOut" }

    func execute(text: String, in window: NSWindow) {
        guard let contentView = window.contentView else {
            print("⚠️ PopOut: contentView is nil")
            return
        }

        let containerView = NSView(frame: contentView.bounds)
        containerView.wantsLayer = true
        guard let overlayWindow = window as? OverlayWindow else { return }
        let effectId = overlayWindow.addEffectView(containerView)

        let characters = Array(text.prefix(50)) // Limit to first 50 characters
        print("🔍 PopOut: text length = \(text.count), using first \(characters.count) characters")

        let totalWidth = CGFloat(characters.count) * 30
        let startX = (contentView.bounds.width - totalWidth) / 2
        let centerY = contentView.bounds.midY

        var visibleCharCount = 0
        for (_, char) in characters.enumerated() {
            // Skip whitespace for cleaner effect
            if char.isWhitespace && char != "\n" { continue }
            visibleCharCount += 1

            let textField = createTextField(with: String(char))

            // Position characters in a line
            let xPos = startX + CGFloat(visibleCharCount - 1) * 30
            textField.frame.origin = CGPoint(x: xPos, y: centerY)

            textField.alphaValue = 0.0
            containerView.addSubview(textField)

            // Stagger the animation based on visible character index
            let delay = Double(visibleCharCount - 1) * 0.05

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Create a transform animation group
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.5)

                // Scale animation
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = 0.1
                scaleAnimation.toValue = 2.0
                scaleAnimation.duration = 0.5
                scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

                // Fade animation
                let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
                fadeInAnimation.fromValue = 0.0
                fadeInAnimation.toValue = 1.0
                fadeInAnimation.duration = 0.3

                // Group animations
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [scaleAnimation, fadeInAnimation]
                animationGroup.duration = 0.5
                animationGroup.fillMode = .forwards
                animationGroup.isRemovedOnCompletion = false

                textField.layer?.add(animationGroup, forKey: "popIn")

                CATransaction.commit()

                // Fade out after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let fadeOut = CABasicAnimation(keyPath: "opacity")
                    fadeOut.fromValue = 1.0
                    fadeOut.toValue = 0.0
                    fadeOut.duration = 0.4
                    fadeOut.fillMode = .forwards
                    fadeOut.isRemovedOnCompletion = false
                    textField.layer?.add(fadeOut, forKey: "fadeOut")
                }
            }
        }

        print("🔍 PopOut: created \(visibleCharCount) visible characters")

        // Clean up after animation completes
        overlayWindow.scheduleCleanup(id: effectId, after: 2.5)
    }

    private func createTextField(with text: String) -> NSTextField {
        let textField = NSTextField(labelWithString: text)
        textField.font = NSFont.monospacedSystemFont(ofSize: 20, weight: .medium)
        textField.textColor = NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.8, alpha: 1.0)
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.sizeToFit()
        textField.wantsLayer = true
        return textField
    }
}
