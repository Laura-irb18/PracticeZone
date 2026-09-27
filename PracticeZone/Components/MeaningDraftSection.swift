import SwiftUI

struct MeaningDraftSection: View {
    @Binding var meaning: MeaningDraft
    let viewModel: VocabularyItemEditorViewModel

    @Environment(\.aiStatus) private var aiStatus

    @State private var isConfirmingRegenerate = false

    private var isPrimary: Bool { viewModel.isPrimary(meaning) }
    private var step: VocabularyItemEditorViewModel.MeaningStep { viewModel.step(for: meaning) }
    private var isGeneratingMeaning: Bool { viewModel.generation == .meaning(meaning.id) }
    private var isTranslating: Bool { viewModel.generation == .translation(meaning.id) }

    /// Only one ✨ per meaning card, in the field the next step fills.
    /// While generating, the icon stays where it started.
    private var showsDefinitionButton: Bool {
        aiStatus.isAvailable && (isGeneratingMeaning || (isPrimary && !isTranslating && step != .needsTranslation))
    }

    private var showsTranslationButton: Bool {
        aiStatus.isAvailable && (isTranslating || (!isGeneratingMeaning && step == .needsTranslation))
    }

    private var showsExamplesButton: Bool {
        aiStatus.isAvailable && step != .needsDefinition
    }

    private var canRegenerate: Bool {
        step == .complete && !isGeneratingMeaning
    }

    var body: some View {
        Section {
            HStack {
                TextField("Definition", text: $meaning.definition, axis: .vertical)
                    .disabled(isGeneratingMeaning)
                if showsDefinitionButton {
                    Button {
                        if isGeneratingMeaning {
                            viewModel.cancelGeneration()
                        } else if canRegenerate {
                            isConfirmingRegenerate = true
                        } else {
                            viewModel.generateMeaning(meaning)
                        }
                    } label: {
                        iconLabel(
                            isGeneratingMeaning ? "Stop Generating" : canRegenerate ? "Regenerate Meaning" : "Generate Meaning",
                            systemImage: canRegenerate ? "arrow.counterclockwise" : "sparkles"
                        )
                    }
                    .buttonStyle(.borderless)
                    .symbolEffect(.breathe, isActive: isGeneratingMeaning)
                    .disabled(!isGeneratingMeaning && !viewModel.canStartGeneration)
                }
            }
            HStack {
                TextField("Spanish translation (optional)", text: $meaning.translation, axis: .vertical)
                    .disabled(isGeneratingMeaning || isTranslating)
                if showsTranslationButton {
                    Button {
                        if isTranslating {
                            viewModel.cancelGeneration()
                        } else {
                            viewModel.translateMeaning(meaning)
                        }
                    } label: {
                        iconLabel(isTranslating ? "Stop Translating" : "Translate", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderless)
                    .symbolEffect(.breathe, isActive: isTranslating)
                    .disabled(!isTranslating && !viewModel.canStartGeneration)
                }
            }
            PartOfSpeechPicker(selection: $meaning.partOfSpeech)
                .padding(.vertical, 4)
                .disabled(isGeneratingMeaning || isTranslating)
        } header: {
            HStack {
                Text("Meaning \(viewModel.number(of: meaning))")
                Spacer()
                if !isPrimary {
                    Button(role: .destructive) {
                        viewModel.removeMeaning(meaning)
                    } label: {
                        iconLabel("Remove Meaning", systemImage: "minus.circle.fill")
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(.borderless)
                    .disabled(viewModel.generation != nil)
                }
            }
        } footer: {
            meaningHint
                .lineLimit(2, reservesSpace: true)
        }
        .headerProminence(.increased)
        .confirmationDialog("Regenerate meaning", isPresented: $isConfirmingRegenerate) {
            Button("Regenerate", role: .destructive) {
                viewModel.regenerateMeaning(meaning)
            }
        } message: {
            Text("Replace this meaning with a new one?")
        }

        ForEach($meaning.examples) { $example in
            let isGeneratingThis = viewModel.generation == .example(meaningID: meaning.id, exampleID: example.id)
            Section {
                HStack {
                    TextField(isGeneratingThis ? "Generating an example…" : "Example sentence", text: $example.text, axis: .vertical)
                        .disabled(isGeneratingThis)
                    if aiStatus.isAvailable && (isGeneratingThis || example.isGenerated) {
                        Button {
                            if isGeneratingThis {
                                viewModel.cancelGeneration()
                            } else {
                                viewModel.regenerateExample(example, in: meaning)
                            }
                        } label: {
                            iconLabel(
                                isGeneratingThis ? "Stop Generating" : "Regenerate Example",
                                systemImage: isGeneratingThis ? "sparkles" : "arrow.counterclockwise"
                            )
                        }
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.breathe, isActive: isGeneratingThis)
                        .disabled(!isGeneratingThis && !viewModel.canStartGeneration)
                    }
                    Button(role: .destructive) {
                        viewModel.removeExample(example, from: meaning)
                    } label: {
                        iconLabel("Remove Example", systemImage: "minus.circle.fill")
                    }
                    .foregroundStyle(.red)
                    .disabled(viewModel.isGeneratingExample(in: meaning))
                }
                .buttonStyle(.borderless)
                TextField("Spanish translation (optional)", text: $example.translation, axis: .vertical)
                    .foregroundStyle(.secondary)
                    .disabled(isGeneratingThis)
            } header: {
                if example.id == meaning.examples.first?.id {
                    Text("Examples")
                }
            } footer: {
                if example.id == meaning.examples.last?.id && meaning.examples.contains(where: \.isGenerated) {
                    Text("Check the examples before saving. AI can make mistakes.")
                }
            }
            .listSectionSpacing(.compact)
        }

        if viewModel.canAddExample(to: meaning) {
            Section {
                HStack {
                    Button("Add Example", systemImage: "plus") {
                        viewModel.addExample(to: meaning)
                    }
                    Spacer()
                    if showsExamplesButton {
                        Button {
                            viewModel.generateExample(for: meaning)
                        } label: {
                            iconLabel("Generate Example", systemImage: "sparkles")
                        }
                        .disabled(!viewModel.canStartGeneration)
                    }
                }
                .buttonStyle(.borderless)
            } header: {
                if meaning.examples.isEmpty {
                    Text("Examples")
                }
            } footer: {
                examplesHint
            }
            .listSectionSpacing(.compact)
        }
    }

    /// An icon-only button label with a 44×44 pt tap area (HIG), without making the icon bigger.
    /// The icon stays against the trailing edge, where it is today.
    private func iconLabel(_ title: LocalizedStringKey, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, alignment: .trailing)
            // 44 pt tall tap area without making the row taller: pad, set the shape, then take the padding back.
            .padding(.vertical, 12)
            .contentShape(.rect)
            .padding(.vertical, -12)
    }

