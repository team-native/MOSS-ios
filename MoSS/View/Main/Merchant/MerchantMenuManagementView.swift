import SwiftUI

private enum MerchantMenuFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case visible = "노출 중"
    case soldOut = "품절"

    var id: String { rawValue }
}

struct MerchantMenuItem: Identifiable, Equatable {
    let id: String
    var name: String
    var price: Int
    var photoName: String
    var isVisible: Bool
    var isSoldOut: Bool

    static let sample: [MerchantMenuItem] = [
        .init(id: "americano", name: "아메리카노", price: 2_500, photoName: "MerchantMenuAmericano", isVisible: true, isSoldOut: false),
        .init(id: "strawberry-latte", name: "딸기라떼", price: 3_500, photoName: "MerchantMenuStrawberryLatte", isVisible: true, isSoldOut: true),
        .init(id: "four-hour-pass", name: "4시간 이용권", price: 8_000, photoName: "MerchantMenu4HourPass", isVisible: false, isSoldOut: false),
        .init(id: "all-day-pass", name: "종일 이용권", price: 15_000, photoName: "MerchantMenuAllDayPass", isVisible: true, isSoldOut: false)
    ]
}

struct MerchantMenuManagementView: View {
    let onBack: () -> Void

    @State private var items = MerchantMenuItem.sample
    @State private var selectedFilter: MerchantMenuFilter = .all
    @State private var sortOrder = "추천순"
    @State private var editingItem: MerchantMenuItem?
    @State private var isShowingEditor = false

    private var filteredItems: [MerchantMenuItem] {
        let filtered = items.filter { item in
            switch selectedFilter {
            case .all: true
            case .visible: item.isVisible
            case .soldOut: item.isSoldOut
            }
        }
        switch sortOrder {
        case "가격 낮은순": return filtered.sorted { $0.price < $1.price }
        case "가격 높은순": return filtered.sorted { $0.price > $1.price }
        case "이름순": return filtered.sorted { $0.name < $1.name }
        default: return filtered
        }
    }

