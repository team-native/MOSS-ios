import PhotosUI
import SwiftUI
import UIKit

struct ProfileEditView: View {
    let onBack: () -> Void

    @State private var nickname = "제초 5급 노리는 햄스터"
    @State private var password = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isShowingSaveNotice = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    profileSection
                    formSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            saveButton
        }
        .background(Color.mossBackground.ignoresSafeArea())
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else { return }
            Task {
                guard let data = try? await newPhoto.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                profileImage = image
            }
        }
        .alert("안내", isPresented: $isShowingSaveNotice) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("입력 내용은 미리보기 화면에만 반영됩니다. 실제 계정 정보 저장은 서버 연동 후 제공됩니다.")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.mossTextPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.mossSageTint, lineWidth: 1)
                    }
            }
            .accessibilityLabel("마이페이지로 돌아가기")
            Text("회원 정보 수정")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.mossTextPrimary)
                .frame(maxWidth: .infinity)
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    private var profileSection: some View {
        VStack(spacing: 12) {
            Text("프로필")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            Group {
                if let profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("MockProfile")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 88, height: 88)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("프로필 사진 바꾸기", systemImage: "square.and.pencil")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mossPrimaryGreen)
                    .frame(width: 214, height: 38)
                    .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.mossSageTint, lineWidth: 1)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("기본 정보")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            labeledField("닉네임") {
                TextField("닉네임", text: $nickname)
                    .textInputAutocapitalization(.never)
            }
            labeledField("이메일") {
                TextField("이메일", text: .constant("s26043@gsm.hs.kr"))
                    .disabled(true)
            }
            labeledField("전화번호") {
                TextField("전화번호", text: .constant("010-1234-5678"))
                    .disabled(true)
            }
            labeledField("비밀번호 변경") {
                SecureField("비밀번호를 입력해주세요", text: $password)
            }
        }
    }

    private func labeledField<Field: View>(_ title: String, @ViewBuilder content: () -> Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.mossBrandSage)
            content()
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.mossTextPrimary)
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .background(Color.mossSurface, in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mossSageTint, lineWidth: 1)
                }
        }
    }

    private var saveButton: some View {
        Button {
            isShowingSaveNotice = true
        } label: {
            Text("저장")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.mossDarkAction, in: RoundedRectangle(cornerRadius: 18))
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}
