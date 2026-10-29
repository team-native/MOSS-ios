import Foundation

/// 서버 공통 응답 형식
/// { "success": Bool, "status": Int, "message": String, "data": T? }
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let status: Int
    let message: String
    let data: T?
}

/// data가 null이거나 쓰지 않는 응답에 사용
struct EmptyData: Decodable {}
