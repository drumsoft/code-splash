import Foundation
import AppKit

/// Protocol for visual effects that can be applied to code text
protocol VisualEffect {
    /// Name of the effect for logging
    var name: String { get }

    /// Execute the effect animation on the given window with the provided text
    /// - Parameters:
    ///   - text: The code text to animate
    ///   - window: The overlay window to display the effect in
    func execute(text: String, in window: NSWindow)
}

/// Factory for creating visual effects with random selection
/// Prevents the same effect from appearing more than twice in a row
enum EffectFactory {
    private static var lastIndex: Int? = nil
    private static var consecutiveCount = 0
    private static let effects: [() -> VisualEffect] = [
        { ScatterEffect() },
        { PopOutEffect() },
        { OrbitEffect() },
        { ScrollEffect() },
        { AccelerateEffect() },
    ]

    static func nextEffect() -> VisualEffect {
        let selectedIndex: Int

        if consecutiveCount >= 2, let last = lastIndex {
            // Force a different effect after 2 consecutive same effects
            var candidates = Array(0..<effects.count)
            candidates.remove(at: last)
            selectedIndex = candidates.randomElement() ?? 0
            consecutiveCount = 1
        } else {
            // Random selection
            selectedIndex = Int.random(in: 0..<effects.count)

            if selectedIndex == lastIndex {
                consecutiveCount += 1
            } else {
                consecutiveCount = 1
            }
        }

        lastIndex = selectedIndex
        return effects[selectedIndex]()
    }
}
