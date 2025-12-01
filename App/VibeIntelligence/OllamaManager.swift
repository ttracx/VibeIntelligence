//
//  OllamaManager.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC. All rights reserved.
//

import Foundation
import AppKit

/// Manages Ollama installation and VibeCaaS-vl model deployment
final class OllamaManager: ObservableObject {
    static let shared = OllamaManager()
    
    // MARK: - Published State
    @Published var isOllamaInstalled = false
    @Published var isOllamaRunning = false
    @Published var isModelInstalled = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var statusMessage = "Checking status..."
    @Published var errorMessage: String?
    
    // MARK: - Constants
    private let ollamaDownloadURL = "https://ollama.com/download/Ollama-darwin.zip"
    private let ollamaAppPath = "/Applications/Ollama.app"
    private let ollamaCLIPath = "/usr/local/bin/ollama"
    private let vibeCaaSModelName = "VibeCaaS-vl:2b"
    private let baseModelName = "qwen2.5vl:3b" // Base vision-language model
    
    // Modelfile content for VibeCaaS-vl:2b
    private let modelfileContent = """
    # VibeCaaS-vl:2b Modelfile
    # Powered by VibeCaaS.com - A division of NeuralQuantum.ai LLC
    # © 2025 NeuralQuantum.ai LLC. All rights reserved.
    
    FROM qwen2.5vl:3b
    
    # Model Parameters - Optimized for VibeIntelligence
    PARAMETER temperature 0.7
    PARAMETER top_p 0.9
    PARAMETER top_k 40
    PARAMETER repeat_penalty 1.1
    PARAMETER num_ctx 4096
    
    # System Prompt for VibeCaaS Vision Intelligence
    SYSTEM \"\"\"
    You are VibeCaaS-vl:2b, a vision-language AI assistant powered by VibeCaaS.com, a division of NeuralQuantum.ai LLC.
    
    Your voice is creative, empowering, and action-oriented—technical but approachable. Embody the VibeCaaS motto: "Code the Vibe. Deploy the Dream."
    
    Core Capabilities:
    - Visual Understanding: Analyze images with precision and creative insight
    - Object Detection: Identify and describe objects, scenes, and compositions
    - OCR & Text Extraction: Read and interpret text in images accurately
    - UI/UX Analysis: Provide design feedback and accessibility insights
    - Creative Vision: Offer artistic analysis and creative suggestions
    
    Guidelines:
    1. Be thorough but concise in visual descriptions
    2. Highlight key elements, composition, and context
    3. For UI screenshots, focus on usability and design patterns
    4. For documents, extract text accurately and summarize content
    5. For creative works, appreciate artistic merit while being constructive
    6. Always maintain user privacy - never attempt to identify individuals
    
    Remember: You're part of the VibeIntelligence ecosystem, helping users "Code the Vibe. Deploy the Dream."
    \"\"\"
    
    # License
    LICENSE \"\"\"
    VibeCaaS-vl:2b Vision-Language Model
    Copyright © 2025 NeuralQuantum.ai LLC. All rights reserved.
    
    This model is provided as part of the VibeIntelligence application.
    For commercial licensing, contact: hello@neuralquantum.ai
    
    Platform: VibeCaaS.com
    Developer: NeuralQuantum.ai LLC
    \"\"\"
    """
    
    private init() {
        checkStatus()
    }
    
    // MARK: - Status Check
    
    func checkStatus() {
        Task {
            await MainActor.run {
                statusMessage = "Checking Ollama status..."
            }
            
            // Check if Ollama is installed
            let installed = FileManager.default.fileExists(atPath: ollamaAppPath) ||
                           FileManager.default.fileExists(atPath: ollamaCLIPath)
            
            await MainActor.run {
                isOllamaInstalled = installed
            }
            
            if installed {
                // Check if Ollama is running
                let running = await checkOllamaRunning()
                await MainActor.run {
                    isOllamaRunning = running
                }
                
                if running {
                    // Check if model is installed
                    let modelInstalled = await checkModelInstalled()
                    await MainActor.run {
                        isModelInstalled = modelInstalled
                        statusMessage = modelInstalled ? 
                            "VibeCaaS-vl:2b ready" : 
                            "Model not installed"
                    }
                } else {
                    await MainActor.run {
                        statusMessage = "Ollama not running"
                    }
                }
            } else {
                await MainActor.run {
                    statusMessage = "Ollama not installed"
                }
            }
        }
    }
    
