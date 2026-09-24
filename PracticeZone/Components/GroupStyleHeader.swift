import SwiftUI

struct GroupStyleHeader: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let iconName: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Word Group")
                    .font(.footnote.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.title.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            GroupIconBadge(iconName: iconName, color: color, size: 96)
                .background {
                    Circle()
                        .fill(color.opacity(0.25))
                        .frame(width: 150, height: 150)
                        .blur(radius: 24)
                }
        }
        .padding(.vertical, 8)
        .animation(.snappy, value: color)
        .animation(.snappy, value: iconName)
    }
}

#Preview {
    GroupStyleHeader(
        title: "Create your word group",
        subtitle: "Choose a color and an icon to make it easy to find.",
        iconName: "book.fill",
        color: .blue
    )
    .padding()
}
