import SwiftUI

/// One page of the welcome: a large symbol, a title and a short explanation.
struct WelcomePageView: View {
    let page: WelcomePage
    let focusedPage: AccessibilityFocusState<Int?>.Binding

    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize = 72

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: page.systemImage)
                    .font(.system(size: symbolSize))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                VStack(spacing: 12) {
                    Text(page.title)
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused(focusedPage, equals: page.id)
                    Text(page.detail)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.top, 80)
            // Leaves room for the page dots at large text sizes.
            .padding(.bottom, 48)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    @Previewable @AccessibilityFocusState var focusedPage: Int?
    WelcomePageView(page: WelcomePage.all[1], focusedPage: $focusedPage)
}
