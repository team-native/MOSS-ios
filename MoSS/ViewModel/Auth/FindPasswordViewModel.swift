import Foundation

@MainActor
final class FindPasswordViewModel: ObservableObject {
    enum Policy {
        static let codeValidSeconds = 120
        static let maxResendCount = 3
        static let codeLength = 6
    }

    @Published var email = "" {
        didSet { if email != oldValue { resetVerification() } }
    }
    @Published var code = "" {
        didSet {
            let digits = String(code.filter(\.isNumber).prefix(Policy.codeLength))
            if digits != code { code = digits }
        }
    }

    @Published private(set) var isCodeSent = false
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var sendCount = 0
    @Published private(set) var isSending = false
    @Published private(set) var isVerifying = false
    /// 인증 완료 시 발급되는 비밀번호 재설정 토큰
    @Published private(set) var resetToken: String?

    @Published var emailError: String?
    @Published var codeError: String?

    private let authService: AuthServiceProtocol
    private let timer = CountdownTimer()

    init(email: String? = nil, authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        self.email = email ?? ""
    }

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces)
    }

    var isVerified: Bool {
        resetToken != nil
    }

    var canSendCode: Bool {
        !trimmedEmail.isEmpty && !isVerified && !isSending && sendCount <= Policy.maxResendCount
    }

    var sendCodeTitle: String {
        isCodeSent ? "재요청" : "인증 요청"
    }

    var canVerify: Bool {
        code.count == Policy.codeLength && !isVerifying
    }

    var codeHelperMessage: String? {
        guard isCodeSent, !isVerified else { return nil }
        if remainingSeconds == 0 {
            return "인증 시간이 만료되었어요. 인증번호를 다시 요청해 주세요."
        }
        let time = String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        return "남은 시간 \(time) · 인증번호가 오지 않았다면 다시 요청해 주세요."
    }

    func sendCode() async {
        emailError = nil
        codeError = nil

        guard !trimmedEmail.isEmpty else {
            emailError = "이메일을 입력해 주세요."
            return
        }
        guard Validator.isValidEmail(trimmedEmail) else {
            emailError = "이메일 형식이 올바르지 않습니다."
            return
        }
        guard sendCount <= Policy.maxResendCount else {
            emailError = "인증번호 재요청 횟수를 초과했어요. 잠시 후 다시 시도해 주세요."
            return
        }

        isSending = true
        defer { isSending = false }

        do {
            try await authService.sendEmailCode(to: trimmedEmail)
            sendCount += 1
            isCodeSent = true
            code = ""
            timer.start(seconds: Policy.codeValidSeconds) { [weak self] remaining in
                self?.remainingSeconds = remaining
            }
        } catch let error as APIError {
            emailError = error.statusCode == 404 ? "가입되지 않은 이메일입니다." : error.userMessage
        } catch {
            emailError = APIError.unknown.userMessage
        }
    }

    func verifyCode() async {
        codeError = nil

        guard remainingSeconds > 0 else {
            codeError = "인증 시간이 만료되었어요. 인증번호를 다시 요청해 주세요."
            return
        }
        guard Validator.isValidVerificationCode(code) else {
            codeError = "인증번호는 숫자 6자리예요."
            return
        }

        isVerifying = true
        defer { isVerifying = false }

        do {
            guard let token = try await authService.verifyEmailCode(email: trimmedEmail, code: code) else {
                codeError = APIError.unknown.userMessage
                return
            }
            resetToken = token
            timer.stop()
        } catch let error as APIError {
            codeError = error.statusCode == 400 ? "인증번호가 일치하지 않습니다." : error.userMessage
        } catch {
            codeError = APIError.unknown.userMessage
        }
    }

    private func resetVerification() {
        timer.stop()
        isCodeSent = false
        remainingSeconds = 0
        resetToken = nil
        code = ""
        emailError = nil
        codeError = nil
    }
}
