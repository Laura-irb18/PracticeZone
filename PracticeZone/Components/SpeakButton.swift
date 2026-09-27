import SwiftUI

struct SpeakButton: View {
    let text: String
    /// Where the icon sits inside its 44 pt tap area: next to the word it follows (.leading)
    /// or against the row's edge (.trailing).
    var iconAlignment: Alignment = .leading
    private let speaker = WordSpeaker.shared

    private var isSpeaking: Bool {
        speaker.speakingText == text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Button {
            speaker.speak(text)
        } label: {
            Label("Listen", systemImage: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .labelStyle(.iconOnly)
                // 44×44 pt tap area (HIG) without making the icon bigger.
                .frame(minWidth: 44, minHeight: 44, alignment: iconAlignment)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .accessibilityValue(isSpeaking ? "Playing" : "")
        // VoiceOver goes quiet while the text is spoken, so the two voices don't overlap.
        .accessibilityAddTraits(.startsMediaSession)
    }
}

#Preview {
    SpeakButton(text: "reservation")
        .font(.title2)
        .padding()
}
