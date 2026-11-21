import SwiftUI

struct ReviewEmptyView: View {
    let place: Place
    let onBack: () -> Void
    let onWriteReview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    placeSummary
                    emptyState
                    encouragement
                    Button(action: onWriteReview) {
                        Label("첫 리뷰 작성하기", systemImage: "plus")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
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

    private var placeSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.mossTextPrimary)
                Text(place.address)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
            }
            Spacer(minLength: 6)
            Text(place.noiseLevel)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 64, height: 64)
                    .background(Color.mossSageTint, in: Circle())
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .padding(4)
                    .background(Color.mossSageTint, in: Circle())
                    .offset(x: 3, y: 3)
            }
            Text("아직 작성된 리뷰가 없어요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .multilineTextAlignment(.center)
            Text("이 장소를 먼저 경험하셨나요? 첫 리뷰로 다른 사람의 공부 공간 선택을 도와주세요.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.top, 30)
        .padding(.bottom, 16)
    }

    private var encouragement: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("첫 리뷰를 기다리고 있어요")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Text("별점, 체감 소음, 좌석과 편의시설 경험을 솔직하게 알려주세요. 사진을 함께 올리면 더 도움이 돼요.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 16))
    }
}
