import SwiftUI

struct MultipleChoiceQuestionView: View {
    let meaning: String
    let options: [String]
    let onNext: (String) -> Void

    @State private var selectedOption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Which word means:")
                .font(.headline)
            Text(meaning)
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    optionButton(option)
                }
            }

            if let selectedOption {
                Button("Next") {
                    onNext(selectedOption)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        let isSelected = selectedOption == option

        return Button {
            selectedOption = option
        } label: {
            HStack {
                Text(option)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
            }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(isSelected ? Color.accentColor : .primary)
    }
}

#Preview {
    MultipleChoiceQuestionView(
        meaning: "an arrangement to have something held for you in advance",
        options: ["reservation", "light", "market", "delay"]
    ) { _ in }
    .padding()
}
