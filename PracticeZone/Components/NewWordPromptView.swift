import SwiftUI

struct NewWordPromptView: View {
    @Binding var word: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .symbolEffect(.breathe, isActive: true)

            Text("Add New Vocabulary")
                .font(.title2)
                .fontWeight(.bold)

            Text("Type an English word and let Apple Intelligence generate its meaning, pronunciation, and example sentences.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("English word", text: $word)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .padding(.top, 8)
        }
        .padding()
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
        .onAppear { isFocused = true }
    }
}

#Preview {
    NewWordPromptView(word: .constant(""))
}
