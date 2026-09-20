import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            WordGroup.self,
            VocabularyItem.self,
            Meaning.self,
            Example.self,
            PracticeAttempt.self,
            ExamAttempt.self,
            ExamQuestionResult.self
        ])
    }
}
