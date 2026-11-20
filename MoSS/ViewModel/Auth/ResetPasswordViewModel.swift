import Foundation

@MainActor
final class ResetPasswordViewModel: ObservableObject {
    struct Condition: Identifiable {
        let title: String
        let isSatisfied: Bool
        var id: String { title }
    }

    @Published var password = "" {
        didSet { if password.count > 15 { password = String(password.prefix(15)) } }
    }
    @Published var passwordConfirm = ""

    @Published var passwordError: String?
    @Published var alertMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isCompleted = false
    /// 재설정 토큰이 만료되어 인증부터 다시 해야 하는 경우
    @Published private(set) var isTokenExpired = false

    private let resetToken: String
    private let authService: AuthServiceProtocol

    init(resetToken: String, authService: AuthServiceProtocol = AuthService()) {
        self.resetToken = resetToken
        self.authService = authService
    }

    var conditions: [Condition] {
        [
            Condition(title: "6자 이상 15자 이하", isSatisfied: Validator.hasValidPasswordLength(password)),
            Condition(title: "영문과 숫자 포함", isSatisfied: Validator.hasLetterAndNumber(password)),
            Condition(title: "특수문자 1개 이상", isSatisfied: Validator.hasSymbol(password))
        ]
    }

    var confirmMessage: (text: String, isMatched: Bool)? {
        guard !passwordConfirm.isEmpty else { return nil }
        return password == passwordConfirm
            ? ("비밀번호가 일치합니다.", true)
            : ("비밀번호가 일치하지 않습니다.", false)
    }

    var canSubmit: Bool {
        Validator.isValidPassword(password) && password == passwordConfirm && !isLoading
    }

    func resetPassword() async {
        passwordError = nil
        guard canSubmit else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.resetPassword(ResetPasswordRequest(
                resetToken: resetToken,
                password: password,
                passwordConfirm: passwordConfirm
            ))
            isCompleted = true
        } catch let error as APIError {
            let message = error.userMessage
            if message.contains("토큰") {
                isTokenExpired = true
                alertMessage = "인증 시간이 만료되었어요.\n이메일 인증을 다시 진행해 주세요."
            } else if error.statusCode == 400 {
                passwordError = message
            } else {
                alertMessage = message
            }
        } catch {
            alertMessage = APIError.unknown.userMessage
        }
    }
}
