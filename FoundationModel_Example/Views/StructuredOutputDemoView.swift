import SwiftUI

struct StructuredOutputDemoView: View {
    @ObservedObject var viewModel: FoundationModelsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("Entity extraction with Generable") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextEditor(text: $viewModel.extractionInput)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))

                        Button("Extract Contact") {
                            Task {
                                await viewModel.runExtraction()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)

                        if let contact = viewModel.extractionResult {
                            Text("Name: \(contact.name)")
                            Text("Email: \(contact.email ?? "N/A")")
                            Text("Phone: \(contact.phone ?? "N/A")")
                            Text("Interests: \(contact.interests.joined(separator: ", "))")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                GroupBox("Summarization") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextEditor(text: $viewModel.summaryInput)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))

                        Button("Generate Summary") {
                            Task {
                                await viewModel.runSummary()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoading)

                        if let brief = viewModel.summaryResult {
                            Text(brief.title)
                                .font(.headline)
                            ForEach(brief.bullets, id: \.self) { bullet in
                                Text("• \(bullet)")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
