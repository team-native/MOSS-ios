import SwiftUI

struct MerchantReviewReportView: View {
    let review: MerchantReviewRecord
    let onBack: () -> Void

    @State private var selectedReason = "허위 정보"
    @State private var details = "실제 매장 운영 시간과 다른 내용이 반복적으로 작성되어 다른 고객에게 혼란을 줄 수 있습니다."
    @State private var hasAttemptedSubmit = false
    @State private var isShowingLocalSubmissionNotice = false
    @FocusState private var isDetailsFocused: Bool

    private let reasons = ["욕설·비방", "허위 정보", "광고·도배", "개인정보 노출", "기타"]

    private var validationMessage: String? {
        guard hasAttemptedSubmit else { return nil }
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "신고 상세 내용을 입력해 주세요." }
        if trimmed.count < 10 { return "신고 검토를 위해 10자 이상 입력해 주세요." }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        introduction
                        reasonSelector
                        detailsField
                            .id("reportDetails")
                        privacyNotice
                        submissionCard {
                            withAnimation(.easeInOut(duration: 0.28)) {
                                proxy.scrollTo("reportDetails", anchor: .center)
                            }
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
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("신고 제출 미리보기", isPresented: $isShowingLocalSubmissionNotice) {
            Button("확인", action: onBack)
        } message: {
            Text("신고 내용은 이 화면 미리보기에만 반영됩니다. 실제 신고 접수와 알림은 서버 연결 후 제공됩니다.")
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 1)
    }

    private var reasonSelector: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(reasons, id: \.self) { reason in
                let isSelected = selectedReason == reason
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        selectedReason = reason
                    }
                } label: {
                    Text(reason)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(isSelected ? Color.mossDarkAction : Color.mossSurface, in: Capsule())
                        .overlay(Capsule().stroke(isSelected ? Color.mossPrimaryGreen : Color.mossLine, lineWidth: 1))
                        .scaleEffect(isSelected ? 1 : 0.98)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: selectedReason)
    }

    private var detailsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("상세 내용")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mossSurface)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(validationMessage == nil ? Color.mossLine : Color.mossError, lineWidth: 1)
                if details.isEmpty {
                    Text("신고 검토에 도움이 되는 구체적인 내용을 적어주세요.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossTextMuted)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $details)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .focused($isDetailsFocused)
                    .onChange(of: details) { _, newValue in
                        if newValue.count > 500 { details = String(newValue.prefix(500)) }
                        if hasAttemptedSubmit && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation(.easeOut(duration: 0.18)) { hasAttemptedSubmit = false }
                        }
                    }
            }
            .frame(height: 82)
            HStack(alignment: .top) {
                Group {
                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.mossError)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        Text("신고 검토에 도움이 되는 구체적인 내용을 적어주세요.")
                            .foregroundStyle(Color.mossTextMuted)
                            .transition(.opacity)
                    }
                }
                .font(.system(size: 10))
                Spacer(minLength: 8)
                Text("\(details.count) / 500")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mossTextMuted)
                    .monospacedDigit()
            }
            .animation(.easeInOut(duration: 0.2), value: hasAttemptedSubmit)
        }
    }

    private var privacyNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantReportInfo")
                .resizable()
                .frame(width: 17, height: 17)
            Text("신고 내용은 작성자에게 공개되지 않으며, 처리 결과는 알림으로 안내해 드립니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }

    private func submissionCard(onReview: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image("MerchantReportFlag")
                    .resizable()
                    .frame(width: 19, height: 19)
                    .frame(width: 38, height: 38)
                    .background(Color(hex: 0xFBECE9), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("이 내용으로 제출할까요?")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("제출 후 신고 내용은 수정할 수 없어요.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                Button {
                    dismissKeyboard()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        hasAttemptedSubmit = false
                    }
                    onReview()
                } label: {
                    Text("다시 확인")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                }
                Button(action: submit) {
                    Text("신고 제출")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                }
                .sensoryFeedback(.success, trigger: isShowingLocalSubmissionNotice)
            }
        }
        .padding(14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.mossTextPrimary.opacity(0.035), radius: 12, y: 4)
    }

    private func submit() {
        dismissKeyboard()
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count >= 10 else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.68)) {
                hasAttemptedSubmit = true
            }
            return
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingLocalSubmissionNotice = true
        }
    }

    private func dismissKeyboard() {
        isDetailsFocused = false
    }
}
