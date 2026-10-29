import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> APIResponse<T>
}

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()

    private let session: URLSession
    private let tokenStorage: TokenStorage
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared, tokenStorage: TokenStorage = .shared) {
        self.session = session
        self.tokenStorage = tokenStorage
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> APIResponse<T> {
        do {
            return try await send(endpoint, as: type)
        } catch APIError.unauthorized where endpoint.requiresAuth {
            // accessToken 만료 시 한 번만 재발급 후 재시도
            try await refreshToken()
            return try await send(endpoint, as: type)
        }
    }

    private func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> APIResponse<T> {
        let request = try endpoint.makeRequest(accessToken: tokenStorage.accessToken)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        #if DEBUG
        print("[API] \(endpoint.method.rawValue) \(endpoint.path) → \(httpResponse.statusCode)")
        #endif

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = (try? decoder.decode(APIResponse<EmptyData>.self, from: data))?.message
                ?? "일시적인 오류가 발생했습니다."
            throw APIError.server(status: httpResponse.statusCode, message: message, body: data)
        }

        do {
            return try decoder.decode(APIResponse<T>.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func refreshToken() async throws {
        guard let refreshToken = tokenStorage.refreshToken else {
            throw APIError.unauthorized
        }

        do {
            let response = try await send(
                TokenAPI.refresh(refreshToken: refreshToken),
                as: TokenResponse.self
            )
            guard let token = response.data else { throw APIError.unauthorized }
            tokenStorage.save(accessToken: token.accessToken, refreshToken: token.refreshToken)
        } catch {
            tokenStorage.clear()
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            throw APIError.unauthorized
        }
    }
}

extension Notification.Name {
    /// refreshToken까지 만료되어 다시 로그인해야 할 때 발송
    static let sessionExpired = Notification.Name("sessionExpired")
}
