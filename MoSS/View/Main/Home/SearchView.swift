import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    let onBack: () -> Void
    let onPlaceSelected: (Place) -> Void

    @State private var isShowingFilters = false
    @State private var noiseLevel = "조용함"
    @State private var distance = "500m 내외"
    @State private var maxPrice = 4_000.0
    @State private var selectedAmenities: Set<String> = ["와이파이"]
    @State private var recentSearches = ["에이밍 스터디 카페", "운암 도서관", "노트북 가능 카페", "조용한 스터디룸"]
    @State private var sortOrder = "거리순"

    private let noiseOptions = ["조용함", "보통", "대화 가능"]
    private let distanceOptions = ["200m 내외", "500m 내외", "1km 이상"]
    private let amenities = ["콘센트 많음", "와이파이", "외부음식 취사 가능", "스터디룸 보유", "노트북 타이핑 가능", "통화 전용룸"]

    private var filteredPlaces: [Place] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let matches = Place.preview.filter { place in
            let matchesQuery = query.isEmpty || place.name.localizedCaseInsensitiveContains(query) || place.details.localizedCaseInsensitiveContains(query) || place.address.localizedCaseInsensitiveContains(query)
            let matchesNoise = noiseLevel != "조용함" || place.noiseLevel != "보통"
            let matchesDistance = distanceValue.map { (Int(place.distance.replacingOccurrences(of: "m", with: "")) ?? .max) <= $0 } ?? true
            let price = Int(place.price.filter(\.isNumber)) ?? .max
            let matchesPrice = price <= Int(maxPrice)
            let matchesAmenities = selectedAmenities.allSatisfy { place.details.contains($0.replacingOccurrences(of: " 많음", with: "")) }
            return matchesQuery && matchesNoise && matchesDistance && matchesPrice && matchesAmenities
        }
        switch sortOrder {
        case "가격 낮은순":
            return matches.sorted { (Int($0.price.filter(\.isNumber)) ?? .max) < (Int($1.price.filter(\.isNumber)) ?? .max) }
        case "조용한순":
            return matches.sorted { $0.noiseLevel == "매우 조용" && $1.noiseLevel != "매우 조용" }
        default:
            return matches.sorted { (Int($0.distance.replacingOccurrences(of: "m", with: "")) ?? .max) < (Int($1.distance.replacingOccurrences(of: "m", with: "")) ?? .max) }
        }
    }

    private var distanceValue: Int? {
        switch distance {
        case "200m 내외": return 200
        case "500m 내외": return 500
        default: return nil
        }
    }

    var body: some View {
        Group {
            if isShowingFilters {
                filterScreen
            } else {
                resultsScreen
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var resultsScreen: some View {
        VStack(spacing: 0) {
            screenHeader(title: "검색 결과", showsBack: true, backAction: onBack)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    searchBar(placeholder: "장소를 검색해 보세요", allowsClear: true)
                    appliedFilters

                    if filteredPlaces.isEmpty {
                        searchEmptyState
                    } else {
                        HStack {
                            Text("필터 적용 결과 \(filteredPlaces.count)개")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(Color.mossTextPrimary)
                            Spacer()
                            Menu {
                                ForEach(["거리순", "조용한순", "가격 낮은순"], id: \.self) { option in
                                    Button(option) { sortOrder = option }
                                }
                            } label: {
                                Label(sortOrder, systemImage: "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .labelStyle(.titleAndIcon)
                                    .foregroundStyle(Color.mossPrimaryGreen)
                            }
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(filteredPlaces) { place in
                                PlaceCard(place: place) { onPlaceSelected(place) }
                            }
                        }
                        advertisementCard
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
    }

    private var searchEmptyState: some View {
        VStack(spacing: 14) {
            VStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 27, weight: .medium))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 64, height: 64)
                    .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 32))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .padding(3)
                            .background(Color.mossSageTint, in: Circle())
                    }

                Text("조건에 맞는 장소가 없어요")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.mossTextPrimary)
                    .multilineTextAlignment(.center)

                Text("거리나 가격 조건을 조금 넓히면 더 많은 공부 스팟을 찾을 수 있어요.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossBrandSage)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22)
            .padding(.top, 28)
            .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 10) {
                Text("이렇게 검색해 보세요")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("· 거리를 500m 이상으로 넓히기")
                    Text("· 무료 조건을 해제하기")
                    Text("· 통화 전용 공간이 있는 장소 찾기")
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 10) {
                Button(action: resetFilters) {
                    Text("조건 초기화")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    resetFilters()
                    searchText = ""
                    onBack()
                } label: {
                    Text("주변 장소 보기")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.mossSurface)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var filterScreen: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { isShowingFilters = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mossTextPrimary)
                        .frame(width: 24, height: 44)
                }
                .accessibilityLabel("검색 결과로 돌아가기")
                searchBar(placeholder: "검색어 입력", allowsClear: false)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("최근 검색어")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading)], alignment: .leading, spacing: 8) {
                            ForEach(recentSearches, id: \.self) { item in
                                Button {
                                    searchText = item
                                    isShowingFilters = false
                                } label: {
                                    HStack(spacing: 5) {
                                        Text(item).lineLimit(1)
                                        Image(systemName: "xmark.circle")
                                    }
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.mossBrandSage)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.mossSurface, in: Capsule())
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("검색어 삭제", systemImage: "trash") { recentSearches.removeAll { $0 == item } }
                                }
                            }
                        }
                    }

                    Divider().overlay(Color.mossLine)
                    optionGroup("소음 단계", options: noiseOptions, selection: $noiseLevel)
                    optionGroup("거리", options: distanceOptions, selection: $distance)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("시간당 가격")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(Color.mossTextPrimary)
                            Spacer()
                            Text("₩0 ~ ₩\(Int(maxPrice).formatted())")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.mossPrimaryGreen)
                        }
                        Slider(value: $maxPrice, in: 500...20_000, step: 500)
                            .tint(Color.mossPrimaryGreen)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("편의시설")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                        LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], alignment: .leading, spacing: 12) {
                            ForEach(amenities, id: \.self) { amenity in
                                Button {
                                    if selectedAmenities.contains(amenity) { selectedAmenities.remove(amenity) }
                                    else { selectedAmenities.insert(amenity) }
                                } label: {
                                    Label(amenity, systemImage: selectedAmenities.contains(amenity) ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 12))
                                        .foregroundStyle(selectedAmenities.contains(amenity) ? Color.mossTextPrimary : Color.mossBrandSage)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { filterActions }
    }

    private var appliedFilters: some View {
        HStack(spacing: 7) {
            Button { isShowingFilters = true } label: { filterChip(noiseLevel, isSelected: true) }
            Button { isShowingFilters = true } label: {
                filterChip(distance == "200m 내외" ? "200m 이내" : distance == "500m 내외" ? "500m 이내" : "1km 이상", isSelected: true)
            }
            Button { isShowingFilters = true } label: { filterChip("₩\(Int(maxPrice).formatted()) 이하", isSelected: false) }
            if !selectedAmenities.isEmpty {
                Button { isShowingFilters = true } label: { filterChip(selectedAmenities.sorted().first ?? "와이파이", isSelected: false) }
            }
        }
        .lineLimit(1)
        .buttonStyle(.plain)
    }

    private var filterActions: some View {
        HStack(spacing: 12) {
            Button(action: resetFilters) {
                Text("초기화")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 100, height: 50)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
            }
            Button { isShowingFilters = false } label: {
                Text("필터 적용하기")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.mossSurface)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.mossSurface)
    }

    private var advertisementCard: some View {
        VStack(spacing: 4) {
            HStack {
                Text("광고 AD").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text("MOSS").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.mossPrimaryGreen)
            }
            Text("나에게 맞는 스터디카페").font(.system(size: 14, weight: .medium)).foregroundStyle(Color.mossPrimaryGreen)
            Text("› 지금 당장 알아보기").font(.system(size: 12)).foregroundStyle(Color.mossBrandSage)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 8))
    }

    private func screenHeader(title: String, showsBack: Bool, backAction: @escaping () -> Void) -> some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .opacity(showsBack ? 1 : 0)
            .disabled(!showsBack)
            Spacer()
            Text(title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private func searchBar(placeholder: String, allowsClear: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(Color.mossBrandSage)
            TextField(placeholder, text: $searchText)
                .font(.system(size: 13))
                .submitLabel(.search)
            if allowsClear && !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.mossTextMuted)
                }
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 44)
        .background(Color.mossSurface, in: Capsule())
    }

    private func filterChip(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isSelected ? Color.mossSurface : Color.mossBrandSage)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.mossPrimaryGreen : Color.mossSurface, in: Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.mossPrimaryGreen : Color.mossLine, lineWidth: 1))
    }

    private func optionGroup(_ title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button { selection.wrappedValue = option } label: {
                        Text(option)
                            .font(.system(size: 12, weight: selection.wrappedValue == option ? .bold : .medium))
                            .foregroundStyle(selection.wrappedValue == option ? Color.mossPrimaryGreen : Color.mossBrandSage)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(selection.wrappedValue == option ? Color.mossSageSoft : Color.mossSurface, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func resetFilters() {
        noiseLevel = noiseOptions[0]
        distance = distanceOptions[0]
        maxPrice = 20_000
        selectedAmenities.removeAll()
    }
}
