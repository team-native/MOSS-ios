import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var session: SessionManager
    let onShowFavorites: () -> Void
    let onShowMyReviews: () -> Void
    let onShowReportHistory: () -> Void
    let onAccountDeletionComplete: () -> Void
    let onShowProfileEdit: () -> Void

    @State private var alertMessage: String?
    @State private var isShowingAccountDeletionConfirmation = false
    @State private var isShowingLogoutConfirmation = false

    private var reviewCount: String { session.isGuest ? "0" : "14" }
    private var reportCount: String { session.isGuest ? "0" : "5" }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("마이페이지")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.mossTextPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                profileCard
                    .padding(.horizontal, 24)

                statsBanner
                    .padding(.horizontal, 24)

                activitySection
                    .padding(.horizontal, 24)

                accountSection
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .overlay {
            if isShowingAccountDeletionConfirmation {
                accountDeletionConfirmation
                    .transition(.opacity)
            } else if isShowingLogoutConfirmation {
                logoutConfirmation
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isShowingAccountDeletionConfirmation)
        .animation(.easeInOut(duration: 0.15), value: isShowingLogoutConfirmation)
        .alert("안내", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("확인", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            Image("MockProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .accessibilityLabel("프로필 이미지")

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(session.isGuest ? "비회원" : "MOSS 사용자")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(session.isGuest ? "게스트" : "회원")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 6))
                }
                Text(session.isGuest ? "로그인 후 활동을 확인할 수 있어요" : "로그인한 계정 정보")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var statsBanner: some View {
        HStack(spacing: 0) {
            statItem(value: reviewCount, title: "작성한 리뷰", color: .mossPrimaryGreen)
            Rectangle()
                .fill(Color.mossLine)
                .frame(width: 1, height: 20)
            statItem(value: reportCount, title: "내 스팟 제보", color: .mossDarkAction)
        }
        .padding(12)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("활동 내역")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)

            VStack(spacing: 1) {
                activityRow("bubble.left", title: "내가 쓴 리뷰 목록", action: onShowMyReviews)
                activityRow("heart", title: "내 찜 목록 확인", action: onShowFavorites)
                activityRow("mappin.and.ellipse", title: "내 스터디 스팟 제보 및 오류 제보 내역", action: onShowReportHistory)
            }
            .background(Color.mossLine, in: RoundedRectangle(cornerRadius: 14))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var logoutConfirmation: some View {
        ZStack {
            Color.mossTextPrimary.opacity(0.6)
                .contentShape(Rectangle())
                .onTapGesture { isShowingLogoutConfirmation = false }

            VStack(spacing: 18) {
                Image("LogoutConfirmationIcon")
                    .frame(width: 24, height: 24)
                    .frame(width: 52, height: 52)
                    .background(Color.mossSageSoft, in: Circle())

                VStack(spacing: 8) {
                    Text("로그아웃할까요?")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("이 기기에서 로그아웃됩니다.\n저장한 찜과 리뷰는 계정에 그대로 보관돼요.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossBrandSage)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: 8) {
                    Button {
                        isShowingLogoutConfirmation = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        isShowingLogoutConfirmation = false
                        session.logoutLocally()
                    } label: {
                        Text("로그아웃")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 330)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 16, y: 6)
            .padding(.horizontal, 24)
        }
    }

    private var accountDeletionConfirmation: some View {
        ZStack {
            Color.mossTextPrimary.opacity(0.6)
                .contentShape(Rectangle())
                .onTapGesture { isShowingAccountDeletionConfirmation = false }

            VStack(spacing: 18) {
                Image("AccountDeletionIcon")
                    .frame(width: 24, height: 24)
                    .frame(width: 52, height: 52)
                    .background(Color(hex: 0xFBECE9), in: Circle())

                VStack(spacing: 8) {
                    Text("정말 탈퇴하시겠어요?")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("찜한 장소, 작성한 리뷰와 제보 내역이\n모두 삭제되며 30일 이후에는 복구할 수 없어요.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossBrandSage)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: 8) {
                    Button {
                        isShowingAccountDeletionConfirmation = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        isShowingAccountDeletionConfirmation = false
                        onAccountDeletionComplete()
                    } label: {
                        Text("탈퇴하기")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossError, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 330)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 16, y: 6)
            .padding(.horizontal, 24)
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("계정 관리")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)

            VStack(alignment: .leading, spacing: 12) {
                Button {
                    if session.isGuest {
                        alertMessage = "로그인 화면은 앱 인증 흐름에서 열 수 있습니다."
                    } else {
                        isShowingLogoutConfirmation = true
                    }
                } label: {
                    Text(session.isGuest ? "로그인하기" : "로그아웃")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mossBrandSage)
                }
                Button(action: onShowProfileEdit) {
                    Text("회원정보 수정")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mossBrandSage)
                }
                Button { isShowingAccountDeletionConfirmation = true } label: {
                    Text("회원탈퇴 (계정 삭제)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mossError)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
        }
    }

    private func statItem(value: String, title: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color.mossBrandSage)
        }
        .frame(maxWidth: .infinity)
    }

    private func activityRow(_ icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.mossBrandSage)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.mossTextMuted)
            }
            .padding(16)
            .background(Color.mossSurface)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
