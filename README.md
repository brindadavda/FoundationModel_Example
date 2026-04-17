# FoundationModel_Example

A complete beginner → advanced learning project for Apple’s **Foundation Models** framework (Swift + SwiftUI, MVVM, iOS 26+).

This project teaches and demonstrates:
- Prompt-based generation with `LanguageModelSession`
- Structured output with `@Generable`
- Tool calling with a custom `Tool`
- Multi-turn chat with transcript-backed session state
- Production-friendly app architecture and error handling

---

## 📚 Official Reference
- Apple Documentation: https://developer.apple.com/documentation/FoundationModels

> This guide follows Apple terminology and concepts directly: `SystemLanguageModel`, `LanguageModelSession`, `Prompt`, `Instructions`, `Transcript`, `Tool`, and `Generable`.

---

## 1) What are Foundation Models in iOS?

The Foundation Models framework is Apple’s native API for using the on-device language model behind Apple Intelligence in your app.

At a high level:
- You use `SystemLanguageModel` to represent the model available on device.
- You create a `LanguageModelSession` to maintain context and generate responses.
- You provide `Instructions` (role/policy) and `Prompt` (task input).
- The framework stores interaction history in a `Transcript`.
- You can add `Tool`s for runtime data/actions.
- You can request typed responses with `Generable` instead of parsing raw text.

---

## 2) Why use Foundation Models? (real-world use cases)

### Excellent fits
- AI writing assistance in notes, messaging, CRM, project tools
- Summarization of user-selected text/doc sections
- Entity extraction (contacts, tasks, dates, tags)
- Content refinement (tone change, shortening, cleanup)
- Guided app workflows where model calls app tools for data

### Example product scenarios
- **Email app:** summarize long threads + draft concise replies
- **Learning app:** explain dense text at beginner/intermediate levels
- **Task app:** convert free-form notes into structured tasks
- **Personal journal:** daily reflection summarization and insights

---

## 3) Key features

### On-device AI (Apple Intelligence)
- Uses Apple’s on-device model through `SystemLanguageModel`
- Reduces cloud dependency for many tasks
- Helps with privacy-sensitive use cases

### Structured output (`Generable`)
- Define a Swift type with `@Generable`
- Request typed output directly: `respond(generating: Type.self)`
- Avoid fragile post-processing and regex parsing

### Tool calling
- Define a `Tool` with typed arguments/output
- Let the model decide when tool invocation is useful
- Great for dynamic app data (calendar, inventory, status)

### Prompt-based generation
- Use clear prompts with scoped task instructions
- Combine system-level behavior (`Instructions`) with task input (`Prompt`)

---

## 4) Capabilities covered in this project

Based on Apple Foundation Models docs, this example demonstrates:
- **Text generation**: chat tab
- **Summarization**: `DailyBrief` generation
- **Entity extraction**: `ContactCardExtraction` from free text
- **Content refinement**: can be done by changing prompt style/task in chat

---

## 5) Foundation Models vs Core ML vs traditional APIs

## Foundation Models
- Best for natural language tasks with prompt-driven behavior
- Includes session/transcript, tool calling, guided generation
- Minimal model plumbing in app code

## Core ML
- Best for custom/local ML models you ship or convert
- You control model architecture and inference pipeline
- Better when you need deterministic custom model behavior

## Traditional API-only AI approach
- Useful for server-owned model governance + heavy workloads
- Requires network and backend orchestration
- Higher privacy/network complexity for user-generated content

**Practical rule:**
- Use Foundation Models first for on-device language UX.
- Use Core ML for specialized non-LLM or custom model tasks.
- Use remote APIs for heavy, centralized, or org-specific model requirements.

---

## 6) High-level architecture overview

1. **UI (SwiftUI Views)** captures user intent
2. **ViewModel (MVVM)** manages state, async flow, loading/errors
3. **AIService** wraps Foundation Models APIs
4. `AIService` owns:
   - `SystemLanguageModel`
   - `LanguageModelSession` (instructions + tools)
5. Responses return as:
   - Text (`String`) for chat/tool summaries
   - Typed models (`Generable`) for extraction/summaries

