import SwiftUI

struct MeaningRow: View {
    let definition: String
    let partOfSpeech: String
    let context: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(definition)
                    .font(.title3)
                if !partOfSpeech.isEmpty {
                    Text(partOfSpeech)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }
            if !context.isEmpty {
                Text(context)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ExampleRow: View {
    let text: String
    let translation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(text)
                    .font(.callout.italic())
                SpeakButton(text: text)
                    .font(.footnote)
            }
            if !translation.isEmpty {
                Text(translation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
