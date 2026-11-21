import SwiftUI

private enum MerchantEventEditDateField: String, Identifiable {
    case start
    case end
    var id: String { rawValue }
    var title: String { self == .start ? "시작일 선택" : "종료일 선택" }
}

struct MerchantEventEditView: View {
    let event: MerchantEventRecord
    let onBack: () -> Void
    let onSave: (MerchantEventRecord) -> Void
    let onDelete: () -> Void

    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var details: String
    @State private var isVisibleInStore: Bool
    @State private var hasAttemptedSave = false
    @State private var isShowingDeleteConfirmation = false
    @State private var validationPulse = 0
    @State private var datePickerTarget: MerchantEventEditDateField?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, details }

    init(
        event: MerchantEventRecord,
        onBack: @escaping () -> Void,
        onSave: @escaping (MerchantEventRecord) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.event = event
        self.onBack = onBack
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: event.title)
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _details = State(initialValue: event.details)
        _isVisibleInStore = State(initialValue: event.isVisibleInStore)
    }

    private var cleanTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanDetails: String { details.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var invalidDateOrder: Bool {
        Calendar.current.startOfDay(for: endDate) < Calendar.current.startOfDay(for: startDate)
    }
    private var validTitle: Bool { (2...40).contains(cleanTitle.count) }
    private var validDetails: Bool { !cleanDetails.isEmpty && details.count <= 500 }
    private var isFormValid: Bool { validTitle && !invalidDateOrder && validDetails }
    private var statusLine: String {
        guard event.status == .ongoing else { return event.status.rawValue }
        return event.daysRemaining == 0 ? "진행 중 · D-Day" : "진행 중 · D-\(event.daysRemaining)"
    }

    private var titleError: String? {
        guard hasAttemptedSave else { return nil }
        if cleanTitle.isEmpty { return "이벤트 제목을 입력해 주세요." }
        if cleanTitle.count < 2 { return "이벤트 제목은 2자 이상 입력해 주세요." }
        if cleanTitle.count > 40 { return "이벤트 제목은 40자 이내로 입력해 주세요." }
        return nil
    }

    private var detailsError: String? {
        guard hasAttemptedSave else { return nil }
        if cleanDetails.isEmpty { return "이벤트 내용을 입력해 주세요." }
        if details.count > 500 { return "이벤트 내용은 500자 이내로 작성해 주세요." }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    statusCard
                    titleField
                    eventPeriod
                    detailsField
                    visibilityCard
                    infoNotice
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 2)
                .padding(.bottom, 18)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .sheet(item: $datePickerTarget) { target in
            MerchantEventEditDatePickerSheet(
                title: target.title,
                selection: target == .start ? $startDate : $endDate
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("이벤트를 삭제할까요?", isPresented: $isShowingDeleteConfirmation) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive, action: onDelete)
        } message: {
            Text("이 이벤트는 로컬 미리보기 목록에서만 삭제됩니다. 실제 서비스 데이터에는 영향이 없어요.")
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: hasAttemptedSave)
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: isVisibleInStore)
        .animation(.easeInOut(duration: 0.2), value: invalidDateOrder)
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
            Text("이벤트 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button(action: save) {
                Text("저장")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.mossBrandSage)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("수정 내용 저장")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("현재 상태")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: 0xDDE9E1))
                Text(statusLine)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
            Spacer()
            Text(isVisibleInStore ? "장소 노출 중" : "노출 중지")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.mossBrandSage)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: 0xE3ECE7), in: RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBrandSage, in: RoundedRectangle(cornerRadius: 16))
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
            if let titleError { errorText(titleError) }
        }
    }

    private var eventPeriod: some View {
        HStack(alignment: .top, spacing: 10) {
            dateField(label: "시작일", date: startDate, target: .start)
            dateField(label: "종료일", date: endDate, target: .end)
        }
    }

    private func dateField(label: String, date: Date, target: MerchantEventEditDateField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(label)
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
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(invalidDateOrder && target == .end ? Color.mossError : Color.mossLine, lineWidth: 1))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            if target == .end && invalidDateOrder {
                errorText("종료일은 시작일 이후여야 해요.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .frame(height: 76)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(detailsError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: details) { _, newValue in
                    if newValue.count > 500 { details = String(newValue.prefix(500)) }
                }
            if let detailsError { errorText(detailsError) }
        }
    }

    private var visibilityCard: some View {
        Toggle(isOn: $isVisibleInStore) {
            VStack(alignment: .leading, spacing: 3) {
                Text("장소 상세에 노출")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Text("종료 전까지 고객에게 보여요")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
            }
        }
        .tint(Color.mossBrandSage)
        .padding(13)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var infoNotice: some View {
        HStack(alignment: .center, spacing: 9) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x7A4E1B))
            Text("종료된 이벤트는 다시 진행 상태로 변경할 수 없어요. 수정 내용은 이 미리보기에서만 유지돼요.")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF8ED), in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button { isShowingDeleteConfirmation = true } label: {
                Text("이벤트 삭제")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: 0xC95B4A), in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            Button(action: save) {
                Text("수정 저장")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private func fieldLabel(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.mossBrandSage)
    }

    private func errorText(_ value: String) -> some View {
        Text(value)
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

    private func save() {
        focusedField = nil
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) { hasAttemptedSave = true }
        guard isFormValid else {
            validationPulse += 1
            return
        }
        onSave(MerchantEventRecord(
            id: event.id,
            title: cleanTitle,
            startDate: startDate,
            endDate: endDate,
            timeRange: event.timeRange,
            details: cleanDetails,
            status: event.status,
            isVisibleInStore: isVisibleInStore
        ))
    }
}

private struct MerchantEventEditDatePickerSheet: View {
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
