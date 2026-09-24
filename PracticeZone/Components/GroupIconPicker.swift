import SwiftUI

struct GroupIconPicker: View {
    @Binding var selection: String

    static let icons = [
        // Study & language
        "book.fill", "text.book.closed.fill", "character.book.closed.fill", "graduationcap.fill",
        "pencil", "backpack.fill", "bookmark.fill", "lightbulb.fill", "brain.head.profile",
        "bubble.left.and.bubble.right.fill", "character.bubble.fill", "globe.americas.fill", "abc", "doc.text.fill",
        // Travel & places
        "airplane", "car.fill", "bus.fill", "tram.fill", "house.fill", "building.2.fill",
        "building.columns.fill", "tent.fill", "map.fill", "suitcase.fill", "beach.umbrella.fill", "mountain.2.fill",
        // Work & shopping
        "briefcase.fill", "laptopcomputer", "phone.fill", "envelope.fill", "creditcard.fill", "cart.fill",
        "bag.fill", "gift.fill", "shippingbox.fill", "hammer.fill", "wrench.and.screwdriver.fill",
        // Food
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "birthday.cake.fill", "carrot.fill", "basket.fill",
        // Health & sport
        "heart.fill", "cross.case.fill", "stethoscope", "pills.fill", "dumbbell.fill", "figure.run",
        "soccerball", "basketball.fill", "tennisball.fill",
        // Leisure
        "music.note", "headphones", "gamecontroller.fill", "film.fill", "tv.fill", "camera.fill",
        "paintpalette.fill", "theatermasks.fill",
        // Nature
        "leaf.fill", "tree.fill", "sun.max.fill", "cloud.rain.fill", "snowflake", "pawprint.fill",
        "fish.fill", "bird.fill", "teddybear.fill",
        // People & everyday
        "person.fill", "person.2.fill", "figure.2.and.child.holdinghands", "face.smiling", "star.fill",
        "flag.fill", "clock.fill", "calendar"
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.icons, id: \.self) { icon in
                Button {
                    selection = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(.fill.tertiary, in: .circle)
                        .padding(3)
                        .overlay {
                            if selection == icon {
                                Circle().stroke(.secondary, lineWidth: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == icon ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var selection = "book.fill"
    GroupIconPicker(selection: $selection)
        .padding()
}
