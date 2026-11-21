import SwiftUI

struct Place: Identifiable {
    let id: String
    let name: String
    let distance: String
    let price: String
    let details: String
    let imageName: String
    let noiseLevel: String
    let address: String
    let rating: String

    var distanceInMeters: Int {
        Int(distance.filter(\.isNumber)) ?? .max
    }

    var hourlyPrice: Int {
        Int(price.filter(\.isNumber)) ?? .max
    }

    static let preview = [
        Place(id: "aiming", name: "에이밍 스터디카페", distance: "150m", price: "시간당 ₩2,500", details: "와이파이 · 콘센트 · 대형 테이블", imageName: "PlaceAiming", noiseLevel: "매우 조용", address: "광주 북구 비엔날레로 87", rating: "4.8"),
        Place(id: "study", name: "공부인스터디카페", distance: "340m", price: "시간당 ₩2,500", details: "개인 독서실 · 주차 가능 · 사물함", imageName: "PlaceStudy", noiseLevel: "매우 조용", address: "광주 북구 설죽로 202", rating: "4.8"),
        Place(id: "start", name: "시작스터디카페", distance: "480m", price: "시간당 ₩2,000", details: "노트북 가능 · 통화룸 · 프린터", imageName: "PlaceStudy", noiseLevel: "조용함", address: "광주 북구 동림동 1150-1", rating: "4.8"),
        Place(id: "unam", name: "운암 집중라운지", distance: "610m", price: "시간당 ₩3,000", details: "24시간 · 와이파이 · 음료 제공", imageName: "PlaceAiming", noiseLevel: "보통", address: "광주 북구 운암동", rating: "4.7")
    ]
}

struct PlaceCard: View {
    let place: Place
    var showsFavorite = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { cardContent }
                    .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        HStack(spacing: 12) {
            Image(place.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    if showsFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.mossError)
                            .padding(5)
                            .background(Color.mossSurface, in: Circle())
                            .offset(x: 5, y: -5)
                    }
                }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(place.name)
                        .font(.system(size: 14, weight: .heavy))
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(place.distance)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.mossPrimaryGreen)
                }
                HStack(spacing: 6) {
                    Text(place.noiseLevel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
                    Text(place.price)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossBrandSage)
                }
                Text(place.details)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mossTextMuted)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
