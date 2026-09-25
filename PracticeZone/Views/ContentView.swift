import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var aiStatus = AIStatus.current

    var body: some View {
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
        .environment(\.aiStatus, aiStatus)
        // The framework doesn't notify availability changes, so check again when the app comes back.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                aiStatus = .current
            }
        }
    }
}

#Preview {
    ContentView()
}
