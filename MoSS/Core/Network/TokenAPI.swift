import Foundation

/// 토큰 재발급은 NetworkService 내부에서 쓰기 때문에 Core에 둔다.
enum TokenAPI: Endpoint {
    case refresh(refreshToken: String)

    var path: String {
        switch self {
        case .refresh: return "/auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .refresh: return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .refresh(let refreshToken):
            return ["refreshToken": refreshToken]
        }
    }
}

/// POST /auth/login, POST /auth/refresh 공통 응답 data
struct TokenResponse: Decodable {
    let id: Int
    let name: String
    let email: String
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}
