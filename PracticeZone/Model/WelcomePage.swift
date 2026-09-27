import Foundation

/// One page of the first-launch welcome.
struct WelcomePage: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let detail: LocalizedStringResource
    let systemImage: String

    static let all: [WelcomePage] = [
        WelcomePage(
            id: 0,
            title: "Build Your Library",
            detail: "Create groups by topic, like Travel or Food, and add the words you want to learn.",
            systemImage: "rectangle.stack.fill"
        ),
        WelcomePage(
            id: 1,
            title: "Meanings with AI",
            detail: "Apple Intelligence writes definitions, examples and Spanish translations, right on your device. Check them before saving: AI can make mistakes.",
            systemImage: "apple.intelligence"
        ),
        WelcomePage(
            id: 2,
            title: "Practice with Your Sentences",
            detail: "Write a sentence with each word and get your grammar corrected.",
            systemImage: "target"
        ),
        WelcomePage(
            id: 3,
            title: "Test Yourself",
            detail: "Take an exam on a group. You'll see what you got right on the results screen.",
            systemImage: "list.bullet.clipboard"
        )
    ]
}