---

## 7) When to use vs when NOT to use

## Use Foundation Models when
- You need interactive language features in app UX
- Data is user-local and privacy-sensitive
- You benefit from typed generation + tool calls
- Task complexity fits on-device context/latency constraints

## Avoid / reconsider when
- Task needs huge context windows across massive corpora
- You require strict deterministic outputs only
- Device or Apple Intelligence availability is uncertain for your user base
- Workload is too heavy for on-device performance targets

---

## 8) Performance considerations

- Check model availability before showing AI-only flows
- Keep prompts/instructions concise to reduce token usage
- Use smaller `Generable` schemas when possible
- Reuse session for multi-turn context, reset when context gets too large
- Consider prewarming with `session.prewarm(promptPrefix:)`
- Profile runtime behavior with Instruments when tuning UX

---

## 9) Limitations and requirements

- Requires **Apple Intelligence enabled** in device settings
- Requires **eligible Apple device** that supports Apple Intelligence
- Requires **iOS 26+** (this project targets iOS 26.4)
- Model availability can be `.modelNotReady` during download/initialization

---

## 10) Security & privacy

Foundation Models are designed for on-device use with Apple Intelligence.
Best practices:
- Minimize sensitive content in prompts
- Avoid putting untrusted text into `Instructions`
- Keep instructions role/policy oriented, not user content
- Use tools only for trusted app actions/data boundaries

---

## 11) Step-by-step integration guide

## A. Xcode setup
1. Install latest Xcode (with iOS 26 SDK support).
2. Open `FoundationModel_Example.xcodeproj`.
3. Confirm deployment target is iOS 26+.

## B. Minimum iOS version
- Set iOS deployment target to **26.0 or higher**.
- This sample is configured to iOS 26.4 in project settings.

## C. Enable Apple Intelligence
On your test device:
1. Open **Settings**
2. Navigate to **Apple Intelligence** (name may vary slightly by locale/build)
3. Enable Apple Intelligence and wait for model readiness

## D. Import framework
In files that use model APIs:
```swift
import FoundationModels
```

## E. Basic configuration pattern
```swift
let model = SystemLanguageModel.default
let instructions = Instructions {
    "You are a concise app assistant."
}
let session = LanguageModelSession(model: model, tools: [MyTool()], instructions: instructions)
let response = try await session.respond(to: "Summarize this note")
```

---

## 12) Full example project (MVVM)

Features included:
- **AI Chat Interface** (prompt → response)
- **Structured Output** (`Generable` extraction + summarization)
- **Tool Calling** (mock calendar tool)

### Important files
- `FoundationModel_Example/Services/AIService.swift`
- `FoundationModel_Example/Services/MockCalendarTool.swift`
- `FoundationModel_Example/ViewModels/FoundationModelsViewModel.swift`
- `FoundationModel_Example/Views/*`
- `FoundationModel_Example/Models/StructuredExtraction.swift`

---

## 13) Folder structure

```text
FoundationModel_Example/
├─ FoundationModel_ExampleApp.swift
├─ ContentView.swift
├─ Models/
│  ├─ ChatMessage.swift
│  └─ StructuredExtraction.swift
├─ Services/
│  ├─ AIService.swift
│  └─ MockCalendarTool.swift
├─ ViewModels/
│  └─ FoundationModelsViewModel.swift
└─ Views/
   ├─ ChatDemoView.swift
   ├─ StructuredOutputDemoView.swift
   └─ ToolCallingDemoView.swift
```

---

## 14) Advanced usage

## Prompt engineering techniques
- Keep prompts explicit and task-bound
- Specify output constraints (length, style, format)
- Separate role (`Instructions`) from user task (`Prompt`)

## Improve response quality
- Provide short, high-signal context
- Ask for stepwise reasoning *format* (without requesting hidden chain-of-thought)
- Use typed generation for important structured data

## Multi-turn conversations with transcript
- Reuse one `LanguageModelSession` for ongoing chat
- Session transcript accumulates user + assistant turns
- For large tasks, split work into multiple sessions to avoid context overflow

