import Foundation

enum AuthAPI: Endpoint {
    case login(LoginRequest)
    case logout

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .logout: return "/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .logout: return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .login(let request): return request
        case .logout: return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login: return false
        case .logout: return true
        }
    }
}
