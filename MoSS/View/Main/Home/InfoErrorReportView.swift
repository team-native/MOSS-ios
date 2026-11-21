import PhotosUI
import SwiftUI

struct InfoErrorReportView: View {
    let place: Place
    let onBack: () -> Void
    let onSubmit: (ReportRecord) -> Void

    @State private var selectedCategory = "가격"
    @State private var reportText = "가격 정보가 달라서 제 전재산은 2500원 뿐이었는데 3000이더라고요. 가격이 인상됐어요. 신속한 수정 부탁드립니다."
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var hasAttemptedSubmit = false
    @FocusState private var isReportTextFocused: Bool

    private let categories = ["가격", "연령 제한", "운영 시간", "소음", "구비 시설", "기타"]

    private var isReportTextValid: Bool {
        !reportText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    placeSummary
                    categorySelector
                    reportContent
                    if hasAttemptedSubmit && !isReportTextValid {
                        validationNotice
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    attachmentSection
                    notice
                    Button(action: submit) {
                        Text("제보하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.mossTextPrimary.opacity(0.08), radius: 6, y: 4)
                    }
                    .opacity(isReportTextValid ? 1 : 0.7)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { isReportTextFocused = false }
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: hasAttemptedSubmit)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: isReportTextValid)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("장소 상세로 돌아가기")
            Spacer()
            Text("정보 오류 제보")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var placeSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(place.name)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(place.noiseLevel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mossSageTint, in: RoundedRectangle(cornerRadius: 6))
            }
            Text(place.address)
                .font(.system(size: 13))
                .foregroundStyle(Color.mossBrandSage)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.mossLine, lineWidth: 1))
    }

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            requiredTitle("오류 항목을 선택해주세요")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    let selected = selectedCategory == category
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 13, weight: selected ? .bold : .medium))
                            .foregroundStyle(selected ? Color.white : Color.mossBrandSage)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .background(selected ? Color.mossPrimaryGreen : Color.mossSurface, in: Capsule())
                            .overlay(Capsule().stroke(selected ? Color.mossPrimaryGreen : Color.mossLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }

    private var reportContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            requiredTitle("제보 내용을 작성해주세요")
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    if reportText.isEmpty {
                        Text("오류 내용을 구체적으로 적어주세요.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.mossTextMuted)
                            .padding(.horizontal, 5)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $reportText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mossTextPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, -4)
                        .padding(.vertical, -6)
                        .focused($isReportTextFocused)
                        .onChange(of: reportText) { _, newValue in
                            if newValue.count > 500 {
                                reportText = String(newValue.prefix(500))
                            }
                        }
                }
                .frame(height: 74)
                HStack {
                    Text("정확한 정보 반영에 큰 도움이 됩니다")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mossPrimaryGreen)
                    Spacer()
                    Text("\(reportText.count) / 500")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mossLine, lineWidth: 1))
        }
    }

    private var attachmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("증빙 사진 첨부 (선택)")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 3, matching: .images) {
                HStack(spacing: 12) {
                    Image("InfoReportCamera")
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color.mossPrimaryGreen)
                        .frame(width: 40, height: 40)
                        .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedPhotos.isEmpty ? "오류 증빙 사진 추가하기" : "사진 \(selectedPhotos.count)장 선택됨")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.mossTextPrimary)
                        Text("가격표, 운영시간 안내판 등 촬영 사진 (최대 3장)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4])).foregroundStyle(Color.mossLine))
            }
            .buttonStyle(.plain)
        }
    }

    private var notice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("InfoReportInfo")
                .frame(width: 14.4, height: 14.4)
                .foregroundStyle(Color(hex: 0xEAA850))
            Text("입력한 내용과 사진 선택은 로컬 미리보기에서만 유지돼요. 실제 접수·사진 전송·처리 결과 안내는 서버 연결 후 제공됩니다.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x7A4E1B))
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF9F0), in: RoundedRectangle(cornerRadius: 12))
    }

    private var validationNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("제보 내용을 입력해주세요.")
                .font(.system(size: 12, weight: .semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.mossWarning)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF4F2), in: RoundedRectangle(cornerRadius: 12))
    }

    private func requiredTitle(_ title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Text("*")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossWarning)
        }
    }

    private func submit() {
        hasAttemptedSubmit = true
        guard isReportTextValid else {
            isReportTextFocused = true
            return
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        let report = ReportRecord(
            id: "report-local-\(UUID().uuidString)",
            category: .information,
            title: "\(place.name) · \(selectedCategory)",
            summary: reportText.trimmingCharacters(in: .whitespacesAndNewlines),
            submittedAt: "\(formatter.string(from: Date())) 접수",
            status: "로컬 미리보기",
            isLocalPreview: true
        )
        isReportTextFocused = false
        onSubmit(report)
    }
}
