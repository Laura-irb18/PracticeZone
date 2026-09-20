import SwiftUI

struct SpeakButton: View {
    let text: String
    private let speaker = WordSpeaker.shared

    var body: some View {
        Button {
            speaker.speak(text)
        } label: {
            Image(systemName: speaker.speakingText == text.trimmingCharacters(in: .whitespacesAndNewlines) ? "speaker.wave.2.fill" : "speaker.wave.2")
        }
        .buttonStyle(.borderless)
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}
