import SwiftUI

struct InfoErrorReportResultView: View {
    let report: ReportRecord
    let onViewStatus: () -> Void
    let onReturnToPlace: () -> Void

    private var placeName: String {
        report.title.components(separatedBy: " · ").first ?? report.title
    }

    private var reportItem: String {
        report.title.components(separatedBy: " · ").dropFirst().first ?? "장소 정보"
    }

    private var submittedDate: String {
        report.submittedAt.replacingOccurrences(of: " 접수", with: "")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    successMessage
                    reportSummary
                    localPreviewNotice
                    Button(action: onViewStatus) {
                        Text("제보 처리 현황 보기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("로컬 미리보기 상세 보기")
                    Button(action: onReturnToPlace) {
                        Text("장소 상세로 돌아가기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.mossLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("장소 상세로 돌아가기")
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onReturnToPlace) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("장소 상세로 돌아가기")
            Spacer()
            Text("제보 접수 완료")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var successMessage: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.mossPrimaryGreen, lineWidth: 1.8)
                    .frame(width: 26, height: 26)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
            .frame(width: 64, height: 64)
            .background(Color(hex: 0xE3ECE7), in: Circle())
            .symbolEffect(.bounce, value: report.id)

            Text("정보 오류 제보를 접수했어요")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .multilineTextAlignment(.center)
            Text("입력한 내용은 이 화면에서만 확인하는 로컬 미리보기예요.\n실제 접수·정보 반영·알림은 서버 연결 후 제공됩니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 28)
    }

    private var reportSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text(placeName)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(reportItem)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: 0xF0ECE8), in: RoundedRectangle(cornerRadius: 6))
            }
            Text("로컬 번호 \(report.displayNumber) · \(submittedDate)")
                .font(.system(size: 10))
                .foregroundStyle(Color.mossTextMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var localPreviewNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: 0x7A4E1B))
            Text("사진은 전송되지 않았고 중복 제보 확인이나 처리 현황 조회도 하지 않았어요. 이 항목은 앱 안의 로컬 미리보기입니다.")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 12))
    }
}

extension ReportRecord {
    var displayNumber: String {
        if id == "report-price" { return "I-2601048" }
        if id.hasPrefix("report-local-") { return "LOCAL-\(id.suffix(6).uppercased())" }
        return "R-\(id.replacingOccurrences(of: "report-", with: "").uppercased())"
    }
}
