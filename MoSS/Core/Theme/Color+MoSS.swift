import SwiftUI

// 피그마 "색상과 타이포그래피" 가이드의 팔레트 (60% Neutral · 30% Green · 10% Accent)
extension Color {
    // 핵심 색상
    static let mossDeepGreen = Color(hex: 0x29483B)
    static let mossPrimaryGreen = Color(hex: 0x4F705E)
    static let mossDarkAction = Color(hex: 0x4A3E3D)
    static let mossTextPrimary = Color(hex: 0x1A2920)

    // 보조 색상
    static let mossBrandSage = Color(hex: 0x5D6B63)
    static let mossSageTint = Color(hex: 0xE3ECE7)
    static let mossSageSoft = Color(hex: 0xEDF2EE)

    // 중립 색상
    static let mossBackground = Color(hex: 0xFAF9F5)
    static let mossSurface = Color(hex: 0xFFFFFF)
    static let mossLine = Color(hex: 0xE2E8E4)
    static let mossTextMuted = Color(hex: 0x8E9B93)

    // 상태 색상
    static let mossSuccess = Color(hex: 0x4F705E)
    static let mossWarning = Color(hex: 0xEAA850)
    static let mossError = Color(hex: 0xC95B4A)
    static let mossInfo = Color(hex: 0x557A8A)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
