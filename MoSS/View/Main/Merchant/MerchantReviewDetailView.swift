import SwiftUI

struct MerchantReviewDetailView: View {
    let review: MerchantReviewRecord
    let existingReply: String?
    let onBack: () -> Void
    let onReport: () -> Void
    let onSaveDraft: (String) -> Void
    let onSubmitReply: (String) -> Void

    @State private var replyText: String
    @State private var isShowingSavedNotice = false
    @State private var isShowingReplyNotice = false

    init(
        review: MerchantReviewRecord,
        existingReply: String?,
        onBack: @escaping () -> Void,
        onReport: @escaping () -> Void,
        onSaveDraft: @escaping (String) -> Void,
        onSubmitReply: @escaping (String) -> Void
    ) {
        self.review = review
        self.existingReply = existingReply
        self.onBack = onBack
        self.onReport = onReport
        self.onSaveDraft = onSaveDraft
        self.onSubmitReply = onSubmitReply
        _replyText = State(initialValue: existingReply ?? "정성스러운 리뷰 감사합니다. 다음 방문에도 편안하게 집중하실 수 있도록 꼼꼼히 관리할게요!")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    reviewCard
                    replyComposer
                    HStack(spacing: 8) {
                        Button {
                            onSaveDraft(replyText)
                            isShowingSavedNotice = true
                        } label: {
                            Text("임시 저장")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(Color.mossPrimaryGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                        }
                        Button {
                            onSubmitReply(replyText)
                            isShowingReplyNotice = true
                        } label: {
                            Text(existingReply == nil ? "답글 등록" : "답글 수정")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    }
                    Text("등록 후에도 답글을 수정할 수 있어요.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("임시 저장", isPresented: $isShowingSavedNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("답글 초안이 이 화면 미리보기에 저장되었습니다. 서버에는 전송되지 않았습니다.")
        }
        .alert("답글 등록", isPresented: $isShowingReplyNotice) {
            Button("확인", action: onBack)
        } message: {
            Text("답글이 샘플 상태에 반영되었습니다. 실제 등록은 서버 연동 후 제공됩니다.")
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
            .accessibilityLabel("리뷰 목록으로 돌아가기")
            Spacer()
            Text("리뷰 상세")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button(action: onReport) {
                Text("신고")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(review.author)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("\(review.date) · 방문 인증")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                }
                Spacer()
                Label(review.rating, systemImage: "star")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossWarning)
            }
            Text(review.id == "merchant-review-1" ? "어쩌구저쩌구" : review.body)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            if review.hasPhoto {
                HStack(spacing: 8) {
                    Image("MerchantReviewPhoto")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Image("MerchantReviewPhotoTwo")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var replyComposer: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("사장님 답글")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text(existingReply == nil ? "미등록" : "답변 완료")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(existingReply == nil ? Color(hex: 0x7A4E1B) : Color.mossPrimaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(existingReply == nil ? Color(hex: 0xFFF8ED) : Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
            }
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mossSurface)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mossPrimaryGreen, lineWidth: 1)
                TextEditor(text: $replyText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.top, 5)
                    .onChange(of: replyText) { _, newValue in
                        if newValue.count > 500 { replyText = String(newValue.prefix(500)) }
                    }
                VStack {
                    Spacer()
                    Text("\(replyText.count) / 500")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.mossTextMuted)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
                .allowsHitTesting(false)
            }
            .frame(height: 112)
        }
    }
}
