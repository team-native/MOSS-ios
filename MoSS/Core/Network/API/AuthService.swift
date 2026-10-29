import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func logout() async
    func signUpStudent(_ request: StudentSignUpRequest) async throws
    func signUpBusiness(_ request: BusinessSignUpRequest) async throws
    func sendEmailCode(to email: String) async throws
    func verifyEmailCode(email: String, code: String) async throws
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

    func signUpStudent(_ request: StudentSignUpRequest) async throws {
        _ = try await network.request(AuthAPI.signUpStudent(request), as: EmptyData.self)
    }

    func signUpBusiness(_ request: BusinessSignUpRequest) async throws {
        _ = try await network.request(AuthAPI.signUpBusiness(request), as: EmptyData.self)
    }

    func sendEmailCode(to email: String) async throws {
        _ = try await network.request(AuthAPI.sendEmail(SendEmailRequest(email: email)), as: EmptyData.self)
    }

    func verifyEmailCode(email: String, code: String) async throws {
        // 회원가입에서는 인증 성공 여부만 필요하므로 resetToken은 사용하지 않음
        _ = try await network.request(
            AuthAPI.verifyEmail(VerifyEmailRequest(email: email, code: code)),
            as: EmptyData.self
        )
    }
}
