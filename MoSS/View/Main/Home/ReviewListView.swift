import SwiftUI

private struct PlaceReview: Identifiable {
    let id: String
    let author: String
    let date: String
    let rating: String
    let noise: String
    let body: String
    let avatar: String
    let ownerReply: String?

    static let preview = [
        PlaceReview(
            id: "study-lover",
            author: "공부하는 만쥬",
            date: "2026.01.24",
            rating: "5.0",
            noise: "매우 조용",
            body: "매장이 너무 조용해서 좋습니다. 푸드존에선 술이랑 안주도 먹으면서 공부를 할 수 있어서 졸릴 때 자주 애용합니다. 여기서 술 자격증 땄습니다. 항상 감사합니다 사장님^^",
            avatar: "ReviewAvatarOne",
            ownerReply: "방문해 주셔서 감사합니다! 앞으로도 이용하시기 더 좋은 환경으로 만들어 나가겠습니다. 자주 이용해 주세요!"
        ),
        PlaceReview(
            id: "dotoriclub",
            author: "도토리 클럽 DJ",
            date: "2026.01.21",
            rating: "4.0",
            noise: "매우 조용",
            body: "야하—!! 야하하!! 우라라라라!! 뿌룹—! 와하!! 얌얌얌!! 우라! 얌얌!! 우라라라!! 야하—!!",
            avatar: "ReviewAvatarTwo",
            ownerReply: nil
        ),
        PlaceReview(
            id: "quiet-study",
            author: "조용한 공부러",
            date: "2026.01.18",
            rating: "4.5",
            noise: "조용함",
            body: "좌석 간격이 넓고 집중하기 좋아요. 콘센트가 가까워 노트북 사용하기 편했습니다.",
            avatar: "MockProfile",
            ownerReply: nil
        )
    ]
}

struct ReviewListView: View {
    let place: Place
    let onBack: () -> Void

    @State private var sortOrder = "최신순"
    @State private var isShowingWriteNotice = false

    private var reviews: [PlaceReview] {
        switch sortOrder {
        case "별점 높은순":
            return PlaceReview.preview.sorted { (Double($0.rating) ?? 0) > (Double($1.rating) ?? 0) }
        case "별점 낮은순":
            return PlaceReview.preview.sorted { (Double($0.rating) ?? 0) < (Double($1.rating) ?? 0) }
        default:
            return PlaceReview.preview
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    summaryPanel
                    sortBar
                    LazyVStack(spacing: 12) {
                        ForEach(reviews) { review in
                            reviewCard(review)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 88)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            Button {
                isShowingWriteNotice = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.mossTextPrimary.opacity(0.19), radius: 8, y: 5)
            }
            .accessibilityLabel("리뷰 작성")
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .alert("리뷰 작성", isPresented: $isShowingWriteNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("리뷰 작성 화면은 다음 퍼블리싱 단계에서 연결할게요.")
        }
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("장소 상세로 돌아가기")
            Spacer()
            Text("\(place.name) 리뷰")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var summaryPanel: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(place.rating)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.mossTextPrimary)
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossWarning)
                    }
                }
                Text("총 127개의 리뷰")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossTextMuted)
            }
            .frame(width: 100)

            Rectangle()
                .fill(Color.mossLine)
                .frame(width: 1, height: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text("체감 소음 분포")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
                noiseRow(title: "조용함", percentage: 82)
                noiseRow(title: "보통", percentage: 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func noiseRow(title: String, percentage: Int) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
                .frame(width: 38, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.mossLine)
                    Capsule()
                        .fill(Color.mossPrimaryGreen)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                }
            }
            .frame(height: 6)
            Text("\(percentage)%")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.mossBrandSage)
                .frame(width: 28, alignment: .trailing)
        }
    }

    private var sortBar: some View {
        HStack {
            Text("리뷰 목록")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Menu {
                ForEach(["최신순", "별점 높은순", "별점 낮은순"], id: \.self) { option in
                    Button(option) { sortOrder = option }
                }
            } label: {
                Label(sortOrder, systemImage: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
        }
        .padding(.top, 8)
    }

    private func reviewCard(_ review: PlaceReview) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Image(review.avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(review.author)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.mossTextPrimary)
                        Text(review.date)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                }
                Spacer()
                Label(review.rating, systemImage: "star.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .labelStyle(.titleAndIcon)
                    .tint(Color.mossWarning)
            }

            Text(review.noise)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.mossDeepGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))

            Text(review.body)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if let ownerReply = review.ownerReply {
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(place.name) 업주", systemImage: "arrow.turn.down.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.mossPrimaryGreen)
                    Text(ownerReply)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.mossBrandSage)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
