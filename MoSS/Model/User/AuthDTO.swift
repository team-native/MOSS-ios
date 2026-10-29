/// POST /auth/login 요청
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

/// 로그인 실패(400) 응답의 data
struct LoginFailureData: Decodable {
    let failedAttempts: Int
    let maxAttempts: Int
}
