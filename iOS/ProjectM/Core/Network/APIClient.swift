import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var accessToken: String? {
        KeychainStore.shared.read(key: .accessToken)
    }

    init() {
        session = URLSession.shared
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try await request(endpoint, method: "GET", body: nil as EmptyBody?)
    }

    func post<B: Encodable, T: Decodable>(_ endpoint: Endpoint, body: B) async throws -> T {
        try await request(endpoint, method: "POST", body: body)
    }

    func delete(_ endpoint: Endpoint) async throws {
        let _: EmptyBody? = try? await request(endpoint, method: "DELETE", body: nil as EmptyBody?)
    }

    private func request<B: Encodable, T: Decodable>(_ endpoint: Endpoint, method: String, body: B?) async throws -> T {
        var req = URLRequest(url: endpoint.url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        return try decoder.decode(T.self, from: data)
    }
}

enum APIError: Error {
    case badStatus(Int)
    case unauthorized
}

private struct EmptyBody: Codable {}
