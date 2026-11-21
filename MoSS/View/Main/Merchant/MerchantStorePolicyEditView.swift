import SwiftUI

struct MerchantStorePolicyDraft: Equatable {
    var minimumAge = "14"
    var ageGroups: Set<String> = ["중·고등학생", "대학생"]
    var noiseLevel = "매우 조용"
    var outlets = "좌석마다 있음"
    var wifi = "무료 제공"
    var calls = "전용 공간만 가능"
    var laptopUse = "타이핑 가능"
}

struct MerchantStorePolicyEditView: View {
    private enum Field: Hashable { case minimumAge }

    @Binding private var draft: MerchantStorePolicyDraft
    let onBack: () -> Void

    @State private var validationMessage: String?
    @State private var isShowingErrorToast = false
    @State private var isShowingSuccessToast = false
    @State private var errorPulse = 0
    @FocusState private var focusedField: Field?

    private let audienceOptions = ["중·고등학생", "대학생", "직장인", "기타"]

    init(draft: Binding<MerchantStorePolicyDraft>, onBack: @escaping () -> Void) {
        _draft = draft
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    ageCard
                    policyCard
                    if isShowingErrorToast {
                        retryNotice
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if isShowingSuccessToast {
                        successNotice
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Button(action: save) {
                        Text("변경사항 저장")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
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
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: draft)
        .animation(.easeInOut(duration: 0.22), value: validationMessage)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isShowingErrorToast)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isShowingSuccessToast)
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
            .accessibilityLabel("매장 설정으로 돌아가기")
            Spacer()
            Text("이용 정책 수정")
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
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var ageCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("연령·이용자 정보")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            VStack(alignment: .leading, spacing: 6) {
                Text("연령 제한 *")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
                HStack(spacing: 4) {
                    Text("만")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossTextPrimary)
                    TextField("14", text: $draft.minimumAge)
                        .font(.system(size: 12))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .minimumAge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: draft.minimumAge) { _, newValue in
                            let digits = String(newValue.filter(\.isNumber).prefix(3))
                            if digits != newValue { draft.minimumAge = digits }
                            clearFeedback()
                        }
                    Text("세 이상")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossTextPrimary)
                }
                .padding(.horizontal, 13)
                .frame(height: 44)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(validationMessage == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
                if let validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.mossError)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 7, alignment: .leading)], alignment: .leading, spacing: 7) {
                ForEach(audienceOptions, id: \.self) { audience in
                    audienceChip(audience)
                }
            }
        }
        .padding(14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func audienceChip(_ audience: String) -> some View {
        let isSelected = draft.ageGroups.contains(audience)
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                if isSelected { draft.ageGroups.remove(audience) }
                else { draft.ageGroups.insert(audience) }
                clearFeedback()
            }
        } label: {
            Text(audience)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(isSelected ? Color.mossBrandSage : Color.mossSurface, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.mossBrandSage : Color.mossLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var policyCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("공간 이용 정책")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            policyRow(title: "소음 정도", value: $draft.noiseLevel, options: ["매우 조용", "조용", "보통"])
            policyRow(title: "콘센트", value: $draft.outlets, options: ["좌석마다 있음", "일부 좌석", "없음"])
            policyRow(title: "와이파이", value: $draft.wifi, options: ["무료 제공", "유료 제공", "제공 안 함"])
            policyRow(title: "통화", value: $draft.calls, options: ["전용 공간만 가능", "매장 내 가능", "통화 불가"])
            policyRow(title: "노트북", value: $draft.laptopUse, options: ["타이핑 가능", "조용한 키보드만", "노트북 사용 불가"])
        }
        .padding(14)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func policyRow(title: String, value: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            value.wrappedValue = option
                            clearFeedback()
                        }
                    } label: {
                        if value.wrappedValue == option {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                Text(value.wrappedValue)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 10))
            }
            .accessibilityLabel("\(title): \(value.wrappedValue), 선택")
        }
        .frame(minHeight: 26)
    }

    private var retryNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantPolicyCircleAlert")
                .resizable()
                .frame(width: 17, height: 17)
            Text("입력 오류로 저장하지 못했어요. 연령 제한을 수정한 뒤 다시 시도해 주세요.")
                .font(.system(size: 11))
                .foregroundStyle(Color.mossError)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button("재시도") {
                focusedField = .minimumAge
                isShowingErrorToast = false
            }
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(Color.mossError)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFBECE9), in: RoundedRectangle(cornerRadius: 12))
    }

    private var successNotice: some View {
        Label("정책을 미리보기에 저장했어요. 서버 저장은 아직 연결되지 않았습니다.", systemImage: "checkmark.circle.fill")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .background(Color.mossTextPrimary, in: RoundedRectangle(cornerRadius: 12))
    }

    private func save() {
        focusedField = nil
        guard let age = Int(draft.minimumAge), (14...100).contains(age), !draft.ageGroups.isEmpty else {
            validationMessage = "연령 기준을 확인해 주세요. 14~100 사이 숫자를 입력해야 해요."
            isShowingSuccessToast = false
            isShowingErrorToast = true
            errorPulse += 1
            return
        }
        validationMessage = nil
        isShowingErrorToast = false
        isShowingSuccessToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.2)) { isShowingSuccessToast = false }
        }
    }

    private func clearFeedback() {
        validationMessage = nil
        isShowingErrorToast = false
        isShowingSuccessToast = false
    }
}
