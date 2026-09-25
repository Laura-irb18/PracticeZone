import SwiftUI

/// The full-width prominent button pinned to the bottom of a screen for its main
/// action (Practice's Check Sentence, the exam's Check Sentence / Try Again).
struct BottomActionButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) {
            label
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#Preview {
    BottomActionButton {} label: {
        Text("Check Sentence")
    }
    .padding()
}
