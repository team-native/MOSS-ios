import Foundation

enum APIConfig {
    // TODO: 백엔드 서버 주소 확정되면 교체
    static let baseURL = URL(string: "https://api.moss.example.com")!

    static let timeout: TimeInterval = 15
}
