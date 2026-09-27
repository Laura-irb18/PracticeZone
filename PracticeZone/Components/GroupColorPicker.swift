import SwiftUI

struct GroupColorPicker: View {
    @Binding var selection: GroupColor

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(GroupColor.allCases) { groupColor in
                Button {
                    selection = groupColor
                } label: {
                    Circle()
                        .fill(groupColor.color.gradient)
                        .frame(width: 32, height: 32)
                        .padding(3)
                        .overlay {
                            if selection == groupColor {
                                Circle().stroke(.secondary, lineWidth: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(groupColor.rawValue.capitalized)
                .accessibilityAddTraits(selection == groupColor ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var selection = GroupColor.blue
    GroupColorPicker(selection: $selection)
        .padding()
}
