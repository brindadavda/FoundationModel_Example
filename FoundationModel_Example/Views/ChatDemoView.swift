import SwiftUI

struct ChatDemoView: View {
    @ObservedObject var viewModel: FoundationModelsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Model: \(viewModel.availabilityText)", systemImage: "cpu")
                .font(.footnote)
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.chatMessages) { message in
                        HStack {
                            if message.role == .assistant {
                                Text("🤖 \(message.text)")
                                    .padding(10)
                                    .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                Spacer(minLength: 20)
                            } else {
                                Spacer(minLength: 20)
                                Text("🧑 \(message.text)")
                                    .padding(10)
                                    .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }

            HStack {
                TextField("Ask a question", text: $viewModel.chatInput, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    Task {
                        await viewModel.sendChat()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }

            if viewModel.isLoading {
                ProgressView("Generating…")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}
