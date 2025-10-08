import Foundation

/// replace continuous whitespace/break/tabs with single space.
func compactText(_ text: String) -> String {
    let pattern = "\\s+"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: text.utf16.count)
    let compactedText = regex?.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: " ") ?? text
    return compactedText
}
