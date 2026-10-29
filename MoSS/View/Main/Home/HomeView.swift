import SwiftUI

// TODO: 메인 이슈에서 지도·목록 화면으로 교체
struct HomeView: View {
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ComingSoonView(title: "메인")

                MoSSButton(
                    title: session.isGuest ? "로그인하러 가기" : "로그아웃",
                    style: .secondary
                ) {
                    Task { await session.logout() }
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, 24)
            }
            .background(Color.mossBackground.ignoresSafeArea())
        }
    }
}
