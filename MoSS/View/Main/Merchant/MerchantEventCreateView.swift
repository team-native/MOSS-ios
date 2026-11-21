import SwiftUI

private enum MerchantEventQuietTime: String, CaseIterable, Hashable, Identifiable {
    case morning = "오전 09–12시"
    case afternoon = "오후 12–18시"
    case evening = "저녁 18–21시"
    case lateNight = "심야 21–24시"

    var id: String { rawValue }
    var timeRange: String {
        switch self {
        case .morning: "09:00–12:00"
        case .afternoon: "12:00–18:00"
        case .evening: "18:00–21:00"
        case .lateNight: "21:00–24:00"
        }
    }
}

private enum MerchantEventDateField: String, Identifiable {
    case start
    case end
    var id: String { rawValue }
    var title: String { self == .start ? "시작일 선택" : "종료일 선택" }
}

struct MerchantEventCreateView: View {
    let onBack: () -> Void
    let onSubmit: (MerchantEventRecord) -> Void

    @State private var title = "시험 기간 심야 할인"
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    @State private var selectedQuietTimes: Set<MerchantEventQuietTime> = [.evening, .lateNight]
    @State private var details = "4시간권 결제 시 최대 20% 할인 혜택을 드려요. 현장 키오스크에서 쿠폰을 선택해 주세요!"
    @State private var hasAttemptedSubmit = false
    @State private var validationPulse = 0
    @State private var datePickerTarget: MerchantEventDateField?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, details }
    private let locationDescription = "에이밍 스터디카페 · 광주 북구 비엔날레로 87"

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedDetails: String { details.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isDateOrderInvalid: Bool { Calendar.current.startOfDay(for: endDate) < Calendar.current.startOfDay(for: startDate) }
    private var isTitleValid: Bool { (2...40).contains(trimmedTitle.count) }
    private var isDetailsValid: Bool { !trimmedDetails.isEmpty && details.count <= 500 }
    private var isQuietTimeValid: Bool { !selectedQuietTimes.isEmpty }
    private var isFormValid: Bool { isTitleValid && !isDateOrderInvalid && isQuietTimeValid && isDetailsValid }

    private var titleError: String? {
        guard hasAttemptedSubmit else { return nil }
        if trimmedTitle.isEmpty { return "이벤트 제목을 입력해 주세요." }
        if trimmedTitle.count < 2 { return "이벤트 제목은 2자 이상 입력해 주세요." }
        if trimmedTitle.count > 40 { return "이벤트 제목은 40자 이내로 입력해 주세요." }
        return nil
    }

    private var dateError: String? {
        guard isDateOrderInvalid else { return nil }
        return "종료일은 시작일 이후여야 해요."
    }

    private var quietTimeError: String? {
        hasAttemptedSubmit && !isQuietTimeValid ? "한산한 대상 시간대를 하나 이상 선택해 주세요." : nil
    }

    private var detailsError: String? {
        guard hasAttemptedSubmit else { return nil }
        if trimmedDetails.isEmpty { return "이벤트 내용을 입력해 주세요." }
        if details.count > 500 { return "이벤트 내용은 500자 이내로 작성해 주세요." }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    titleField
                    eventPeriod
                    quietTimeSection
                    detailsField
                    locationSection
                    if hasAttemptedSubmit && !isFormValid {
                        validationNotice
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 2)
                .padding(.bottom, 14)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }
            }
            submitButton
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .sheet(item: $datePickerTarget) { target in
            MerchantEventDatePickerSheet(
                title: target.title,
                selection: target == .start ? $startDate : $endDate
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: hasAttemptedSubmit)
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: selectedQuietTimes)
        .animation(.easeInOut(duration: 0.2), value: isDateOrderInvalid)
        .sensoryFeedback(.error, trigger: validationPulse)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image("MerchantMenuBack")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("이벤트 관리로 돌아가기")
            Spacer()
            Text("새 이벤트 등록")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("이벤트 제목 *")
            TextField("이벤트 제목을 입력해 주세요", text: $title)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextPrimary)
                .focused($focusedField, equals: .title)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .padding(.horizontal, 13)
                .frame(height: 44)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(titleError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: title) { _, newValue in
                    if newValue.count > 40 { title = String(newValue.prefix(40)) }
                }
            HStack {
                helperText("2–40자로 작성해 주세요.")
                Spacer()
                helperText("\(title.count) / 40")
            }
            if let titleError { errorText(titleError) }
        }
    }

    private var eventPeriod: some View {
        HStack(alignment: .top, spacing: 10) {
            dateField(title: "시작일 *", date: startDate, isInvalid: false, target: .start)
            dateField(title: "종료일 *", date: endDate, isInvalid: isDateOrderInvalid, target: .end)
        }
    }

    private func dateField(title: String, date: Date, isInvalid: Bool, target: MerchantEventDateField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(title)
            Button { datePickerTarget = target } label: {
                HStack {
                    Text(formattedDate(date))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossTextPrimary)
                    Spacer(minLength: 2)
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.mossTextMuted)
                }
                .padding(.horizontal, 13)
                .frame(height: 44)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isInvalid ? Color.mossError : Color.mossLine, lineWidth: 1))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            if target == .end, let dateError { errorText(dateError) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quietTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한산한 대상 시간대 *")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            FlexibleEventTimeGrid(selectedQuietTimes: $selectedQuietTimes)
            if let quietTimeError { errorText(quietTimeError) }
        }
    }

    private var detailsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("이벤트 내용 *")
            TextEditor(text: $details)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextPrimary)
                .focused($focusedField, equals: .details)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(height: 84)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(detailsError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: details) { _, newValue in
                    if newValue.count > 500 { details = String(newValue.prefix(500)) }
                }
            HStack(alignment: .top) {
                helperText("혜택과 이용 조건을 명확히 적어주세요.")
                Spacer(minLength: 8)
                helperText("\(details.count) / 500")
            }
            if let detailsError { errorText(detailsError) }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("장소 상세 노출")
            Text(locationDescription)
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextPrimary)
                .lineLimit(2)
                .padding(.horizontal, 13)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.mossLine, lineWidth: 1))
            helperText("등록 후 장소 상세의 ‘진행 중인 이벤트’에 노출돼요.")
        }
    }

    private var validationNotice: some View {
        HStack(alignment: .center, spacing: 9) {
            Image("MerchantEventAlert")
                .resizable()
                .frame(width: 17, height: 17)
            Text("필수값을 확인해 주세요. 입력한 항목을 수정하면 등록할 수 있어요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossError)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 12))
    }

    private var submitButton: some View {
        Button(action: submit) {
            Text("검토 후 등록")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.mossBrandSage)
    }

    private func helperText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundStyle(Color.mossTextMuted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundStyle(Color.mossError)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    private func submit() {
        focusedField = nil
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) { hasAttemptedSubmit = true }
        guard isFormValid else {
            validationPulse += 1
            return
        }

        let orderedTimes = MerchantEventQuietTime.allCases.filter { selectedQuietTimes.contains($0) }
        let newEvent = MerchantEventRecord(
            id: UUID().uuidString,
            title: trimmedTitle,
            startDate: startDate,
            endDate: endDate,
            timeRange: orderedTimes.map(\.timeRange).joined(separator: " · "),
            details: trimmedDetails,
            status: .pending
        )
        onSubmit(newEvent)
    }
}

private struct FlexibleEventTimeGrid: View {
    @Binding var selectedQuietTimes: Set<MerchantEventQuietTime>

    var body: some View {
        ViewThatFits(in: .horizontal) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    chip(.morning)
                    chip(.afternoon)
                    chip(.evening)
                }
                HStack(spacing: 7) {
                    chip(.lateNight)
                }
            }
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) { chip(.morning); chip(.afternoon) }
                HStack(spacing: 7) { chip(.evening); chip(.lateNight) }
            }
        }
    }

    private func chip(_ time: MerchantEventQuietTime) -> some View {
        let isSelected = selectedQuietTimes.contains(time)
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                if isSelected { selectedQuietTimes.remove(time) }
                else { selectedQuietTimes.insert(time) }
            }
        } label: {
            Text(time.rawValue)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.mossTextMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.mossBrandSage : Color.mossSurface, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.mossBrandSage : Color.mossLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct MerchantEventDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Binding var selection: Date

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            DatePicker(title, selection: $selection, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
            Button("완료") { dismiss() }
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color.mossBackground.ignoresSafeArea())
    }
}
