import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

nonisolated protocol APIClientProtocol {
    func get<Response: Decodable>(_ path: String, headers: [String: String]) async throws -> Response
    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body, headers: [String: String]) async throws -> Response
}

extension APIClientProtocol {
    func get<Response: Decodable>(_ path: String) async throws -> Response {
        try await get(path, headers: [:])
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        try await post(path, body: body, headers: [:])
    }
}

nonisolated struct APIClient: APIClientProtocol {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<Response: Decodable>(_ path: String, headers: [String: String]) async throws -> Response {
        let request: URLRequest = try makeRequest(path: path, method: .get, body: Optional<Data>.none, headers: headers)
        return try await send(request)
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body, headers: [String: String]) async throws -> Response {
        let encodedBody: Data
        do {
            encodedBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingFailed(error)
        }
        let request: URLRequest = try makeRequest(path: path, method: .post, body: encodedBody, headers: headers)
        return try await send(request)
    }

    private func makeRequest(path: String, method: HTTPMethod, body: Data?, headers: [String: String]) throws -> URLRequest {
        guard let url: URL = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
