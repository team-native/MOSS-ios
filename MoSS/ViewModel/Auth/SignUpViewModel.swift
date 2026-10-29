import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    enum Policy {
        static let codeValidSeconds = 120
        static let maxResendCount = 3
        static let nameMaxLength = 8
        static let phoneMaxLength = 11
        static let passwordMaxLength = 15
        static let codeLength = 6
    }

    // MARK: 입력값
    @Published var role: UserRole = .student
    @Published var email = "" {
        didSet { if email != oldValue { resetEmailVerification() } }
    }
    @Published var code = "" {
        didSet {
            let digits = String(code.filter(\.isNumber).prefix(Policy.codeLength))
            if digits != code { code = digits }
        }
    }
    @Published var name = "" {
        didSet { if name.count > Policy.nameMaxLength { name = String(name.prefix(Policy.nameMaxLength)) } }
    }
    @Published var phoneNumber = "" {
        didSet {
            let digits = String(phoneNumber.filter(\.isNumber).prefix(Policy.phoneMaxLength))
            if digits != phoneNumber { phoneNumber = digits }
        }
    }
    @Published var grade: Grade = .high
    @Published var password = "" {
        didSet { if password.count > Policy.passwordMaxLength { password = String(password.prefix(Policy.passwordMaxLength)) } }
    }
    @Published var passwordConfirm = ""
    @Published var isTermsAgreed = false

    // MARK: 이메일 인증 상태
    @Published private(set) var isCodeSent = false
    @Published private(set) var isEmailVerified = false
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var sendCount = 0
    @Published private(set) var isSendingCode = false

    // MARK: 에러
    @Published var emailError: String?
    @Published var codeError: String?
    @Published var nameError: String?
    @Published var phoneError: String?
    @Published var passwordError: String?
    @Published var alertMessage: String?

    @Published private(set) var isLoading = false
    @Published private(set) var isCompleted = false

    private let authService: AuthServiceProtocol
    private let timer = CountdownTimer()

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    // MARK: - 화면 표시용

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces)
    }

    var canSendCode: Bool {
        !trimmedEmail.isEmpty && !isEmailVerified && !isSendingCode && sendCount <= Policy.maxResendCount
    }

    var sendCodeTitle: String {
        isCodeSent ? "재요청" : "인증 요청"
    }

    var codeHelperMessage: String? {
        guard isCodeSent, !isEmailVerified else { return nil }
        if remainingSeconds == 0 {
            return "인증 시간이 만료되었어요. 인증번호를 다시 요청해 주세요."
        }
        let time = String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        return "남은 시간 \(time) · 인증번호가 오지 않았다면 다시 요청해 주세요."
    }

    /// 비밀번호 확인 실시간 안내 (입력 중일 때만)
    var passwordConfirmMessage: (text: String, isMatched: Bool)? {
        guard !passwordConfirm.isEmpty else { return nil }
        return password == passwordConfirm
            ? ("비밀번호가 일치해요.", true)
            : ("비밀번호가 일치하지 않아요.", false)
    }

    var passwordHelperMessage: String? {
        guard !password.isEmpty, !Validator.isValidPassword(password) else { return nil }
        return "6~15자, 영문·숫자·특수문자를 모두 포함해 주세요."
    }

    var canSubmit: Bool {
        isEmailVerified
            && !name.isEmpty
            && !phoneNumber.isEmpty
            && !password.isEmpty
            && !passwordConfirm.isEmpty
            && isTermsAgreed
            && !isLoading
    }

    // MARK: - 이메일 인증

    func sendCode() async {
        emailError = nil
        codeError = nil

        guard Validator.isValidEmail(trimmedEmail) else {
            emailError = "이메일 형식이 올바르지 않습니다."
            return
        }
        guard sendCount <= Policy.maxResendCount else {
            emailError = "인증번호 재요청 횟수를 초과했어요. 잠시 후 다시 시도해 주세요."
            return
        }

        isSendingCode = true
        defer { isSendingCode = false }

        do {
            try await authService.sendEmailCode(to: trimmedEmail)
            sendCount += 1
            isCodeSent = true
            code = ""
            startTimer()
        } catch let error as APIError {
            emailError = error.userMessage
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

        do {
            try await authService.verifyEmailCode(email: trimmedEmail, code: code)
            isEmailVerified = true
            stopTimer()
        } catch let error as APIError {
            codeError = error.statusCode == 400
                ? "인증번호가 일치하지 않습니다."
                : error.userMessage
        } catch {
            codeError = APIError.unknown.userMessage
        }
    }

    // MARK: - 회원가입

    func signUp() async {
        guard validate() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            switch role {
            case .student:
                try await authService.signUpStudent(StudentSignUpRequest(
                    email: trimmedEmail,
                    name: name,
                    number: phoneNumber,
                    password: password,
                    passwordConfirm: passwordConfirm,
                    grade: grade
                ))
            case .business:
                try await authService.signUpBusiness(BusinessSignUpRequest(
                    email: trimmedEmail,
                    name: name,
                    number: phoneNumber,
                    password: password,
                    passwordConfirm: passwordConfirm
                ))
            }
            isCompleted = true
        } catch let error as APIError {
            handle(error)
        } catch {
            alertMessage = APIError.unknown.userMessage
        }
    }

    // MARK: - Private

    private func validate() -> Bool {
        emailError = nil
        nameError = nil
        phoneError = nil
        passwordError = nil

        if !isEmailVerified {
            emailError = "이메일 인증을 완료해 주세요."
        }
        if !Validator.isValidName(name) {
            nameError = "닉네임은 2~8자로 입력해 주세요."
        }
        if !Validator.isValidPhoneNumber(phoneNumber) {
            phoneError = "휴대폰 번호 형식이 올바르지 않습니다."
        }
        if !Validator.isValidPassword(password) {
            passwordError = "6~15자, 영문·숫자·특수문자를 모두 포함해 주세요."
        } else if password != passwordConfirm {
            passwordError = "비밀번호가 일치하지 않습니다."
        }
        if !isTermsAgreed {
            alertMessage = "필수 이용약관 및 개인정보 처리방침에 동의해 주세요."
        }

        return emailError == nil && nameError == nil && phoneError == nil
            && passwordError == nil && isTermsAgreed
    }

    private func handle(_ error: APIError) {
        let message = error.userMessage

        switch error.statusCode {
        case 409 where message.contains("이메일"):
            emailError = message
        case 409 where message.contains("휴대폰"):
            phoneError = message
        case 400 where message.contains("비밀번호"):
            passwordError = message
        default:
            alertMessage = message
        }
    }

    private func resetEmailVerification() {
        stopTimer()
        isCodeSent = false
        isEmailVerified = false
        remainingSeconds = 0
        code = ""
        codeError = nil
        emailError = nil
    }

    private func startTimer() {
        timer.start(seconds: Policy.codeValidSeconds) { [weak self] remaining in
            self?.remainingSeconds = remaining
        }
    }

    private func stopTimer() {
        timer.stop()
    }
}
