import AppKit

class TextFieldCache {
    static let shared = TextFieldCache()

    private var cache: [NSTextField] = []

    private init() {}

    func get(_ text: String, font: NSFont, color: NSColor, alpha: Float) -> NSTextField {
        if let textField = cache.popLast() {
            textField.stringValue = text
            textField.font = font
            textField.textColor = color
            textField.layer?.opacity = alpha
            textField.sizeToFit()
            return textField
        }
        let textField = NSTextField(labelWithString: text)
        textField.font = font
        textField.textColor = color
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.sizeToFit()
        textField.wantsLayer = true
        textField.layer?.opacity = alpha
        return textField
    }

    func release(_ textField: NSTextField) {
        cache.append(textField)
    }
}
