import SwiftUI

struct MerchantReportSubmission: Equatable {
    let review: MerchantReviewRecord
    let reason: String
    let details: String

    var displayNumber: String { "R-26010042" }
}

struct MerchantReportStatusView: View {
    let submission: MerchantReportSubmission
    let onBack: () -> Void
    let onReturnToReviews: () -> Void

    @State private var isAnimatingProgress = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    overviewCard
                    progressCard
                    reportedReviewCard
                    privacyNotice
                    Button(action: onReturnToReviews) {
                        Text("리뷰 관리로 돌아가기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 1)
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .onAppear { isAnimatingProgress = true }
        .transition(.opacity.combined(with: .scale(scale: 0.985)))
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 상세로 돌아가기")
            Spacer()
            Text("리뷰 신고 처리")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var overviewCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("신고 번호 \(submission.displayNumber)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossSageTint)
                Text("처리 중이에요")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 8)
            Text("영업일 1–3일")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: 0xE3ECE7), in: RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 16))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("처리 현황")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            progressStep(
                title: "접수",
                message: "\(submission.reason) 사유로 신고가 접수됐어요.",
                date: "10.01",
                icon: "MerchantReportCheck",
                isComplete: true
            )
            progressStep(
                title: "처리 중",
                message: "운영 정책과 리뷰 원문을 확인하고 있어요.",
                date: "10.02",
                icon: "MerchantReportLoader",
                isComplete: true,
                rotates: true
            )
            progressStep(
                title: "처리 완료",
                message: "조치 결과를 알림으로 안내해 드려요.",
                date: "예정",
                icon: "MerchantReportCircle",
                isComplete: false
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func progressStep(
        title: String,
        message: String,
        date: String,
        icon: String,
        isComplete: Bool,
        rotates: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 15, height: 15)
                .rotationEffect(.degrees(rotates && isAnimatingProgress ? 360 : 0))
                .animation(
                    rotates ? .linear(duration: 1.2).repeatForever(autoreverses: false) : .default,
                    value: isAnimatingProgress
                )
                .frame(width: 32, height: 32)
                .background(isComplete ? Color.mossPrimaryGreen : Color(hex: 0xF0ECE8), in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(title == "처리 중" ? Color.mossPrimaryGreen : Color.mossTextMuted)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 2)
            Text(date)
                .font(.system(size: 10))
                .foregroundStyle(Color.mossTextMuted)
        }
        .accessibilityElement(children: .combine)
    }

    private var reportedReviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("신고한 리뷰")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text(submission.reason)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x7A4E1B))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 6))
            }
            Text("“\(submission.review.body)”")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .lineLimit(2)
            Text(submission.details)
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var privacyNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantReportStatusInfo")
                .resizable()
                .frame(width: 17, height: 17)
            Text("신고만으로 리뷰가 바로 삭제되지는 않아요. 정책 위반이 확인되면 숨김 또는 삭제 처리됩니다.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }
}
