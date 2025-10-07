import Foundation
import AppKit

// Parse command line arguments
func parseArguments() -> UInt16 {
    let arguments = CommandLine.arguments
    var port: UInt16 = 8080 // Default port

    var i = 1
    while i < arguments.count {
        let arg = arguments[i]

        if arg == "-p" || arg == "--port" {
            if i + 1 < arguments.count {
                if let parsedPort = UInt16(arguments[i + 1]) {
                    port = parsedPort
                    i += 2
                    continue
                } else {
                    print("❌ Invalid port number: \(arguments[i + 1])")
                    print("Usage: code-splash [-p PORT]")
                    exit(1)
                }
            } else {
                print("❌ Missing port number after -p option")
                print("Usage: code-splash [-p PORT]")
                exit(1)
            }
        } else if arg == "-h" || arg == "--help" {
            print("Usage: code-splash [-p PORT]")
            print("")
            print("Options:")
            print("  -p, --port PORT    Port number to listen on (default: 8080)")
            print("  -h, --help         Show this help message")
            exit(0)
        } else {
            print("❌ Unknown option: \(arg)")
            print("Usage: code-splash [-p PORT]")
            exit(1)
        }

        i += 1
    }

    return port
}

// Ensure we're running with UI capabilities
let app = NSApplication.shared

// Create overlay window
let overlayWindow = OverlayWindow()

// Parse port from command line
let port = parseArguments()

// Create and start HTTP server
let server = HTTPServer(port: port) { codeText in
    // Show effect when code is received
    overlayWindow.showEffect(text: codeText)
}

do {
    try server.start()
} catch {
    print("❌ Failed to start server: \(error)")
    exit(1)
}

// Handle Ctrl+C gracefully
signal(SIGINT) { _ in
    print("\n👋 Shutting down code-splash...")
    exit(0)
}

// Keep the app running
RunLoop.main.run()
