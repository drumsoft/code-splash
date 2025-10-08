import AppKit

class Colors {
    static let shared = Colors()
    
    private init() {}
    
    private let colors: [NSColor] = [
        NSColor(calibratedRed: 242/255, green: 101/255, blue: 127/255, alpha: 1),
        NSColor(calibratedRed: 239/255, green: 101/255, blue: 242/255, alpha: 1),
        NSColor(calibratedRed: 12/255, green: 4/255, blue: 242/255, alpha: 1),
        NSColor(calibratedRed: 4/255, green: 216/255, blue: 138/255, alpha: 1),
        NSColor(calibratedRed: 242/255, green: 226/255, blue: 4/255, alpha: 1),
        NSColor(calibratedRed: 216/255, green: 58/255, blue: 87/255, alpha: 1),
        NSColor(calibratedRed: 242/255, green: 140/255, blue: 159/255, alpha: 1),
        NSColor(calibratedRed: 4/255, green: 104/255, blue: 165/255, alpha: 1),
        NSColor(calibratedRed: 3/255, green: 119/255, blue: 165/255, alpha: 1),
        NSColor(calibratedRed: 216/255, green: 119/255, blue: 97/255, alpha: 1),
    ]

    // Get a couple of random color index from the palette
    func colorIndexPair() -> (Int, Int) {
        let firstIndex = Int.random(in: 0..<colors.count)
        var secondIndex: Int
        repeat {
            secondIndex = Int.random(in: 0..<colors.count)
        } while secondIndex == firstIndex
        return (firstIndex, secondIndex)
    }

    // Get a color at a specific ratio between two colors in the palette
    func gradientColor(at ratio: CGFloat, between: (Int, Int)) -> NSColor {
        let (startIndex, endIndex) = between
        let startColor = colors[startIndex]
        let endColor = colors[endIndex]

        let clampedRatio = max(0, min(1, ratio))

        let red = startColor.redComponent + (endColor.redComponent - startColor.redComponent) * clampedRatio
        let green = startColor.greenComponent + (endColor.greenComponent - startColor.greenComponent) * clampedRatio
        let blue = startColor.blueComponent + (endColor.blueComponent - startColor.blueComponent) * clampedRatio

        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
    }
}
