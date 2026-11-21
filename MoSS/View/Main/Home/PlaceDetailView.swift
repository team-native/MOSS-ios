import SwiftUI

struct PlaceDetailView: View {
    let place: Place
    let onBack: () -> Void

    @State private var isFavorite = false
    @State private var alertMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroCover
                details
                    .background(Color.mossSurface, in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
                    .padding(.top, -24)
            }
            .padding(.bottom, 20)
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .alert("알림", isPresented: alertBinding) {
            Button("확인", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var heroCover: some View {
        ZStack(alignment: .top) {
            Image("PlaceDetailHero")
                .resizable()
                .scaledToFill()
                .frame(height: 244)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(Color.mossTextPrimary.opacity(0.12))
                .accessibilityLabel("장소 대표 이미지")

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.mossTextPrimary.opacity(0.45), in: Circle())
                }
                .accessibilityLabel("뒤로가기")
                Spacer()
                ShareLink(item: "\(place.name) · \(place.address)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.mossTextPrimary.opacity(0.45), in: Circle())
                }
                .accessibilityLabel("장소 공유")
            }
            .padding(.horizontal, 20)
            .padding(.top, 58)
        }
        .frame(height: 244)
        .clipped()
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    Text(place.name)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.mossTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Text(place.noiseLevel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.mossDeepGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
                }
                Text(place.address)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(1)
            }

            quickStats
            amenitiesSection
            eventSection
            actionButtons
            reviewsPreview
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 18)
    }

    private var quickStats: some View {
        HStack(spacing: 0) {
            stat(title: "시간당 요금", value: "₩\(place.hourlyPrice.formatted())")
            stat(title: "학교와의 거리", value: "도보 3분", valueColor: .mossPrimaryGreen)
            stat(title: "운영 시간", value: "09:00~23:00")
            stat(title: "평균 별점", value: "★ \(place.rating)", valueColor: .mossWarning)
        }
        .padding(.vertical, 11)
        .background(Color.mossBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func stat(title: String, value: String, valueColor: Color = .mossTextPrimary) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(Color.mossTextMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
    }

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("구비 시설")
            ViewThatFits(in: .horizontal) {
                amenityChips(["무료 기가 와이파이", "개인 콘센트 완비", "소음 억제 백색소음기"])
                amenityChips(["와이파이", "콘센트", "백색소음기"])
            }
        }
    }

    private func amenityChips(_ titles: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 7)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    private var eventSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionTitle("진행 중인 이벤트 / 공지")
            HStack(spacing: 10) {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.mossWarning)
                VStack(alignment: .leading, spacing: 3) {
                    Text("기말고사 응원 학생 10% 추가 할인")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7A4E1B))
                    Text("학생증 제시 시 라멘 무료 증정 (~12/20)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: 0x9E6E34))
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Color(hex: 0xFFF9F0), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button {
                alertMessage = "리뷰 작성은 준비 중이에요."
            } label: {
                Label("리뷰 작성", systemImage: "pencil")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
            }
            Button {
                isFavorite.toggle()
            } label: {
                Label(isFavorite ? "찜됨" : "찜 2.4k", systemImage: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isFavorite ? Color.mossError : Color.mossTextPrimary)
                    .frame(height: 44)
                    .padding(.horizontal, 10)
            }
            .accessibilityLabel(isFavorite ? "찜 해제" : "장소 찜하기")
            Button {
                alertMessage = "신고 사유를 선택하는 화면은 준비 중이에요."
            } label: {
                Image(systemName: "flag")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.mossTextMuted)
                    .frame(width: 36, height: 44)
            }
            .accessibilityLabel("장소 신고")
        }
    }

    private var reviewsPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionTitle("최근 리뷰 (127개)")
                Spacer()
                Button("전체 보기") {
                    alertMessage = "리뷰 목록은 다음 퍼블리싱 단계에서 연결할게요."
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossPrimaryGreen)
            }
            reviewCard(name: "제초 5급 노리는 햄스터", rating: "4.8", body: "시끄러운 토끼도 없고 조용해서 너무 좋아요!! 귀여운 사자가 가끔 라멘도 줘서 행복하게 공부가 잘 됩니당")
            reviewCard(name: "세상에서 젤 귀여운 다람쥐", rating: "3.5", body: "방문한 것에 비해 조금 초라하고 아쉬웠지만, 조용해서 좋은 곳이에요.")
        }
    }

    private func reviewCard(name: String, rating: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                Spacer()
                Label(rating, systemImage: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossWarning)
            }
            Text(body)
                .font(.system(size: 11))
                .foregroundStyle(Color.mossBrandSage)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .heavy))
            .foregroundStyle(Color.mossTextPrimary)
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }
}
