import SwiftUI
import FoundationModels

struct ContentView: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
        case .available where !supportsAppLanguages:
            ContentUnavailableView(
                "The language model doesn't support English and Spanish on this device.",
                systemImage: "apple.intelligence.badge.xmark"
            )
        case .available:
            TabView {
                WordGroupsView()
                    .tabItem {
                        Label("Word Groups", systemImage: "rectangle.stack.fill")
                    }

                ExamsView()
                    .tabItem {
                        Label("Exams", systemImage: "list.bullet.clipboard")
                    }
            }
        case .unavailable(let reason):
            UnavailableView(reason: reason)
        }
    }

    /// The app asks the model for English definitions and examples, and Spanish translations.
    private var supportsAppLanguages: Bool {
        let model = SystemLanguageModel.default
        return model.supportsLocale(Locale(identifier: "en")) && model.supportsLocale(Locale(identifier: "es"))
    }
}

#Preview {
    ContentView()
}
