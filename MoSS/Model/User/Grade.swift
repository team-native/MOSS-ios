/// 서버 enum Grade { MIDDLE, HIGH, UNIV }
enum Grade: String, Codable, CaseIterable {
    case middle = "MIDDLE"
    case high = "HIGH"
    case univ = "UNIV"

    var title: String {
        switch self {
        case .middle: return "중학생"
        case .high: return "고등학생"
        case .univ: return "대학생"
        }
    }
}
