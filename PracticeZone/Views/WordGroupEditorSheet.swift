import SwiftUI
import SwiftData

struct WordGroupEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = WordGroupEditorViewModel()

    let group: WordGroup?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    GroupStyleHeader(
                        title: viewModel.isEditing ? "Edit your word group" : "Create your word group",
                        subtitle: "Choose a color and an icon to make it easy to find.",
                        iconName: viewModel.iconName,
                        color: viewModel.color.color
                    )
                }
                .listRowBackground(Color.clear)


                Section("") {
                    TextField("Group name", text: $viewModel.name)
                    TextField("Optional description", text: $viewModel.groupDescription)
                }

                Section {
                    GroupColorPicker(selection: $viewModel.color)
                }

                Section {
                    GroupIconPicker(selection: $viewModel.iconName)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        viewModel.save(in: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.load(group)
            }
        }
    }
}

#Preview {
    WordGroupEditorSheet(group: nil)
        .modelContainer(for: WordGroup.self, inMemory: true)
}
