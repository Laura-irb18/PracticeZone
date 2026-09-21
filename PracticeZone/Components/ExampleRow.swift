import SwiftUI

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

#Preview {
    ExampleRow(
        text: "We made a reservation for dinner at eight.",
        translation: "Hicimos una reserva para cenar a las ocho."
    )
    .padding()
}
