import Foundation

/// 앱 전체의 로그인 상태를 관리한다.
@MainActor
final class SessionManager: ObservableObject {
    enum State: Equatable {
        case loggedOut
        case guest
        case loggedIn(User?)
    }

    @Published private(set) var state: State

    private let authService: AuthServiceProtocol
    private let tokenStorage: TokenStorage

    init(authService: AuthServiceProtocol = AuthService(), tokenStorage: TokenStorage = .shared) {
        self.authService = authService
        self.tokenStorage = tokenStorage
        // 자동 로그인: 저장된 토큰이 있으면 로그인 상태로 시작
        self.state = tokenStorage.hasToken ? .loggedIn(nil) : .loggedOut

        NotificationCenter.default.addObserver(
            forName: .sessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.state = .loggedOut
            }
        }
    }

    var isGuest: Bool {
        state == .guest
    }

    func didLogin(_ user: User) {
        state = .loggedIn(user)
    }

    func continueAsGuest() {
        state = .guest
    }

    func logout() async {
        if case .loggedIn = state {
            await authService.logout()
        }
        state = .loggedOut
    }
}
