import SwiftUI
import FoundationModels

struct ContentView: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
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
}

#Preview {
    ContentView()
}
