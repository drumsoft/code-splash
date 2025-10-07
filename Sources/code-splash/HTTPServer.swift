import Foundation
import Network

/// Simple HTTP server that listens for POST requests with code text
class HTTPServer {
    private let port: UInt16
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.code-splash.http-server")
    private let onCodeReceived: (String) -> Void

    init(port: UInt16 = 8080, onCodeReceived: @escaping (String) -> Void) {
        self.port = port
        self.onCodeReceived = onCodeReceived
    }

    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)

        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("🎬 code-splash server listening on port \(self?.port ?? 0)")
            case .failed(let error):
                print("❌ Server failed: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: queue)
    }

    func stop() {
        listener?.cancel()
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)

        // Read HTTP request
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let data = data, let request = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }

            // Parse HTTP request
            if let body = self?.parseHTTPRequest(request) {
                self?.onCodeReceived(body)

                // Send HTTP response
                let response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })
            } else {
                // Send 404 response
                let response = "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found"
                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })
            }
        }
    }

    private func parseHTTPRequest(_ request: String) -> String? {
        let lines = request.components(separatedBy: "\r\n")

        // Check if it's a POST to /effect
        guard let requestLine = lines.first,
              requestLine.hasPrefix("POST /effect") else {
            return nil
        }

        // Find empty line separating headers from body
        if let emptyLineIndex = lines.firstIndex(of: ""),
           emptyLineIndex + 1 < lines.count {
            let bodyLines = lines[(emptyLineIndex + 1)...]
            return bodyLines.joined(separator: "\n")
        }

        return nil
    }
}
