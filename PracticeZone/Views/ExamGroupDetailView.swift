import SwiftUI
import SwiftData

struct ExamGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let group: WordGroup

    var body: some View {
        List {
            Section {
                NavigationLink {
                    ExamTakingView(group: group)
                } label: {
                    Label("Start Exam", systemImage: "pencil.and.list.clipboard")
                }
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
            context: "used when booking a table, room, or seat",
            order: 0,
            item: item
        )
    ]
    group.items = [item]
    return NavigationStack {
        ExamGroupDetailView(group: group)
    }
}