    private var visibleCount: Int { 7 + items.filter(\.isVisible).count }
    private var hiddenCount: Int { 1 + items.filter { !$0.isVisible }.count }
    private var soldOutCount: Int { items.filter(\.isSoldOut).count }
    private var totalCount: Int { 8 + items.count }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    summary
                    filters
                    LazyVStack(spacing: 10) {
                        ForEach(filteredItems) { item in
                            menuCard(item)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    Button(action: addItem) {
                        HStack(spacing: 8) {
                            Image("MerchantMenuAddPlus")
                                .resizable()
                                .frame(width: 17, height: 17)
                            Text("새 메뉴 추가")
                                .font(.system(size: 14, weight: .heavy))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    Color.clear.frame(height: 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .sheet(isPresented: $isShowingEditor, onDismiss: { editingItem = nil }) {
            MerchantMenuEditorView(
                item: editingItem,
                onClose: { isShowingEditor = false },
                onSave: saveItem
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selectedFilter)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: items)
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
            Text("메뉴·상품 관리")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button(action: addItem) {
                Image("MerchantMenuHeaderPlus")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("새 메뉴 추가")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var summary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("등록된 메뉴 \(totalCount)개")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Text("노출 \(visibleCount) · 숨김 \(hiddenCount) · 품절 \(soldOutCount)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
                    .contentTransition(.numericText())
            }
            Spacer()
            Menu {
                ForEach(["추천순", "가격 낮은순", "가격 높은순", "이름순"], id: \.self) { order in
                    Button(order) {
                        withAnimation(.easeInOut(duration: 0.2)) { sortOrder = order }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(sortOrder)
                    Image("MerchantMenuChevronDown")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossPrimaryGreen)
            }
        }
    }

    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(MerchantMenuFilter.allCases) { filter in
                let isSelected = selectedFilter == filter
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) { selectedFilter = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.mossPrimaryGreen : Color.mossSurface, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
    }

    private func menuCard(_ item: MerchantMenuItem) -> some View {
        HStack(spacing: 12) {
            Button { editItem(item) } label: {
                HStack(spacing: 12) {
                    Image(item.photoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .opacity(item.isSoldOut ? 0.45 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(Color.mossTextPrimary)
                                .lineLimit(1)
                            if item.isSoldOut {
                                Text("품절")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundStyle(Color(hex: 0xC95B4A))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        Text("₩\(item.price.formatted())")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.isVisible ? Color(hex: 0x3F7659) : Color.mossTextMuted)
                                .frame(width: 7, height: 7)
                            Text(item.isVisible ? "고객에게 노출 중" : "숨김 처리")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.mossTextMuted)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Button { editItem(item) } label: {
                Image("MerchantMenuPencil")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .frame(width: 34, height: 34)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(item.name) 편집")
        }
        .padding(12)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func addItem() {
        editingItem = nil
        isShowingEditor = true
    }

    private func editItem(_ item: MerchantMenuItem) {
        editingItem = item
        isShowingEditor = true
    }

    private func saveItem(_ updatedItem: MerchantMenuItem) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[index] = updatedItem
            } else {
                items.insert(updatedItem, at: 0)
            }
        }
        isShowingEditor = false
    }
}

private struct MerchantMenuEditorView: View {
    private enum Field { case name, price }

    let item: MerchantMenuItem?
    let onClose: () -> Void
    let onSave: (MerchantMenuItem) -> Void

    @State private var name: String
    @State private var priceText: String
    @State private var isVisible: Bool
    @State private var isSoldOut: Bool
    @State private var hasAttemptedSave = false
    @State private var validationErrorPulse = 0
    @FocusState private var focusedField: Field?

    init(item: MerchantMenuItem?, onClose: @escaping () -> Void, onSave: @escaping (MerchantMenuItem) -> Void) {
        self.item = item
        self.onClose = onClose
        self.onSave = onSave
        _name = State(initialValue: item?.name ?? "")
        _priceText = State(initialValue: item.map { String($0.price) } ?? "")
        _isVisible = State(initialValue: item?.isVisible ?? true)
        _isSoldOut = State(initialValue: item?.isSoldOut ?? false)
    }

    private var nameError: String? {
        guard hasAttemptedSave else { return nil }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "메뉴명을 입력해 주세요." }
        if name.count < 2 { return "메뉴명은 두 글자 이상 입력해 주세요." }
        return nil
    }

    private var priceError: String? {
        guard hasAttemptedSave else { return nil }
        guard let price = Int(priceText), price > 0 else { return "0보다 큰 숫자로 가격을 입력해 주세요." }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    inputField(title: "메뉴명", text: $name, prompt: "예: 아메리카노", field: .name, error: nameError)
                    inputField(title: "가격", text: $priceText, prompt: "숫자만 입력해 주세요", field: .price, error: priceError)
                    stateOptions
                    Button(action: save) {
                        Text(item == nil ? "메뉴 추가" : "수정 저장")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 4)
                    Color.clear.frame(height: 18)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { dismissKeyboard() }
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: hasAttemptedSave)
        .sensoryFeedback(.error, trigger: validationErrorPulse)
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text(item == nil ? "새 메뉴 추가" : "메뉴 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private func inputField(title: String, text: Binding<String>, prompt: String, field: Field, error: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            TextField(prompt, text: text)
                .font(.system(size: 14))
                .foregroundStyle(Color.mossTextPrimary)
                .keyboardType(field == .price ? .numberPad : .default)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(error == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: text.wrappedValue) { _, newValue in
                    if field == .name, newValue.count > 30 { text.wrappedValue = String(newValue.prefix(30)) }
                    if field == .price {
                        let digits = String(newValue.filter(\.isNumber).prefix(8))
                        if digits != newValue { text.wrappedValue = digits }
                    }
                    if hasAttemptedSave && error == nil { hasAttemptedSave = false }
                }
            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossError)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var stateOptions: some View {
        VStack(spacing: 0) {
            stateToggle(title: "고객에게 노출", subtitle: "고객 앱에서 메뉴를 확인할 수 있어요", isOn: $isVisible)
            Color.mossLine.frame(height: 1).padding(.leading, 52)
            stateToggle(title: "품절 처리", subtitle: "재고가 없을 때 품절로 표시해요", isOn: $isSoldOut)
        }
        .padding(.horizontal, 14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func stateToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mossTextPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
            }
            Spacer()
            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(Color.mossPrimaryGreen)
        }
        .frame(minHeight: 58)
    }

    private func save() {
        dismissKeyboard()
        hasAttemptedSave = true
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedPrice = Int(priceText)
        guard trimmedName.count >= 2, let price = parsedPrice, price > 0 else {
            validationErrorPulse += 1
            return
        }
        let updated = MerchantMenuItem(
            id: item?.id ?? UUID().uuidString,
            name: trimmedName,
            price: price,
            photoName: item?.photoName ?? "MerchantMenuAmericano",
            isVisible: isVisible,
            isSoldOut: isSoldOut
        )
        onSave(updated)
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}
