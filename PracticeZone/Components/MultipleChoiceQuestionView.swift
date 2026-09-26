import SwiftUI

struct MultipleChoiceQuestionView: View {
    let meaning: String
    let options: [String]
    let onNext: (String) -> Void
    let onSkip: () -> Void

    @State private var selectedOption: String?
    @State private var isConfirmingSkip = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Which word means:")
                .font(.headline)
            Text(meaning)
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    optionButton(option, letter: Self.letter(for: index))
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                BottomActionButton {
                    if let selectedOption {
                        onNext(selectedOption)
                    }
                } label: {
                    Text("Next")
                }
                .disabled(selectedOption == nil)

                Button {
                    isConfirmingSkip = true
                } label: {
                    Text("Skip Question")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .confirmationDialog("Skip Question?", isPresented: $isConfirmingSkip, titleVisibility: .visible) {
                    Button("Skip Question", role: .destructive) {
                        onSkip()
                    }
                } message: {
                    Text("It counts as incorrect, and you can't go back to it.")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    /// "A", "B", "C", "D"… for the option at `index`.
    private static func letter(for index: Int) -> String {
        String(UnicodeScalar(UInt8(65 + index)))
    }

    private func optionButton(_ option: String, letter: String) -> some View {
        let isSelected = selectedOption == option

        return Button {
            selectedOption = option
        } label: {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.subheadline.bold())
                    .foregroundStyle(isSelected ? Color.white : Color.secondary)
                    .frame(width: 32, height: 32)
                    .background {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.accentColor : Color.clear)
                            Circle()
                                .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 1.5)
                        }
                    }

                Text(option)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            }
            .contentShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    MultipleChoiceQuestionView(
        meaning: "an arrangement to have something held for you in advance",
        options: ["reservation", "light", "market", "delay"]
    ) { _ in
    } onSkip: {
    }
}
