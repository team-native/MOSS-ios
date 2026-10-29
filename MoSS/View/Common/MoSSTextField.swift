import SwiftUI

/// 라벨 + 입력창 + 도움말로 구성된 공통 입력 필드
/// - errorMessage가 있으면 라벨·테두리·도움말이 Error 색으로 바뀐다.
/// - 메시지 우선순위: errorMessage > successMessage > helperMessage
struct MoSSTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var successMessage: String?
    var helperMessage: String?
    var isDisabled: Bool = false
    /// 입력창 오른쪽 텍스트 버튼 (예: 인증 요청, 확인)
    var trailingActionTitle: String?
    var isTrailingActionEnabled: Bool = true
    var onTrailingAction: (() -> Void)?

    @State private var isRevealed = false

    private var hasError: Bool {
        errorMessage != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .mossFont(.label)
                .foregroundStyle(hasError ? Color.mossError : Color.mossBrandSage)

            HStack(spacing: 8) {
                inputField
                    .mossFont(.body)
                    .foregroundStyle(isDisabled ? Color.mossTextMuted : Color.mossTextPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .disabled(isDisabled)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye" : "eye.slash")
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "비밀번호 숨기기" : "비밀번호 보기")
                }

                if let trailingActionTitle, let onTrailingAction {
                    Button(trailingActionTitle, action: onTrailingAction)
                        .font(.moss(.bold, size: 12))
                        .foregroundStyle(isTrailingActionEnabled ? Color.mossPrimaryGreen : Color.mossTextMuted)
                        .buttonStyle(.plain)
                        .disabled(!isTrailingActionEnabled)
                        .fixedSize()
                }
            }
            .padding(.horizontal, 16)
            .frame(height: Layout.inputHeight)
            .background(isDisabled ? Color.mossSageSoft : Color.mossSurface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.inputRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Layout.inputRadius)
                    .stroke(hasError ? Color.mossError : Color.clear, lineWidth: 1)
            }

            if let message = errorMessage ?? successMessage ?? helperMessage {
                Text(message)
                    .mossFont(.caption, weight: .regular)
                    .foregroundStyle(messageColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var messageColor: Color {
        if errorMessage != nil { return .mossError }
        if successMessage != nil { return .mossSuccess }
        return .mossTextMuted
    }

    @ViewBuilder
    private var inputField: some View {
        let prompt = Text(placeholder).foregroundStyle(Color.mossTextMuted)

        if isSecure && !isRevealed {
            SecureField("", text: $text, prompt: prompt)
        } else {
            TextField("", text: $text, prompt: prompt)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MoSSTextField(label: "이메일", placeholder: "s26043@gsm.hs.kr", text: .constant(""))
        MoSSTextField(
            label: "비밀번호",
            placeholder: "비밀번호를 입력하세요",
            text: .constant("password"),
            isSecure: true,
            errorMessage: "입력 내용을 다시 확인해 주세요 (실패 2/5)"
        )
        MoSSTextField(
            label: "인증번호",
            placeholder: "인증번호를 입력해 주세요",
            text: .constant(""),
            helperMessage: "남은 시간 01:13 · 인증번호가 오지 않았다면 다시 요청해 주세요.",
            trailingActionTitle: "확인",
            onTrailingAction: {}
        )
    }
    .padding(24)
    .background(Color.mossBackground)
}
