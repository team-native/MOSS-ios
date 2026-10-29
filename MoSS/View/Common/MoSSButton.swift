import SwiftUI

enum MoSSButtonStyle {
    /// 로그인·저장·등록 같은 주요 버튼 (Dark Action)
    case primary
    /// 비회원 둘러보기 같은 보조 버튼 (Sage Soft)
    case secondary

    var background: Color {
        switch self {
        case .primary: return .mossDarkAction
        case .secondary: return .mossSageSoft
        }
    }

    var foreground: Color {
        switch self {
        case .primary: return .white
        case .secondary: return .mossDarkAction
        }
    }
}

struct MoSSButton: View {
    let title: String
    var style: MoSSButtonStyle = .primary
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .mossFont(.button)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(style.foreground)
                }
            }
            .foregroundStyle(style.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius))
            .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        MoSSButton(title: "로그인") {}
        MoSSButton(title: "비회원으로 둘러보기", style: .secondary) {}
        MoSSButton(title: "로그인", isLoading: true) {}
        MoSSButton(title: "로그인", isEnabled: false) {}
    }
    .padding(24)
    .background(Color.mossBackground)
}
