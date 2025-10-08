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

/// Factory for creating visual effects in round-robin order
enum EffectFactory {
    private static var currentIndex = 0
    private static let effects: [() -> VisualEffect] = [
        { ScatterEffect() },
        { PopOutEffect() },
        { OrbitEffect() },
        { ScrollEffect() },
    ]

    static func nextEffect() -> VisualEffect {
        let effect = effects[currentIndex]()
        currentIndex = (currentIndex + 1) % effects.count
        return effect
    }
}
