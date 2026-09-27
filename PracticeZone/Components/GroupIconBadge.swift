import SwiftUI

struct GroupIconBadge: View {
    let iconName: String
    let color: Color
    var size: CGFloat = 32

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: .rect(cornerRadius: size * 0.28))
            .shadow(color: color.opacity(0.4), radius: size * 0.12, y: size * 0.06)
    }
}

#Preview {
    GroupIconBadge(iconName: "book.fill", color: .blue, size: 96)
}
