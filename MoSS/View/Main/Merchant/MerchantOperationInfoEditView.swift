import SwiftUI

struct MerchantOperationInfoDraft: Equatable {
    var weekdayOpen: Date
    var weekdayClose: Date
    var weekendOpen: Date
    var weekendClose: Date
    var closedDays: Set<Int>
    var minimumHourlyPrice: Int
    var maximumHourlyPrice: Int
    var facilities: Set<String>

    static let sample = MerchantOperationInfoDraft(
        weekdayOpen: time(hour: 9),
        weekdayClose: time(hour: 23),
        weekendOpen: time(hour: 10),
        weekendClose: time(hour: 22),
        closedDays: [],
        minimumHourlyPrice: 2_500,
        maximumHourlyPrice: 4_000,
        facilities: ["무료 와이파이", "개인 콘센트", "프린터", "사물함", "음료 제공"]
    )

    private static func time(hour: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: 0)) ?? Date()
    }
}

struct MerchantOperationInfoEditView: View {
    private enum Editor: String, Identifiable {
        case weekdayHours
        case weekendHours
        case daysOff
        case priceRange
        var id: String { rawValue }
    }

    private let facilities = ["무료 와이파이", "개인 콘센트", "프린터", "사물함", "주차 가능", "음료 제공"]
    private let weekdays = [(1, "월"), (2, "화"), (3, "수"), (4, "목"), (5, "금"), (6, "토"), (7, "일")]

    @Binding private var draft: MerchantOperationInfoDraft
    let onBack: () -> Void

    @State private var activeEditor: Editor?
    @State private var validationMessage: String?
    @State private var isShowingSuccess = false
    @State private var savePulse = 0

    init(draft: Binding<MerchantOperationInfoDraft>, onBack: @escaping () -> Void) {
        _draft = draft
        self.onBack = onBack
    }

    private var daysOffLabel: String {
        guard !draft.closedDays.isEmpty else { return "없음" }
        let names = weekdays.filter { draft.closedDays.contains($0.0) }.map { $0.1 }
        return "매주 " + names.joined(separator: "·") + "요일"
    }

    private var weekSummary: String {
        draft.closedDays.isEmpty ? "주 7일" : "주 \(7 - draft.closedDays.count)일"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    operatingHoursCard
                    summaryCards
                    facilitiesSection
                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.mossError)
                            .padding(.horizontal, 2)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Button(action: save) {
                        Text("운영 정보 저장")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    if isShowingSuccess {
                        HStack(spacing: 9) {
                            Image("MerchantOperationSaved")
                                .resizable()
                                .frame(width: 17, height: 17)
                            Text("운영 정보가 미리보기에 저장됐어요.")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 40)
                        .background(Color.mossTextPrimary, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.mossTextPrimary.opacity(0.15), radius: 9, x: 0, y: 5)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .sheet(item: $activeEditor) { editor in
            editorSheet(for: editor)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: draft)
        .animation(.easeInOut(duration: 0.22), value: validationMessage)
        .animation(.spring(response: 0.36, dampingFraction: 0.82), value: isShowingSuccess)
        .sensoryFeedback(.error, trigger: savePulse)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image("MerchantMenuBack")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("매장 관리로 돌아가기")
            Spacer()
            Text("운영 정보 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var operatingHoursCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("영업시간")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Text(weekSummary)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.mossBrandSage)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                    .contentTransition(.numericText())
            }
            timeRow(title: "월–금", start: draft.weekdayOpen, end: draft.weekdayClose) {
                activeEditor = .weekdayHours
            }
            timeRow(title: "토–일", start: draft.weekendOpen, end: draft.weekendClose) {
                activeEditor = .weekendHours
            }
        }
        .padding(14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func timeRow(title: String, start: Date, end: Date, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
            Spacer()
            Button(action: action) {
                Text("\(start.formatted(date: .omitted, time: .shortened))  —  \(end.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .padding(.horizontal, 12)
                    .frame(height: 31)
                    .background(Color.mossBackground, in: RoundedRectangle(cornerRadius: 8))
                    .contentTransition(.numericText())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) 영업시간 변경")
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 10) {
            summaryCard(title: "정기 휴무일", value: daysOffLabel, actionTitle: "변경하기") {
                activeEditor = .daysOff
            }
            summaryCard(
                title: "시간당 가격대",
                value: "₩\(draft.minimumHourlyPrice.formatted())–\(draft.maximumHourlyPrice.formatted())",
                actionTitle: "변경하기"
            ) {
                activeEditor = .priceRange
            }
        }
    }

    private func summaryCard(title: String, value: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossTextMuted)
                Text(value)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text(actionTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 91, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var facilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("편의시설")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(facilities, id: \.self) { facility in
                    facilityChip(facility)
                }
            }
        }
    }

