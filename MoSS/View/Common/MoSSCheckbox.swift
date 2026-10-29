import SwiftUI

struct MoSSCheckbox: View {
    let title: String
    @Binding var isChecked: Bool

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isChecked ? Color.mossBrandSage : Color.mossSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isChecked ? Color.clear : Color.mossLine, lineWidth: 1)
                    }
                    .overlay {
                        if isChecked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .frame(width: 20, height: 20)

                Text(title)
                    .mossFont(.label, weight: .regular)
                    .foregroundStyle(Color.mossBrandSage)
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }
}

#Preview {
    MoSSCheckbox(title: "모스의 필수 이용약관 및 개인정보 처리방침에 동의합니다.", isChecked: .constant(true))
        .padding(24)
        .background(Color.mossBackground)
}
