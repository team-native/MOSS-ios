import SwiftUI

struct AccountDeletionCompleteView: View {
    let onBack: () -> Void

    @State private var isShowingRecoveryGuide = false

    private var recoveryDeadline: String {
        let date = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return "\(formatter.string(from: date))까지"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    successMessage
                    recoveryCard
                    warningNotice
                    Button {
                        isShowingRecoveryGuide = true
                    } label: {
                        Text("계정 복구 안내 보기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("계정 복구 안내", isPresented: $isShowingRecoveryGuide) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("탈퇴일로부터 30일 이내에 기존 이메일로 로그인하면 계정을 복구할 수 있습니다. 서버 연동 전에는 실제 계정 상태가 변경되지 않습니다.")
        }
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("마이페이지로 돌아가기")
            Spacer()
            Text("회원탈퇴 완료")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var successMessage: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 64, height: 64)
                .background(Color.mossSageTint, in: Circle())
            Text("회원탈퇴가 완료됐어요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .multilineTextAlignment(.center)
            Text("그동안 MoSS와 함께해 주셔서 감사합니다.\n계정은 30일 동안 복구할 수 있어요.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.top, 36)
        .padding(.bottom, 28)
    }

    private var recoveryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("복구 가능 기간")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossBrandSage)
                Spacer()
                Text(recoveryDeadline)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
            Text("기간 안에 기존 이메일로 로그인하면 작성한 리뷰와 찜 목록을 포함해 계정을 복구할 수 있어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var warningNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossError)
            Text("30일이 지나면 계정, 프로필, 찜, 리뷰 등 개인 데이터가 순차적으로 영구 말소되며 복구할 수 없어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossError)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 12))
    }
}
