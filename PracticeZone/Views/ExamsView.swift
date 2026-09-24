import SwiftUI
import SwiftData

struct ExamsView: View {
    @Query(sort: \WordGroup.createdAt, order: .reverse) private var wordGroups: [WordGroup]

    var body: some View {
        NavigationStack {
            List {
                ForEach(wordGroups) { group in
                    NavigationLink {
                        ExamGroupDetailView(group: group)
                    } label: {
                        Label {
                            Text(group.name)
                        } icon: {
                            Image(systemName: group.iconName)
                                .foregroundStyle(group.color.color)
                        }
                    }
                }
            }
            .navigationTitle("Exams")
            .overlay {
                if wordGroups.isEmpty {
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
