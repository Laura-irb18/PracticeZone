import SwiftUI

struct GeneratingWordView: View {
    let word: String
    @State private var show = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .symbolEffect(.breathe, isActive: true)
            Text("Generating details for \"\(word)\"...")
                .font(.title3)
                .fontWeight(.bold)
                .opacity(show ? 1 : 0)
        }
        .padding()
        .padding(.top, 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { show = true }
    }
}

#Preview {
    GeneratingWordView(word: "reservation")
}
