import SwiftUI

/// Sheet to write or rewrite one meaning's definition. Only the definition is asked;
/// part of speech and context stay empty for meanings the user writes.
struct MeaningEditSheet: View {
    let title: String
    let initialDefinition: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var definition = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Definition", text: $definition, axis: .vertical)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(definition)
                        dismiss()
                    }
                    .disabled(definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear { definition = initialDefinition }
    }
}

#Preview {
    MeaningEditSheet(title: "Edit Meaning", initialDefinition: "a place where you can stay") { _ in }
}