    private func facilityChip(_ title: String) -> some View {
        let isSelected = draft.facilities.contains(title)
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                if isSelected { draft.facilities.remove(title) }
                else { draft.facilities.insert(title) }
                validationMessage = nil
                isShowingSuccess = false
            }
        } label: {
            HStack(spacing: 6) {
                Image(isSelected ? "MerchantOperationCheck" : "MerchantOperationPlus")
                    .resizable()
                    .frame(width: 13, height: 13)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isSelected ? Color.mossBrandSage : Color.mossTextMuted)
            }
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(isSelected ? Color.mossSageSoft : Color.mossSurface, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.mossSageSoft : Color.mossLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func editorSheet(for editor: Editor) -> some View {
        switch editor {
        case .weekdayHours:
            MerchantOperationHoursEditor(
                title: "평일 영업시간",
                openTime: draft.weekdayOpen,
                closeTime: draft.weekdayClose
            ) { open, close in
                draft.weekdayOpen = open
                draft.weekdayClose = close
                activeEditor = nil
                isShowingSuccess = false
            }
        case .weekendHours:
            MerchantOperationHoursEditor(
                title: "주말 영업시간",
                openTime: draft.weekendOpen,
                closeTime: draft.weekendClose
            ) { open, close in
                draft.weekendOpen = open
                draft.weekendClose = close
                activeEditor = nil
                isShowingSuccess = false
            }
        case .daysOff:
            MerchantDaysOffEditor(selectedDays: draft.closedDays) { selectedDays in
                draft.closedDays = selectedDays
                activeEditor = nil
                isShowingSuccess = false
            }
        case .priceRange:
            MerchantPriceRangeEditor(minimum: draft.minimumHourlyPrice, maximum: draft.maximumHourlyPrice) { minimum, maximum in
                draft.minimumHourlyPrice = minimum
                draft.maximumHourlyPrice = maximum
                activeEditor = nil
                isShowingSuccess = false
            }
        }
    }

    private func save() {
        let weekdayOpen = minutesAfterMidnight(draft.weekdayOpen)
        let weekdayClose = minutesAfterMidnight(draft.weekdayClose)
        let weekendOpen = minutesAfterMidnight(draft.weekendOpen)
        let weekendClose = minutesAfterMidnight(draft.weekendClose)
        guard weekdayOpen < weekdayClose, weekendOpen < weekendClose else {
            validationMessage = "마감 시간은 시작 시간보다 늦게 설정해 주세요."
            isShowingSuccess = false
            savePulse += 1
            return
        }
        guard draft.minimumHourlyPrice > 0, draft.minimumHourlyPrice <= draft.maximumHourlyPrice else {
            validationMessage = "가격대의 최저 금액과 최고 금액을 확인해 주세요."
            isShowingSuccess = false
            savePulse += 1
            return
        }
        validationMessage = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { isShowingSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.2)) { isShowingSuccess = false }
        }
    }

    private func minutesAfterMidnight(_ date: Date) -> Int {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }
}

