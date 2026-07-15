import Foundation

enum StreamingAPIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Int)
    case encodingFailed(Error)
    case serverError(String)
}

nonisolated protocol StreamingAPIClientProtocol {
    func stream<Body: Encodable>(_ path: String, body: Body) -> AsyncThrowingStream<String, Error>
}

nonisolated struct StreamingAPIClient: StreamingAPIClientProtocol {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func stream<Body: Encodable>(_ path: String, body: Body) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let request: URLRequest = try makeRequest(path: path, body: body)
                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw StreamingAPIError.invalidResponse
                    }
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw StreamingAPIError.requestFailed(httpResponse.statusCode)
                    }

                    var eventName: String = "message"

                    for try await line in bytes.lines {
                        if line.hasPrefix("event:") {
                            eventName = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
                        } else if line.hasPrefix("data:") {
                            let data: String = String(line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces))
                            if eventName == "done" { break }
                            try emit(event: eventName, data: data, to: continuation)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func emit(event: String, data: String, to continuation: AsyncThrowingStream<String, Error>.Continuation) throws {
        guard !data.isEmpty else { return }

        switch event {
        case "delta":
            if let text: String = decodeText(from: data) {
                continuation.yield(text)
            }
        case "error":
            throw StreamingAPIError.serverError(data)
        default:
            break
        }
    }

    private func decodeText(from data: String) -> String? {
        guard let raw: Data = data.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DeltaPayload.self, from: raw).text
    }

    private func makeRequest<Body: Encodable>(path: String, body: Body) throws -> URLRequest {
        guard let url: URL = URL(string: path, relativeTo: baseURL) else {
            throw StreamingAPIError.invalidURL
        }

        let encodedBody: Data
        do {
            encodedBody = try JSONEncoder().encode(body)
        } catch {
            throw StreamingAPIError.encodingFailed(error)
        }

        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        return request
    }
}

private nonisolated struct DeltaPayload: Decodable {
    let text: String
}