## Tool integration strategy
- Use tools for dynamic, non-static data
- Keep tool scope narrow and descriptions precise
- Return concise tool output the model can reason over

## Performance optimization
- Prewarm sessions on startup screens if appropriate
- Use small `Generable` types
- Avoid verbose instructions and giant prompt payloads
- Periodically summarize and reset long conversations

---

## 15) Apple-aligned best practices

- Keep prompts minimal and clear
- Prefer structured output (`Generable`) over manual parsing
- Use tools for dynamic app data and side effects
- Treat on-device model as capable but resource-bounded
- Handle availability states gracefully in UI
- Validate and sanitize user-facing outputs where needed

---

## 16) Sample prompts + expected outputs

## Chat
Prompt:
> “Give me a 3-step morning focus routine.”

Expected:
- Short actionable routine (3 steps)
- Friendly tone
- No unsupported claims

## Entity extraction (Generable)
Input:
> “Alex Kim (alex@sample.com, +1-555-9876) likes climbing and watercolor.”

Expected `ContactCardExtraction`:
- `name`: "Alex Kim"
- `email`: "alex@sample.com"
- `phone`: "+1-555-9876"
- `interests`: ["climbing", "watercolor"]

## Tool calling
Prompt:
> “Use the calendar tool for 2026-04-18 and plan my day.”

Expected:
- Model invokes tool
- Receives mock events
- Returns organized schedule advice

## Summarization
Input:
> A paragraph about product updates

Expected `DailyBrief`:
- Concise title
- 3 key bullets

---

## 17) Running the project

1. Open project in Xcode
2. Select iOS 26+ device with Apple Intelligence support
3. Build & run
4. Use tabs:
   - Chat
   - Structured
   - Tools

If the model is unavailable, UI shows availability state and error feedback.

---

## 18) Notes on evolving SDK behavior

Foundation Models APIs may evolve between iOS 26.x releases. Keep an eye on:
- API signature changes in docs
- Updated availability behavior
- New use cases or guardrail options in `SystemLanguageModel`

Always re-validate your app with latest Apple documentation and SDK release notes.

---

## 19) Troubleshooting common runtime errors

### `FoundationModels.LanguageModelSession.GenerationError error -1`

If your UI shows a generic message like:
> “The operation couldn’t be completed. (FoundationModels.LanguageModelSession.GenerationError error -1.)”

it usually means Foundation Models threw a typed `GenerationError`, but the UI only displayed a generic localized fallback.

Common root causes and handling:
- **Model assets unavailable** (`assetsUnavailable`)  
  Ensure Apple Intelligence is enabled and model assets are downloaded.
- **Context too large** (`exceededContextWindowSize`)  
  Start a new session and shorten instructions/prompt/output length.
- **Unsupported locale** (`unsupportedLanguageOrLocale`)  
  Keep prompts in supported locales, check locale support in advance.
- **Guardrail/refusal** (`guardrailViolation`, `refusal`)  
  Rephrase prompts to safer, clearer, app-focused requests.
- **Guided output decode/schema issues** (`decodingFailure`, `unsupportedGuide`)  
  Simplify `@Generable` schema and `@Guide` constraints.

In this sample, `AIService` now maps generation/tool errors to actionable user messages and includes a fallback path in the tool demo.

### `com.apple.UnifiedAssetFramework Code=5000` (Model Catalog)

If logs contain:
- `Error Domain=com.apple.UnifiedAssetFramework Code=5000`
- `There are no underlying assets ... for asset set com.apple.modelcatalog`
- `ModelManagerError ... Code=1026`

then the device does not currently have usable Apple Intelligence model assets.

Checklist:
1. Verify device is Apple Intelligence-compatible.
2. Ensure Apple Intelligence is enabled in **Settings**.
3. Keep device on **Wi‑Fi + power** until model download completes.
4. Reboot device after enabling Apple Intelligence.
5. Re-test on a real device (simulator support can differ by seed/version).

The repeated `CHHapticPattern ... hapticpatternlibrary.plist` lines are keyboard/haptic warnings and are not the root cause of Foundation Models generation failure.
