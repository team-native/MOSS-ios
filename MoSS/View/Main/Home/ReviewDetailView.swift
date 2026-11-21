import SwiftUI

struct ReviewDetailView: View {
    let place: Place
    let review: PlaceReview
    @Binding var isShowingDeleteConfirmation: Bool
    let onBack: () -> Void
    let onEdit: () -> Void
    let onReport: () -> Void
    let onDelete: () -> Void

    @State private var isHelpful = false

    private var ratingDescription: String {
        guard let rating = Double(review.rating) else { return "리뷰" }
        if rating >= 4.5 { return "아주 만족해요" }
        if rating >= 3.5 { return "만족해요" }
        return "보통이에요"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    placeSummary
                    reviewContent
                    if review.isMine {
                        ownerActions
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .overlay {
            if isShowingDeleteConfirmation {
                deleteConfirmation
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isShowingDeleteConfirmation)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 목록으로 돌아가기")
            Spacer()
            Text("리뷰 상세")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Menu {
                Button("신고하기", systemImage: "flag", action: onReport)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("리뷰 더 보기")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var placeSummary: some View {
        HStack(spacing: 12) {
            Image(place.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 5) {
                Text(place.name)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                Text(place.address)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(1)
                Text(review.noise)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var reviewContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.mossWarning)
                        }
                    }
                    Text("\(ratingDescription) · \(review.rating)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.mossWarning)
                }
                Spacer()
                Text(review.date)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
            }

            Text(review.body)
                .font(.system(size: 14))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if !review.photoAssets.isEmpty {
                HStack(spacing: 8) {
                    ForEach(review.photoAssets, id: \.self) { assetName in
                        Image(assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 116)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            Button {
                isHelpful.toggle()
            } label: {
                Label("\(review.helpfulCount + (isHelpful ? 1 : 0))명에게 도움이 되었어요", systemImage: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 11))
                    .foregroundStyle(isHelpful ? Color.mossPrimaryGreen : Color.mossBrandSage)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var ownerActions: some View {
        HStack(spacing: 10) {
            Button(action: onEdit) {
                Text("수정하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 14))
            }
            Button {
                isShowingDeleteConfirmation = true
            } label: {
                Text("삭제하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.mossError, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var deleteConfirmation: some View {
        ZStack {
            Color.mossTextPrimary.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isShowingDeleteConfirmation = false }

            VStack(spacing: 18) {
                Image(systemName: "trash")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.mossError)
                    .frame(width: 52, height: 52)
                    .background(Color(hex: 0xFBECE9), in: Circle())

                VStack(spacing: 8) {
                    Text("리뷰를 삭제할까요?")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.mossTextPrimary)
                    Text("삭제한 리뷰는 다시 복구할 수 없어요.\n이 리뷰의 사진과 도움 기록도 함께 삭제됩니다.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossBrandSage)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: 8) {
                    Button {
                        isShowingDeleteConfirmation = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button(action: onDelete) {
                        Text("삭제하기")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.mossError, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 330)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 16, y: 6)
            .padding(.horizontal, 24)
        }
    }

}