    @ViewBuilder
    private var meaningHint: some View {
        let sparkles = Text(Image(systemName: "sparkles")).foregroundStyle(.tint)
        if !aiStatus.isAvailable {
            Text(step == .needsDefinition ? "Required." : "")
        } else if isGeneratingMeaning {
            Text("Generating the meaning… Tap \(sparkles) to stop.")
        } else if isTranslating {
            Text("Translating… Tap \(sparkles) to stop.")
        } else {
            switch step {
            case .needsDefinition where isPrimary && viewModel.hasWord:
                Text("Required. Type it, or tap \(sparkles) to generate it.")
            case .needsDefinition where isPrimary:
                Text("Required. Type it, or enter a word to generate it with \(sparkles).")
            case .needsDefinition:
                Text("Required. Type it, then tap \(sparkles) to translate it.")
            case .needsTranslation where !viewModel.hasWord:
                Text("Enter a word to translate it with \(sparkles).")
            case .needsTranslation:
                Text("Tap \(sparkles) to add the Spanish translation and part of speech.")
            case .complete where meaning.isGenerated:
                Text("Check the result before saving. AI can make mistakes.")
            case .complete:
                Text("")
            }
        }
    }

    @ViewBuilder
    private var examplesHint: some View {
        let sparkles = Text(Image(systemName: "sparkles")).foregroundStyle(.tint)
        if !aiStatus.isAvailable {
            EmptyView()
        } else if viewModel.isGeneratingExample(in: meaning) {
            Text("Generating an example… Tap \(sparkles) to stop.")
        } else {
            switch step {
            case .needsDefinition:
                Text("Add a definition first to generate examples.")
            case .needsTranslation, .complete:
                if viewModel.hasWord {
                    Text("Tap \(sparkles) to generate an example.")
                } else {
                    Text("Enter a word to generate examples with \(sparkles).")
                }
            }
        }
    }

}

#Preview {
    @Previewable @State var meaning = MeaningDraft()
    Form {
        MeaningDraftSection(meaning: $meaning, viewModel: VocabularyItemEditorViewModel())
    }
}
