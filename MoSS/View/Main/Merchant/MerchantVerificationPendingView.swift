import SwiftUI

struct MerchantVerificationPendingView: View {
    let submission: MerchantBusinessVerificationSubmission
    let onBack: () -> Void
    let onResubmitDocuments: () -> Void

    @State private var animatesHourglass = false

    private var receivedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return "\(formatter.string(from: submission.submittedAt)) 접수"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    statusCard
                    summaryCard
                    processSteps
                    localPreviewNotice
                    Button(action: onResubmitDocuments) {
                        Text("보완 서류 제출하기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .onAppear { animatesHourglass = true }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: animatesHourglass)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image("MerchantMenuBack")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("사업자 인증 신청으로 돌아가기")
            Spacer()
            Text("인증 진행 상황")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image("MerchantVerificationHourglass")
                .resizable()
                .frame(width: 24, height: 24)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.09), in: Circle())
                .rotationEffect(.degrees(animatesHourglass ? -5 : 5))
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animatesHourglass)
            VStack(alignment: .leading, spacing: 4) {
                Text(receivedDate)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossSageTint)
                Text("사업자 인증 심사 중")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                Text("미리보기 상태")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.mossSageTint)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBrandSage, in: RoundedRectangle(cornerRadius: 16))
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            summaryRow(title: "매장", value: "에이밍 스터디카페")
            summaryRow(title: "사업자번호", value: submission.businessNumber)
            summaryRow(title: "예상 완료", value: "영업일 1~2일 내", valueColor: Color.mossPrimaryGreen)
        }
        .padding(14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow(title: String, value: String, valueColor: Color = .mossTextPrimary) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextMuted)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }

    private var processSteps: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("예상 절차")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            stepRow(
                icon: "MerchantVerificationCheck",
                iconBackground: Color.mossSageSoft,
                title: "신청 접수",
                description: "입력 내용은 이 기기의 미리보기에 저장됐어요."
            )
            HStack(spacing: 11) {
                Image("MerchantVerificationFileWarning")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .frame(width: 30, height: 30)
                    .background(Color(hex: 0xFFF8ED), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("서류 확인")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("실제 서류 검토는 서버 연동 후 제공됩니다.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                }
                Spacer(minLength: 0)
                Text("미리보기")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x7A4E1B))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 8))
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
            stepRow(
                icon: "MerchantVerificationClock",
                iconBackground: Color.mossBackground,
                title: "승인 및 권한 부여",
                description: "실제 승인 결과는 서버 연동 후 확인할 수 있어요."
            )
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: animatesHourglass)
    }

    private func stepRow(icon: String, iconBackground: Color, title: String, description: String) -> some View {
        HStack(spacing: 11) {
            Image(icon)
                .resizable()
                .frame(width: 15, height: 15)
                .frame(width: 30, height: 30)
                .background(iconBackground, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var localPreviewNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image("MerchantVerificationWarning")
                .resizable()
                .frame(width: 17, height: 17)
            Text("사업자 정보와 첨부 파일은 실제로 전송되지 않았습니다. 이 화면은 로컬 미리보기이며 실제 인증 결과가 아닙니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 12))
    }
}
