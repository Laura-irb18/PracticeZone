import SwiftUI

struct ExampleRow: View {
    let text: String
    let translation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(text)
                    .font(.callout.italic())
                    // The sentence always shows in full: it wraps instead of being cut off with "…".
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SpeakButton(text: text, iconAlignment: .trailing)
                    .font(.subheadline)
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
    List {
        ExampleRow(
            text: "Please keep your luggage with you at all times while you are waiting at the gate.",
            translation: "Por favor, mantenga su equipaje con usted en todo momento mientras espera en la puerta."
        )
    }
}
