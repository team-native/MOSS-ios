import SwiftUI

struct MerchantReviewRecord: Identifiable, Equatable {
    let id: String
    let author: String
    let date: String
    let rating: String
    let body: String
    let hasPhoto: Bool
    let reply: String?

    static let preview: [MerchantReviewRecord] = [
        MerchantReviewRecord(
            id: "merchant-review-1",
            author: "공부하는 만쥬",
            date: "2026.10.02",
            rating: "5.0",
            body: "매장이 너무 조용해서 좋습니다. 푸드존에선 술이랑 안주도 먹으면서 공부를 할 수 있어서 졸릴 때 자주 애용합니다. 여기서 술 자격증 땄습니다. 항상 감사합니다 사장님^^",
            hasPhoto: true,
            reply: nil
        ),
        MerchantReviewRecord(
            id: "merchant-review-2",
            author: "도토리 클럽 DJ",
            date: "2026.10.01",
            rating: "4.0",
            body: "우-라? 야하... 쁘릿!! 우라라라라-!! 푸하! 쁘릿쁘릿! 하아? 쁘릿... 우라! 야하하하-!!! 쁘-릿!! 하아? 우라라라-!!",
            hasPhoto: false,
            reply: nil
        ),
        MerchantReviewRecord(
            id: "merchant-review-3",
            author: "문이 없어서 항상 불안한 고양이",
            date: "2026.09.29",
            rating: "4.5",
            body: "저희 집보다 여기 스카가 더 좋은 것 같아요. 항상 잘 이용합니다. 싸서 좋아요 ㅎㅎ",
            hasPhoto: true,
            reply: "방문해 주셔서 감사합니다. 편안하게 공부하실 수 있도록 계속 노력하겠습니다."
        )
    ]
}

struct MerchantReviewManagementView: View {
    let onSelectReview: (MerchantReviewRecord) -> Void
    let replyDrafts: [String: String]

    init(replyDrafts: [String: String] = [:], onSelectReview: @escaping (MerchantReviewRecord) -> Void) {
        self.replyDrafts = replyDrafts
        self.onSelectReview = onSelectReview
    }

    @State private var selectedFilter = "미답변"
    @State private var sortOrder = "최신순"
    @State private var isShowingSearch = false

    private var filteredReviews: [MerchantReviewRecord] {
        let reviews: [MerchantReviewRecord]
        switch selectedFilter {
        case "미답변": reviews = MerchantReviewRecord.preview.filter { effectiveReply(for: $0) == nil }
        case "답변완료": reviews = MerchantReviewRecord.preview.filter { effectiveReply(for: $0) != nil }
        default: reviews = MerchantReviewRecord.preview
        }
        switch sortOrder {
        case "오래된순": return reviews.sorted { $0.date < $1.date }
        case "별점 높은순": return reviews.sorted { (Double($0.rating) ?? 0) > (Double($1.rating) ?? 0) }
        case "별점 낮은순": return reviews.sorted { (Double($0.rating) ?? 0) < (Double($1.rating) ?? 0) }
        default: return reviews.sorted { $0.date > $1.date }
        }
    }

    private func effectiveReply(for review: MerchantReviewRecord) -> String? {
        guard let savedReply = replyDrafts[review.id] else { return review.reply }
        return savedReply.isEmpty ? nil : savedReply
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    summary
                    filters
                    LazyVStack(spacing: 10) {
                        ForEach(filteredReviews) { review in
                            reviewCard(review)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("리뷰 검색", isPresented: $isShowingSearch) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("리뷰 검색은 서버 연동 후 제공됩니다.")
        }
    }

    private var header: some View {
        HStack {
            Color.clear.frame(width: 40, height: 40)
            Spacer()
            Text("리뷰 관리")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button { isShowingSearch = true } label: {
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

    private var summary: some View {
        HStack {
            Text("전체 127개")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Menu {
                ForEach(["최신순", "오래된순", "별점 높은순", "별점 낮은순"], id: \.self) { option in
                    Button(option) { sortOrder = option }
                }
            } label: {
                Label(sortOrder, systemImage: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
        }
    }

    private var filters: some View {
        HStack(spacing: 4) {
            filterButton("전체 127")
            filterButton("미답변 3")
            filterButton("답변완료 124")
        }
        .padding(4)
        .background(Color(hex: 0xEFECE6), in: RoundedRectangle(cornerRadius: 12))
    }

    private func filterButton(_ title: String) -> some View {
        let label = String(title.split(separator: " ").first ?? "")
        let isSelected = selectedFilter == label
        return Button {
            selectedFilter = label
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? Color.mossDarkAction : .clear, in: RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func reviewCard(_ review: MerchantReviewRecord) -> some View {
        Button {
            onSelectReview(MerchantReviewRecord(
                id: review.id,
                author: review.author,
                date: review.date,
                rating: review.rating,
                body: review.body,
                hasPhoto: review.hasPhoto,
                reply: effectiveReply(for: review)
            ))
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(review.author)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                            .lineLimit(1)
                        Text(review.date)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    Spacer()
                    Label(review.rating, systemImage: "star")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossWarning)
                }

                HStack(spacing: 10) {
                    Text(review.body)
                        .font(.system(size: review.hasPhoto ? 13 : 12))
                        .foregroundStyle(Color.mossBrandSage)
                        .lineSpacing(3)
                        .lineLimit(review.hasPhoto ? 4 : 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if review.hasPhoto {
                        Image("MerchantReviewPhoto")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                HStack {
                    Text(effectiveReply(for: review) == nil ? "미답변" : "답변 완료")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(effectiveReply(for: review) == nil ? Color(hex: 0x7A4E1B) : Color.mossPrimaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(effectiveReply(for: review) == nil ? Color(hex: 0xFFF8ED) : Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    Text(effectiveReply(for: review) == nil ? "답변하기" : "답변 보기")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossPrimaryGreen)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(review.author), 별점 \(review.rating), \(review.reply == nil ? "미답변" : "답변 완료")")
    }
}
