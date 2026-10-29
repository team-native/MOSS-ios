import SwiftUI

struct FindPasswordView: View {
    @EnvironmentObject private var router: AuthRouter
    @StateObject private var viewModel: FindPasswordViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email, code
    }

    init(email: String? = nil) {
        _viewModel = StateObject(wrappedValue: FindPasswordViewModel(email: email))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                AuthTitleView(
                    title: "비밀번호를 다시 설정해요",
                    description: "가입한 이메일을 입력하면 본인 확인용 인증번호를 보내드릴게요."
                )

                VStack(spacing: 16) {
                    MoSSTextField(
                        label: "이메일",
                        placeholder: "이메일을 입력해 주세요",
                        text: $viewModel.email,
                        errorMessage: viewModel.emailError,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        isDisabled: viewModel.isVerified,
                        trailingActionTitle: viewModel.isVerified ? nil : viewModel.sendCodeTitle,
                        isTrailingActionEnabled: viewModel.canSendCode,
                        onTrailingAction: {
                            focusedField = nil
                            Task { await viewModel.sendCode() }
                        }
                    )
                    .focused($focusedField, equals: .email)

                    if viewModel.isCodeSent && !viewModel.isVerified {
                        MoSSTextField(
                            label: "인증번호",
                            placeholder: "인증번호를 입력해 주세요",
                            text: $viewModel.code,
                            errorMessage: viewModel.codeError,
                            keyboardType: .numberPad,
                            textContentType: .oneTimeCode,
                            helperMessage: viewModel.codeHelperMessage,
                            trailingActionTitle: "확인",
                            isTrailingActionEnabled: viewModel.canVerify,
                            onTrailingAction: {
                                focusedField = nil
                                Task { await viewModel.verifyCode() }
                            }
                        )
                        .focused($focusedField, equals: .code)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                if viewModel.isVerified {
                    MoSSNoticeCard(
                        systemImage: "checkmark",
                        message: "이메일 인증이 완료되었습니다.",
                        isEmphasized: true
                    )
                    .transition(.opacity)
                }

                MoSSButton(title: "새 비밀번호 설정", isEnabled: viewModel.isVerified) {
                    if let token = viewModel.resetToken {
                        router.push(.resetPassword(resetToken: token))
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, 30)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("비밀번호 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isCodeSent)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isVerified)
    }
}

#Preview {
    NavigationStack {
        FindPasswordView(email: "s26043@gsm.hs.kr")
    }
    .environmentObject(AuthRouter())
}
