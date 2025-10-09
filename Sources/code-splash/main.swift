import Foundation
import AppKit

// Parse command line arguments
struct Options {
    var port: UInt16 = 8080
    var maxOpacity: CGFloat = 1.0
}

func parseArguments() -> Options {
    let arguments = CommandLine.arguments
    var options = Options()

    var i = 1
    while i < arguments.count {
        let arg = arguments[i]

        if arg == "-p" || arg == "--port" {
            if i + 1 < arguments.count {
                if let parsedPort = UInt16(arguments[i + 1]) {
                    options.port = parsedPort
                    i += 2
                    continue
                } else {
                    print("❌ Invalid port number: \(arguments[i + 1])")
                    printUsage()
                    exit(1)
                }
            } else {
                print("❌ Missing port number after -p option")
                printUsage()
                exit(1)
            }
        } else if arg == "-o" || arg == "--opacity" {
            if i + 1 < arguments.count {
                if let parsedOpacity = Double(arguments[i + 1]), parsedOpacity >= 0.0 && parsedOpacity <= 1.0 {
                    options.maxOpacity = CGFloat(parsedOpacity)
                    i += 2
                    continue
                } else {
                    print("❌ Invalid opacity value: \(arguments[i + 1]) (must be between 0.0 and 1.0)")
                    printUsage()
                    exit(1)
                }
            } else {
                print("❌ Missing opacity value after -o option")
                printUsage()
                exit(1)
            }
        } else if arg == "-h" || arg == "--help" {
            printUsage()
            exit(0)
        } else {
            print("❌ Unknown option: \(arg)")
            printUsage()
            exit(1)
        }

        i += 1
    }

    return options
}

func printUsage() {
    print("Usage: code-splash [-p PORT] [-o OPACITY]")
    print("")
    print("Options:")
    print("  -p, --port PORT        Port number to listen on (default: 8080)")
    print("  -o, --opacity OPACITY  Maximum opacity for effects, 0.0-1.0 (default: 1.0)")
    print("  -h, --help             Show this help message")
}

// Ensure we're running with UI capabilities
let app = NSApplication.shared

// Parse options from command line
let options = parseArguments()

// Create overlay window with max opacity
let overlayWindow = OverlayWindow(maxOpacity: options.maxOpacity)

// Create and start HTTP server
let server = HTTPServer(port: options.port) { codeText in
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