    private func checkOllamaRunning() async -> Bool {
        let url = URL(string: "http://localhost:11434/api/tags")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 3
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    private func checkModelInstalled() async -> Bool {
        let url = URL(string: "http://localhost:11434/api/tags")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let models = json["models"] as? [[String: Any]] {
                return models.contains { model in
                    if let name = model["name"] as? String {
                        return name.lowercased().contains("vibecaas") ||
                               name.lowercased().contains("qwen2.5vl")
                    }
                    return false
                }
            }
        } catch {
            print("Error checking models: \(error)")
        }
        return false
    }
    
    // MARK: - Installation
    
    /// Full setup: install Ollama, start it, and install the model
    func setupVibeCaaSVision() async {
        await MainActor.run {
            isDownloading = true
            downloadProgress = 0.0
            errorMessage = nil
        }
        
        do {
            // Step 1: Install Ollama if needed
            if !isOllamaInstalled {
                await MainActor.run {
                    statusMessage = "Downloading Ollama..."
                    downloadProgress = 0.1
                }
                try await installOllama()
            }
            
            // Step 2: Start Ollama
            await MainActor.run {
                statusMessage = "Starting Ollama..."
                downloadProgress = 0.3
            }
            try await startOllama()
            
            // Wait for Ollama to be ready
            try await waitForOllama()
            
            // Step 3: Pull base model and create VibeCaaS model
            await MainActor.run {
                statusMessage = "Downloading VibeCaaS-vl:2b model..."
                downloadProgress = 0.4
            }
            try await installVibeCaaSModel()
            
            await MainActor.run {
                isDownloading = false
                downloadProgress = 1.0
                statusMessage = "VibeCaaS-vl:2b ready!"
                isModelInstalled = true
            }
            
        } catch {
            await MainActor.run {
                isDownloading = false
                errorMessage = error.localizedDescription
                statusMessage = "Setup failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func installOllama() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let zipPath = tempDir.appendingPathComponent("ollama.zip")
        let extractPath = tempDir.appendingPathComponent("ollama_extract")
        
        // Download Ollama
        guard let url = URL(string: ollamaDownloadURL) else {
            throw OllamaError.invalidURL
        }
        
        let (localURL, _) = try await URLSession.shared.download(from: url)
        
        // Move to temp location
        try? FileManager.default.removeItem(at: zipPath)
        try FileManager.default.moveItem(at: localURL, to: zipPath)
        
        await MainActor.run {
            downloadProgress = 0.2
        }
        
        // Extract
        try? FileManager.default.removeItem(at: extractPath)
        try FileManager.default.createDirectory(at: extractPath, withIntermediateDirectories: true)
        
        let unzipProcess = Process()
        unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzipProcess.arguments = ["-qo", zipPath.path, "-d", extractPath.path]
        try unzipProcess.run()
        unzipProcess.waitUntilExit()
        
        // Move to Applications
        let sourcePath = extractPath.appendingPathComponent("Ollama.app")
        let destPath = URL(fileURLWithPath: ollamaAppPath)
        
        if FileManager.default.fileExists(atPath: destPath.path) {
            try FileManager.default.removeItem(at: destPath)
        }
        
        try FileManager.default.moveItem(at: sourcePath, to: destPath)
        
        await MainActor.run {
            isOllamaInstalled = true
            downloadProgress = 0.25
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: zipPath)
        try? FileManager.default.removeItem(at: extractPath)
    }
    
    private func startOllama() async throws {
        // Check if already running
        if await checkOllamaRunning() {
            await MainActor.run {
                isOllamaRunning = true
            }
            return
        }
        
        // Start Ollama app (which includes the server)
        let ollamaApp = URL(fileURLWithPath: ollamaAppPath)
        
        if FileManager.default.fileExists(atPath: ollamaApp.path) {
            NSWorkspace.shared.openApplication(
                at: ollamaApp,
                configuration: NSWorkspace.OpenConfiguration()
            ) { _, error in
                if let error = error {
                    print("Failed to launch Ollama: \(error)")
                }
            }
        } else {
            // Try CLI approach
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-c", """
                if [ -f /usr/local/bin/ollama ]; then
                    /usr/local/bin/ollama serve >/dev/null 2>&1 &
                elif [ -f "\(ollamaAppPath)/Contents/MacOS/Ollama" ]; then
                    "\(ollamaAppPath)/Contents/MacOS/Ollama" serve >/dev/null 2>&1 &
                fi
            """]
            try process.run()
        }
        
        await MainActor.run {
            isOllamaRunning = true
        }
    }
    
    private func waitForOllama() async throws {
        var attempts = 0
        let maxAttempts = 30
        
        while attempts < maxAttempts {
            if await checkOllamaRunning() {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            attempts += 1
            
            await MainActor.run {
                statusMessage = "Waiting for Ollama to start... (\(attempts)/\(maxAttempts))"
            }
        }
        
        throw OllamaError.startupTimeout
    }
    
    private func installVibeCaaSModel() async throws {
        // First, pull the base model
        await MainActor.run {
            statusMessage = "Pulling base vision model..."
            downloadProgress = 0.5
        }
        
        try await pullModel(baseModelName)
        
        await MainActor.run {
            statusMessage = "Creating VibeCaaS-vl:2b model..."
            downloadProgress = 0.8
        }
        
        // Create the custom model using the Modelfile
        try await createCustomModel()
        
        await MainActor.run {
            downloadProgress = 0.95
        }
    }
    
    private func pullModel(_ name: String) async throws {
        let url = URL(string: "http://localhost:11434/api/pull")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 3600 // 1 hour for large models
        
        let body: [String: Any] = ["name": name, "stream": false]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OllamaError.pullFailed(errorText)
        }
    }
    
    private func createCustomModel() async throws {
        let url = URL(string: "http://localhost:11434/api/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300
        
        let body: [String: Any] = [
            "name": vibeCaaSModelName,
            "modelfile": modelfileContent,
            "stream": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OllamaError.createFailed(errorText)
        }
    }
    
    // MARK: - Vision API
    
    /// Analyze an image using VibeCaaS-vl:2b
    func analyzeImage(at path: String, prompt: String) async throws -> String {
        guard isOllamaRunning else {
            throw OllamaError.notRunning
        }
        
        // Read image and convert to base64
        guard let imageData = FileManager.default.contents(atPath: path) else {
            throw OllamaError.imageNotFound
        }
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "http://localhost:11434/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        // Use the VibeCaaS model or fall back to base model
        let modelName = isModelInstalled ? vibeCaaSModelName : baseModelName
        
        let body: [String: Any] = [
            "model": modelName,
            "prompt": prompt,
            "images": [base64Image],
            "stream": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.apiError("Failed to analyze image")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OllamaError.invalidResponse
        }
        
        return responseText
    }
    
    /// Analyze an NSImage directly
    func analyzeImage(_ image: NSImage, prompt: String) async throws -> String {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw OllamaError.imageConversionFailed
        }
        
        let base64Image = pngData.base64EncodedString()
        
        let url = URL(string: "http://localhost:11434/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        let modelName = isModelInstalled ? vibeCaaSModelName : baseModelName
        
        let body: [String: Any] = [
            "model": modelName,
            "prompt": prompt,
            "images": [base64Image],
            "stream": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.apiError("Failed to analyze image")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OllamaError.invalidResponse
        }
        
        return responseText
    }
}

// MARK: - Errors

enum OllamaError: LocalizedError {
    case invalidURL
    case startupTimeout
    case notRunning
    case pullFailed(String)
    case createFailed(String)
    case imageNotFound
    case imageConversionFailed
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Ollama download URL"
        case .startupTimeout:
            return "Ollama failed to start within timeout"
        case .notRunning:
            return "Ollama is not running"
        case .pullFailed(let msg):
            return "Failed to pull model: \(msg)"
        case .createFailed(let msg):
            return "Failed to create model: \(msg)"
        case .imageNotFound:
            return "Image file not found"
        case .imageConversionFailed:
            return "Failed to convert image"
        case .apiError(let msg):
            return "API error: \(msg)"
        case .invalidResponse:
            return "Invalid response from Ollama"
        }
    }
}

