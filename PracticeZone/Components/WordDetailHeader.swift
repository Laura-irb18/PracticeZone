import SwiftUI

struct WordDetailHeader: View {
    let word: String
    let friendlyPronunciation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(word)
                    .font(.largeTitle.bold())
                SpeakButton(text: word)
                    .font(.title2)
            }
            if !friendlyPronunciation.isEmpty {
                Text(friendlyPronunciation)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        WordDetailHeader(word: "reservation", friendlyPronunciation: "reser-vei-shon")
    }
}
