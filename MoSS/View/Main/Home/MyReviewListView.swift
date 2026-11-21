import SwiftUI

private struct MyReviewEntry: Identifiable {
    let place: Place
    let review: PlaceReview
    let imageName: String

    var id: String { review.id }
}

struct MyReviewListView: View {
    @Binding var submittedReviews: [PlaceReview]
    @Binding var reviewPlaces: [String: Place]
    @Binding var editedReviews: [String: PlaceReview]
    let onBack: () -> Void
    let onSelectReview: (Place, PlaceReview) -> Void

    @State private var isSearching = false
    @State private var searchText = ""

    private var entries: [MyReviewEntry] {
        let places = Place.preview
        let fixtures = [
            MyReviewEntry(
                place: places[0],
                review: sampleReview(id: "my-review-aiming", date: "2026.09.24", rating: "5.0", body: "시험 기간에 방문했는데 조용하고 좌석 간격도 넓어서 집중이 잘 됐어요. 콘센트가 자리마다 있어 편했습니다."),
                imageName: "MyReviewAiming"
            ),
            MyReviewEntry(
                place: places[1],
                review: sampleReview(id: "my-review-study", date: "2026.08.12", rating: "4.0", body: "백색소음이 은은하고 노트북존이 분리되어 있어 좋아요. 늦은 시간에도 안전하게 이용했습니다."),
                imageName: "MyReviewStudy"
            ),
            MyReviewEntry(
                place: places[2],
                review: sampleReview(id: "my-review-start", date: "2026.07.30", rating: "4.5", body: "무료 커피와 프린터가 유용했어요. 창가 자리는 오후에 햇빛이 조금 강합니다."),
                imageName: "MyReviewStart"
            ),
            MyReviewEntry(
                place: Place(id: "my-review-place", name: "아이름찾기귀찮아스터디카페", distance: "1.2km", price: "시간당 ₩2,500", details: "조용한 좌석", imageName: "PlaceAiming", noiseLevel: "매우 조용", address: "광주 북구", rating: "4.8"),
                review: sampleReview(id: "my-review-other", date: "2026.07.30", rating: "4.8", body: "사장님이 매우 귀여우십니다. 고양이인데 털도 많이 안 빠지셔요."),
                imageName: "MyReviewOther"
            )
        ]
        let localEntries = submittedReviews
            .filter(\.isMine)
            .map { review in
                let place = reviewPlaces[review.id] ?? places[0]
                return MyReviewEntry(
                    place: place,
                    review: editedReviews[review.id] ?? review,
                    imageName: thumbnailName(for: place)
                )
            }
        return (localEntries + fixtures)
            .filter { entry in
                searchText.isEmpty || entry.place.name.localizedCaseInsensitiveContains(searchText) || entry.review.body.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if isSearching {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.mossBrandSage)
                    TextField("장소명 또는 리뷰 내용 검색", text: $searchText)
                        .font(.system(size: 13))
                        .submitLabel(.search)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.mossTextMuted)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text("총 \(max(14 + submittedReviews.filter(\.isMine).count, entries.count))개의 리뷰")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if entries.isEmpty {
                        Text("검색 결과가 없어요")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mossTextMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 48)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(entries) { entry in
                                reviewCard(entry)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("마이페이지로 돌아가기")
            Spacer()
            Text("내가 쓴 리뷰")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching.toggle()
                    if !isSearching { searchText = "" }
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 검색")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private func reviewCard(_ entry: MyReviewEntry) -> some View {
        Button {
            onSelectReview(entry.place, editedReviews[entry.review.id] ?? entry.review)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(entry.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.place.name)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                            .lineLimit(1)
                        Text(entry.review.date)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    Spacer(minLength: 4)
                    Label(entry.review.rating, systemImage: "star.fill")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossWarning)
                }
                HStack(spacing: 6) {
                    statusBadge(entry.review.noise, foreground: .mossPrimaryGreen, background: .mossSageTint)
                    statusBadge("재방문 의사 있음", foreground: .mossTextMuted, background: .mossBackground)
                }
                Text(entry.review.body)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func statusBadge(_ title: String, foreground: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background, in: RoundedRectangle(cornerRadius: 6))
    }

    private func sampleReview(id: String, date: String, rating: String, body: String) -> PlaceReview {
        PlaceReview(
            id: id,
            author: "MOSS 사용자",
            date: date,
            rating: rating,
            noise: "매우 조용",
            body: body,
            avatar: "MockProfile",
            ownerReply: nil,
            photoAssets: [],
            helpfulCount: 0,
            isMine: true
        )
    }

    private func thumbnailName(for place: Place) -> String {
        switch place.id {
        case "study": return "MyReviewStudy"
        case "start": return "MyReviewStart"
        case "my-review-place": return "MyReviewOther"
        default: return "MyReviewAiming"
        }
    }
}
