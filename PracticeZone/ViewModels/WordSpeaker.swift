import AVFoundation
import Observation

@Observable
@MainActor
final class WordSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = WordSpeaker()

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var speakingText: String?

    private override init() {
        super.init()
        synthesizer.delegate = self
        synthesizer.usesApplicationAudioSession = false
    }

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        speakingText = trimmed
        synthesizer.speak(utterance)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speakingText = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speakingText = nil
        }
    }
}
