import Foundation
import FoundationModels

@MainActor
final class AIService {
    enum AIServiceError: LocalizedError {
        case modelUnavailable(SystemLanguageModel.Availability)
        case emptyPrompt

        var errorDescription: String? {
            switch self {
            case .modelUnavailable(let availability):
                return "Model unavailable: \(availability)"
            case .emptyPrompt:
                return "Please enter a prompt before sending."
            }
        }
    }

    private let model: SystemLanguageModel
    private let session: LanguageModelSession

    init(model: SystemLanguageModel = .default) {
        self.model = model

        // Instructions should be stable, safe, and role-defining.
        let instructions = Instructions {
            "You are a concise assistant inside an iOS app."
            "Prioritize clear, accurate responses in plain language."
            "If a tool is available and useful, call it."
        }

        self.session = LanguageModelSession(
            model: model,
            tools: [MockCalendarTool()],
            instructions: instructions
        )
    }

    var availability: SystemLanguageModel.Availability {
        model.availability
    }

    var transcript: Transcript {
        session.transcript
    }

    func prewarmIfNeeded() async {
        do {
            try await session.prewarm(promptPrefix: "User asks general productivity questions.")
        } catch {
            // Ignore prewarm errors; requests can still proceed.
        }
    }

    func sendChat(prompt: String) async throws -> String {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.emptyPrompt
        }
        try verifyAvailability()

        let response = try await session.respond(to: prompt)
        return response.content
    }

    func summarize(_ text: String) async throws -> DailyBrief {
        try verifyAvailability()

        return try await session.respond(generating: DailyBrief.self) {
            Prompt {
                "Summarize the following text into a title and 3 bullets:"
                text
            }
        }.content
    }

    func extractContact(from text: String) async throws -> ContactCardExtraction {
        try verifyAvailability()

        return try await session.respond(generating: ContactCardExtraction.self) {
            Prompt {
                "Extract a contact card from this text."
                text
            }
        }.content
    }

    func runToolDemo(for date: String) async throws -> String {
        try verifyAvailability()

        let prompt = "Use the calendar tool to get events for \(date), then present a friendly schedule."
        let response = try await session.respond(to: prompt)
        return response.content
    }

    private func verifyAvailability() throws {
        guard case .available = model.availability else {
            throw AIServiceError.modelUnavailable(model.availability)
        }
    }
}
