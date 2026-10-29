import Foundation

/// 자동 로그인을 위해 토큰을 키체인에 보관한다.
final class TokenStorage {
    static let shared = TokenStorage()

    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    var accessToken: String? {
        KeychainHelper.read(Key.accessToken)
    }

    var refreshToken: String? {
        KeychainHelper.read(Key.refreshToken)
    }

    var hasToken: Bool {
        refreshToken != nil
    }

    func save(accessToken: String, refreshToken: String) {
        KeychainHelper.save(accessToken, for: Key.accessToken)
        KeychainHelper.save(refreshToken, for: Key.refreshToken)
    }

    func clear() {
        KeychainHelper.delete(Key.accessToken)
        KeychainHelper.delete(Key.refreshToken)
    }
}
