import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FoundationModelsViewModel()

    var body: some View {
        NavigationStack {
            TabView {
                ChatDemoView(viewModel: viewModel)
                    .tabItem {
                        Label("Chat", systemImage: "message")
                    }

                StructuredOutputDemoView(viewModel: viewModel)
                    .tabItem {
                        Label("Structured", systemImage: "list.bullet.clipboard")
                    }

                ToolCallingDemoView(viewModel: viewModel)
                    .tabItem {
                        Label("Tools", systemImage: "hammer")
                    }
            }
            .navigationTitle("Foundation Models")
        }
    }
}

#Preview {
    ContentView()
}
