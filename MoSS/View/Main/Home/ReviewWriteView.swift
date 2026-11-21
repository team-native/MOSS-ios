import PhotosUI
import SwiftUI

struct ReviewWriteView: View {
    let place: Place
    let onClose: () -> Void
    let onSubmit: (PlaceReview) -> Void

    @State private var rating = 4
    @State private var selectedNoise = "매우 조용해요"
    @State private var reviewText = "매장이 전반적으로 조용해서 백색소음도 만족스럽습니다!"
    @State private var selectedPhotos: [PhotosPickerItem] = []

    private let noiseOptions = [
        ("매우 조용해요", "집중 전용 스터디존 수준"),
        ("적당히 보통이에요", "백색소음 / 무소음 타이핑"),
        ("조금 소란스러워요", "카페 음악 / 일상적인 대화 가능")
    ]

    private var ratingMessage: String {
        switch rating {
        case 5: return "최고예요!"
        case 4: return "추천해요!"
        case 3: return "보통이에요"
        case 2: return "아쉬워요"
        default: return "별로예요"
        }
    }

    private var canSubmit: Bool {
        rating > 0 && reviewText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    placeIntro
                    ratingPicker
                    noisePicker
                    photoPicker
                    reviewEditor
                    Button {
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "ko_KR")
                        formatter.dateFormat = "yyyy.MM.dd"
                        let review = PlaceReview(
                            id: UUID().uuidString,
                            author: "나",
                            date: formatter.string(from: Date()),
                            rating: String(format: "%.1f", Double(rating)),
                            noise: selectedNoise,
                            body: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                            avatar: "MockProfile",
                            ownerReply: nil,
                            photoAssets: [],
                            helpfulCount: 0,
                            isMine: true
                        )
                        onSubmit(review)
                    } label: {
                        Text("리뷰 등록하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.55)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .accessibilityLabel("리뷰 작성 닫기")
            Spacer()
            Text("리뷰 쓰기")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private var placeIntro: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Text("공부하는 사람들을 위해 조용하고 진솔한 경험을 남겨주세요")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var ratingPicker: some View {
        VStack(spacing: 10) {
            Text("공부 환경은 어떠셨나요?")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossBrandSage)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        rating = value
                    } label: {
                        Image(systemName: "star")
                            .font(.system(size: 31, weight: .regular))
                            .foregroundStyle(value <= rating ? Color.mossWarning : Color.mossLine)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("별점 \(value)점")
                    .accessibilityAddTraits(rating == value ? .isSelected : [])
                }
            }
            Text("\(ratingMessage) (\(rating)점 / 5점)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossWarning)
        }
        .frame(maxWidth: .infinity)
    }

    private var noisePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("소음 정도가 어느 정도였나요?")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            VStack(spacing: 8) {
                ForEach(noiseOptions, id: \.0) { option in
                    let selected = selectedNoise == option.0
                    Button {
                        selectedNoise = option.0
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selected ? "circle.fill" : "circle")
                                .font(.system(size: 12))
                                .foregroundStyle(selected ? Color.mossPrimaryGreen : Color.mossLine)
                            Text("\(option.0) (\(option.1))")
                                .font(.system(size: 13, weight: selected ? .bold : .regular))
                                .foregroundStyle(selected ? Color.mossPrimaryGreen : Color.mossBrandSage)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 2)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.mossPrimaryGreen)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selected ? Color.mossSageSoft : Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }

    private var photoPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사진 첨부 (선택)")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 3, matching: .images) {
                HStack(spacing: 12) {
                    Image(systemName: "camera")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .frame(width: 40, height: 40)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedPhotos.isEmpty ? "사진으로 한 눈에 분위기를 보여주세요" : "사진 \(selectedPhotos.count)장 선택됨")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.mossTextPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("내부 분위기, 좌석 사진 등 (최대 3장)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4])).foregroundStyle(Color.mossLine))
            }
            .buttonStyle(.plain)
        }
    }

    private var reviewEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상세 후기 작성")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossBrandSage)
            TextEditor(text: $reviewText)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(height: 130)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
                .onChange(of: reviewText) { _, newValue in
                    if newValue.count > 500 {
                        reviewText = String(newValue.prefix(500))
                    }
                }
            HStack {
                Text("최소 20자 이상 작성해주세요")
                Spacer()
                Text("\(reviewText.count) / 500")
            }
            .font(.system(size: 11))
            .foregroundStyle(Color.mossTextMuted)
        }
    }
}
