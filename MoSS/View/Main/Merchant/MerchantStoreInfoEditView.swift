import PhotosUI
import SwiftUI
import UIKit

struct MerchantStoreInfoDraft: Equatable {
    var name = "에이밍 스터디카페"
    var category = "스터디카페"
    var address = "광주 북구 비엔날레로 87"
    var phone = "062-123-4567"
    var introduction = "조용한 집중을 위한 24시간 프리미엄 학습 공간입니다."
    var photoData: Data?
}

struct MerchantStoreInfoEditView: View {
    private enum Field: Hashable { case name, phone, introduction }
    private enum Editor: String, Identifiable { case category, address; var id: String { rawValue } }

    @Binding private var draft: MerchantStoreInfoDraft
    let onBack: () -> Void

    @State private var activeEditor: Editor?
    @State private var photoSelection: PhotosPickerItem?
    @State private var hasAttemptedSave = false
    @State private var isShowingSuccess = false
    @State private var errorPulse = 0
    @FocusState private var focusedField: Field?

    init(draft: Binding<MerchantStoreInfoDraft>, onBack: @escaping () -> Void) {
        _draft = draft
        self.onBack = onBack
    }

    private var nameError: String? {
        guard hasAttemptedSave else { return nil }
        return draft.name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 ? nil : "매장명을 두 글자 이상 입력해 주세요."
    }

    private var categoryError: String? {
        guard hasAttemptedSave else { return nil }
        return draft.category.isEmpty ? "카테고리를 선택해 주세요." : nil
    }

    private var addressError: String? {
        guard hasAttemptedSave else { return nil }
        return draft.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "주소를 입력해 주세요." : nil
    }

    private var phoneError: String? {
        guard hasAttemptedSave else { return nil }
        let digits = draft.phone.filter(\.isNumber)
        return (9...11).contains(digits.count) ? nil : "연락처를 숫자 9~11자리로 입력해 주세요."
    }

    private var introductionError: String? {
        guard hasAttemptedSave else { return nil }
        return draft.introduction.count <= 200 ? nil : "매장 소개는 200자 이내로 입력해 주세요."
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 11) {
                    heroImage
                    storeNameField
                    categoryField
                    addressField
                    phoneField
                    introductionField
                    infoNotice
                    if let submissionError {
                        Label(submissionError, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.mossError)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Button(action: save) {
                        Text("변경 내용 저장")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    if isShowingSuccess {
                        Label("매장 정보가 미리보기에 저장됐어요.", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.mossPrimaryGreen)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 24)
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
        .sheet(item: $activeEditor) { editor in
            switch editor {
            case .category:
                MerchantStoreCategoryEditor(selectedCategory: draft.category) { category in
                    draft.category = category
                    activeEditor = nil
                    isShowingSuccess = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            case .address:
                MerchantStoreAddressEditor(address: draft.address) { address in
                    draft.address = address
                    activeEditor = nil
                    isShowingSuccess = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: photoSelection) { _, selection in
            guard let selection else { return }
            Task {
                guard let data = try? await selection.loadTransferable(type: Data.self),
                      UIImage(data: data) != nil else { return }
                draft.photoData = data
                isShowingSuccess = false
            }
        }
        .animation(.easeInOut(duration: 0.22), value: hasAttemptedSave)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: draft)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isShowingSuccess)
        .sensoryFeedback(.error, trigger: errorPulse)
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
            Text("기본 정보 수정")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var heroImage: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let data = draft.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Image("MerchantStoreInfoHero").resizable().scaledToFill()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .clipped()
            PhotosPicker(selection: $photoSelection, matching: .images) {
                HStack(spacing: 5) {
                    Image("MerchantStoreInfoCamera")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("대표 이미지 변경")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 11)
                .frame(height: 30)
                .background(Color.mossDarkAction, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
    }

    private var storeNameField: some View {
        textField(title: "매장명", text: $draft.name, prompt: "매장명을 입력해 주세요", field: .name, error: nameError, maxLength: 30)
    }

    private var categoryField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("카테고리")
            Button { activeEditor = .category } label: {
                HStack {
                    Text(draft.category.isEmpty ? "카테고리를 선택해 주세요" : draft.category)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossTextPrimary)
                    Spacer()
                    Text("변경")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossBrandSage)
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(categoryError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
            }
            .buttonStyle(.plain)
            if let categoryError { fieldError(categoryError) }
        }
    }

    private var addressField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("주소")
            Button { activeEditor = .address } label: {
                HStack(spacing: 8) {
                    Text(draft.address.isEmpty ? "주소를 입력해 주세요" : draft.address)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossTextPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("검색")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossBrandSage)
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(addressError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
            }
            .buttonStyle(.plain)
            if let addressError { fieldError(addressError) }
        }
    }

    private var phoneField: some View {
        textField(title: "연락처", text: $draft.phone, prompt: "예: 062-123-4567", field: .phone, error: phoneError, keyboard: .phonePad, maxLength: 14)
    }

    private var introductionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("매장 소개")
            TextEditor(text: $draft.introduction)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossTextPrimary)
                .focused($focusedField, equals: .introduction)
                .scrollContentBackground(.hidden)
                .frame(height: 82)
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(introductionError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: draft.introduction) { _, newValue in
                    if newValue.count > 200 { draft.introduction = String(newValue.prefix(200)) }
                    isShowingSuccess = false
                }
            HStack {
                if let introductionError { fieldError(introductionError) }
                Spacer()
                Text("\(draft.introduction.count)/200")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mossTextMuted)
            }
        }
    }

    private var infoNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantStoreInfoZap")
                .resizable()
                .frame(width: 17, height: 17)
            Text("저장한 정보는 이 미리보기 화면에만 반영됩니다. 서버 연동은 추후 진행됩니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
    }

    private var submissionError: String? {
        guard hasAttemptedSave else { return nil }
        return nameError ?? categoryError ?? addressError ?? phoneError ?? introductionError
    }

    private func textField(
        title: String,
        text: Binding<String>,
        prompt: String,
        field: Field,
        error: String?,
        keyboard: UIKeyboardType = .default,
        maxLength: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle(title)
            TextField(prompt, text: text)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossTextPrimary)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(error == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count > maxLength { text.wrappedValue = String(newValue.prefix(maxLength)) }
                    if field == .phone {
                        let digits = String(newValue.filter(\.isNumber).prefix(11))
                        if newValue.filter(\.isNumber) != digits { text.wrappedValue = digits }
                    }
                    isShowingSuccess = false
                }
            if let error { fieldError(error) }
        }
    }

    private func fieldTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.mossBrandSage)
    }

    private func fieldError(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.system(size: 11))
            .foregroundStyle(Color.mossError)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func save() {
        focusedField = nil
        hasAttemptedSave = true
        let cleanName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAddress = draft.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneDigits = draft.phone.filter(\.isNumber)
        guard cleanName.count >= 2,
              !draft.category.isEmpty,
              !cleanAddress.isEmpty,
              (9...11).contains(phoneDigits.count),
              draft.introduction.count <= 200 else {
            errorPulse += 1
            isShowingSuccess = false
            return
        }
        draft.name = cleanName
        draft.address = cleanAddress
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) { isShowingSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.2)) { isShowingSuccess = false }
        }
    }
}

