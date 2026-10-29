import SwiftUI

struct FindIDResultView: View {
    let result: FindIDResponse

    @EnvironmentObject private var router: AuthRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 14) {
                    Circle()
                        .fill(Color.mossSageTint)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(Color.mossPrimaryGreen)
                        }

                    AuthTitleView(
                        title: "계정을 찾았어요",
                        description: "입력하신 정보와 일치하는 MoSS 계정입니다."
                    )
                }

                accountCard

                VStack(spacing: 10) {
                    MoSSButton(title: "로그인하러 가기") {
                        router.popToLogin(email: result.email)
                    }

                    MoSSButton(title: "비밀번호 찾기", style: .secondary) {
                        router.push(.findPassword(email: result.email))
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, 30)
            .padding(.bottom, 24)
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("아이디 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("가입 이메일")
                .font(.moss(.bold, size: 12))
                .foregroundStyle(Color.mossTextMuted)

            Text(result.email)
                .mossFont(.titleM)
                .foregroundStyle(Color.mossTextPrimary)
                .textSelection(.enabled)

            if let joinedDate = DateFormatter.joinedDateText(from: result.createdAt) {
                Text("\(joinedDate) 가입")
                    .font(.moss(.regular, size: 12))
                    .foregroundStyle(Color.mossBrandSage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.mossSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.mossLine, lineWidth: 1)
        }
    }
}

private extension DateFormatter {
    /// "2026-10-22" 또는 "2026-10-22T..." → "2026년 10월 22일"
    static func joinedDateText(from value: String) -> String? {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd"

        guard let date = input.date(from: String(value.prefix(10))) else { return nil }

        let output = DateFormatter()
        output.locale = Locale(identifier: "ko_KR")
        output.dateFormat = "yyyy년 M월 d일"
        return output.string(from: date)
    }
}

#Preview {
    NavigationStack {
        FindIDResultView(result: FindIDResponse(email: "s26043@gsm.hs.kr", createdAt: "2026-10-22"))
    }
    .environmentObject(AuthRouter())
}
