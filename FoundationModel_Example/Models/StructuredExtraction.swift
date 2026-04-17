import Foundation
import FoundationModels

@Generable
struct ContactCardExtraction {
    // Keep field names short and clear to reduce schema token usage.
    @Guide(description: "Full name of the person.")
    var name: String

    @Guide(description: "Email address if available.")
    var email: String?

    @Guide(description: "Phone number if available.")
    var phone: String?

    @Guide(description: "List of key topics the person is interested in.", .maximumCount(5))
    var interests: [String]
}

@Generable
struct DailyBrief {
    @Guide(description: "A concise title for the summary.")
    var title: String

    @Guide(description: "Three short bullet points that capture the key information.", .count(3))
    var bullets: [String]
}
