import SwiftUI

struct PartOfSpeechPicker: View {
    @Binding var selection: PartOfSpeech?

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], alignment: .leading, spacing: 8) {
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
