import SwiftUI

/// 계정 찾기 화면 상단의 큰 제목 + 설명
struct AuthTitleView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .mossFont(.titleL)
                .foregroundStyle(Color.mossTextPrimary)

            Text(description)
                .mossFont(.body)
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AuthTitleView(title: "가입한 계정을 찾아드릴게요", description: "회원가입 시 등록한 이름과 휴대폰 번호를 입력해 주세요.")
        .padding(24)
        .background(Color.mossBackground)
}
