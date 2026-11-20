import SwiftUI

/// Sage Soft 배경의 안내 카드 (아이콘 + 문구)
struct MoSSNoticeCard: View {
    let systemImage: String
    let message: String
    var isEmphasized: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossPrimaryGreen)

            Text(message)
                .font(.moss(isEmphasized ? .bold : .regular, size: isEmphasized ? 13 : 12))
                .foregroundStyle(isEmphasized ? Color.mossPrimaryGreen : Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.mossSageSoft)
        .clipShape(RoundedRectangle(cornerRadius: Layout.inputRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        MoSSNoticeCard(systemImage: "checkmark.shield", message: "개인정보 보호를 위해 입력 정보는 계정 확인에만 사용됩니다.")
        MoSSNoticeCard(systemImage: "checkmark", message: "이메일 인증이 완료되었습니다.", isEmphasized: true)
    }
    .padding(24)
    .background(Color.mossBackground)
}
