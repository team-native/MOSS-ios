import SwiftUI

/// 로고 배지 + "MoSS" 워드마크 (마지막 S만 Deep Green)
struct MoSSLogo: View {
    var showsTagline: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            (Text("MoS").foregroundColor(.mossDarkAction) + Text("S").foregroundColor(.mossDeepGreen))
                .font(.moss(.display))
                .tracking(-1)
                .accessibilityLabel("MoSS")

            if showsTagline {
                Text("학생들을 위한 차분하고 조용한 공부 명소")
                    .mossFont(.body, weight: .medium)
                    .foregroundStyle(Color.mossDarkAction)
            }
        }
    }
}

#Preview {
    MoSSLogo()
        .padding()
        .background(Color.mossBackground)
}
