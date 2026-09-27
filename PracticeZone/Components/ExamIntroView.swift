import SwiftUI

/// Shown before the first exam question, laid out like the system's "What's New"
/// sheets. Production grading only checks grammar, so the learner is told that
/// using the word, with the right meaning, is up to them.
struct ExamIntroView: View {
    let onContinue: () -> Void

    @AccessibilityFocusState private var isTitleFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Before You Start")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isTitleFocused)

                rule(
                    "Make each sentence yours",
                    systemImage: "pencil.line",
                    detail: "AI checks that your sentence is well written, not whether your word is in it. Use it with the meaning you studied: that's where the learning happens."
                )
                rule(
                    "No going back",
                    systemImage: "arrow.forward",
                    detail: "Once you answer or skip a question, you can't return to it."
                )
                rule(
                    "Answers at the end",
                    systemImage: "eye.slash",
                    detail: "You'll see what you got right on the results screen."
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "apple.intelligence")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Text("Your sentences are checked by Apple Intelligence, right on your device. They never leave your device. AI feedback can make mistakes, so if a correction doesn't look right, compare it with what you studied.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                BottomActionButton(action: onContinue) {
                    Text("Continue")
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .onAppear {
            // VoiceOver starts at the title instead of the sheet's grabber.
            isTitleFocused = true
        }
    }

    private func rule(_ title: String, systemImage: String, detail: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(.tint)
                .frame(width: 32)
        }
    }
}

#Preview {
    ExamIntroView {}
}
