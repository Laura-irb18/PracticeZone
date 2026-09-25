import SwiftUI

/// Says why an AI feature is turned off. Each screen passes the `AIStatus` message that fits it.
struct AIUnavailableNote: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "apple.intelligence.badge.xmark")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview("Editor") {
    AIUnavailableNote(message: AIStatus.modelNotReady.message)
        .padding()
}

#Preview("Practice") {
    AIUnavailableNote(message: AIStatus.deviceNotEligible.practiceMessage)
        .padding()
}
