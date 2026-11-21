import SwiftUI

struct ReviewReportView: View {
    let review: PlaceReview
    let onBack: () -> Void

    @State private var selectedReason = "광고·도배"
    @State private var details = ""
    @State private var isShowingLocalSubmissionNotice = false

    private let reasons = ["욕설·비방", "허위 정보", "광고·도배", "개인정보 노출", "기타"]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    introduction
                    reviewCard
                    reasonSection
                    detailsField
                    privacyNotice
                    Button {
                        isShowingLocalSubmissionNotice = true
                    } label: {
                        Text("신고 접수")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 22)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("신고 내용 확인", isPresented: $isShowingLocalSubmissionNotice) {
            Button("확인", action: onBack)
        } message: {
            Text("화면 미리보기에서는 신고 내용만 확인합니다. 실제 신고 접수는 서버 연결 후 제공됩니다.")
        }
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
            Text("리뷰 신고")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("신고 사유를 알려주세요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
            Text("운영 정책에 따라 검토 후 필요한 조치를 안내해 드려요.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
        }
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(review.author)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Label(review.rating, systemImage: "star")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossWarning)
            }
            Text(review.body)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .lineLimit(2)
                .lineSpacing(3)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("신고 사유 *")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            HStack(spacing: 8) {
                ForEach(reasons.prefix(4), id: \.self) { reason in
                    reasonChip(reason)
                }
            }
            HStack(spacing: 8) {
                reasonChip(reasons[4])
                Spacer(minLength: 0)
            }
        }
    }

    private func reasonChip(_ reason: String) -> some View {
        let isSelected = selectedReason == reason
        return Button {
            selectedReason = reason
        } label: {
            Text(reason)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(isSelected ? Color.mossPrimaryGreen : Color.mossSurface, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.mossPrimaryGreen : Color.mossLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var detailsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("상세 내용 *")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mossSurface)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mossLine, lineWidth: 1)
                if details.isEmpty {
                    Text("구체적인 내용을 적어주세요.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossTextMuted)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $details)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .onChange(of: details) { _, newValue in
                        if newValue.count > 500 {
                            details = String(newValue.prefix(500))
                        }
                    }
            }
            .frame(height: 104)
            Text("구체적인 내용을 적어주세요. \(details.count) / 500")
                .font(.system(size: 10))
                .foregroundStyle(Color.mossTextMuted)
        }
    }

    private var privacyNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossPrimaryGreen)
            Text("신고 내용은 작성자에게 공개되지 않으며, 처리 결과는 알림으로 안내해 드려요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }
}
