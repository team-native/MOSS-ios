import SwiftUI

struct ReviewEditView: View {
    let place: Place
    let review: PlaceReview
    let onBack: () -> Void
    let onSave: (PlaceReview) -> Void

    @State private var selectedRating: Int
    @State private var selectedNoise: String
    @State private var reviewText: String
    @State private var validationMessage: String?

    private let noiseOptions = ["매우 조용", "보통", "대화 가능"]

    init(place: Place, review: PlaceReview, onBack: @escaping () -> Void, onSave: @escaping (PlaceReview) -> Void) {
        self.place = place
        self.review = review
        self.onBack = onBack
        self.onSave = onSave
        _selectedRating = State(initialValue: Int(Double(review.rating) ?? 5))
        _selectedNoise = State(initialValue: review.noise)
        _reviewText = State(initialValue: review.body)
    }

    private var ratingDescription: String {
        switch selectedRating {
        case 1: return "아쉬워요"
        case 2: return "조금 아쉬워요"
        case 3: return "보통이에요"
        case 4: return "만족해요"
        default: return "아주 만족해요"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    targetPlace
                    ratingCard
                    noiseSelector
                    reviewEditor
                    editNotice
                    Button(action: saveReview) {
                        Text("수정 완료")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("리뷰 수정", isPresented: alertBinding) {
            Button("확인", role: .cancel) { validationMessage = nil }
        } message: {
            Text(validationMessage ?? "")
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
            .accessibilityLabel("리뷰 상세로 돌아가기")
            Spacer()
            Text("리뷰 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button("완료", action: saveReview)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 40, height: 40)
                .disabled(reviewText.trimmingCharacters(in: .whitespacesAndNewlines).count < 20)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var targetPlace: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
            Text("오늘 수정 가능 횟수 1회 중 1회 남음")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)
        }
    }

    private var ratingCard: some View {
        VStack(spacing: 12) {
            Text("별점을 다시 선택해 주세요")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        selectedRating = rating
                    } label: {
                        Image(systemName: selectedRating >= rating ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.mossWarning)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("별점 \(rating)점")
                }
            }
            Text("\(ratingDescription) · \(selectedRating).0")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.mossWarning)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var noiseSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("체감 소음")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            HStack(spacing: 8) {
                ForEach(noiseOptions, id: \.self) { option in
                    Button {
                        selectedNoise = option
                    } label: {
                        Text(option)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selectedNoise == option ? Color.mossSurface : Color.mossBrandSage)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedNoise == option ? Color.mossPrimaryGreen : Color.mossSurface, in: Capsule())
                            .overlay(Capsule().stroke(selectedNoise == option ? Color.mossPrimaryGreen : Color.mossLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var reviewEditor: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("리뷰 내용 *")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mossSurface)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(reviewText.count < 20 ? Color.mossError : Color.mossLine, lineWidth: 1)
                if reviewText.isEmpty {
                    Text("장소 이용 경험을 작성해 주세요.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossTextMuted)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                }
                TextEditor(text: $reviewText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 8)
                    .onChange(of: reviewText) { _, newValue in
                        if newValue.count > 500 {
                            reviewText = String(newValue.prefix(500))
                        }
                    }
            }
            .frame(height: 128)
            Text("최소 20자 이상 작성해 주세요. \(reviewText.count) / 500")
                .font(.system(size: 10))
                .foregroundStyle(reviewText.count < 20 ? Color.mossError : Color.mossTextMuted)
        }
    }

    private var editNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x7A4E1B))
            Text("리뷰는 하루에 한 번만 수정할 수 있어요. 수정 완료 후 내일까지 다시 변경할 수 없어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 12))
    }

    private func saveReview() {
        let trimmedText = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.count >= 20 else {
            validationMessage = "리뷰 내용을 20자 이상 작성해 주세요."
            return
        }
        let updatedReview = PlaceReview(
            id: review.id,
            author: review.author,
            date: review.date,
            rating: "\(selectedRating).0",
            noise: selectedNoise,
            body: trimmedText,
            avatar: review.avatar,
            ownerReply: review.ownerReply,
            photoAssets: review.photoAssets,
            helpfulCount: review.helpfulCount,
            isMine: review.isMine
        )
        onSave(updatedReview)
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { validationMessage != nil },
            set: { if !$0 { validationMessage = nil } }
        )
    }
}
