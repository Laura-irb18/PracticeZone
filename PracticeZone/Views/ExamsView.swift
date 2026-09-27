import SwiftUI
import SwiftData

struct ExamsView: View {
    @Query(sort: \WordGroup.createdAt, order: .reverse) private var wordGroups: [WordGroup]
    @Environment(\.aiStatus) private var aiStatus

    @State private var isShowingIntro = false

    var body: some View {
        NavigationStack {
            List {
                if aiStatus.isAvailable && !wordGroups.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Your Groups")
                            .font(.title3.bold())
                        Text("Take an exam to see how much you remember")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    ForEach(wordGroups) { group in
                        NavigationLink {
                            ExamGroupDetailView(group: group)
                        } label: {
                            ExamGroupRow(group: group)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollDisabled(!aiStatus.isAvailable || wordGroups.isEmpty)
            .navigationTitle("Exams")
            .overlay {
                if !aiStatus.isAvailable {
                    ContentUnavailableView(
                        "Exams Unavailable",
                        systemImage: "apple.intelligence.badge.xmark",
                        description: Text(aiStatus.examsMessage)
                    )
                } else if wordGroups.isEmpty {
                    ContentUnavailableView(
                        "Your Library Is Empty",
                        systemImage: "rectangle.stack",
                        description: Text("Create a group in Library to take an exam.")
                    )
                }
            }
            .toolbar {
                if aiStatus.isAvailable {
                    ToolbarItem(placement: .primaryAction) {
                        Button("About Exams", systemImage: "info.circle") {
                            isShowingIntro = true
                        }
                        .disabled(wordGroups.isEmpty)
                    }
                }
            }
            // The same intro shown before the first exam, so it can be read again.
            .sheet(isPresented: $isShowingIntro) {
                ExamIntroView {
                    isShowingIntro = false
                }
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    ExamsView()
        .modelContainer(for: WordGroup.self, inMemory: true)
}

#Preview("With groups") {
    let container = try! ModelContainer(for: WordGroup.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let home = WordGroup(name: "Home", iconName: "house.fill", color: .orange)
    container.mainContext.insert(home)
    let item = VocabularyItem(word: "couch", friendlyPronunciation: "", wordGroup: home)
    item.meanings = [Meaning(definition: "a long seat for several people", partOfSpeech: "noun", order: 0, item: item)]
    home.items = [item]
    home.examAttempts = [
        ExamAttempt(date: .now.addingTimeInterval(-2 * 86_400), multipleChoiceScore: 2, multipleChoiceTotal: 3, productionScore: 2, productionTotal: 2, wordGroup: home)
    ]
    container.mainContext.insert(WordGroup(name: "Work", iconName: "briefcase.fill", color: .purple))
    return ExamsView()
        .modelContainer(container)
}

#Preview("Without Apple Intelligence") {
    ExamsView()
        .environment(\.aiStatus, .deviceNotEligible)
        .modelContainer(for: WordGroup.self, inMemory: true)
}
