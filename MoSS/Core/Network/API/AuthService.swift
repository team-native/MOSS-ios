import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func logout() async
    func signUpStudent(_ request: StudentSignUpRequest) async throws
    func signUpBusiness(_ request: BusinessSignUpRequest) async throws
    func sendEmailCode(to email: String) async throws
    /// 인증 성공 시 비밀번호 재설정 토큰을 반환한다. (회원가입에서는 사용하지 않음)
    @discardableResult
    func verifyEmailCode(email: String, code: String) async throws -> String?
    func findID(name: String, number: String) async throws -> FindIDResponse
    func resetPassword(_ request: ResetPasswordRequest) async throws
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

    @discardableResult
    func verifyEmailCode(email: String, code: String) async throws -> String? {
        let response = try await network.request(
            AuthAPI.verifyEmail(VerifyEmailRequest(email: email, code: code)),
            as: VerifyEmailResponse.self
        )
        return response.data?.resetToken
    }

    func findID(name: String, number: String) async throws -> FindIDResponse {
        let response = try await network.request(
            AuthAPI.findID(FindIDRequest(name: name, number: number)),
            as: FindIDResponse.self
        )
        guard let result = response.data else {
            throw APIError.unknown
        }
        return result
    }

    func resetPassword(_ request: ResetPasswordRequest) async throws {
        _ = try await network.request(AuthAPI.resetPassword(request), as: EmptyData.self)
    }
}
