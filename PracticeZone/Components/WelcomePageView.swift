import SwiftUI

/// One page of the welcome: a large symbol, a title and a short explanation.
struct WelcomePageView: View {
    let page: WelcomePage
    let focusedPage: AccessibilityFocusState<Int?>.Binding

    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize = 72

    var body: some View {
        GeometryReader { proxy in
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
                // Centers short pages while preserving scrolling room for larger text sizes.
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .center)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    @Previewable @AccessibilityFocusState var focusedPage: Int?
    WelcomePageView(page: WelcomePage.all[1], focusedPage: $focusedPage)
}
