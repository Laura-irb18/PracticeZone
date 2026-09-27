import SwiftUI

struct PartOfSpeechPicker: View {
    @Binding var selection: PartOfSpeech?

    /// Grows with the text, so larger sizes fit fewer chips per row instead of truncating them.
    @ScaledMetric(relativeTo: .subheadline) private var minimumChipWidth = 110

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumChipWidth))], alignment: .leading, spacing: 8) {
            ForEach(PartOfSpeech.allCases, id: \.self) { partOfSpeech in
                let isSelected = selection == partOfSpeech
                Button {
                    selection = isSelected ? nil : partOfSpeech
                } label: {
                    Text(partOfSpeech.label.capitalized)
                        .font(.subheadline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.fill.tertiary),
                            in: .rect(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: PartOfSpeech? = nil
    PartOfSpeechPicker(selection: $selection)
        .padding()
}
