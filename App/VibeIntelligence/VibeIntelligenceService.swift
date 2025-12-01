//
//  VibeIntelligenceService.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import Foundation
import AppKit

// MARK: - AI Provider
enum AIProvider: String, CaseIterable {
    case auto
    case anthropic
    case openai
    case gemini
    case vibecaas  // VibeCaaS-vl:2b local vision model
    case ollama
    case lmstudio
    
    var displayName: String {
        switch self {
        case .auto: return "Auto-detect"
        case .anthropic: return "Anthropic Claude"
        case .openai: return "OpenAI GPT"
        case .gemini: return "Google Gemini"
        case .vibecaas: return "VibeCaaS-vl:2b (Vision)"
        case .ollama: return "Ollama (Local)"
        case .lmstudio: return "LM Studio (Local)"
        }
    }
    
    var icon: String {
        switch self {
        case .auto: return "sparkle.magnifyingglass"
        case .anthropic: return "cloud"
        case .openai: return "brain"
        case .gemini: return "sparkles"
        case .vibecaas: return "eye.circle"
        case .ollama: return "desktopcomputer"
        case .lmstudio: return "server.rack"
        }
    }
    
    var isLocal: Bool {
        switch self {
        case .vibecaas, .ollama, .lmstudio: return true
        default: return false
        }
    }
}

// MARK: - Service Errors
enum VibeIntelligenceError: LocalizedError {
    case noAPIKey
    case networkError(String)
    case apiError(String)
    case emptyResponse
    case invalidProvider
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .emptyResponse:
            return "Received empty response"
        case .invalidProvider:
            return "No valid AI provider available"
        }
    }
}

// MARK: - VibeIntelligence Service
class VibeIntelligenceService {
    static let shared = VibeIntelligenceService()
    
    private let configManager = ConfigManager.shared
    private let keychainManager = KeychainManager.shared
    private let anthropicURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let openaiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let geminiURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!
    private let ollamaURL = URL(string: "http://localhost:11434/api/generate")!
    private let lmstudioURL = URL(string: "http://localhost:1234/v1/chat/completions")!
    
    private init() {}
    
    // MARK: - Main Processing Method
    
    func process(text: String, mode: ProcessingMode) async throws -> String {
        let systemPrompt = getSystemPrompt(for: mode)
        let provider = await determineProvider()
        
        switch provider {
        case .anthropic:
            return try await callAnthropic(systemPrompt: systemPrompt, userText: text)
        case .openai:
            return try await callOpenAI(systemPrompt: systemPrompt, userText: text)
        case .gemini:
            return try await callGemini(systemPrompt: systemPrompt, userText: text)
        case .vibecaas:
            return try await callVibeCaaS(systemPrompt: systemPrompt, userText: text)
        case .ollama:
            return try await callOllama(systemPrompt: systemPrompt, userText: text)
        case .lmstudio:
            return try await callLMStudio(systemPrompt: systemPrompt, userText: text)
        case .auto:
            throw VibeIntelligenceError.invalidProvider
        }
    }
    
    /// Process text with an image using VibeCaaS-vl vision model
    func processWithImage(text: String, image: NSImage, mode: ProcessingMode) async throws -> String {
        let systemPrompt = getSystemPrompt(for: mode)
        return try await OllamaManager.shared.analyzeImage(image, prompt: "\(systemPrompt)\n\nUser request: \(text)")
    }
    
    // MARK: - Provider Detection
    
    private func determineProvider() async -> AIProvider {
        let preferred = configManager.currentProvider
        
        if preferred != .auto {
            return preferred
        }
        
        // Auto-detect: try local first (VibeCaaS-vl has priority for vision tasks)
        let ollamaAvailable = await isOllamaAvailable()
        
        if OllamaManager.shared.isModelInstalled && ollamaAvailable {
            return .vibecaas
        }
        
        if ollamaAvailable {
            return .ollama
        }
        
        if await isLMStudioAvailable() {
            return .lmstudio
        }
        
        // Check which cloud providers have keys configured
        if keychainManager.hasAPIKey(for: .anthropic) {
            return .anthropic
        }
        
        if keychainManager.hasAPIKey(for: .openai) {
            return .openai
        }
        
        if keychainManager.hasAPIKey(for: .gemini) {
            return .gemini
        }
        
        // Default to anthropic (will show error if no key)
        return .anthropic
    }
    
