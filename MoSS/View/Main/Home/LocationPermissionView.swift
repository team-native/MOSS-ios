import SwiftUI
import UIKit

struct LocationPermissionView: View {
    @Binding var searchText: String
    let onBack: () -> Void
    let onSearchRegion: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    permissionEmptyState
                    permissionCard
                    regionalSearch
                    notice
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
            .accessibilityLabel("뒤로가기")
            Spacer()
            Text("내 주변 장소")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var permissionEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "location.slash")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(Color.mossPrimaryGreen)
                .frame(width: 64, height: 64)
                .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 32))

            Text("위치 권한이 꺼져 있어요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .multilineTextAlignment(.center)

            Text("현재 위치 주변의 공부 스팟을 보려면 기기 설정에서 위치 접근을 허용해 주세요.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.top, 30)
        .padding(.bottom, 14)
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text("위치 접근 권한")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text("거부됨")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.mossError)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 6))
            }

            Text("설정 › MoSS › 위치 › 앱을 사용하는 동안")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)

            Button {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            } label: {
                Label("기기 설정으로 이동", systemImage: "gearshape.fill")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var regionalSearch: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("지역으로 대신 검색")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.mossBrandSage)
                TextField("지역 또는 학교 이름", text: $searchText)
                    .font(.system(size: 13))
                    .submitLabel(.search)
                    .onSubmit(onSearchRegion)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    .accessibilityLabel("지역 검색어 지우기")
                }
            }
            .padding(.horizontal, 15)
            .frame(height: 44)
            .background(Color.mossSurface, in: Capsule())

            ViewThatFits(in: .horizontal) {
                regionChips(compact: false)
                regionChips(compact: true)
            }
        }
    }

    private func regionChips(compact: Bool) -> some View {
        HStack(spacing: 7) {
            regionChip(compact ? "운암동" : "최근 지역 · 운암동", query: "운암동")
            regionChip("학교 주변", query: "비엔날레로")
            regionChip("지도에서 선택", query: "")
        }
    }

    private func regionChip(_ title: String, query: String) -> some View {
        Button {
            searchText = query
            onSearchRegion()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
                .lineLimit(1)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Color.mossSurface, in: Capsule())
                .overlay(Capsule().stroke(Color.mossLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var notice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossPrimaryGreen)
            Text("지역 검색은 실시간 위치를 사용하지 않으며, 언제든 권한을 다시 허용할 수 있어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }
}