private struct MerchantStoreCategoryEditor: View {
    @Environment(\.dismiss) private var dismiss
    private let categories = ["스터디카페", "카페", "도서관", "독서실", "코워킹스페이스", "기타"]
    @State private var selectedCategory: String
    let onSave: (String) -> Void

    init(selectedCategory: String, onSave: @escaping (String) -> Void) {
        _selectedCategory = State(initialValue: selectedCategory)
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("카테고리 선택")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            ForEach(categories, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedCategory = category }
                } label: {
                    HStack {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.mossTextPrimary)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.mossPrimaryGreen)
                        }
                    }
                    .frame(height: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Button {
                onSave(selectedCategory)
                dismiss()
            } label: { storeInfoPrimaryButton("선택 완료") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground.ignoresSafeArea())
    }
}

private struct MerchantStoreAddressEditor: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String) -> Void
    @State private var address: String
    @State private var showError = false
    @FocusState private var isFocused: Bool

    init(address: String, onSave: @escaping (String) -> Void) {
        self.onSave = onSave
        _address = State(initialValue: address)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("주소 입력")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Text("도로명 주소를 입력해 주세요. 실제 주소 검색 기능은 서버 연동 후 제공됩니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossTextMuted)
                .fixedSize(horizontal: false, vertical: true)
            TextField("예: 광주 북구 비엔날레로 87", text: $address)
                .font(.system(size: 13))
                .focused($isFocused)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(showError ? Color.mossError : Color.mossLine, lineWidth: 1))
            if showError {
                Label("주소를 입력해 주세요.", systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossError)
            }
            Button {
                let value = address.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !value.isEmpty else { showError = true; return }
                onSave(value)
                dismiss()
            } label: { storeInfoPrimaryButton("주소 저장") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .background {
            Color.clear.contentShape(Rectangle()).onTapGesture { isFocused = false }
        }
        .animation(.easeInOut(duration: 0.2), value: showError)
    }
}

private func storeInfoPrimaryButton(_ title: String) -> some View {
    Text(title)
        .font(.system(size: 14, weight: .heavy))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
}
