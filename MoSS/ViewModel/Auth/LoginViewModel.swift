import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !isLoading
    }

    /// 로그인 성공 시 User 반환, 실패 시 에러 상태를 갱신하고 nil 반환
    func login() async -> User? {
        guard validate() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            return try await authService.login(email: trimmedEmail, password: password)
        } catch let error as APIError {
            handle(error)
        } catch {
            alertMessage = APIError.unknown.userMessage
        }
        return nil
    }

    func clearEmailError() {
        emailError = nil
    }

    func clearPasswordError() {
        passwordError = nil
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces)
    }

    private func validate() -> Bool {
        emailError = nil
        passwordError = nil

        if trimmedEmail.isEmpty {
            emailError = "이메일을 입력해 주세요."
        } else if !Validator.isValidEmail(trimmedEmail) {
            emailError = "이메일 형식이 올바르지 않습니다."
        }

        if password.isEmpty {
            passwordError = "비밀번호를 입력해 주세요."
        }

        return emailError == nil && passwordError == nil
    }

    private func handle(_ error: APIError) {
        switch error.statusCode {
        case 400:
            // 이메일·비밀번호 불일치 시 누적 실패 횟수 표시 (실패 2/5)
            if let failure = error.errorData(as: LoginFailureData.self) {
                passwordError = "입력 내용을 다시 확인해 주세요 (실패 \(failure.failedAttempts)/\(failure.maxAttempts))"
            } else {
                passwordError = error.userMessage
            }
        case 429:
            // 5회 실패 시 5분간 로그인 제한
            alertMessage = error.userMessage
        default:
            alertMessage = error.userMessage
        }
    }
}
