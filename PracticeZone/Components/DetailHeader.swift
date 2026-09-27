import SwiftUI

/// The header of a detail screen, modeled on the iTunes Store album page: the group's
/// badge on the leading side, the title on top, small details at the bottom and the
/// screen's main action, if it has one, as a capsule on the trailing side.
struct DetailHeader<Title: View, Details: View, Action: View>: View {
    let iconName: String
    let color: Color
    @ViewBuilder let title: Title
    @ViewBuilder let details: Details
    @ViewBuilder let action: Action

    private let badgeSize: CGFloat = 110

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            GroupIconBadge(iconName: iconName, color: color, size: badgeSize)
            VStack(alignment: .leading, spacing: 0) {
                title
                Spacer(minLength: 8)
                HStack(alignment: .bottom) {
                    details
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    action
                }
            }
            .frame(minHeight: badgeSize)
        }
        // Room for the badge's shadow, which the list row would otherwise clip.
        .padding(.vertical, 16)
    }
}

#Preview {
    List {
        DetailHeader(iconName: "airplane", color: .blue) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Travel")
                    .font(.title2.bold())
                Text("Words for booking trips")
                    .foregroundStyle(.secondary)
            }
        } details: {
            Text("12 words")
        } action: {
            CompactActionButton(title: "Practice", systemImage: "target") {}
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}
