import SwiftUI

enum ReportCategory: String, CaseIterable, Identifiable {
    case spot = "스터디 스팟"
    case information = "정보 오류"

    var id: String { rawValue }
}

struct ReportRecord: Identifiable {
    let id: String
    let category: ReportCategory
    let title: String
    let summary: String
    let submittedAt: String
    let status: String
    var isLocalPreview = false

    static let preview: [ReportRecord] = [
        ReportRecord(
            id: "report-price",
            category: .information,
            title: "에이밍 스터디카페 · 가격",
            summary: "시간당 이용 요금이 2,500원에서 3,000원으로 변경됐어요.",
            submittedAt: "2026.10.01 접수",
            status: "검토 중"
        ),
        ReportRecord(
            id: "report-library-floor",
            category: .spot,
            title: "운암도서관 층수 오류",
            summary: "조용한 열람실과 콘센트 좌석이 있어요.",
            submittedAt: "2026.09.27 접수",
            status: "반영 완료"
        ),
        ReportRecord(
            id: "report-hours",
            category: .information,
            title: "공부인스터디카페 · 운영시간",
            summary: "주말 마감 시간이 22시로 변경되었어요.",
            submittedAt: "2026.09.20 접수",
            status: "접수"
        ),
        ReportRecord(
            id: "report-civic-cafe",
            category: .spot,
            title: "광주 시민공원 북카페",
            summary: "상업시설 기준에 맞지 않아 반영되지 않았어요.",
            submittedAt: "2026.09.12 접수",
            status: "미반영"
        ),
        ReportRecord(
            id: "report-wifi",
            category: .information,
            title: "시작스터디카페 · 와이파이",
            summary: "무료 와이파이 이용이 가능해요.",
            submittedAt: "2026.09.08 접수",
            status: "검토 중"
        )
    ]
}

struct ReportHistoryView: View {
    @Binding var reports: [ReportRecord]
    let onBack: () -> Void
    let onSelectReport: (ReportRecord) -> Void

    @State private var selectedCategory: ReportCategory?

    private var filteredReports: [ReportRecord] {
        guard let selectedCategory else { return reports }
        return reports.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    categoryFilter
                    HStack {
                        Text("내 제보 \(reports.count)건")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                        Spacer()
                        Text("최신순")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                    }
                    LazyVStack(spacing: 10) {
                        ForEach(filteredReports) { report in
                            reportCard(report)
                        }
                    }
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
            .accessibilityLabel("마이페이지로 돌아가기")
            Spacer()
            Text("제보 내역")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var categoryFilter: some View {
        HStack(spacing: 4) {
            filterButton(title: "전체 \(reports.count)", category: nil)
            filterButton(title: "스팟 \(reports.filter { $0.category == .spot }.count)", category: .spot)
            filterButton(title: "정보 오류 \(reports.filter { $0.category == .information }.count)", category: .information)
        }
        .padding(4)
        .background(Color(hex: 0xEFECE6), in: RoundedRectangle(cornerRadius: 12))
    }

    private func filterButton(title: String, category: ReportCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            selectedCategory = category
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.mossPrimaryGreen)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func reportCard(_ report: ReportRecord) -> some View {
        Button {
            onSelectReport(report)
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    statusBadge(report.category.rawValue, background: Color(hex: 0xF0ECE8), foreground: Color.mossBrandSage)
                    Spacer()
                    statusBadge(report.isLocalPreview ? "미리보기" : report.status, background: statusBackground(report.status), foreground: statusForeground(report.status))
                }
                Text(report.title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(report.summary)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(report.submittedAt)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mossTextMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(report.category.rawValue), \(report.title), \(report.status)")
    }

    private func statusBadge(_ title: String, background: Color, foreground: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(background, in: RoundedRectangle(cornerRadius: 6))
    }

    private func statusBackground(_ status: String) -> Color {
        switch status {
        case "로컬 미리보기": Color(hex: 0xFFF8ED)
        case "검토 중": Color(hex: 0xFFF8ED)
        case "반영 완료": Color(hex: 0xE3ECE7)
        default: Color(hex: 0xF0ECE8)
        }
    }

    private func statusForeground(_ status: String) -> Color {
        switch status {
        case "로컬 미리보기": Color(hex: 0x7A4E1B)
        case "검토 중": Color(hex: 0x7A4E1B)
        case "반영 완료": Color.mossPrimaryGreen
        default: Color.mossBrandSage
        }
    }
}
