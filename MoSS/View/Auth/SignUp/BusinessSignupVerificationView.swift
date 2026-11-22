import SwiftUI

struct BusinessSignupVerificationView: View {
    @State private var businessNumber = ""
    @State private var ownerName = ""
    @State private var openingDate = ""
    @State private var isTermsAgreed = false
    @State private var hasAttemptedSubmit = false
    @State private var isShowingPreviewNotice = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case businessNumber, ownerName, openingDate
    }

    private var businessNumberDigits: String {
        businessNumber.filter(\.isNumber)
    }

    private var isOpeningDateValid: Bool {
        let components = openingDate.split(separator: ".")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]),
              String(components[0]).count == 4,
              String(components[1]).count == 2,
              String(components[2]).count == 2
        else {
            return false
        }

        let calendar = Calendar(identifier: .gregorian)
        let input = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: input) else { return false }
        let normalized = calendar.dateComponents([.year, .month, .day], from: date)
        return normalized.year == year && normalized.month == month && normalized.day == day
    }

    private var businessNumberError: String? {
        guard hasAttemptedSubmit, businessNumberDigits.count != 10 else { return nil }
        return "사업자등록번호 숫자 10자리를 입력해 주세요."
    }

    private var ownerNameError: String? {
        guard hasAttemptedSubmit,
              ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        return "대표자명을 입력해 주세요."
    }

    private var openingDateError: String? {
        guard hasAttemptedSubmit, !isOpeningDateValid else { return nil }
        return "개업일자를 YYYY.MM.DD 형식으로 입력해 주세요."
    }

    private var termsError: String? {
        hasAttemptedSubmit && !isTermsAgreed ? "필수 약관에 동의해 주세요." : nil
    }

    private var canCompletePreview: Bool {
        businessNumberDigits.count == 10
            && !ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && isOpeningDateValid
            && isTermsAgreed
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    introduction
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 20) {
                        businessNumberField
                        ownerNameField
                        openingDateField
                    }

                    verificationStatus

                    Spacer(minLength: 24)

                    VStack(alignment: .leading, spacing: 6) {
                        MoSSCheckbox(
                            title: "모스의 필수 이용약관 및 개인정보 처리방침에 동의합니다.",
                            isChecked: $isTermsAgreed
                        )
                        if let termsError {
                            fieldError(termsError)
                        }
                    }
                    .padding(.top, 8)

                    MoSSButton(title: "회원 가입 완료 · 미리보기") {
                        focusedField = nil
                        hasAttemptedSubmit = true
                        if canCompletePreview {
                            isShowingPreviewNotice = true
                        }
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .navigationTitle("사업자 확인")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.mossBackground, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: hasAttemptedSubmit)
        .alert("미리보기 전용", isPresented: $isShowingPreviewNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("입력 내용은 저장되거나 전송되지 않았어요. 실제 사업자 조회, 계정 생성 또는 가입 완료는 진행되지 않았습니다.")
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("매장 등록을 시작해요")
                .mossFont(.titleM, weight: .extraBold)
                .foregroundStyle(Color.mossTextPrimary)
            Text("사업자 확인이 끝나면 이벤트 및 광고를 쓸 수 있어요")
                .mossFont(.caption, weight: .regular)
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var businessNumberField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("사업자등록번호")
            TextField("123-45-67890", text: $businessNumber)
                .mossFont(.body, weight: .regular)
                .keyboardType(.numberPad)
                .textContentType(.none)
                .focused($focusedField, equals: .businessNumber)
                .onChange(of: businessNumber) { _, value in
                    let formatted = formatBusinessNumber(value)
                    if formatted != value { businessNumber = formatted }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(businessNumberError == nil ? Color.mossLine : Color.mossError, lineWidth: 1)
                }
            if let businessNumberError {
                fieldError(businessNumberError)
            }
        }
    }

    private var ownerNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("대표자명")
            TextField("갑옷씨", text: $ownerName)
                .mossFont(.body, weight: .regular)
                .textContentType(.name)
                .focused($focusedField, equals: .ownerName)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ownerNameError == nil ? Color.mossLine : Color.mossError, lineWidth: 1)
                }
            if let ownerNameError {
                fieldError(ownerNameError)
            }
        }
    }

    private var openingDateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("개업일자")
            TextField("2010.01.27", text: $openingDate)
                .mossFont(.body, weight: .regular)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .openingDate)
                .onChange(of: openingDate) { _, value in
                    let formatted = formatOpeningDate(value)
                    if formatted != value { openingDate = formatted }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(openingDateError == nil ? Color.mossLine : Color.mossError, lineWidth: 1)
                }
            if let openingDateError {
                fieldError(openingDateError)
            }
        }
    }

    private var verificationStatus: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("확인 상태 미리보기")
                    .mossFont(.label, weight: .bold)
                    .foregroundStyle(.white)
                Text("실제 조회나 알림은 진행되지 않아요.")
                    .mossFont(.caption, weight: .regular)
                    .foregroundStyle(Color.white.opacity(0.82))
            }
            Spacer(minLength: 8)
            Text("미리보기")
                .mossFont(.caption, weight: .bold)
                .foregroundStyle(Color.mossDeepGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.mossSurface.opacity(0.9), in: Capsule())
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(Color.mossBrandSage, in: RoundedRectangle(cornerRadius: 15))
        .accessibilityElement(children: .combine)
    }

    private func fieldTitle(_ title: String) -> some View {
        Text(title)
            .mossFont(.label, weight: .bold)
            .foregroundStyle(Color.mossBrandSage)
    }

    private func fieldError(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .mossFont(.caption, weight: .regular)
            .foregroundStyle(Color.mossError)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func formatBusinessNumber(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(10))
        guard digits.count > 3 else { return digits }
        let first = String(digits.prefix(3))
        let remainder = String(digits.dropFirst(3))
        guard digits.count > 5 else { return "\(first)-\(remainder)" }
        return "\(first)-\(remainder.prefix(2))-\(remainder.dropFirst(2))"
    }

    private func formatOpeningDate(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(8))
        guard digits.count > 4 else { return digits }
        let year = String(digits.prefix(4))
        let remainder = String(digits.dropFirst(4))
        guard digits.count > 6 else { return "\(year).\(remainder)" }
        return "\(year).\(remainder.prefix(2)).\(remainder.dropFirst(2))"
    }
}
