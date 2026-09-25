import SwiftUI
import SwiftData

struct AddVocabularyItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = VocabularyItemEditorViewModel()
    @State private var isConfirmingRegenerate = false

    let group: WordGroup

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Vocabulary", text: $viewModel.word, axis: .vertical)
                        .onChange(of: viewModel.word) { oldValue, newValue in
                            if oldValue.isEmpty && !newValue.isEmpty {
                                viewModel.prewarmMeaningSession()
                            }
                        }
//                        .autocorrectionDisabled()
                }

                Section {
                    TextField("Definition", text: $viewModel.meaning.definition, axis: .vertical)
                    TextField("Spanish translation (optional)", text: $viewModel.meaning.translation, axis: .vertical)
                    PartOfSpeechPicker(selection: $viewModel.meaning.partOfSpeech)
                        .padding(.vertical, 4)
                } header: {
                    Text("Meaning")
                } footer: {
                    meaningHint
                        .lineLimit(2, reservesSpace: true)
                }

                Section {
                    Button {
                        guard !viewModel.isGeneratingMeaning else { return }
                        if viewModel.meaningStep == .complete {
                            isConfirmingRegenerate = true
                        } else {
                            Task {
                                await viewModel.generateMeaning()
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: generateMeaningIcon)
                                .symbolEffect(.breathe, isActive: viewModel.isGeneratingMeaning)
                            Text(generateMeaningTitle)
                        }
                        .frame(minWidth: 220)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.canGenerateMeaning)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .confirmationDialog("Regenerate meaning", isPresented: $isConfirmingRegenerate) {
                        Button("Regenerate", role: .destructive) {
                            Task {
                                await viewModel.regenerateMeaning()
                            }
                        }
                    } message: {
                        Text("Replace this meaning with a new one?")
                    }
                }

                ForEach($viewModel.meaning.examples) { $example in
                    Section {
                        HStack {
                            TextField("Example sentence", text: $example.text, axis: .vertical)
                            Button("Remove Example", systemImage: "minus.circle.fill", role: .destructive) {
                                viewModel.removeExample(example)
                            }
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.red)
                            .buttonStyle(.borderless)
                        }
                        TextField("Spanish translation (optional)", text: $example.translation, axis: .vertical)
                            .foregroundStyle(.secondary)
                    }
                }

                if viewModel.canAddExample {
                    Section {
                        Button("Add Example", systemImage: "plus") {
                            viewModel.addExample()
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
                "Couldn't generate a meaning",
                isPresented: Binding(
                    get: { viewModel.generationError != nil },
                    set: { if !$0 { viewModel.generationError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.generationError?.localizedDescription ?? "")
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
    }

    private var generateMeaningTitle: String {
        guard !viewModel.isGeneratingMeaning else { return "Generating…" }
        return switch viewModel.meaningStep {
        case .needsDefinition: "Generate Meaning"
        case .needsTranslation: "Translate"
        case .complete: "Regenerate"
        }
    }

    private var generateMeaningIcon: String {
        guard !viewModel.isGeneratingMeaning else { return "sparkles" }
        return switch viewModel.meaningStep {
        case .needsDefinition, .needsTranslation: "sparkles"
        case .complete: "arrow.counterclockwise"
        }
    }

    private var meaningHint: Text {
        let sparkles = Text(Image(systemName: "sparkles")).foregroundStyle(.tint)
        let hasWord = viewModel.canGenerateMeaning
        return switch viewModel.meaningStep {
        case .needsDefinition:
            hasWord
                ? Text("Required. Type it, or tap \(sparkles) Generate Meaning.")
                : Text("Required. Type it, or enter a word to use \(sparkles) Generate Meaning.")
        case .needsTranslation:
            hasWord
                ? Text("Tap \(sparkles) Translate to add the Spanish translation and part of speech.")
                : Text("Enter a word to use \(sparkles) Translate.")
        case .complete:
            viewModel.didGenerateMeaning
                ? Text("Check the result before saving. AI can make mistakes.")
                : Text("")
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
