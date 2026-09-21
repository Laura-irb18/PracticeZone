import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
