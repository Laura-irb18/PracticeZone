import SwiftUI

/// The top of an exam group, above Start Exam: the exam symbol in the group's color,
/// a question and a motivating message picked once per visit. The message is left
/// out when the exam can't start yet.
struct ExamHeader: View {
    let color: Color
    var isReady = true

    @State private var message = Self.messages.randomElement() ?? ""

    private static let messages: [LocalizedStringKey] = [
        "Every word you practice sticks a little more.",
        "Mistakes are part of learning.",
        "One word at a time.",
        "Small steps, big progress.",
        "You've got this!"
    ]

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundStyle(color)
                .padding(.bottom, 8)
            Text("Ready for your exam?")
                .font(.title2.bold())
            if isReady {
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ExamHeader(color: .blue)
}
