import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var router = AuthRouter()
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 0) {
                    MoSSLogo()
                        .padding(.top, 70)
                        .padding(.bottom, 40)

                    form
                        .padding(.horizontal, Layout.screenPadding)

                    links
                        .padding(.top, 24)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.mossBackground.ignoresSafeArea())
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    SignUpView()
                case .findID:
                    FindIDView()
                case .findIDResult(let result):
                    FindIDResultView(result: result)
                case .findPassword(let email):
                    FindPasswordView(email: email)
                case .resetPassword(let resetToken):
                    ResetPasswordView(resetToken: resetToken)
                }
            }
            .onChange(of: router.prefilledEmail) {
                // 회원가입·계정 찾기를 마치고 돌아오면 이메일을 채워 둔다
                guard let email = router.prefilledEmail else { return }
                viewModel.email = email
                viewModel.password = ""
                router.prefilledEmail = nil
            }
            .alert(
                "로그인에 실패했습니다",
                isPresented: Binding(
                    get: { viewModel.alertMessage != nil },
                    set: { if !$0 { viewModel.alertMessage = nil } }
                )
            ) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
        .environmentObject(router)
    }

    private var form: some View {
        VStack(spacing: 16) {
            MoSSTextField(
                label: "이메일",
                placeholder: "s26043@gsm.hs.kr",
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                textContentType: .username
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }
            .onChange(of: viewModel.email) { viewModel.clearEmailError() }

            MoSSTextField(
                label: "비밀번호",
                placeholder: "비밀번호를 입력하세요",
                text: $viewModel.password,
                isSecure: true,
                errorMessage: viewModel.passwordError,
                textContentType: .password
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit(login)
            .onChange(of: viewModel.password) { viewModel.clearPasswordError() }

            MoSSButton(
                title: "로그인",
                isEnabled: viewModel.canSubmit,
                isLoading: viewModel.isLoading,
                action: login
            )

            MoSSButton(title: "비회원으로 둘러보기", style: .secondary) {
                session.continueAsGuest()
            }
        }
    }

    private var links: some View {
        HStack(spacing: 12) {
            NavigationLink("이메일 회원가입", value: AuthRoute.signUp)

            Rectangle()
                .fill(Color.mossLine)
                .frame(width: 1, height: 12)

            NavigationLink("아이디 찾기", value: AuthRoute.findID)
        }
        .mossFont(.label, weight: .semiBold)
        .foregroundStyle(Color.mossBrandSage)
    }

    private func login() {
        focusedField = nil
        Task {
            if let user = await viewModel.login() {
                session.didLogin(user)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
