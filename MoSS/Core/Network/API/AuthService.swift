import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func logout() async
}

final class AuthService: AuthServiceProtocol {
    private let network: NetworkServiceProtocol
    private let tokenStorage: TokenStorage

    init(network: NetworkServiceProtocol = NetworkService.shared, tokenStorage: TokenStorage = .shared) {
        self.network = network
        self.tokenStorage = tokenStorage
    }

    func login(email: String, password: String) async throws -> User {
        let response = try await network.request(
            AuthAPI.login(LoginRequest(email: email, password: password)),
            as: TokenResponse.self
        )
        guard let token = response.data else {
            throw APIError.unknown
        }

        tokenStorage.save(accessToken: token.accessToken, refreshToken: token.refreshToken)
        return User(id: token.id, name: token.name, email: token.email)
    }

    func logout() async {
        // 서버 요청이 실패해도 기기에서는 로그아웃 처리
        _ = try? await network.request(AuthAPI.logout, as: EmptyData.self)
        tokenStorage.clear()
    }
}
