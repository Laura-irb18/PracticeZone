import SwiftUI

struct GroupDetailHeader: View {
    let name: String
    let iconName: String
    let color: Color
    let wordCount: Int
    let groupDescription: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(color.gradient, in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.title.bold())
                Text("^[\(wordCount) word](inflect: true)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !groupDescription.isEmpty {
                Text(groupDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        GroupDetailHeader(name: "Travel", iconName: "airplane", color: .blue, wordCount: 0, groupDescription: "Words for booking trips")
    }
}
