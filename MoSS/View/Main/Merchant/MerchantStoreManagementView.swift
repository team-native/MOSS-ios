import SwiftUI

enum MerchantStoreDestination: String, Identifiable {
    case basicInfo = "기본 정보"
    case operationInfo = "운영 정보"
    case menu = "메뉴·상품"
    case photos = "사진 관리"
    case settings = "매장 설정"

    var id: String { rawValue }
}

struct MerchantStoreManagementView: View {
    let onSelectDestination: (MerchantStoreDestination) -> Void

    @State private var isPublic = true
    @State private var isShowingVisibilityNotice = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    identityCard
                    visibilityCard
                    managementMenu
                    permissionNotice
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("매장 공개 상태", isPresented: $isShowingVisibilityNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(isPublic ? "미리보기에서 공개 상태로 표시합니다. 실제 고객 앱의 노출은 서버 연동 후 변경됩니다." : "미리보기에서 비공개 상태로 표시합니다. 실제 노출은 서버 연동 후 변경됩니다.")
        }
        .sensoryFeedback(.selection, trigger: isPublic)
    }

    private var header: some View {
        HStack {
            Color.clear.frame(width: 40, height: 40)
            Spacer()
            Text("매장 관리")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button { onSelectDestination(.settings) } label: {
                Image("MerchantStoreSettings")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("매장 설정")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("대표 업주 권한")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossSageTint)
                    Text("에이밍 스터디카페")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Image("MerchantStoreIcon")
                    .resizable()
                    .frame(width: 23, height: 23)
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
            }
            HStack(spacing: 8) {
                statusPill(icon: "MerchantStoreBadgeCheck", title: "사업자 인증 완료")
                statusPill(icon: "MerchantStoreEye", title: isPublic ? "공개 중" : "비공개")
            }
            .animation(.easeInOut(duration: 0.2), value: isPublic)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statusPill(icon: String, title: String) -> some View {
        HStack(spacing: 7) {
            Image(icon)
                .resizable()
                .frame(width: 16, height: 16)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: title == "사업자 인증 완료" ? .infinity : nil, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }

    private var visibilityCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("매장 공개 상태")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Text(isPublic ? "고객 앱에 정상 노출되고 있어요" : "고객 앱에 노출되지 않아요")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
                    .contentTransition(.opacity)
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                    isPublic.toggle()
                }
                isShowingVisibilityNotice = true
            } label: {
                Capsule()
                    .fill(isPublic ? Color.mossPrimaryGreen : Color.mossLine)
                    .frame(width: 44, height: 26)
                    .overlay(alignment: isPublic ? .trailing : .leading) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .padding(3)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.72), value: isPublic)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("매장 공개 상태")
            .accessibilityValue(isPublic ? "공개" : "비공개")
            .accessibilityAddTraits(.isButton)
        }
        .padding(13)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
    }

    private var managementMenu: some View {
        VStack(spacing: 0) {
            menuRow(
                title: "기본 정보",
                subtitle: "매장명, 주소, 연락처, 소개",
                icon: "MerchantStoreFilePen",
                destination: .basicInfo
            )
            menuRow(
                title: "운영 정보",
                subtitle: "영업시간, 휴무일, 가격대, 편의시설",
                icon: "MerchantStoreClock",
                destination: .operationInfo
            )
            menuRow(
                title: "메뉴·상품",
                subtitle: "가격, 노출, 품절 상태 관리",
                icon: "MerchantStoreUtensils",
                badge: "12개",
                destination: .menu
            )
            menuRow(
                title: "사진 관리",
                subtitle: "대표 및 매장 사진 8장",
                icon: "MerchantStoreImages",
                badge: "8장",
                destination: .photos,
                showsDivider: false
            )
        }
        .padding(.horizontal, 14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func menuRow(
        title: String,
        subtitle: String,
        icon: String,
        badge: String? = nil,
        destination: MerchantStoreDestination,
        showsDivider: Bool = true
    ) -> some View {
        Button { onSelectDestination(destination) } label: {
            HStack(spacing: 12) {
                Image(icon)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .frame(width: 38, height: 38)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                if let badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                } else {
                    Image("MerchantStoreChevron")
                        .resizable()
                        .frame(width: 17, height: 17)
                }
            }
            .padding(.vertical, 13)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                if showsDivider { Color.mossLine.frame(height: 1).padding(.leading, 50) }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("두 번 탭하여 \(title) 관리 화면 열기")
    }

    private var permissionNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantStoreShieldCheck")
                .resizable()
                .frame(width: 18, height: 18)
            Text("대표 업주는 매장 정보를 수정하고 관리자를 초대할 수 있어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }
}
