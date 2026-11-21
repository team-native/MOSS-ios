import SwiftUI

struct FavoritesView: View {
    @Binding var savedPlaceIDs: Set<String>
    @Binding var sortOrder: String
    let onExplore: () -> Void
    let onSelectPlace: (Place) -> Void

    private var savedPlaces: [Place] {
        let places = Place.preview.filter { savedPlaceIDs.contains($0.id) }
        switch sortOrder {
        case "이름순":
            return places.sorted { $0.name < $1.name }
        case "가격 낮은순":
            return places.sorted { $0.hourlyPrice < $1.hourlyPrice }
        default:
            return places.sorted { $0.distanceInMeters < $1.distanceInMeters }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if savedPlaces.isEmpty {
                emptyState
            } else {
                savedPlaceList
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("찜 목록")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Text("\(savedPlaces.count)곳")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossPrimaryGreen)
        }
        .padding(.horizontal, 24)
        .frame(height: 64)
    }

    private var savedPlaceList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack(alignment: .center) {
                    Text("저장한 장소를 가까운 순서로 보여드려요.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossBrandSage)
                    Spacer(minLength: 4)
                    Menu {
                        ForEach(["거리순", "이름순", "가격 낮은순"], id: \.self) { option in
                            Button(option) { sortOrder = option }
                        }
                    } label: {
                        Label(sortOrder, systemImage: "chevron.down")
                            .font(.system(size: 13, weight: .bold))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.mossPrimaryGreen)
                    }
                }

                LazyVStack(spacing: 12) {
                    ForEach(savedPlaces) { place in
                        SavedPlaceCard(
                            place: place,
                            onSelect: { onSelectPlace(place) },
                            onRemove: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    _ = savedPlaceIDs.remove(place.id)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 92, height: 92)
                .background(Color.mossSageSoft, in: Circle())

            VStack(spacing: 8) {
                Text("아직 찜한 장소가 없어요")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Text("마음에 드는 공부 명소를 발견하면 하트를 눌러 이곳에 모아보세요.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossBrandSage)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button(action: onExplore) {
                Label("주변 장소 둘러보기", systemImage: "map")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.mossSurface)
                    .frame(width: 210, height: 52)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SavedPlaceCard: View {
    let place: Place
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: onSelect) {
                HStack(alignment: .top, spacing: 12) {
                    Image(place.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(place.name)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                            .lineLimit(1)

                        Text(place.address)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossBrandSage)
                            .lineLimit(1)

                        HStack(spacing: 7) {
                            Text(place.noiseLevel)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.mossPrimaryGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
                            Text(place.distance)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.mossPrimaryGreen)
                            Label(place.rating, systemImage: "star.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.mossWarning)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                        Text(place.details)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossTextMuted)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(place.name), \(place.address), \(place.noiseLevel), 상세 보기")

            Button(action: onRemove) {
                Image(systemName: "heart")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Color.mossWarning)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("찜 해제: \(place.name)")
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
