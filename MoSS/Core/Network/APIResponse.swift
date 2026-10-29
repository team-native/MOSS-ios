import Foundation

/// 서버 공통 응답 형식
/// { "success": Bool, "status": Int, "message": String, "data": T? }
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let status: Int
    let message: String
    let data: T?
}

/// data를 쓰지 않는 응답에 사용. data 형태와 상관없이 디코딩에 성공한다.
struct EmptyData: Decodable {
    init() {}
    init(from decoder: Decoder) throws {}
}
