import SwiftUI

struct ReviewDeleteRecoveryView: View {
    let deletedAt: Date
    let onRestore: () -> Void
    let onReviewList: () -> Void

    private var recoveryDeadline: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: deletedAt) ?? deletedAt
    }

    private var deadlineText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: recoveryDeadline)
    }

    private var remainingText: String {
        let components = Calendar.current.dateComponents([.day, .hour], from: Date(), to: recoveryDeadline)
        let days = max(components.day ?? 0, 0)
        let hours = max(components.hour ?? 0, 0)
        return "\(days)일 \(hours)시간 남았어요"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    deletedState
                    recoveryCard
                    expirationNotice
                    Button(action: onRestore) {
                        Text("삭제한 리뷰 복구")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button(action: onReviewList) {
                        Text("리뷰 목록으로 이동")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.mossLine, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onReviewList) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 목록으로 돌아가기")
            Spacer()
            Text("리뷰 삭제")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var deletedState: some View {
        VStack(spacing: 14) {
            Image(systemName: "trash")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 64, height: 64)
                .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 32))
            Text("리뷰를 삭제했어요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .multilineTextAlignment(.center)
            Text("삭제한 리뷰는 7일 동안 보관돼요. 기간 안에는 언제든 다시 복구할 수 있어요.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.top, 30)
        .padding(.bottom, 14)
    }

    private var recoveryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("복구 가능 기한")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossBrandSage)
                Spacer()
                Text(deadlineText)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.mossLine)
                    Capsule()
                        .fill(Color.mossPrimaryGreen)
                        .frame(width: geometry.size.width)
                }
            }
            .frame(height: 6)
            Text(remainingText)
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 16))
    }

    private var expirationNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossError)
            Text("복구 기간이 지나면 리뷰와 첨부 사진이 완전히 삭제되어 되돌릴 수 없어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossError)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 12))
    }
}
