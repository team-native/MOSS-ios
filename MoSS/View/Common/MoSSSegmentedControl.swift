import SwiftUI

/// 피그마 "가입 유형" 토글 형태의 세그먼트 컨트롤
struct MoSSSegmentedControl<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    selection = option
                } label: {
                    Text(title(option))
                        .mossFont(.label, weight: isSelected ? .bold : .medium)
                        .foregroundStyle(isSelected ? Color.white : Color.mossBrandSage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(isSelected ? Color.mossBrandSage : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color.mossSageSoft)
        .clipShape(RoundedRectangle(cornerRadius: Layout.inputRadius))
        .animation(.easeInOut(duration: 0.15), value: selection)
    }
}

#Preview {
    MoSSSegmentedControl(
        options: [UserRole.student, .business],
        selection: .constant(.student),
        title: { $0 == .student ? "학생 가입" : "업주 가입" }
    )
    .padding(24)
    .background(Color.mossBackground)
}
