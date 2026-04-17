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
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch let toolError as LanguageModelSession.ToolCallError {
            // If the model attempts a tool call and it fails, expose a useful message.
            throw AppError.userFacing(
                "Tool call failed for '\(toolError.tool.name)'. Check permissions and tool logic, then retry."
            )
        } catch let generationError as LanguageModelSession.GenerationError {
            // GenerationError error -1 in UI is typically an opaque fallback for one of these cases.
            // Map known cases to clearer guidance for people using the demo.
            throw AppError.userFacing(message(for: generationError))
        } catch {
            // A resilient fallback for demo UX: return deterministic tool output when generation fails.
            let fallback = try await MockCalendarTool().call(arguments: .init(date: date))
            return """
            The model couldn't complete a full tool-calling generation right now.
            Fallback events for \(date): \(fallback)
            """
        }
    }

    func userFacingErrorMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.localizedDescription
        }
        if let generationError = error as? LanguageModelSession.GenerationError {
            return message(for: generationError)
        }
        return error.localizedDescription
    }

    private func verifyAvailability() throws {
        guard case .available = model.availability else {
            throw AIServiceError.modelUnavailable(model.availability)
        }
    }

    private func message(for error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .assetsUnavailable:
            return "Model assets are unavailable. Ensure Apple Intelligence is enabled and assets are downloaded."
        case .exceededContextWindowSize:
            return "Session context is too large. Start a new session or shorten instructions/prompts."
        case .unsupportedLanguageOrLocale:
            return "The requested language/locale is not supported by the current model."
        case .guardrailViolation:
            return "The request was blocked by model safety guardrails. Rephrase to a safer prompt."
        case .refusal:
            return "The model refused the request. Try a clearer and policy-compliant prompt."
        case .decodingFailure:
            return "The model response could not be decoded into the expected format. Retry or simplify output constraints."
        case .unsupportedGuide:
            return "The guided generation schema includes unsupported constraints. Simplify @Guide rules."
        @unknown default:
            return "Generation failed with an unknown Foundation Models error. Retry after checking availability and prompt size."
        }
    }
}

private enum AppError: LocalizedError {
    case userFacing(String)

    var errorDescription: String? {
        switch self {
        case .userFacing(let message):
            return message
        }
    }
}
