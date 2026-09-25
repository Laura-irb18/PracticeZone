import SwiftUI
import SwiftData

struct VocabularyItemEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiStatus) private var aiStatus

    @State private var viewModel = VocabularyItemEditorViewModel()

    let group: WordGroup?
    let item: VocabularyItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Vocabulary", text: $viewModel.word)
                        .onChange(of: viewModel.word) { oldValue, newValue in
                            viewModel.wordChanged(from: oldValue, to: newValue)
                        }
//                        .autocorrectionDisabled()
                    TextField("Friendly Pronunciation (optional)", text: $viewModel.friendlyPronunciation)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } footer: {
                    if !aiStatus.isAvailable {
                        AIUnavailableNote(message: aiStatus.message)
                    }
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
            .navigationTitle(viewModel.isEditing ? "Edit Word" : "New Word")
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
        .onAppear {
            viewModel.load(item)
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
    return VocabularyItemEditorSheet(group: group, item: nil)
        .modelContainer(container)
}
