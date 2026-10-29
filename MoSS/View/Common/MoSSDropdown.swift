import SwiftUI

/// 라벨 + 선택 메뉴 (피그마 "학년 구분" 드롭다운)
struct MoSSDropdown<Option: Hashable>: View {
    let label: String
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .mossFont(.label)
                .foregroundStyle(Color.mossBrandSage)

            Menu {
                Picker(label, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(title(option)).tag(option)
                    }
                }
            } label: {
                HStack {
                    Text(title(selection))
                        .mossFont(.body)
                        .foregroundStyle(Color.mossTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mossBrandSage)
                }
                .padding(.horizontal, 16)
                .frame(height: Layout.inputHeight)
                .background(Color.mossSurface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.inputRadius))
            }
        }
    }
}

#Preview {
    MoSSDropdown(
        label: "학년 구분",
        options: Grade.allCases,
        selection: .constant(.univ),
        title: \.title
    )
    .padding(24)
    .background(Color.mossBackground)
}
