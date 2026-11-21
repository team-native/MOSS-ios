import SwiftUI

enum MerchantTab: String, CaseIterable, Identifiable {
    case home = "홈"
    case reviews = "리뷰"
    case store = "매장"
    case more = "더보기"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: "house"
        case .reviews: "text.bubble"
        case .store: "storefront"
        case .more: "line.3.horizontal"
        }
    }
}

struct MerchantWorkspaceView: View {
    let onExit: () -> Void
    @State private var selectedTab: MerchantTab = .home
    @State private var selectedReview: MerchantReviewRecord?
    @State private var selectedReplyEdit: MerchantReviewRecord?
    @State private var selectedStoreDestination: MerchantStoreDestination?
    @State private var operationInfoDraft = MerchantOperationInfoDraft.sample
    @State private var storeInfoDraft = MerchantStoreInfoDraft()
    @State private var replyDrafts: [String: String] = [:]
    @State private var isShowingReviewReport = false
    @State private var submittedReport: MerchantReportSubmission?
    @State private var isShowingReportStatus = false
    @State private var isShowingBusinessVerification = false
    @State private var isShowingVerificationSubmissionNotice = false

    var body: some View {
        Group {
            if isShowingBusinessVerification {
                MerchantBusinessVerificationView(
                    onBack: {
                        withAnimation(.snappy(duration: 0.25)) { isShowingBusinessVerification = false }
                    },
                    onSubmit: {
                        withAnimation(.snappy(duration: 0.25)) { isShowingBusinessVerification = false }
                        isShowingVerificationSubmissionNotice = true
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if isShowingReportStatus, let submittedReport {
                MerchantReportStatusView(
                    submission: submittedReport,
                    onBack: {
                        withAnimation(.snappy(duration: 0.25)) { isShowingReportStatus = false }
                    },
                    onReturnToReviews: {
                        withAnimation(.snappy(duration: 0.25)) {
                            isShowingReportStatus = false
                            isShowingReviewReport = false
                            self.submittedReport = nil
                            selectedReview = nil
                            selectedTab = .reviews
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if isShowingReviewReport, let selectedReview {
                MerchantReviewReportView(
                    review: selectedReview,
                    onBack: {
                        withAnimation(.snappy(duration: 0.25)) { isShowingReviewReport = false }
                    },
                    onSubmit: { reason, details in
                        withAnimation(.snappy(duration: 0.28)) {
                            submittedReport = MerchantReportSubmission(review: selectedReview, reason: reason, details: details)
                            isShowingReviewReport = false
                            isShowingReportStatus = true
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedReplyEdit {
                MerchantReplyEditView(
                    review: selectedReplyEdit,
                    initialReply: replyDrafts[selectedReplyEdit.id] ?? selectedReplyEdit.reply ?? "",
                    onBack: {
                        withAnimation(.snappy(duration: 0.25)) { self.selectedReplyEdit = nil }
                    },
                    onSave: { replyDrafts[selectedReplyEdit.id] = $0 },
                    onDelete: {
                        withAnimation(.snappy(duration: 0.25)) {
                            replyDrafts[selectedReplyEdit.id] = ""
                            self.selectedReplyEdit = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedStoreDestination, selectedStoreDestination == .basicInfo {
                MerchantStoreInfoEditView(draft: $storeInfoDraft) {
                    withAnimation(.snappy(duration: 0.25)) { self.selectedStoreDestination = nil }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedStoreDestination, selectedStoreDestination == .operationInfo {
                MerchantOperationInfoEditView(draft: $operationInfoDraft) {
                    withAnimation(.snappy(duration: 0.25)) { self.selectedStoreDestination = nil }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedStoreDestination, selectedStoreDestination == .menu {
                MerchantMenuManagementView {
                    withAnimation(.snappy(duration: 0.25)) { self.selectedStoreDestination = nil }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedStoreDestination {
                MerchantStoreDestinationPreviewView(destination: selectedStoreDestination) {
                    withAnimation(.snappy(duration: 0.25)) { self.selectedStoreDestination = nil }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let selectedReview {
                MerchantReviewDetailView(
                    review: selectedReview,
                    existingReply: selectedReview.reply,
                    onBack: {
                        withAnimation(.snappy(duration: 0.25)) { self.selectedReview = nil }
                    },
                    onReport: {
                        withAnimation(.snappy(duration: 0.25)) { isShowingReviewReport = true }
                    },
                    onSaveDraft: { replyDrafts[selectedReview.id] = $0 },
                    onSubmitReply: { replyDrafts[selectedReview.id] = $0 }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                switch selectedTab {
                case .home:
                    MerchantHomeView(
                        onSelectTab: { selectedTab = $0 },
                        onSelectStoreDestination: { destination in
                            withAnimation(.snappy(duration: 0.25)) {
                                selectedTab = .store
                                selectedStoreDestination = destination
                            }
                        }
                    )
                case .reviews:
                    MerchantReviewManagementView(replyDrafts: replyDrafts, onSelectReview: { review in
                        withAnimation(.snappy(duration: 0.25)) {
                            if review.reply == nil {
                                selectedReview = review
                            } else {
                                selectedReplyEdit = review
                            }
                        }
                    })
                case .store:
                    MerchantStoreManagementView(onSelectDestination: { destination in
                        withAnimation(.snappy(duration: 0.25)) { selectedStoreDestination = destination }
                    })
                case .more:
                    VStack(spacing: 20) {
                        ComingSoonView(title: "사업자 더보기")
                        Button {
                            withAnimation(.snappy(duration: 0.25)) { isShowingBusinessVerification = true }
                        } label: {
                            Text("사업자 인증 신청")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(Color.mossPrimaryGreen)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        Button(action: onExit) {
                            Text("일반 사용자 화면으로 돌아가기")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.mossPrimaryGreen)
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            merchantTabBar
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("인증 신청 접수 (미리보기)", isPresented: $isShowingVerificationSubmissionNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("인증 신청은 로컬 미리보기로만 처리했습니다. 사업자 정보 조회 및 파일 전송은 진행되지 않았습니다.")
        }
    }

    private var merchantTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MerchantTab.allCases) { tab in
                Button {
                    selectedTab = tab
                    isShowingBusinessVerification = false
                    selectedReview = nil
                    selectedReplyEdit = nil
                    selectedStoreDestination = nil
                    isShowingReviewReport = false
                    isShowingReportStatus = false
                    submittedReport = nil
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: selectedTab == tab ? .heavy : .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.mossPrimaryGreen : Color.mossTextMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 61)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Color.mossSurface)
        .overlay(alignment: .top) { Color.mossLine.frame(height: 1) }
    }
}

private struct MerchantHomeView: View {
    let onSelectTab: (MerchantTab) -> Void
    let onSelectStoreDestination: (MerchantStoreDestination) -> Void
    @State private var isShowingNotice = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    greeting
                    storeStatusCard
                    statistics
                    reportAlert
                    quickTasks
                    recentReviews
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .alert("알림", isPresented: $isShowingNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("새로운 매장 알림은 서버 연동 후 표시됩니다.")
        }
    }

    private var header: some View {
        HStack {
            Color.clear.frame(width: 40, height: 40)
            Spacer()
            Text("사업자 홈")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            Spacer()
            Button { isShowingNotice = true } label: {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.mossBrandSage)
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("알림")
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var greeting: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("안녕하세요, 김민지 사장님")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.mossBrandSage)
                Text("에이밍 스터디카페")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.mossTextPrimary)
            }
            Spacer()
            Text("영업 중")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.mossPrimaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.mossSageSoft, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var storeStatusCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘의 매장 상태")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mossSageTint)
                    Text("정상 운영 중이에요")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text("09:00–23:00")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mossPrimaryGreen, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statistics: some View {
        HStack(spacing: 10) {
            statCard(title: "전체 리뷰", value: "127", caption: "최근 7일 +18%", icon: "star") {
                onSelectTab(.reviews)
            }
            statCard(title: "답글 대기", value: "3건", caption: "오늘 2건 도착", icon: "bubble.left") {
                onSelectTab(.reviews)
            }
            statCard(title: "진행 이벤트", value: "1", caption: "오늘 종료 예정", icon: "eye") {
                onSelectTab(.more)
            }
        }
    }

    private func statCard(title: String, value: String, caption: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossTextMuted)
                    Spacer(minLength: 2)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.mossPrimaryGreen)
                }
                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Color.mossTextPrimary)
                Text(caption)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var reportAlert: some View {
        Button {
            onSelectTab(.store)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "pencil")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.mossWarning)
                VStack(alignment: .leading, spacing: 5) {
                    Text("정보 오류 제보가 1건 왔어요")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.mossWarning)
                    Text("운영 시간 확인 후 정보를 수정해 주세요")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mossWarning)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0xFFF8F0), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.mossWarning, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var quickTasks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("빠른 업무")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.mossTextPrimary)
            HStack(spacing: 10) {
                quickTask("text.bubble", title: "리뷰 답변") { onSelectTab(.reviews) }
                quickTask("clock", title: "영업시간") { onSelectStoreDestination(.operationInfo) }
                quickTask("shippingbox", title: "메뉴 관리") { onSelectStoreDestination(.menu) }
                quickTask("photo", title: "사진 관리") { onSelectStoreDestination(.photos) }
            }
        }
    }

    private func quickTask(_ icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.mossPrimaryGreen)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var recentReviews: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("최근 리뷰")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Button("전체 보기") { onSelectTab(.reviews) }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("공부하는 만쥬")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(Color.mossTextPrimary)
                        Text("오늘 · 오후 2:18")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.mossTextMuted)
                    }
                    Spacer()
                    Label("5.0", systemImage: "star")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.mossWarning)
                }
                Text("매장이 너무 조용해서 좋습니다. 푸드존에선 술이랑 안주도 먹으면서 공부를 할 수 있어서 졸릴 때 자주 애용합니다. 여기서 술 자격증 땄습니다. 항상 감사합니다 사장님^^")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mossBrandSage)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(13)
            .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct MerchantStoreDestinationPreviewView: View {
    let destination: MerchantStoreDestination
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mossTextPrimary)
                        .frame(width: 40, height: 40)
                }
                .accessibilityLabel("매장 관리로 돌아가기")
                Spacer()
                Text(destination.rawValue)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.mossTextPrimary)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            Text("이 화면은 Figma 순서에 따라 다음 단계에서 구현합니다.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mossTextMuted)
                .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.mossBackground.ignoresSafeArea())
    }
}