private struct MerchantOperationHoursEditor: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let onSave: (Date, Date) -> Void
    @State private var openTime: Date
    @State private var closeTime: Date
    @State private var showError = false

    init(title: String, openTime: Date, closeTime: Date, onSave: @escaping (Date, Date) -> Void) {
        self.title = title
        self.onSave = onSave
        _openTime = State(initialValue: openTime)
        _closeTime = State(initialValue: closeTime)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            sheetTitle(title)
            DatePicker("영업 시작", selection: $openTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .tint(Color.mossPrimaryGreen)
            DatePicker("영업 종료", selection: $closeTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .tint(Color.mossPrimaryGreen)
            if showError {
                Label("마감 시간은 시작 시간보다 늦어야 합니다.", systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossError)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Button {
                let calendar = Calendar.current
                let openParts = calendar.dateComponents([.hour, .minute], from: openTime)
                let closeParts = calendar.dateComponents([.hour, .minute], from: closeTime)
                let openMinutes = (openParts.hour ?? 0) * 60 + (openParts.minute ?? 0)
                let closeMinutes = (closeParts.hour ?? 0) * 60 + (closeParts.minute ?? 0)
                guard openMinutes < closeMinutes else { showError = true; return }
                onSave(openTime, closeTime)
                dismiss()
            } label: { primaryButtonLabel("시간 저장") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: showError)
    }
}

private struct MerchantDaysOffEditor: View {
    @Environment(\.dismiss) private var dismiss
    private let weekdays = [(1, "월요일"), (2, "화요일"), (3, "수요일"), (4, "목요일"), (5, "금요일"), (6, "토요일"), (7, "일요일")]
    @State private var selectedDays: Set<Int>
    let onSave: (Set<Int>) -> Void

    init(selectedDays: Set<Int>, onSave: @escaping (Set<Int>) -> Void) {
        _selectedDays = State(initialValue: selectedDays)
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sheetTitle("정기 휴무일")
            Text("휴무일로 설정할 요일을 선택해 주세요.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextMuted)
            VStack(spacing: 0) {
                ForEach(weekdays, id: \.0) { day, name in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                            if selectedDays.contains(day) { selectedDays.remove(day) }
                            else { selectedDays.insert(day) }
                        }
                    } label: {
                        HStack {
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.mossTextPrimary)
                            Spacer()
                            Image(systemName: selectedDays.contains(day) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(selectedDays.contains(day) ? Color.mossPrimaryGreen : Color.mossTextMuted)
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Button {
                onSave(selectedDays)
                dismiss()
            } label: { primaryButtonLabel("휴무일 저장") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground.ignoresSafeArea())
    }
}

private struct MerchantPriceRangeEditor: View {
    private enum Field { case minimum, maximum }
    @Environment(\.dismiss) private var dismiss
    let onSave: (Int, Int) -> Void
    @State private var minimumText: String
    @State private var maximumText: String
    @State private var hasAttemptedSave = false
    @State private var errorPulse = 0
    @FocusState private var focusedField: Field?

    init(minimum: Int, maximum: Int, onSave: @escaping (Int, Int) -> Void) {
        self.onSave = onSave
        _minimumText = State(initialValue: String(minimum))
        _maximumText = State(initialValue: String(maximum))
    }

    private var errorMessage: String? {
        guard hasAttemptedSave else { return nil }
        guard let minimum = Int(minimumText), let maximum = Int(maximumText), minimum > 0, maximum >= minimum else {
            return "최저 금액과 최고 금액을 올바르게 입력해 주세요."
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sheetTitle("시간당 가격대")
            Text("최저 금액과 최고 금액을 원 단위로 입력해 주세요.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextMuted)
            amountField(title: "최저 금액", text: $minimumText, field: .minimum)
            amountField(title: "최고 금액", text: $maximumText, field: .maximum)
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossError)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Button(action: save) { primaryButtonLabel("가격대 저장") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }
        }
        .animation(.easeInOut(duration: 0.2), value: hasAttemptedSave)
        .sensoryFeedback(.error, trigger: errorPulse)
    }

    private func amountField(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossTextPrimary)
            TextField("숫자만 입력", text: text)
                .font(.system(size: 14))
                .keyboardType(.numberPad)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(errorMessage == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: text.wrappedValue) { _, newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(8))
                    if digits != newValue { text.wrappedValue = digits }
                }
        }
    }

    private func save() {
        focusedField = nil
        hasAttemptedSave = true
        guard let minimum = Int(minimumText), let maximum = Int(maximumText), minimum > 0, maximum >= minimum else {
            errorPulse += 1
            return
        }
        onSave(minimum, maximum)
        dismiss()
    }
}

private func sheetTitle(_ title: String) -> some View {
    HStack {
        Text(title)
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(Color.mossTextPrimary)
        Spacer()
    }
}

private func primaryButtonLabel(_ title: String) -> some View {
    Text(title)
        .font(.system(size: 14, weight: .heavy))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
}
