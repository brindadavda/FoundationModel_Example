import Foundation
import FoundationModels

/// A mock tool that demonstrates how the model can call app logic at runtime.
struct MockCalendarTool: Tool {
    @Generable
    struct Arguments {
        @Guide(description: "ISO date in YYYY-MM-DD format.")
        var date: String
    }

    let name = "lookup_calendar"
    let description = "Returns a mock list of calendar events for a date."

    func call(arguments: Arguments) async throws -> String {
        switch arguments.date {
        case "2026-04-18":
            return "10:00 Product sync, 13:00 Design review, 17:00 Gym"
        case "2026-04-19":
            return "09:00 Weekly planning, 14:30 1:1, 19:00 Dinner"
        default:
            return "No events found. Ask the user if they want to create one."
        }
    }
}
