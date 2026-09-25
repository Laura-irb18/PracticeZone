import SwiftUI

struct MeaningRow: View {
    let definition: String
    let translation: String
    let partOfSpeech: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
            if !translation.isEmpty {
                Text(translation)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    MeaningRow(
        definition: "an arrangement to have something held for you in advance",
        translation: "reserva",
        partOfSpeech: "noun"
    )
    .padding()
}
