import SwiftUI
import UniformTypeIdentifiers

struct MerchantBusinessVerificationSubmission: Identifiable, Equatable {
    let id: UUID
    let businessNumber: String
    let ownerName: String
    let documentName: String
    let submittedAt: Date

    init(businessNumber: String, ownerName: String, documentName: String, submittedAt: Date = Date()) {
        self.id = UUID()
        self.businessNumber = businessNumber
        self.ownerName = ownerName
        self.documentName = documentName
        self.submittedAt = submittedAt
    }
}

struct MerchantBusinessVerificationView: View {
    let onBack: () -> Void
    let onSubmit: (MerchantBusinessVerificationSubmission) -> Void

    @State private var businessNumber = "123-45-67890"
    @State private var ownerName = "치이카와"
    @State private var documentName: String? = "사업자등록증_에이밍.pdf"
    @State private var documentDescription = "PDF · 1.8MB"
    @State private var hasAttemptedSubmit = false
    @State private var numberFormatVerified = false
    @State private var isImportingDocument = false
    @State private var isShowingFileError = false
    @State private var errorPulse = 0
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case businessNumber, ownerName }

    private var numberDigits: String { businessNumber.filter(\.isNumber) }
    private var businessNumberError: String? {
        guard hasAttemptedSubmit else { return nil }
        return numberDigits.count == 10 ? nil : "사업자등록번호 숫자 10자리를 입력해 주세요."
    }
    private var ownerNameError: String? {
        guard hasAttemptedSubmit else { return nil }
        return ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "대표자명을 입력해 주세요." : nil
    }
    private var documentError: String? {
        guard hasAttemptedSubmit else { return nil }
        return documentName == nil ? "사업자등록증 파일을 첨부해 주세요." : nil
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    introduction
                    VStack(alignment: .leading, spacing: 13) {
                        businessNumberField
                        ownerNameField
                        documentField
                    }
                    privacyNotice
                    if isShowingFileError {
                        Label("파일을 읽지 못했습니다. PDF 또는 이미지 파일을 다시 선택해 주세요.", systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossError)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Button(action: submit) {
                        Text("인증 신청하기")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    Text("신청 시 사업자 정보 조회 및 인증 처리에 동의합니다. 이 미리보기에서는 실제 조회/전송을 하지 않습니다.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
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
        .fileImporter(
            isPresented: $isImportingDocument,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false,
            onCompletion: importDocument
        )
        .animation(.easeInOut(duration: 0.2), value: hasAttemptedSubmit)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: numberFormatVerified)
        .animation(.easeInOut(duration: 0.2), value: isShowingFileError)
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
            .accessibilityLabel("이전 화면")
            Spacer()
            Text("사업자 인증")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("내 매장의 업주임을 인증해요")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
            Text("사업자 정보와 등록증을 확인한 뒤 매장 관리 권한을 드립니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var businessNumberField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("사업자등록번호")
            HStack(spacing: 8) {
                TextField("000-00-00000", text: $businessNumber)
                    .font(.system(size: 13))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .businessNumber)
                    .onChange(of: businessNumber) { _, newValue in
                        let digits = String(newValue.filter(\.isNumber).prefix(10))
                        let formatted = formatBusinessNumber(digits)
                        if businessNumber != formatted { businessNumber = formatted }
                        numberFormatVerified = false
                    }
                Button(action: verifyNumberFormat) {
                    Text("확인")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossBrandSage)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(businessNumberError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
            if let businessNumberError {
                fieldError(businessNumberError)
            } else if numberFormatVerified {
                Label("형식 확인 완료 · 미리보기", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Text("숫자 10자리를 입력해 주세요.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mossTextMuted)
            }
        }
    }

    private var ownerNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldTitle("대표자명")
            TextField("대표자명을 입력해 주세요", text: $ownerName)
                .font(.system(size: 13))
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .ownerName)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(ownerNameError == nil ? Color.mossLine : Color.mossError, lineWidth: 1))
            if let ownerNameError { fieldError(ownerNameError) }
        }
    }

    private var documentField: some View {
        VStack(alignment: .leading, spacing: 7) {
            fieldTitle("사업자등록증")
            HStack(spacing: 8) {
                Button { isImportingDocument = true } label: {
                    HStack(spacing: 12) {
                        Image("MerchantVerificationFile")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .frame(width: 40, height: 40)
                            .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(documentName ?? "PDF 또는 이미지 첨부")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundStyle(Color.mossTextPrimary)
                                .lineLimit(1)
                            Text(documentDescription.isEmpty ? "눌러서 파일을 선택해 주세요" : documentDescription)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.mossTextMuted)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if documentName != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            documentName = nil
                            documentDescription = ""
                        }
                    } label: {
                        Image("MerchantVerificationRemove")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("첨부 파일 삭제")
                }
            }
            .padding(14)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(documentError == nil ? Color.mossLine : Color.mossError, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
            .contentShape(Rectangle())
            if let documentError { fieldError(documentError) }
        }
    }

    private var privacyNotice: some View {
        HStack(spacing: 9) {
            Image("MerchantVerificationShield")
                .resizable()
                .frame(width: 17, height: 17)
            Text("관리자가 등록 정보를 확인한 후 승인해요.\n보통 영업일 기준 1~2일이 걸립니다. 파일은 이 기기에서만 선택되며 업로드하지 않습니다.")
                .font(.system(size: 12))
                .foregroundStyle(Color.mossBrandSage)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
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

    private func verifyNumberFormat() {
        focusedField = nil
        guard numberDigits.count == 10 else {
            hasAttemptedSubmit = true
            errorPulse += 1
            return
        }
        numberFormatVerified = true
    }

    private func submit() {
        focusedField = nil
        hasAttemptedSubmit = true
        guard numberDigits.count == 10,
              !ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              documentName != nil else {
            errorPulse += 1
            return
        }
        onSubmit(MerchantBusinessVerificationSubmission(
            businessNumber: businessNumber,
            ownerName: ownerName.trimmingCharacters(in: .whitespacesAndNewlines),
            documentName: documentName ?? ""
        ))
    }

    private func formatBusinessNumber(_ digits: String) -> String {
        let first = String(digits.prefix(3))
        let remaining = String(digits.dropFirst(min(3, digits.count)))
        let second = String(remaining.prefix(2))
        let last = String(remaining.dropFirst(min(2, remaining.count)))
        if digits.count <= 3 { return first }
        if digits.count <= 5 { return first + "-" + second }
        return first + "-" + second + "-" + last
    }

    private func importDocument(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let values = try url.resourceValues(forKeys: [.fileSizeKey])
                let size = ByteCountFormatter.string(fromByteCount: Int64(values.fileSize ?? 0), countStyle: .file)
                withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                    documentName = url.lastPathComponent
                    documentDescription = "\(url.pathExtension.uppercased()) · \(size) · 로컬 미리보기"
                    isShowingFileError = false
                }
            } catch {
                isShowingFileError = true
            }
        case .failure(let error):
            if (error as NSError).code != NSUserCancelledError { isShowingFileError = true }
        }
    }
}
