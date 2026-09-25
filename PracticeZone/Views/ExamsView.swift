import SwiftUI
import SwiftData

struct ExamsView: View {
    @Query(sort: \WordGroup.createdAt, order: .reverse) private var wordGroups: [WordGroup]
    @Environment(\.aiStatus) private var aiStatus

    var body: some View {
        NavigationStack {
            List {
                if aiStatus.isAvailable {
                    ForEach(wordGroups) { group in
                        NavigationLink {
                            ExamGroupDetailView(group: group)
                        } label: {
                            Label {
                                Text(group.name)
                            } icon: {
                                Image(systemName: group.iconName)
                            }
                        }
                    }
                }
            }
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
                        "No Word Groups",
                        systemImage: "rectangle.stack",
                        description: Text("Create a word group first to take an exam.")
                    )
                }
            }
        }
    }
}

#Preview {
    ExamsView()
        .modelContainer(for: WordGroup.self, inMemory: true)
}

#Preview("Without Apple Intelligence") {
    ExamsView()
        .environment(\.aiStatus, .deviceNotEligible)
        .modelContainer(for: WordGroup.self, inMemory: true)
}