    func isOllamaAvailable() async -> Bool {
        let url = URL(string: "http://localhost:11434/api/tags")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    func isLMStudioAvailable() async -> Bool {
        let url = URL(string: "http://localhost:1234/v1/models")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Anthropic API
    
    private func callAnthropic(systemPrompt: String, userText: String) async throws -> String {
        // Try Keychain first, then ConfigManager, then environment
        if let apiKey = keychainManager.getAPIKey(for: .anthropic), !apiKey.isEmpty {
            return try await callAnthropicWithKey(apiKey: apiKey, systemPrompt: systemPrompt, userText: userText)
        }
        
        if let apiKey = configManager.loadAPIKey(), !apiKey.isEmpty {
            return try await callAnthropicWithKey(apiKey: apiKey, systemPrompt: systemPrompt, userText: userText)
        }
        
        if let envKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !envKey.isEmpty {
            return try await callAnthropicWithKey(apiKey: envKey, systemPrompt: systemPrompt, userText: userText)
        }
        
        throw VibeIntelligenceError.noAPIKey
    }
    
    private func callAnthropicWithKey(apiKey: String, systemPrompt: String, userText: String) async throws -> String {
        var request = URLRequest(url: anthropicURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 60
        
        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 8192,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userText]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VibeIntelligenceError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw VibeIntelligenceError.apiError(message)
            }
            throw VibeIntelligenceError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - OpenAI API
    
    private func callOpenAI(systemPrompt: String, userText: String) async throws -> String {
        guard let apiKey = keychainManager.getAPIKey(for: .openai) ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              !apiKey.isEmpty else {
            throw VibeIntelligenceError.noAPIKey
        }
        
        var request = URLRequest(url: openaiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "max_tokens": 8192,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userText]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VibeIntelligenceError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw VibeIntelligenceError.apiError(message)
            }
            throw VibeIntelligenceError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - Gemini API
    
    private func callGemini(systemPrompt: String, userText: String) async throws -> String {
        guard let apiKey = keychainManager.getAPIKey(for: .gemini) ?? ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
              !apiKey.isEmpty else {
            throw VibeIntelligenceError.noAPIKey
        }
        
        // Gemini uses query parameter for API key
        var urlComponents = URLComponents(url: geminiURL, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "\(systemPrompt)\n\n---\n\nUser request:\n\(userText)"]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 8192,
                "temperature": 0.7
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VibeIntelligenceError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw VibeIntelligenceError.apiError(message)
            }
            throw VibeIntelligenceError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - VibeCaaS-vl API (Local Vision Model)
    
    private func callVibeCaaS(systemPrompt: String, userText: String) async throws -> String {
        guard OllamaManager.shared.isOllamaRunning else {
            // Fall back to regular Ollama if VibeCaaS not running
            return try await callOllama(systemPrompt: systemPrompt, userText: userText)
        }
        
        var request = URLRequest(url: ollamaURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        // Use VibeCaaS-vl model if installed, otherwise fall back to base
        let modelName = OllamaManager.shared.isModelInstalled ? "VibeCaaS-vl:2b" : "qwen2.5vl:3b"
        
        let body: [String: Any] = [
            "model": modelName,
            "system": systemPrompt,
            "prompt": userText,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VibeIntelligenceError.networkError("VibeCaaS-vl request failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = json["response"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - Ollama API
    
    private func callOllama(systemPrompt: String, userText: String) async throws -> String {
        var request = URLRequest(url: ollamaURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        let model = configManager.ollamaModel
        
        let body: [String: Any] = [
            "model": model,
            "system": systemPrompt,
            "prompt": userText,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VibeIntelligenceError.networkError("Ollama request failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = json["response"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - LM Studio API
    
    private func callLMStudio(systemPrompt: String, userText: String) async throws -> String {
        var request = URLRequest(url: lmstudioURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        let body: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userText]
            ],
            "temperature": 0.7,
            "max_tokens": 8192
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VibeIntelligenceError.networkError("LM Studio request failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw VibeIntelligenceError.emptyResponse
        }
        
        return text
    }
    
    // MARK: - System Prompts
    
    private func getSystemPrompt(for mode: ProcessingMode) -> String {
        switch mode {
        case .enhance:
            return """
            You are VibeIntelligence, an expert prompt engineer built by VibeCaaS.com ("Code the Vibe. Deploy the Dream.").

            Your voice is creative, empowering, and action-oriented—technical but approachable.

            Rewrite the following text to be more comprehensive, clear, and robust. Add:
            - Explicit requirements and acceptance criteria
            - Edge cases to consider
            - Clear structure with sections if needed
            - Specific details that were implied but not stated

            Maintain the original intent but make it unambiguous and actionable.
            Keep the energy up—this should feel like a well-composed track, not a dry spec sheet.

            Output ONLY the rewritten text, no explanations.
            """
            
        case .agent:
            return """
            You are VibeIntelligence, an expert prompt engineer built by VibeCaaS.com ("Code the Vibe. Deploy the Dream.").

            Transform this text into a well-structured prompt optimized for AI coding agents (Cursor, Claude Code, GitHub Copilot, Windsurf).

            Structure the output with:
            ## Task: [Clear, action-oriented title]
            ### Goal
            [1-2 sentence objective—make it punchy]

            ### Requirements
            [Numbered list of specific requirements with these sub-categories:]
            1. **Core Functionality**
               - [Specific requirement]
            2. **UI/UX** (if applicable)
               - [Specific requirement]
            3. **Data & State**
               - [Specific requirement]
            4. **Error Handling**
               - [Specific requirement]

            ### Technical Constraints
            - Stack/framework preferences
            - Patterns to follow
            - Limitations to respect

            ### Edge Cases
            - [What to handle]
            - [Failure scenarios]

            ### Output Format
            - Expected deliverable (files, structure)
            - Code style preferences
            - Testing expectations

            ### Verification Checklist
            Before completing, verify:
            - [ ] [Specific check]
            - [ ] [Specific check]

            Be specific about error handling, types, and testing expectations.
            Make it actionable—ready to ship, not just to read.

            Output ONLY the structured prompt, no meta-commentary.
            """
            
        case .spec:
            return """
            You are VibeIntelligence, a technical architect from VibeCaaS.com ("Code the Vibe. Deploy the Dream.").

            Expand this into a detailed technical specification. Structure it as:

            # [Feature/System Name] - Technical Specification
            *VibeCaaS Technical Document*

            ## Overview
            [High-level description and objectives]

            ## Functional Requirements
            ### FR-1: [Requirement Name]
            - Description:
            - Acceptance Criteria:
            - Priority: [P0/P1/P2]

            ## Non-Functional Requirements
            ### Performance
            - [Specific metrics]

            ### Security
            - [Security considerations]

            ### Scalability
            - [Scale requirements]

            ## Data Model
            [Schemas, entities, relationships if applicable]

            ## API Contract
            [Endpoints, request/response formats if applicable]

            ## Error Handling Strategy
            [Error types, recovery mechanisms]

            ## Testing Requirements
            - Unit tests:
            - Integration tests:
            - E2E tests:

            ## Dependencies
            [External services, libraries]

            ## Open Questions
            [Items needing clarification]

            Output ONLY the specification document, no explanations.
            """
            
        case .simplify:
            return """
            You are VibeIntelligence, a technical writer from VibeCaaS.com ("Code the Vibe. Deploy the Dream.").

            Simplify and clarify this text:
            - Remove redundancy—keep only what moves the needle
            - Use plain language—technical accuracy without jargon overload
            - Improve readability—short sentences, clear structure
            - Keep all essential information
            - Fix any grammar issues

            Think of it like stripping a track to its essential beat.

            Output ONLY the simplified text.
            """
            
        case .proofread:
            return """
            You are VibeIntelligence from VibeCaaS.com.

            Proofread this text:
            - Fix spelling and grammar errors
            - Improve punctuation
            - Fix awkward phrasing
            - Maintain the original voice and intent
            - Make minimal changes—just clean it up

            Output ONLY the corrected text.
            """
        }
    }
}
