import SwiftUI
import SwiftData

struct AddVocabularyItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = VocabularyItemEditorViewModel()

    let group: WordGroup

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Vocabulary", text: $viewModel.word, axis: .vertical)
                        .onChange(of: viewModel.word) { oldValue, newValue in
                            viewModel.wordChanged(from: oldValue, to: newValue)
                        }
//                        .autocorrectionDisabled()
                }

                ForEach($viewModel.meanings) { $meaning in
                    MeaningDraftSection(meaning: $meaning, viewModel: viewModel)
                }

                if viewModel.canAddMeaning {
                    Section {
                        Button("Add Meaning", systemImage: "plus") {
                            viewModel.addMeaning()
                        }
                    }
                }
            }
            .navigationTitle("New Word")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        if viewModel.save(to: group, in: modelContext) {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(
                viewModel.generationErrorTitle,
                isPresented: Binding(
                    get: { viewModel.generationError != nil },
                    set: { if !$0 { viewModel.generationError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.generationErrorMessage)
            }
            .alert(
                "Couldn't save the word",
                isPresented: Binding(
                    get: { viewModel.saveError != nil },
                    set: { if !$0 { viewModel.saveError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.saveError?.localizedDescription ?? "")
            }
        }
        .onDisappear {
            viewModel.cancelGeneration()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: WordGroup.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let group = WordGroup(name: "Travel")
    container.mainContext.insert(group)
    return AddVocabularyItemView(group: group)
        .modelContainer(container)
}
