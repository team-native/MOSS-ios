/// POST /auth/signup/student 요청
struct StudentSignUpRequest: Encodable {
    let role: UserRole = .student
    let email: String
    let name: String
    let number: String
    let password: String
    let passwordConfirm: String
    let grade: Grade
}

/// POST /auth/signup/business 요청
struct BusinessSignUpRequest: Encodable {
    let role: UserRole = .business
    let email: String
    let name: String
    let number: String
    let password: String
    let passwordConfirm: String
}

/// 회원가입 성공 응답 data
struct SignUpResponse: Decodable {
    let userId: Int
    let name: String
    let email: String
    let createdAt: String
}

/// POST /auth/send-email 요청
struct SendEmailRequest: Encodable {
    let email: String
}

/// POST /auth/verify-email 요청
struct VerifyEmailRequest: Encodable {
    let email: String
    let code: String
}
