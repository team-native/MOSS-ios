/// POST /auth/find-id 요청
struct FindIDRequest: Encodable {
    let name: String
    let number: String
}

/// POST /auth/find-id 응답 data
struct FindIDResponse: Decodable, Hashable {
    let email: String
    let createdAt: String
}

/// POST /auth/verify-email 응답 data
struct VerifyEmailResponse: Decodable {
    let resetToken: String?
    let expiresAt: String?
}

/// PATCH /auth/reset-password 요청
struct ResetPasswordRequest: Encodable {
    let resetToken: String
    let password: String
    let passwordConfirm: String
}
