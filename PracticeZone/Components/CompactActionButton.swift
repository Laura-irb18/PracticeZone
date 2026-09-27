import SwiftUI

/// The prominent capsule, sized to its label, for a screen's main action inside its
/// content (Practice, under the word's `DetailHeader`). Same look as the other main actions in the
/// content (New Group, Add Word, Start Exam): large, bold, bordered. Not Liquid Glass:
/// the HIG keeps glass out of the content layer.
struct CompactActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Inline image instead of a Label: in a list row the Label icon takes the
            // accent color and disappears on the blue button.
            Text("\(Image(systemName: systemImage)) \(title)")
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        // Keeps its full width on narrow screens; the text next to it wraps instead.
        .fixedSize()
    }
}

#Preview {
    CompactActionButton(title: "Practice", systemImage: "target") {}
}
