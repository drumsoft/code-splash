import Foundation
import AppKit

/// Full-screen transparent overlay window for displaying visual effects
class OverlayWindow: NSWindow {
    private var effectViews: [UUID: NSView] = [:]
    private let maxOpacity: CGFloat

    init(maxOpacity: CGFloat = 1.0) {
        self.maxOpacity = maxOpacity

        // Get the main screen bounds
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.frame

        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Configure window to be transparent, click-through overlay
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.level = .floating
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Set content view with max opacity
        let contentView = NSView(frame: screenFrame)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        contentView.alphaValue = maxOpacity
        self.contentView = contentView
    }

    /// Show an effect in the overlay window
    func showEffect(text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Create and execute next effect (round-robin)
            let effect = EffectFactory.nextEffect()
            print("✨ Displaying effect: \(effect.name)")
            effect.execute(text: text, in: self)

            // Show window
            self.orderFrontRegardless()
        }
    }

    /// Clear a specific effect by ID
    func clearEffect(id: UUID) {
        // Remove the view
        effectViews[id]?.removeFromSuperview()
        effectViews.removeValue(forKey: id)
        print("   Removed effect view with ID: \(id)")
    }

    /// Add a view for the effect and return its ID
    func addEffectView(_ view: NSView) -> UUID {
        let id = UUID()
        effectViews[id] = view
        contentView?.addSubview(view)
        print("   Added effect view with ID: \(id)")
        return id
    }
}
