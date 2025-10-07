import Foundation
import AppKit

/// Full-screen transparent overlay window for displaying visual effects
class OverlayWindow: NSWindow {
    private var effectViews: [UUID: NSView] = [:]
    private var cleanupWorkItems: [UUID: DispatchWorkItem] = [:]

    init() {
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

        // Set content view
        let contentView = NSView(frame: screenFrame)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
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
        // Cancel any pending cleanup
        cleanupWorkItems[id]?.cancel()
        cleanupWorkItems.removeValue(forKey: id)

        // Remove the view
        effectViews[id]?.removeFromSuperview()
        effectViews.removeValue(forKey: id)
    }

    /// Add a view for the effect and return its ID
    func addEffectView(_ view: NSView) -> UUID {
        let id = UUID()
        effectViews[id] = view
        contentView?.addSubview(view)
        return id
    }

    /// Schedule cleanup for a specific effect after a delay
    func scheduleCleanup(id: UUID, after delay: TimeInterval) {
        // Cancel any existing cleanup for this ID
        cleanupWorkItems[id]?.cancel()

        // Create new cleanup work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.clearEffect(id: id)
        }
        cleanupWorkItems[id] = workItem

        // Schedule cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
