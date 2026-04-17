import SwiftUI

struct ToolCallingDemoView: View {
    @ObservedObject var viewModel: FoundationModelsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tool calling demo")
                .font(.headline)

            Text("Enter a date (YYYY-MM-DD). The model can choose to call our mock calendar tool.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            TextField("2026-04-18", text: $viewModel.toolDate)
                .textFieldStyle(.roundedBorder)

            Button("Run Tool Example") {
                Task {
                    await viewModel.runToolDemo()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView("Running tool call…")
            }

            if !viewModel.toolResult.isEmpty {
                Text(viewModel.toolResult)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .padding()
    }
}
