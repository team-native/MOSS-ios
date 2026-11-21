import SwiftUI

struct ReportDetailView: View {
    let report: ReportRecord
    let onBack: () -> Void

    private var placeName: String {
        report.title.components(separatedBy: " · ").first ?? report.title
    }

    private var reportItem: String {
        report.title.components(separatedBy: " · ").dropFirst().first ?? "장소 정보"
    }

    private var reportNumber: String { report.displayNumber }

    private var submittedDate: String {
        report.submittedAt.replacingOccurrences(of: " 접수", with: "").replacingOccurrences(of: "2026.", with: "")
    }

    private var activeStepCount: Int {
        if report.isLocalPreview { return 0 }
        switch report.status {
        case "접수": return 1
        case "검토 중": return 2
        default: return 3
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    reportSummary
                    statusTimeline
                    resultCard
                    privacyNotice
                    Button(action: onBack) {
                        Text("제보 내역으로 돌아가기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("제보 내역으로 돌아가기")
            Spacer()
            Text("제보 상세")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var reportSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                badge(report.category.rawValue, background: Color(hex: 0xF0ECE8), foreground: Color.mossBrandSage)
                Spacer()
                badge(report.isLocalPreview ? "미리보기" : report.status, background: statusBackground, foreground: statusForeground)
            }
            Text(placeName)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
            Text("오류 항목 · \(reportItem)  |  제보 번호 \(reportNumber)")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossTextMuted)
            Text(report.id == "report-price"
                 ? "현장 가격표에는 시간당 3,000원으로 안내되어 있어요. 앱의 2,500원 정보를 수정해 주세요."
                 : report.summary)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statusTimeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("처리 상태")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            if report.isLocalPreview {
                timelineStep(index: 0, title: "로컬 미리보기", detail: "이 내용은 서버에 제출되지 않았으며 실제 검토나 처리는 진행되지 않았어요.", date: submittedDate, icon: "eye")
            } else {
                timelineStep(index: 0, title: "접수", detail: "제보 내용을 안전하게 접수했어요.", date: submittedDate, icon: "checkmark")
                timelineStep(index: 1, title: "검토", detail: "매장 안내와 제출 사진을 확인하고 있어요.", date: "10.02", icon: "magnifyingglass")
                timelineStep(index: 2, title: "반영", detail: "확인된 정보를 장소 상세에 반영해요.", date: "예정", icon: "circle")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func timelineStep(index: Int, title: String, detail: String, date: String, icon: String) -> some View {
        let isComplete = index < activeStepCount
        return HStack(spacing: 12) {
            Image(systemName: isComplete ? icon : "circle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isComplete ? Color.white : Color.mossTextMuted)
                .frame(width: 32, height: 32)
                .background(isComplete ? Color.mossPrimaryGreen : Color(hex: 0xF0ECE8), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(isComplete ? Color.mossPrimaryGreen : Color.mossTextMuted)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossBrandSage)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            Text(index == 0 ? date : (isComplete ? date : "예정"))
                .font(.system(size: 10))
                .foregroundStyle(Color.mossTextMuted)
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("처리 결과")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
            Text(resultMessage)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossTextPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF0F4F1), in: RoundedRectangle(cornerRadius: 16))
    }

    private var privacyNotice: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mossPrimaryGreen)
            Text(report.isLocalPreview ? "현재는 화면 확인용 로컬 데이터예요. 실제 접수·중복 확인·결과 알림은 서버 연결 후 제공됩니다." : "허위 제보가 아닌 이상 제보자에게 불이익은 없으며, 매장에는 제보자의 정보가 공개되지 않아요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossPrimaryGreen)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF0F4F1), in: RoundedRectangle(cornerRadius: 12))
    }

    private var resultMessage: String {
        if report.isLocalPreview { return "제보 양식을 앱 화면에서 확인할 수 있도록 임시 저장했어요. 실제 접수·검토·정보 반영은 이루어지지 않았습니다." }
        switch report.status {
        case "검토 중": return "매장 확인을 요청했어요.\n반영이 완료되면 알림으로 알려드릴게요."
        case "반영 완료": return "제보 내용이 확인되어 장소 정보에 반영되었어요."
        case "미반영": return "제보 내용을 검토했지만 반영 기준에 맞지 않았어요."
        default: return "제보가 접수되었어요. 확인이 끝나면 알림으로 알려드릴게요."
        }
    }

    private var statusBackground: Color {
        if report.isLocalPreview { return Color(hex: 0xFFF8ED) }
        switch report.status {
        case "검토 중": return Color(hex: 0xFFF8ED)
        case "반영 완료": return Color(hex: 0xE3ECE7)
        default: return Color(hex: 0xF0ECE8)
        }
    }

    private var statusForeground: Color {
        if report.isLocalPreview { return Color(hex: 0x7A4E1B) }
        switch report.status {
        case "검토 중": return Color(hex: 0x7A4E1B)
        case "반영 완료": return Color.mossPrimaryGreen
        default: return Color.mossBrandSage
        }
    }

    private func badge(_ title: String, background: Color, foreground: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(background, in: RoundedRectangle(cornerRadius: 6))
    }
}
