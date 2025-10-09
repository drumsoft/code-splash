import Foundation

/// replace continuous whitespace/break/tabs with single space.
/// - Parameter text: The input text to be compacted.
/// - Returns: The compacted text with consecutive whitespace characters replaced by a single space.
func compactText(_ text: String) -> String {
    let pattern = "\\s+"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: text.utf16.count)
    let compactedText = regex?.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: " ") ?? text
    return compactedText
}

/// Retrieves a substring of the specified `length` from the `text`, starting from a random position.
/// If the text is shorter than the specified length, the entire text is returned.
/// - Parameters:
///   - text: The input text from which to extract the substring.
///   - length: The desired length of the substring.
/// - Returns: A substring of the specified length, or the entire text if it is shorter than the specified length.
func randomSubstring(_ text: String, length: Int) -> String {
    guard text.count > length else {
        return text
    }
    
    let maxStartIndex = text.count - length
    let startIndex = Int.random(in: 0...maxStartIndex)
    let start = text.index(text.startIndex, offsetBy: startIndex)
    let end = text.index(start, offsetBy: length)
    
    return String(text[start..<end])
}

/// Randomly selects and returns a consecutive `lines` from the `text`.
/// Removes the smallest indentation from returned lines.
/// If the text has fewer lines than the specified lines, the entire lines of text is returned.
/// - Parameters:
///   - text: The input text from which to select lines.
///   - lines: The number of lines to select.
/// - Returns: A substring containing the selected lines.
func randomLineSubstring(_ text: String, lines: Int) -> String {
    let allLines: [String] = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

    let selectedLines: [String]
    if allLines.count > lines {
        let maxStartIndex = allLines.count - lines
        let startIndex = Int.random(in: 0...maxStartIndex)
        selectedLines = Array(allLines[startIndex..<(startIndex + lines)])
    } else {
        selectedLines = allLines
    }

    // Find the minimum indentation level among the selected lines
    let minIndentation = selectedLines
        .map { $0.prefix { $0 == " " || $0 == "\t" }.count }
        .min() ?? 0

    // Remove the minimum indentation from each line
    let trimmedLines = selectedLines.map { line in
        if line.count >= minIndentation {
            return String(line.dropFirst(minIndentation))
        } else {
            return line
        }
    }

    return trimmedLines.joined(separator: "\n")
}

/// Selects a random consecutive of `lines` from the `text`, removes invisible characters at the beginning and end, and returns the result.
/// If the text has fewer lines than specified by `lines`, all lines are returned.
/// - Parameters:
///   - text: The input text from which to select lines.
///   - lines: The number of lines to select.
/// - Returns: Array of strings containing the selected lines.
func selectRandomLines(_ text: String, lines: Int) -> [String] {
    let allLines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    guard allLines.count > lines else {
        return allLines.map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    let maxStartIndex = allLines.count - lines
    let startIndex = Int.random(in: 0...maxStartIndex)
    let selectedLines = allLines[startIndex..<(startIndex + lines)]
    
    return selectedLines.map { $0.trimmingCharacters(in: .whitespaces) }
}
