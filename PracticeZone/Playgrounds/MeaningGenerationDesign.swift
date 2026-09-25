import SwiftUI

// Design sketches for the "Generate Meaning" button. Not used by the app.

#Preview("A · Message + button") {
    Form {
        Section {
            TextField("Definition", text: .constant(""), axis: .vertical)
            TextField("Spanish translation (optional)", text: .constant(""))
        } header: {
            Text("Meaning")
        } footer: {
            HStack(spacing: 12) {
                Text("Required. Type it, or tap Generate Meaning.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                Button("Generate Meaning", systemImage: "sparkles") {}
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .frame(width: 44, height: 44)
//                    .buttonStyle(.glass)
            }
        }
    }
}

#Preview("B · Sparkles in header") {
    Form {
        Section {
            TextField("Definition", text: .constant(""), axis: .vertical)
            TextField("Spanish translation (optional)", text: .constant(""))
        } header: {
            HStack {
                Text("Meaning")
                Spacer()
                Button("Generate Meaning", systemImage: "sparkles") {}
                    .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview("C · Sparkles in field") {
    Form {
        Section("Meaning") {
            HStack {
                TextField("Definition", text: .constant(""), axis: .vertical)
                Button("Generate Meaning", systemImage: "sparkles") {}
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }
            TextField("Spanish translation (optional)", text: .constant(""))
        }
    }
}
