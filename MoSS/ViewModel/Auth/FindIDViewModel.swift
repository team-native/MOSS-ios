import Foundation

@MainActor
final class FindIDViewModel: ObservableObject {
    enum Policy {
        static let maxAttempts = 5
        static let phoneMaxLength = 11
    }

    @Published var name = ""
    @Published var phoneNumber = "" {
        didSet {
            let digits = String(phoneNumber.filter(\.isNumber).prefix(Policy.phoneMaxLength))
            if digits != phoneNumber { phoneNumber = digits }
        }
    }

    @Published var nameError: String?
    @Published var phoneError: String?
    @Published var alertMessage: String?
    @Published private(set) var isLoading = false

    private let authService: AuthServiceProtocol
    // 명세: 5번 시도 제한 (서버 제한 정책 확정 전까지 앱에서 횟수 관리)
    private var failedAttempts = 0

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    var canSubmit: Bool {
        !trimmedName.isEmpty && !phoneNumber.isEmpty && !isLoading && !isLocked
    }

    var isLocked: Bool {
        failedAttempts >= Policy.maxAttempts
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    func findID() async -> FindIDResponse? {
        guard validate() else { return nil }
        guard !isLocked else {
            alertMessage = "조회 가능 횟수(\(Policy.maxAttempts)회)를 초과했어요.\n잠시 후 다시 시도해 주세요."
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await authService.findID(name: trimmedName, number: phoneNumber)
            failedAttempts = 0
            return result
        } catch let error as APIError {
            if error.statusCode == 404 {
                failedAttempts += 1
                phoneError = "\(error.userMessage) (\(failedAttempts)/\(Policy.maxAttempts))"
            } else {
                alertMessage = error.userMessage
            }
        } catch {
            alertMessage = APIError.unknown.userMessage
        }
        return nil
    }

    private func validate() -> Bool {
        nameError = nil
        phoneError = nil

        if trimmedName.isEmpty {
            nameError = "이름을 입력해 주세요."
        }
        if phoneNumber.isEmpty {
            phoneError = "휴대폰 번호를 입력해 주세요."
        } else if !Validator.isValidPhoneNumber(phoneNumber) {
            phoneError = "휴대폰 번호 형식이 올바르지 않습니다."
        }
        return nameError == nil && phoneError == nil
    }
}
