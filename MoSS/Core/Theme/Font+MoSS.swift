import SwiftUI

/// 피그마 타입 스케일 (Gothic A1)
enum MoSSTextStyle {
    case display
    case titleL
    case titleM
    case button
    case body
    case label
    case caption

    var size: CGFloat {
        switch self {
        case .display: return 32
        case .titleL: return 22
        case .titleM: return 18
        case .button: return 16
        case .body: return 14
        case .label: return 13
        case .caption: return 11
        }
    }

    var weight: MoSSFontWeight {
        switch self {
        case .display, .titleL: return .black
        case .titleM: return .extraBold
        case .button, .label: return .bold
        case .body: return .regular
        case .caption: return .medium
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .display: return 40
        case .titleL: return 30
        case .titleM: return 26
        case .button: return 24
        case .body: return 22
        case .label: return 20
        case .caption: return 16
        }
    }
}

enum MoSSFontWeight: String, CaseIterable {
    case regular = "Regular"
    case medium = "Medium"
    case semiBold = "SemiBold"
    case bold = "Bold"
    case extraBold = "ExtraBold"
    case black = "Black"

    var fontName: String {
        "GothicA1-\(rawValue)"
    }

    // 폰트 파일이 없을 때 시스템 폰트로 대체하기 위한 값
    var systemWeight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}

extension Font {
    static func moss(_ weight: MoSSFontWeight, size: CGFloat) -> Font {
        guard FontRegistrar.isAvailable(weight) else {
            return .system(size: size, weight: weight.systemWeight)
        }
        return .custom(weight.fontName, fixedSize: size)
    }

    static func moss(_ style: MoSSTextStyle) -> Font {
        .moss(style.weight, size: style.size)
    }
}

private struct MoSSFontModifier: ViewModifier {
    let style: MoSSTextStyle
    let weight: MoSSFontWeight?

    func body(content: Content) -> some View {
        content
            .font(.moss(weight ?? style.weight, size: style.size))
            // lineSpacing은 줄 사이 간격만 더하므로 (행간 - 글자 크기)만큼 보정
            .lineSpacing(max(0, style.lineHeight - style.size * 1.2))
    }
}

extension View {
    /// 피그마 타입 스케일 적용. weight를 넘기면 굵기만 덮어쓴다.
    func mossFont(_ style: MoSSTextStyle, weight: MoSSFontWeight? = nil) -> some View {
        modifier(MoSSFontModifier(style: style, weight: weight))
    }
}
