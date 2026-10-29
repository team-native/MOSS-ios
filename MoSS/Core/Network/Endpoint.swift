import Foundation

/// API 하나를 표현하는 타입. 기능별 API enum(AuthAPI 등)이 채택한다.
protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
    /// Authorization 헤더가 필요한 API인지 여부
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var body: Encodable? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var requiresAuth: Bool { false }

    func makeRequest(baseURL: URL = APIConfig.baseURL, accessToken: String? = nil) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: APIConfig.timeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }

        if requiresAuth, let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
