import SwiftUI
import SwiftData

struct AddVocabularyItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: WordGroup

    @State private var word = ""
    @State private var generator: VocabularyGenerator?
    @State private var saveError: String?

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
            isPresented: Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } }),
            presenting: saveError
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

        if let generatedWord = generated.word,
           generatedWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != generator.word.lowercased() {
            saveError = "The generated details didn't match \"\(generator.word)\". Try again."
            return
        }

        let meaningEntries = dedupedMeanings(from: generated.meanings ?? [])
        guard !meaningEntries.isEmpty else {
            saveError = "Couldn't generate a meaning for \"\(generator.word)\". Try again."
            return
        }

        let item = VocabularyItem(
            word: generator.word,
            friendlyPronunciation: sanitizedPronunciation(generated.friendlyPronunciation, word: generator.word),
            wordGroup: group
        )

        for (index, entry) in meaningEntries.enumerated() {
            let meaning = Meaning(
                definition: entry.definition,
                partOfSpeech: entry.partOfSpeech,
                context: entry.context,
                order: index,
                item: item
            )
            item.meanings.append(meaning)
        }

        for generatedExample in generated.examples ?? [] {
            let example = Example(
                text: generatedExample.text ?? "",
                friendlyPronunciation: sanitizedPronunciation(generatedExample.friendlyPronunciation, word: nil),
                translation: generatedExample.translation ?? "",
                item: item
            )
            item.examples.append(example)
        }

        modelContext.insert(item)
        group.items.append(item)
        dismiss()
    }

    private struct MeaningEntry {
        let definition: String
        let partOfSpeech: String
        let context: String
    }

    private func dedupedMeanings(from generated: [GeneratedMeaning.PartiallyGenerated]) -> [MeaningEntry] {
        var seen = Set<String>()
        var result: [MeaningEntry] = []
        for entry in generated {
            guard let definition = entry.definition?.trimmingCharacters(in: .whitespacesAndNewlines), !definition.isEmpty else { continue }
            let key = definition.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(MeaningEntry(
                definition: definition,
                partOfSpeech: entry.partOfSpeech.map(String.init(describing:)) ?? "other",
                context: entry.context ?? ""
            ))
        }
        return result
    }

    private func sanitizedPronunciation(_ raw: String?, word: String?) -> String {
        guard let raw else { return "" }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZáéíóúüñÁÉÍÓÚÜÑ -")
        let cleaned = raw.unicodeScalars.filter { allowed.contains($0) }.map(Character.init)
        let result = String(cleaned).trimmingCharacters(in: .whitespaces)
        if let word, result.lowercased() == word.lowercased() { return "" }
        return result
    }
}

private struct NewWordPromptView: View {
    @Binding var word: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .symbolEffect(.breathe, isActive: true)

            Text("Add New Vocabulary")
                .font(.title2)
                .fontWeight(.bold)

            Text("Type an English word and let Apple Intelligence generate its meaning, pronunciation, and example sentences.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("English word", text: $word)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .padding(.top, 8)
        }
        .padding()
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
        .onAppear { isFocused = true }
    }
}

private struct GeneratingWordView: View {
    let word: String
    @State private var show = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .symbolEffect(.breathe, isActive: true)
            Text("Generating details for \"\(word)\"...")
                .font(.title3)
                .fontWeight(.bold)
                .opacity(show ? 1 : 0)
        }
        .padding()
        .padding(.top, 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { show = true }
    }
}

private struct GeneratedWordDetailView: View {
    let word: String
    let generated: GeneratedVocabulary.PartiallyGenerated

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                SpeakButton(text: word)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Pronunciation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(generated.friendlyPronunciation ?? "Generating...")
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Meanings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let meanings = generated.meanings, !meanings.isEmpty {
                    ForEach(Array(meanings.enumerated()), id: \.offset) { _, meaning in
                        MeaningRow(
                            definition: meaning.definition ?? "Generating...",
                            partOfSpeech: meaning.partOfSpeech.map(String.init(describing:)) ?? "",
                            context: meaning.context ?? ""
                        )
                    }
                } else {
                    Text("Generating...")
                        .font(.title3)
                }
            }

            if let examples = generated.examples, !examples.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Examples")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                        ExampleRow(
                            text: example.text ?? "Generating...",
                            translation: example.translation ?? ""
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        AddVocabularyItemView(group: WordGroup(name: "Sample", groupDescription: "", iconName: "book"))
    }
}
