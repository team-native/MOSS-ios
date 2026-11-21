import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var selectedTab = "홈"
    @State private var searchText = ""
    @State private var selectedPlace: Place?
    @State private var selectedReview: PlaceReview?
    @State private var submittedReviews: [PlaceReview] = []
    @State private var reviewPlaces: [String: Place] = [:]
    @State private var removedReviewIDs: Set<String> = []
    @State private var editedReviews: [String: PlaceReview] = [:]
    @State private var isShowingReviewWrite = false
    @State private var isShowingReviewEdit = false
    @State private var isShowingReviewDeleteConfirmation = false
    @State private var isShowingReviewDeleteRecovery = false
    @State private var isShowingReviewReport = false
    @State private var isShowingInfoErrorReport = false
    @State private var reviewDeletedAt = Date()
    @State private var isShowingLocationPermission = false
    @State private var isShowingReviewList = false
    @State private var isShowingMyReviewList = false
    @State private var isReturningToMyReviewList = false

    private let places = Place.preview

    private var hasVisibleReviews: Bool {
        let placeReviews = submittedReviews.filter { reviewPlaces[$0.id]?.id == selectedPlace?.id }
        return (placeReviews + PlaceReview.preview).contains { !removedReviewIDs.contains($0.id) }
    }

    var body: some View {
        Group {
            if isShowingReviewWrite, let selectedPlace {
                ReviewWriteView(
                    place: selectedPlace,
                    onClose: { isShowingReviewWrite = false },
                    onSubmit: { review in
                        submittedReviews.insert(review, at: 0)
                        reviewPlaces[review.id] = selectedPlace
                        isShowingReviewWrite = false
                        isShowingReviewList = true
                        selectedReview = nil
                    }
                )
            } else if isShowingReviewReport, let selectedReview {
                ReviewReportView(
                    review: selectedReview,
                    onBack: { isShowingReviewReport = false }
                )
            } else if isShowingReviewDeleteRecovery, let selectedReview {
                ReviewDeleteRecoveryView(
                    deletedAt: reviewDeletedAt,
                    onRestore: {
                        removedReviewIDs.remove(selectedReview.id)
                        isShowingReviewDeleteRecovery = false
                        self.selectedReview = nil
                        isShowingReviewList = true
                    },
                    onReviewList: {
                        isShowingReviewDeleteRecovery = false
                        self.selectedReview = nil
                        isShowingReviewList = true
                    }
                )
            } else if isShowingReviewEdit, let selectedReview, let selectedPlace {
                ReviewEditView(
                    place: selectedPlace,
                    review: selectedReview,
                    onBack: { isShowingReviewEdit = false },
                    onSave: { updatedReview in
                        editedReviews[updatedReview.id] = updatedReview
                        self.selectedReview = updatedReview
                        isShowingReviewEdit = false
                    }
                )
            } else if let selectedReview, let selectedPlace {
                ReviewDetailView(
                    place: selectedPlace,
                    review: selectedReview,
                    isShowingDeleteConfirmation: $isShowingReviewDeleteConfirmation,
                    onBack: {
                        self.selectedReview = nil
                        if isReturningToMyReviewList {
                            isReturningToMyReviewList = false
                            isShowingMyReviewList = true
                        }
                    },
                    onEdit: {
                        selectedTab = "마이"
                        isShowingReviewEdit = true
                    },
                    onReport: { isShowingReviewReport = true },
                    onDelete: {
                        removedReviewIDs.insert(selectedReview.id)
                        isShowingReviewDeleteConfirmation = false
                        reviewDeletedAt = Date()
                        isShowingReviewDeleteRecovery = true
                    }
                )
            } else if isShowingReviewList, let selectedPlace {
                ReviewListView(
                    place: selectedPlace,
                    submittedReviews: $submittedReviews,
                    reviewPlaces: $reviewPlaces,
                    removedReviewIDs: $removedReviewIDs,
                    editedReviews: $editedReviews,
                    onBack: {
                        isShowingReviewList = false
                        selectedTab = "홈"
                    },
                    onSelectReview: { selectedReview = $0 },
                    onWriteReview: { isShowingReviewWrite = true }
                )
            } else if isShowingLocationPermission {
                LocationPermissionView(
                    searchText: $searchText,
                    onBack: { isShowingLocationPermission = false },
                    onSearchRegion: {
                        isShowingLocationPermission = false
                        selectedTab = "검색"
                    }
                )
            } else if isShowingInfoErrorReport, let selectedPlace {
                InfoErrorReportView(
                    place: selectedPlace,
                    onBack: { isShowingInfoErrorReport = false }
                )
            } else if isShowingMyReviewList {
                MyReviewListView(
                    submittedReviews: $submittedReviews,
                    reviewPlaces: $reviewPlaces,
                    editedReviews: $editedReviews,
                    onBack: { isShowingMyReviewList = false },
                    onSelectReview: { place, review in
                        isShowingMyReviewList = false
                        isReturningToMyReviewList = true
                        selectedPlace = place
                        selectedReview = review
                        selectedTab = "마이"
                    }
                )
            } else if let selectedPlace {
                PlaceDetailView(
                    place: selectedPlace,
                    onBack: { self.selectedPlace = nil },
                    onShowReviews: { isShowingReviewList = true },
                    onWriteReview: { isShowingReviewWrite = true },
                    onReport: { isShowingInfoErrorReport = true }
                )
            } else if selectedTab == "홈" {
                if session.isGuest {
                    GuestPreviewView(
                        searchText: $searchText,
                        onSearch: { selectedTab = "검색" },
                        onSelectPlace: { selectedPlace = $0 },
                        onLogin: { Task { await session.logout() } }
                    )
                } else {
                    homeContent
                }
            } else if selectedTab == "검색" {
                SearchView(
                    searchText: $searchText,
                    onBack: { selectedTab = "홈" },
                    onPlaceSelected: { selectedPlace = $0 }
                )
            } else if selectedTab == "찜" {
                FavoritesView {
                    selectedTab = "홈"
                }
            } else if selectedTab == "마이" {
                MyPageView(
                    onShowFavorites: { selectedTab = "찜" },
                    onShowMyReviews: { isShowingMyReviewList = true }
                )
            } else {
                ComingSoonView(title: selectedTab)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isShowingReviewDeleteConfirmation && !isShowingInfoErrorReport && !isShowingReviewWrite && (!isShowingReviewList || selectedReview != nil || !hasVisibleReviews) {
                bottomNavigation
            }
        }
    }

    private var homeContent: some View {
        VStack(spacing: 0) {
            mapSection
            nearbySection
        }
    }

    private var mapSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("HomeMap")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    HStack {
                        Text("9:41").font(.system(size: 14, weight: .bold))
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "cellularbars")
                            Image(systemName: "wifi")
                            Image(systemName: "battery.100")
                        }
                        .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.mossTextPrimary)
                    .padding(.horizontal, 24)
                    .frame(height: 60)

                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass").foregroundStyle(Color.mossBrandSage)
                            TextField("내 주변 조용한 공부 스팟 검색", text: $searchText)
                                .font(.system(size: 13))
                                .submitLabel(.search)
                                .onSubmit { selectedTab = "검색" }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .background(Color.mossSurface, in: Capsule())
                        .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 12, y: 5)

                        Button { selectedTab = "검색" } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.mossPrimaryGreen, in: Circle())
                                .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 12, y: 5)
                        }
                        .accessibilityLabel("검색 및 필터")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    Spacer()
                }

                VStack(spacing: 0) {
                    Text("에이밍 스터디카페   ₩2,500/h")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 11))
                        .rotationEffect(.degrees(180))
                        .foregroundStyle(Color.mossPrimaryGreen)
                }
                .position(x: geometry.size.width * 0.52, y: geometry.size.height * 0.38)

                Image(systemName: "location.circle.fill")
                    .font(.system(size: 38))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.mossPrimaryGreen)
                    .position(x: geometry.size.width * 0.45, y: geometry.size.height * 0.62)

                Button { isShowingLocationPermission = true } label: {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 42))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.mossPrimaryGreen, .white)
                }
                .position(x: geometry.size.width - 42, y: geometry.size.height - 42)
                .accessibilityLabel("위치 권한 안내")
            }
        }
        .frame(height: 412)
    }

    private var nearbySection: some View {
        VStack(spacing: 12) {
            Capsule().fill(Color.mossLine).frame(width: 36, height: 4).padding(.top, 10)
            HStack {
                Text("내 주변 명소 (27개)")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("거리순")
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                }
            }
            Label("금호중앙중학교 앞에서 찾는 중", systemImage: "location.north.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 10))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(places) { place in
                        PlaceCard(place: place) { selectedPlace = place }
                    }
                    if session.isGuest {
                        guestPrompt
                    } else {
                        Button {
                            Task { await session.logout() }
                        } label: {
                            Text("로그아웃")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .foregroundStyle(Color.mossPrimaryGreen)
                                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 20)
        .background(Color.mossSurface)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
        .shadow(color: Color.mossTextPrimary.opacity(0.08), radius: 10, y: -4)
    }

    private var guestPrompt: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "heart")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 42, height: 42)
                    .background(Color.mossSageTint, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("마음에 드는 장소를 찜해보세요")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("로그인하면 기기 간에도 목록이 저장돼요.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                }
                Spacer(minLength: 0)
            }
            Button {
                Task { await session.logout() }
            } label: {
                Text("로그인하고 찜·리뷰 이용")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(15)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var bottomNavigation: some View {
        HStack {
            tabItem("홈", icon: "house")
            tabItem("검색", icon: "magnifyingglass")
            tabItem("찜", icon: "heart")
            tabItem("마이", icon: "person")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(Color.mossSurface)
    }

    private func tabItem(_ title: String, icon: String) -> some View {
        Button {
            isShowingReviewEdit = false
            isShowingReviewWrite = false
            isShowingReviewDeleteConfirmation = false
            isShowingReviewDeleteRecovery = false
            isShowingReviewReport = false
            isShowingInfoErrorReport = false
            selectedReview = nil
            isShowingReviewList = false
            isShowingMyReviewList = false
            isReturningToMyReviewList = false
            isShowingLocationPermission = false
            selectedPlace = nil
            selectedTab = title
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 23, weight: selectedTab == title ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == title ? .bold : .medium))
            }
            .foregroundStyle(selectedTab == title ? Color.mossPrimaryGreen : Color.mossTextMuted)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView().environmentObject(SessionManager())
}
