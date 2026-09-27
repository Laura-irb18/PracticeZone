import SwiftUI

/// The full-width prominent button pinned to the bottom of a screen for its main action.
struct BottomActionButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) {
            label
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
    }
}

#Preview {
    BottomActionButton {} label: {
        Text("Check Sentence")
    }
    .padding()
}
