import SwiftUI
import SwiftData

struct ExamGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiStatus) private var aiStatus
    let group: WordGroup

    @State private var isTakingExam = false
    @State private var isShowingIntro = false
    @AppStorage("hasSeenExamIntro") private var hasSeenExamIntro = false

    var body: some View {
        List {
            VStack(spacing: 20) {
                ExamHeader(color: group.color.color, isReady: startExamNote == nil)
                VStack(spacing: 8) {
                    startExamButton
                    Text(startExamNote ?? details)
                        .font(.footnote)
                        // Why the exam can't start is essential; the details are secondary.
                        .foregroundStyle(startExamNote == nil ? HierarchicalShapeStyle.secondary : HierarchicalShapeStyle.primary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("History") {
                if group.sortedExamAttempts.isEmpty {
                    Text("No exams yet. Your results will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(group.sortedExamAttempts) { attempt in
                        NavigationLink {
                            ExamResultView(attempt: attempt)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(attempt.scorePercentage)%")
                                    .font(.headline)
                                Text(attempt.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAttempt(attempt)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        // An alternative to the swipe (HIG: offer alternatives to gestures).
                        .contextMenu {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteAttempt(attempt)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingIntro, onDismiss: {
            // Only Continue marks the intro as seen; swiping it down doesn't start the exam.
            if hasSeenExamIntro {
                isTakingExam = true
            }
        }) {
            ExamIntroView {
                hasSeenExamIntro = true
                isShowingIntro = false
            }
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $isTakingExam) {
            ExamTakingView(group: group)
        }
    }

    /// Why the exam can't start, or nil when it can.
    /// ExamsView already hides groups without AI; this covers losing it while here.
    private var startExamNote: String? {
        if !aiStatus.isAvailable {
            aiStatus.examsMessage
        } else if group.examItems.isEmpty {
            "Add words with meanings to this group to take an exam."
        } else {
            nil
        }
    }

    /// Under Start Exam, like the price under Fitness's subscribe button: "12 words · Last exam 80%".
    private var details: String {
        let words = group.items.count == 1 ? "1 word" : "\(group.items.count) words"
        guard let lastAttempt = group.sortedExamAttempts.first else { return words }
        return "\(words) · Last exam \(lastAttempt.scorePercentage)%"
    }

    /// Full width, like Fitness's subscribe button. Bordered, not Liquid Glass: it's in the content.
    private var startExamButton: some View {
        Button {
            if hasSeenExamIntro {
                isTakingExam = true
            } else {
                isShowingIntro = true
            }
        } label: {
            // Inline image instead of a Label: in a list row the Label icon takes the
            // accent color and disappears on the blue button.
            Text("\(Image(systemName: "play.fill")) Start Exam")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .padding(.horizontal)
        .disabled(startExamNote != nil)
    }

    private func deleteAttempt(_ attempt: ExamAttempt) {
        modelContext.delete(attempt)
    }
}

#Preview {
    let group = WordGroup(name: "Travel", groupDescription: "Words for booking trips", iconName: "airplane")
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon", wordGroup: group)
    item.meanings = [
        Meaning(
            definition: "an arrangement to have something held for you in advance",
            partOfSpeech: "noun",
            order: 0,
            item: item
        )
    ]
    group.items = [item]
    return NavigationStack {
        ExamGroupDetailView(group: group)
    }
}

#Preview("With history") {
    let group = WordGroup(name: "Travel", iconName: "airplane")
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "", wordGroup: group)
    item.meanings = [Meaning(definition: "an arrangement to have something held for you in advance", partOfSpeech: "noun", order: 0, item: item)]
    group.items = [item]
    group.examAttempts = [
        ExamAttempt(multipleChoiceScore: 2, multipleChoiceTotal: 3, productionScore: 2, productionTotal: 2, wordGroup: group),
        ExamAttempt(date: .now.addingTimeInterval(-86_400), multipleChoiceScore: 1, multipleChoiceTotal: 3, productionScore: 1, productionTotal: 2, wordGroup: group)
    ]
    return NavigationStack {
        ExamGroupDetailView(group: group)
    }
}

#Preview("Empty group") {
    NavigationStack {
        ExamGroupDetailView(group: WordGroup(name: "Travel", iconName: "airplane"))
    }
}
