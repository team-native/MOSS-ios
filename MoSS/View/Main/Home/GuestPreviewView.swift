import SwiftUI

struct GuestPreviewView: View {
    @Binding var searchText: String
    let onSearch: () -> Void
    let onSelectPlace: (Place) -> Void
    let onLogin: () -> Void

    @State private var sortOrder = "거리순"

    private var recommendedPlaces: [Place] {
        let places = Array(Place.preview.prefix(2))
        switch sortOrder {
        case "가격 낮은순":
            return places.sorted { $0.hourlyPrice < $1.hourlyPrice }
        case "이름순":
            return places.sorted { $0.name < $1.name }
        default:
            return places.sorted { $0.distanceInMeters < $1.distanceInMeters }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    guestNotice
                    searchBar
                    recommendationsHeader
                    LazyVStack(spacing: 10) {
                        ForEach(recommendedPlaces) { place in
                            PlaceCard(place: place) { onSelectPlace(place) }
                        }
                    }
                    loginPrompt
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onLogin) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("로그인 화면으로 돌아가기")
            Spacer()
            Text("주변 공부 스팟")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button("로그인", action: onLogin)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var guestNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "eye")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossPrimaryGreen)
            Text("비회원 둘러보기 중이에요. 간단한 조회는 가능하지만 찜과 리뷰 작성은 로그인 후 이용할 수 있어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.mossBrandSage)
            TextField("내 주변 조용한 공부 스팟", text: $searchText)
                .font(.system(size: 13))
                .submitLabel(.search)
                .onSubmit(onSearch)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.mossTextMuted)
                }
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 44)
        .background(Color.mossSurface, in: Capsule())
    }

    private var recommendationsHeader: some View {
        HStack(spacing: 8) {
            Text("추천 장소")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer(minLength: 0)
            Text("나에게 맞는 스터디카페  ›  지금 당장 알아보기")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(Color.mossBrandSage)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(Color(hex: 0xDDE9E1), in: RoundedRectangle(cornerRadius: 6))
            Menu {
                ForEach(["거리순", "이름순", "가격 낮은순"], id: \.self) { option in
                    Button(option) { sortOrder = option }
                }
            } label: {
                Label(sortOrder, systemImage: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
        }
    }

    private var loginPrompt: some View {
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
            Button(action: onLogin) {
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
}
