import SwiftUI

struct SignUpView: View {
    /// 가입 완료 시 가입한 이메일을 로그인 화면에 전달
    var onCompleted: (String) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email, code, name, phone, password, passwordConfirm
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                roleSelection
                emailSection
                profileSection
                passwordSection

                if viewModel.role == .business {
                    Text("가입 후 매장 등록 단계에서 사업자 확인을 진행해요")
                        .mossFont(.caption, weight: .regular)
                        .foregroundStyle(Color.mossBrandSage)
                }

                MoSSCheckbox(
                    title: "모스의 필수 이용약관 및 개인정보 처리방침에 동의합니다.",
                    isChecked: $viewModel.isTermsAgreed
                )
                .padding(.top, 6)

                MoSSButton(
                    title: "회원 가입 완료",
                    isEnabled: viewModel.canSubmit,
                    isLoading: viewModel.isLoading,
                    action: signUp
                )
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.role)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isCodeSent)
        .alert(
            "알림",
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .alert("회원가입이 완료되었어요", isPresented: .constant(viewModel.isCompleted)) {
            Button("로그인하러 가기") {
                onCompleted(viewModel.trimmedEmail)
                dismiss()
            }
        } message: {
            Text("가입한 이메일로 로그인해 주세요.")
        }
    }

    // MARK: - Sections

    private var roleSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("가입 유형")
                .mossFont(.label)
                .foregroundStyle(Color.mossBrandSage)

            MoSSSegmentedControl(
                options: [UserRole.student, .business],
                selection: $viewModel.role,
                title: { $0 == .student ? "학생 가입" : "업주 가입" }
            )
        }
    }

    private var emailSection: some View {
        VStack(spacing: 20) {
            MoSSTextField(
                label: "이메일 주소",
                placeholder: "이메일 주소를 입력해 주세요",
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                successMessage: viewModel.isEmailVerified ? "이메일 인증이 완료되었어요." : nil,
                isDisabled: viewModel.isEmailVerified,
                trailingActionTitle: viewModel.isEmailVerified ? nil : viewModel.sendCodeTitle,
                isTrailingActionEnabled: viewModel.canSendCode,
                onTrailingAction: {
                    focusedField = nil
                    Task { await viewModel.sendCode() }
                }
            )
            .focused($focusedField, equals: .email)

            if viewModel.isCodeSent && !viewModel.isEmailVerified {
                MoSSTextField(
                    label: "인증번호",
                    placeholder: "인증번호를 입력해 주세요",
                    text: $viewModel.code,
                    errorMessage: viewModel.codeError,
                    keyboardType: .numberPad,
                    textContentType: .oneTimeCode,
                    helperMessage: viewModel.codeHelperMessage,
                    trailingActionTitle: "확인",
                    isTrailingActionEnabled: viewModel.code.count == SignUpViewModel.Policy.codeLength,
                    onTrailingAction: {
                        focusedField = nil
                        Task { await viewModel.verifyCode() }
                    }
                )
                .focused($focusedField, equals: .code)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var profileSection: some View {
        VStack(spacing: 20) {
            MoSSTextField(
                label: "닉네임",
                placeholder: "닉네임을 입력해주세요 (2~8자)",
                text: $viewModel.name,
                errorMessage: viewModel.nameError,
                textContentType: .nickname
            )
            .focused($focusedField, equals: .name)
            .onChange(of: viewModel.name) { viewModel.nameError = nil }

            MoSSTextField(
                label: "휴대폰 번호",
                placeholder: "숫자만 입력해주세요",
                text: $viewModel.phoneNumber,
                errorMessage: viewModel.phoneError,
                keyboardType: .numberPad,
                textContentType: .telephoneNumber
            )
            .focused($focusedField, equals: .phone)
            .onChange(of: viewModel.phoneNumber) { viewModel.phoneError = nil }

            if viewModel.role == .student {
                MoSSDropdown(
                    label: "학년 구분",
                    options: Grade.allCases,
                    selection: $viewModel.grade,
                    title: \.title
                )
                .transition(.opacity)
            }
        }
    }

    private var passwordSection: some View {
        VStack(spacing: 20) {
            MoSSTextField(
                label: "비밀번호",
                placeholder: "6~15자, 영문·숫자·특수문자 포함",
                text: $viewModel.password,
                isSecure: true,
                errorMessage: viewModel.passwordError,
                textContentType: .newPassword,
                helperMessage: viewModel.passwordHelperMessage
            )
            .focused($focusedField, equals: .password)
            .onChange(of: viewModel.password) { viewModel.passwordError = nil }

            MoSSTextField(
                label: "비밀번호 확인",
                placeholder: "비밀번호를 한번 더 입력하세요",
                text: $viewModel.passwordConfirm,
                isSecure: true,
                errorMessage: viewModel.passwordConfirmMessage?.isMatched == false
                    ? viewModel.passwordConfirmMessage?.text : nil,
                textContentType: .newPassword,
                successMessage: viewModel.passwordConfirmMessage?.isMatched == true
                    ? viewModel.passwordConfirmMessage?.text : nil
            )
            .focused($focusedField, equals: .passwordConfirm)
        }
    }

    private func signUp() {
        focusedField = nil
        Task { await viewModel.signUp() }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
