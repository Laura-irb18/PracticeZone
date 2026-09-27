import SwiftUI

/// Shown before the first exam question, laid out like the system's "What's New"
/// sheets. Production grading only checks grammar, so the learner is told that
/// using the word, with the right meaning, is up to them.
struct ExamIntroView: View {
    let onContinue: () -> Void

    @AccessibilityFocusState private var isTitleFocused: Bool
    @ScaledMetric(relativeTo: .title) private var ruleIconSize = 44

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
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
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: ruleIconSize, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: ruleIconSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ExamIntroView {}
}
