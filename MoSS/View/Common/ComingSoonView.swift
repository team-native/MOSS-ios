import SwiftUI

/// 아직 구현되지 않은 화면에 임시로 사용
struct ComingSoonView: View {
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .mossFont(.titleM)
                .foregroundStyle(Color.mossTextPrimary)
            Text("준비 중인 화면입니다.")
                .mossFont(.body)
                .foregroundStyle(Color.mossTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
