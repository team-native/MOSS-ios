import Foundation

enum APIError: Error {
    case invalidURL
    case network(URLError)
    /// 서버가 success: false로 응답한 경우. body는 data 필드를 따로 디코딩할 때 사용
    case server(status: Int, message: String, body: Data)
    case unauthorized
    case decoding(Error)
    case unknown

    /// 사용자에게 보여줄 메시지
    var userMessage: String {
        switch self {
        case .server(_, let message, _):
            return message
        case .network(let error) where error.code == .notConnectedToInternet:
            return "인터넷 연결을 확인해 주세요."
        case .network(let error) where error.code == .timedOut:
            return "요청 시간이 초과되었습니다.\n잠시 후 다시 시도해 주세요."
        case .unauthorized:
            return "로그인이 필요합니다."
        default:
            return "일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        }
    }

    var statusCode: Int? {
        if case .server(let status, _, _) = self { return status }
        if case .unauthorized = self { return 401 }
        return nil
    }

    /// 에러 응답의 data 필드를 원하는 타입으로 디코딩 (예: 로그인 실패 횟수)
    func errorData<T: Decodable>(as type: T.Type) -> T? {
        guard case .server(_, _, let body) = self else { return nil }
        return (try? JSONDecoder().decode(APIResponse<T>.self, from: body))?.data
    }
}
