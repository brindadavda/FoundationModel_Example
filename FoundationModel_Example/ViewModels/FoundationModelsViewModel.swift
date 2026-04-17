import Foundation
import FoundationModels

@MainActor
final class FoundationModelsViewModel: ObservableObject {
    @Published var chatInput: String = ""
    @Published var chatMessages: [ChatMessage] = []

    @Published var extractionInput: String = "Jane Doe (jane@example.com, +1-555-1010) loves trail running and coffee roasting."
    @Published var extractionResult: ContactCardExtraction?

    @Published var summaryInput: String = "Foundation Models can summarize content directly on device, reducing round trips to servers."
    @Published var summaryResult: DailyBrief?

    @Published var toolDate: String = "2026-04-18"
    @Published var toolResult: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var availabilityText: String {
        switch service.availability {
        case .available:
            return "Available"
        case .unavailable(let reason):
            return "Unavailable: \(reason)"
        }
    }

    private let service: AIService

    init(service: AIService = AIService()) {
        self.service = service

        Task {
            await service.prewarmIfNeeded()
        }
    }

    func sendChat() async {
        await perform {
            let prompt = chatInput
            chatInput = ""
            chatMessages.append(ChatMessage(role: .user, text: prompt))
            let output = try await service.sendChat(prompt: prompt)
            chatMessages.append(ChatMessage(role: .assistant, text: output))
        }
    }

    func runExtraction() async {
        await perform {
            extractionResult = try await service.extractContact(from: extractionInput)
        }
    }

    func runSummary() async {
        await perform {
            summaryResult = try await service.summarize(summaryInput)
        }
    }

    func runToolDemo() async {
        await perform {
            toolResult = try await service.runToolDemo(for: toolDate)
        }
    }

    private func perform(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
