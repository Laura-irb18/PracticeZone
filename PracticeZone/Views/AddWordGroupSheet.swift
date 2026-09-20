import SwiftUI

struct AddWordGroupSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var groupDescription = ""
    @State private var selectedIcon = Self.curatedIcons.first!

    let onCreate: (String, String, String) -> Void

    static let curatedIcons = [
        "folder", "book", "character.book.closed", "graduationcap",
        "pencil", "star", "flag", "text.book.closed",
        "lightbulb", "leaf", "globe", "message"
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Group name", text: $name)
                }

                Section("Description") {
                    TextField("Optional description", text: $groupDescription)
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Self.curatedIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 8)
                                    )
                                    .foregroundStyle(selectedIcon == icon ? Color.accentColor : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Word Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onCreate(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            groupDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                            selectedIcon
                        )
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddWordGroupSheet { _, _, _ in }
}
