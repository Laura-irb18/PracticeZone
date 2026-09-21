import SwiftUI
import SwiftData

struct AddVocabularyItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: WordGroup

    @State private var word = ""
    @State private var generator: VocabularyGenerator?
    @State private var saver = VocabularyItemSaver()

    var body: some View {
        ScrollView {
            if let generator {
                if generator.generated == nil {
                    GeneratingWordView(word: generator.word)
                } else if let generated = generator.generated {
                    GeneratedWordDetailView(word: generator.word, generated: generated)
                        .padding()
                }
            } else {
                NewWordPromptView(word: $word)
            }
        }
        .scrollDisabled(generator == nil)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .navigationTitle("New Vocabulary")
        .navigationBarBackButtonHidden(generator?.isGenerating == true)
        .alert(
            "Something went wrong",
            isPresented: errorBinding,
            presenting: generator?.error
        ) { _ in
            Button("OK", role: .cancel) { generator = nil }
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert(
            "Couldn't save this word",
            isPresented: Binding(get: { saver.saveError != nil }, set: { if !$0 { saver.saveError = nil } }),
            presenting: saver.saveError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { generator?.error != nil },
            set: { if !$0 { generator?.error = nil } }
        )
    }

    @ViewBuilder
    private var bottomBar: some View {
        if generator?.isGenerating == true {
            ProgressView()
                .padding()
        } else if let generator, generator.generated != nil {
            HStack {
                Button {
                    startGeneration(word: generator.word)
                } label: {
                    Label("Retry", systemImage: "arrow.counterclockwise")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    save(generator: generator)
                } label: {
                    Label("Save", systemImage: "checkmark")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            Button {
                startGeneration(word: word)
            } label: {
                Label("Generate Vocabulary", systemImage: "sparkles")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding()
        }
    }

    private func startGeneration(word: String) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return }
        let newGenerator = VocabularyGenerator(word: trimmedWord)
        generator = newGenerator
        newGenerator.generate()
    }

    private func save(generator: VocabularyGenerator) {
        guard let generated = generator.generated else { return }
        let didSave = saver.save(
            generated: generated,
            word: generator.word,
            group: group,
            modelContext: modelContext
        )
        if didSave {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        AddVocabularyItemView(group: WordGroup(name: "Sample", groupDescription: "", iconName: "book"))
    }
}
