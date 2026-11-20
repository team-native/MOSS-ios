import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject private var router: AuthRouter
    @StateObject private var viewModel: ResetPasswordViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case password, confirm
    }

    init(resetToken: String) {
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(resetToken: resetToken))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                AuthTitleView(
                    title: "새 비밀번호를 입력해 주세요",
                    description: "특수문자를 포함하여 6~15자 이내로 입력해 주세요."
                )

                VStack(spacing: 16) {
                    MoSSTextField(
                        label: "새 비밀번호",
                        placeholder: "새 비밀번호를 입력해 주세요",
                        text: $viewModel.password,
                        isSecure: true,
                        errorMessage: viewModel.passwordError,
                        textContentType: .newPassword,
                        helperMessage: "영문, 숫자, 특수문자를 포함해 6자~15자 입력해 주세요."
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .confirm }
                    .onChange(of: viewModel.password) { viewModel.passwordError = nil }

                    MoSSTextField(
                        label: "새 비밀번호 확인",
                        placeholder: "비밀번호를 한번 더 입력하세요",
                        text: $viewModel.passwordConfirm,
                        isSecure: true,
                        errorMessage: viewModel.confirmMessage?.isMatched == false
                            ? viewModel.confirmMessage?.text : nil,
                        textContentType: .newPassword,
                        successMessage: viewModel.confirmMessage?.isMatched == true
                            ? viewModel.confirmMessage?.text : nil
                    )
                    .focused($focusedField, equals: .confirm)
                }

                conditionList

                MoSSButton(
                    title: "비밀번호 변경하기",
                    isEnabled: viewModel.canSubmit,
                    isLoading: viewModel.isLoading
                ) {
                    focusedField = nil
                    Task { await viewModel.resetPassword() }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, 30)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("새 비밀번호 설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
        .alert(
            "알림",
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) {
                // 재설정 토큰이 만료되면 이메일 인증 화면으로 돌아감
                if viewModel.isTokenExpired, !router.path.isEmpty {
                    router.path.removeLast()
                }
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .alert("비밀번호가 변경되었어요", isPresented: .constant(viewModel.isCompleted)) {
            Button("로그인하러 가기") {
                router.popToLogin()
            }
        } message: {
            Text("새 비밀번호로 로그인해 주세요.")
        }
    }

    private var conditionList: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(viewModel.conditions) { condition in
                HStack(spacing: 8) {
                    Image(systemName: condition.isSatisfied ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 15))
                        .foregroundStyle(condition.isSatisfied ? Color.mossPrimaryGreen : Color.mossLine)

                    Text(condition.title)
                        .font(.moss(.regular, size: 12))
                        .foregroundStyle(condition.isSatisfied ? Color.mossBrandSage : Color.mossTextMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.mossSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(resetToken: "token")
    }
    .environmentObject(AuthRouter())
}
