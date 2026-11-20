import SwiftUI

struct FindIDView: View {
    @EnvironmentObject private var router: AuthRouter
    @StateObject private var viewModel = FindIDViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, phone
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                AuthTitleView(
                    title: "가입한 계정을 찾아드릴게요",
                    description: "회원가입 시 등록한 이름과 휴대폰 번호를 입력해 주세요."
                )

                VStack(spacing: 16) {
                    MoSSTextField(
                        label: "이름",
                        placeholder: "이름을 입력해 주세요",
                        text: $viewModel.name,
                        errorMessage: viewModel.nameError,
                        textContentType: .name
                    )
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .phone }
                    .onChange(of: viewModel.name) { viewModel.nameError = nil }

                    MoSSTextField(
                        label: "휴대폰 번호",
                        placeholder: "숫자만 입력해 주세요",
                        text: $viewModel.phoneNumber,
                        errorMessage: viewModel.phoneError,
                        keyboardType: .numberPad,
                        textContentType: .telephoneNumber,
                        helperMessage: "본인 명의로 가입한 번호를 입력해 주세요."
                    )
                    .focused($focusedField, equals: .phone)
                    .onChange(of: viewModel.phoneNumber) { viewModel.phoneError = nil }
                }

                MoSSNoticeCard(
                    systemImage: "checkmark.shield",
                    message: "개인정보 보호를 위해 입력 정보는 계정 확인에만 사용됩니다."
                )

                MoSSButton(
                    title: "아이디 찾기",
                    isEnabled: viewModel.canSubmit,
                    isLoading: viewModel.isLoading,
                    action: findID
                )
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, 30)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("아이디 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
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
    }

    private func findID() {
        focusedField = nil
        Task {
            if let result = await viewModel.findID() {
                router.push(.findIDResult(result))
            }
        }
    }
}

#Preview {
    NavigationStack {
        FindIDView()
    }
    .environmentObject(AuthRouter())
}
