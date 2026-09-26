import SwiftUI
import SwiftData

struct ExamGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiStatus) private var aiStatus
    let group: WordGroup

    @State private var isTakingExam = false

    var body: some View {
        List {
            Section {
                Button {
                    isTakingExam = true
                } label: {
                    Label("Start Exam", systemImage: "pencil.and.list.clipboard")
                }
                // ExamsView already hides groups without AI; this covers losing it while here.
                .disabled(!aiStatus.isAvailable)
            }

            if !group.sortedExamAttempts.isEmpty {
                Section("History") {
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
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .fullScreenCover(isPresented: $isTakingExam) {
            ExamTakingView(group: group)
        }
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
