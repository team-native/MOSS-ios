import Foundation

enum Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    /// 닉네임(name) 2~8자
    static func isValidName(_ name: String) -> Bool {
        (2...8).contains(name.count)
    }

    /// 010으로 시작하는 휴대폰 번호 10~11자리 (숫자만)
    static func isValidPhoneNumber(_ number: String) -> Bool {
        number.range(of: #"^01[016789][0-9]{7,8}$"#, options: .regularExpression) != nil
    }

    /// 비밀번호 6~15자, 영문·숫자·특수문자 각 1개 이상
    static func isValidPassword(_ password: String) -> Bool {
        guard (6...15).contains(password.count) else { return false }
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[^A-Za-z0-9\\s]", options: .regularExpression) != nil
        return hasLetter && hasNumber && hasSymbol
    }

    /// 인증번호 숫자 6자리
    static func isValidVerificationCode(_ code: String) -> Bool {
        code.range(of: #"^[0-9]{6}$"#, options: .regularExpression) != nil
    }
}
