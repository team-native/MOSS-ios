import SwiftUI

enum MerchantEventFilter: String, CaseIterable, Identifiable {
    case ongoing = "진행 중"
    case pending = "승인 대기"
    case ended = "종료"
    var id: String { rawValue }
}

enum MerchantEventStatus: String, Equatable, Identifiable {
    case ongoing = "진행 중"
    case pending = "승인 대기"
    case ended = "종료"
    var id: String { rawValue }
}

struct MerchantEventRecord: Identifiable, Equatable {
    let id: String
    var title: String
    var startDate: Date
    var endDate: Date
    var timeRange: String
    var details: String
    var status: MerchantEventStatus
    var isVisibleInStore = true

    var dateRange: String {
        "\(Self.formatShortDate(startDate))–\(Self.formatShortDate(endDate))"
    }

    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: endDate)
        return max(0, Calendar.current.dateComponents([.day], from: today, to: end).day ?? 0)
    }

    private static func sampleDate(offsetDays: Int) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: offsetDays, to: today) ?? today
    }

    private static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }

    static let sample: [MerchantEventRecord] = [
        .init(id: "night-discount", title: "시험 기간 심야 이용권 20% 할인", startDate: sampleDate(offsetDays: -9), endDate: sampleDate(offsetDays: 4), timeRange: "평일 21:00–24:00", details: "한산한 시간대에 4시간권을 할인해요.", status: .ongoing),
        .init(id: "morning-upgrade", title: "오전 집중석 무료 업그레이드", startDate: sampleDate(offsetDays: -1), endDate: sampleDate(offsetDays: 5), timeRange: "평일 09:00–12:00", details: "운영 정책 검토 중이며 최대 1일이 소요돼요.", status: .pending),
        .init(id: "autumn-snack", title: "가을 맞이 닭발 무료 나눔 이벤트", startDate: sampleDate(offsetDays: -20), endDate: sampleDate(offsetDays: -14), timeRange: "매일 10:00–16:00", details: "총 38명이 이벤트를 확인했어요.", status: .ended)
    ]
}

struct MerchantEventManagementView: View {
    @Binding var events: [MerchantEventRecord]
    @Binding var weeklyEventCount: Int
    @Binding var selectedFilter: MerchantEventFilter
    let onBack: () -> Void
    let onCreate: () -> Void
    let onEdit: (MerchantEventRecord) -> Void

    @State private var isShowingLimitAlert = false

    private var visibleEvents: [MerchantEventRecord] {
        events.filter { $0.status.rawValue == selectedFilter.rawValue }
    }

    private var ongoingCount: Int { events.filter { $0.status == .ongoing }.count }
    private var pendingCount: Int { events.filter { $0.status == .pending }.count }
    private var endedCount: Int { 5 + events.filter { $0.status == .ended }.count }
    private var totalCount: Int { 5 + events.count }
    private var canCreate: Bool { ongoingCount + pendingCount < 3 && weeklyEventCount < 2 }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    capacityNotice
                    summary
                    filters
                    LazyVStack(spacing: 10) {
                        ForEach(visibleEvents) { event in
                            eventCard(event)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    if visibleEvents.isEmpty {
                        ContentUnavailableView("이벤트가 없어요", systemImage: "calendar", description: Text("다른 상태를 선택하거나 새 이벤트를 등록해 주세요."))
                            .padding(.vertical, 22)
                            .transition(.opacity)
                    }
                    createButton
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("이벤트 등록 제한", isPresented: $isShowingLimitAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("진행 이벤트는 동시에 최대 3개, 주간 최대 2회까지 등록할 수 있어요.")
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selectedFilter)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: events)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image("MerchantMenuBack")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("사업자 홈으로 돌아가기")
            Spacer()
            Text("이벤트 관리")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button(action: addEvent) {
                Text("추가")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossBrandSage)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("이벤트 추가")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var capacityNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantEventCalendar")
                .resizable()
                .frame(width: 17, height: 17)
            Text("이벤트는 동시에 최대 3개, 주간 최대 2회 등록할 수 있어요. 이번 주 \(2 - weeklyEventCount)회 남았어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF0F4F1), in: RoundedRectangle(cornerRadius: 12))
        .contentTransition(.numericText())
    }

    private var summary: some View {
        HStack {
            Text("전체 \(totalCount)개")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
                .contentTransition(.numericText())
            Spacer()
            Text("진행 중 \(ongoingCount) / 3")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
        }
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(MerchantEventFilter.allCases) { filter in
                let selected = filter == selectedFilter
                let count = count(for: filter)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedFilter = filter }
                } label: {
                    Text("\(filter.rawValue) \(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(filterForeground(filter, selected: selected))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filterBackground(filter, selected: selected), in: Capsule())
                        .overlay(Capsule().stroke(selected ? filterBackground(filter, selected: true) : Color.mossLine, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
    }

    private func eventCard(_ event: MerchantEventRecord) -> some View {
        Button {
            onEdit(event)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.status.rawValue)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(statusForeground(event.status))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(statusBackground(event.status), in: RoundedRectangle(cornerRadius: 6))
                    Spacer()
                    Text(event.dateRange)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.mossTextMuted)
                }
                Text(event.title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 8) {
                    Image("MerchantEventClock")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text(event.timeRange)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossBrandSage)
                }
                Text(event.details)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("두 번 탭하여 이벤트를 수정합니다")
    }

    private var createButton: some View {
        Button(action: addEvent) {
            HStack(spacing: 8) {
                Image("MerchantEventPlus")
                    .resizable()
                    .frame(width: 17, height: 17)
                Text("새 이벤트 등록")
                    .font(.system(size: 14, weight: .heavy))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
            .opacity(canCreate ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .accessibilityHint(canCreate ? "이벤트 작성 폼 열기" : "이벤트 등록 한도에 도달했어요")
    }

    private func count(for filter: MerchantEventFilter) -> Int {
        switch filter {
        case .ongoing: ongoingCount
        case .pending: pendingCount
        case .ended: endedCount
        }
    }

    private func filterForeground(_ filter: MerchantEventFilter, selected: Bool) -> Color {
        if selected { return .white }
        return filter == .pending ? Color(hex: 0x7A4E1B) : Color.mossBrandSage
    }

    private func filterBackground(_ filter: MerchantEventFilter, selected: Bool) -> Color {
        if selected { return Color.mossBrandSage }
        return filter == .pending ? Color(hex: 0xFFF8ED) : Color.mossSurface
    }

    private func statusForeground(_ status: MerchantEventStatus) -> Color {
        switch status {
        case .ongoing: Color.mossBrandSage
        case .pending: Color(hex: 0x7A4E1B)
        case .ended: Color.mossBrandSage
        }
    }

    private func statusBackground(_ status: MerchantEventStatus) -> Color {
        switch status {
        case .ongoing: Color(hex: 0xE3ECE7)
        case .pending: Color(hex: 0xFFF8ED)
        case .ended: Color(hex: 0xF0ECE8)
        }
    }

    private func addEvent() {
        guard canCreate else { isShowingLimitAlert = true; return }
        onCreate()
    }
}
