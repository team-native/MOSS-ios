import Foundation

enum AuthAPI: Endpoint {
    case login(LoginRequest)
    case logout
    case signUpStudent(StudentSignUpRequest)
    case signUpBusiness(BusinessSignUpRequest)
    case sendEmail(SendEmailRequest)
    case verifyEmail(VerifyEmailRequest)
    case findID(FindIDRequest)
    case resetPassword(ResetPasswordRequest)

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .logout: return "/auth/logout"
        case .signUpStudent: return "/auth/signup/student"
        case .signUpBusiness: return "/auth/signup/business"
        case .sendEmail: return "/auth/send-email"
        case .verifyEmail: return "/auth/verify-email"
        case .findID: return "/auth/find-id"
        case .resetPassword: return "/auth/reset-password"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .logout, .signUpStudent, .signUpBusiness, .sendEmail, .verifyEmail, .findID:
            return .post
        case .resetPassword:
            return .patch
        }
    }

    var body: Encodable? {
        switch self {
        case .login(let request): return request
        case .logout: return nil
        case .signUpStudent(let request): return request
        case .signUpBusiness(let request): return request
        case .sendEmail(let request): return request
        case .verifyEmail(let request): return request
        case .findID(let request): return request
        case .resetPassword(let request): return request
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .logout: return true
        default: return false
        }
    }
}
