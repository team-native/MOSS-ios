import SwiftUI

struct MerchantReplyEditView: View {
    let review: MerchantReviewRecord
    let initialReply: String
    let onBack: () -> Void
    let onSave: (String) -> Void
    let onDelete: () -> Void

    @State private var replyText: String
    @State private var hasAttemptedSave = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingSavedNotice = false
    @FocusState private var isReplyFocused: Bool

    init(
        review: MerchantReviewRecord,
        initialReply: String,
        onBack: @escaping () -> Void,
        onSave: @escaping (String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.review = review
        self.initialReply = initialReply
        self.onBack = onBack
        self.onSave = onSave
        self.onDelete = onDelete
        _replyText = State(initialValue: initialReply)
    }

    private var validationMessage: String? {
        guard hasAttemptedSave, replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return "답글 내용을 입력해 주세요."
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    reviewCard
                    editWindowNotice
                    replyEditor
                    deletionNotice
                    HStack(spacing: 10) {
                        Button { isShowingDeleteConfirmation = true } label: {
                            Text("답글 삭제")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: 0xC95B4A), in: RoundedRectangle(cornerRadius: 12))
                        }
                        Button(action: save) {
                            Text("수정 저장")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .sensoryFeedback(.error, trigger: hasAttemptedSave)
                    }
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { dismissKeyboard() }
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .confirmationDialog("답글을 삭제할까요?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("답글 삭제", role: .destructive, action: onDelete)
            Button("취소", role: .cancel) { }
        } message: {
            Text("삭제 후에는 답글을 복구할 수 없습니다. (미리보기에서는 로컬 상태만 변경됩니다.)")
        }
        .alert("수정 내용을 저장했어요", isPresented: $isShowingSavedNotice) {
            Button("확인", action: onBack)
        } message: {
            Text("답글은 화면 미리보기의 로컬 샘플에 반영됐습니다. 실제 서버에는 저장되지 않았습니다.")
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 관리로 돌아가기")
            Spacer()
            Text("업주 답글 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(review.author)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Label(review.rating, systemImage: "star")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossWarning)
            }
            Text(review.body)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(3)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var editWindowNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantReplyEditClock")
                .resizable()
                .frame(width: 17, height: 17)
            Text("답글은 최초 작성 후 3일 동안 수정·삭제할 수 있어요.\n남은 기간 1일 6시간")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .lineSpacing(2)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 12))
    }

    private var replyEditor: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("등록된 답글")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text("\(replyText.count) / 500")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .monospacedDigit()
            }
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mossSurface)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(validationMessage == nil ? Color.mossPrimaryGreen : Color.mossError, lineWidth: 1)
                if replyText.isEmpty {
                    Text("답글 내용을 입력해 주세요.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossTextMuted)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $replyText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.top, 5)
                    .focused($isReplyFocused)
                    .onChange(of: replyText) { _, newValue in
                        if newValue.count > 500 { replyText = String(newValue.prefix(500)) }
                        if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation(.easeOut(duration: 0.18)) { hasAttemptedSave = false }
                        }
                    }
                VStack {
                    Spacer()
                    Text("2026.10.01 작성 · 수정 가능 2026.10.04까지")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.mossTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
                .allowsHitTesting(false)
            }
            .frame(height: 190)
            if let validationMessage {
                Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossError)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasAttemptedSave)
    }

    private var deletionNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantReplyEditInfo")
                .resizable()
                .frame(width: 17, height: 17)
            Text("삭제하면 고객 리뷰에는 ‘업주 답글이 삭제되었어요’가 표시되지 않아요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF0F4F1), in: RoundedRectangle(cornerRadius: 12))
    }

    private func save() {
        dismissKeyboard()
        let trimmed = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { hasAttemptedSave = true }
            return
        }
        replyText = trimmed
        onSave(trimmed)
        isShowingSavedNotice = true
    }

    private func dismissKeyboard() {
        isReplyFocused = false
    }
}
