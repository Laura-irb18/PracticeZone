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

#Preview {
    MeaningRow(
        definition: "an arrangement to have something held for you in advance",
        partOfSpeech: "noun",
        context: "used when booking a table, room, or seat"
    )
    .padding()
}
