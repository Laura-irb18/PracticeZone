import SwiftUI

/// Shown once, the first time the app opens: what the app does, one page per feature.
struct WelcomeView: View {
    let onFinish: () -> Void

    @State private var currentPage = 0
    @AccessibilityFocusState private var focusedPage: Int?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let pages = WelcomePage.all
    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(pages) { page in
                WelcomePageView(page: page, focusedPage: $focusedPage)
                    .tag(page.id)
            }
        }
        // At accessibility sizes the dots would cover the text; Next and VoiceOver already say where you are.
        .tabViewStyle(.page(indexDisplayMode: dynamicTypeSize.isAccessibilitySize ? .never : .always))
        // A background behind the dots so they stay visible in Light mode.
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .safeAreaInset(edge: .top) {
            if !isLastPage {
                Button("Skip", action: onFinish)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)
                    // Keeps the control clear of the system area and gives it a 44 pt touch target.
                    .padding(.vertical, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomActionButton {
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation { currentPage += 1 }
                }
            } label: {
                Text(isLastPage ? "Get Started" : "Next")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        // VoiceOver reads each new page's title, whether it came from Next or a swipe.
        .onChange(of: currentPage) { _, page in
            focusedPage = page
        }
        .onAppear {
            focusedPage = currentPage
        }
    }
}

#Preview {
    WelcomeView {}
}
