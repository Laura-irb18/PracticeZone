import SwiftUI

/// A group in the Exams list: its badge, name, when it was last examined and a
/// capsule with its word count and last score. Modeled on Podcasts' episode rows.
struct ExamGroupRow: View {
    let group: WordGroup

    var body: some View {
        HStack(spacing: 14) {
            GroupIconBadge(iconName: group.iconName, color: group.color.color, size: 72)
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.title3.bold())
                lastExamText
                    .font(.caption)
                    .foregroundStyle(.secondary)
                summary
                    .font(.subheadline)
                    // Neutral text: group colors don't reach 4.5:1 on the capsule in Light mode.
                    // The badge already carries the group's color.
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.fill.tertiary, in: .capsule)
                    .padding(.top, 2)
            }
        }
    }

    private var lastAttempt: ExamAttempt? {
        group.sortedExamAttempts.first
    }

    @ViewBuilder
    private var lastExamText: some View {
        if let lastAttempt {
            Text("Last exam \(lastAttempt.date, format: .relative(presentation: .named))")
        } else {
            Text("Not taken yet")
        }
    }

    @ViewBuilder
    private var summary: some View {
        if group.examItems.isEmpty {
            Text("Add words first")
        } else if let lastAttempt {
            Text("^[\(group.items.count) word](inflect: true) · **\(lastAttempt.scorePercentage)%**")
        } else {
            Text("^[\(group.items.count) word](inflect: true)")
        }
    }
}

#Preview {
    let travel = WordGroup(name: "Travel", iconName: "airplane", color: .blue)
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "", wordGroup: travel)
    item.meanings = [Meaning(definition: "an arrangement to have something held for you in advance", partOfSpeech: "noun", order: 0, item: item)]
    travel.items = [item]
    travel.examAttempts = [
        ExamAttempt(date: .now.addingTimeInterval(-2 * 86_400), multipleChoiceScore: 2, multipleChoiceTotal: 3, productionScore: 2, productionTotal: 2, wordGroup: travel)
    ]
    let empty = WordGroup(name: "Empty", iconName: "tray", color: .gray)
    return List {
        ExamGroupRow(group: travel)
        ExamGroupRow(group: empty)
    }
    .listStyle(.plain)
}
