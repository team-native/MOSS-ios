import SwiftUI

/// 로그인 화면에서 시작하는 인증 관련 화면 이동
enum AuthRoute: Hashable {
    case signUp
    case findID
    case findIDResult(FindIDResponse)
    case findPassword(email: String?)
    case resetPassword(resetToken: String)
}

@MainActor
final class AuthRouter: ObservableObject {
    @Published var path: [AuthRoute] = []
    /// 로그인 화면으로 돌아갈 때 이메일 입력창에 채워 넣을 값
    @Published var prefilledEmail: String?

    func push(_ route: AuthRoute) {
        path.append(route)
    }

    func popToLogin(email: String? = nil) {
        prefilledEmail = email
        path.removeAll()
    }
}
