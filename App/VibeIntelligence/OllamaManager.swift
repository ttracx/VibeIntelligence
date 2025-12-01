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
    
    /// The VibeCaaS-vl:2b model from the Ollama hub
    /// Powered by VibeCaaS.com - A division of NeuralQuantum.ai LLC
    static let vibeCaaSModelName = "NeuroEquality/VibeCaaS-vl:2b"
    static let vibeCaaSModelShortName = "VibeCaaS-vl:2b"
    
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
                        // Check for the NeuroEquality/VibeCaaS-vl model
                        return name.lowercased().contains("vibecaas") ||
                               name.lowercased().contains("neuroequality")
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
        let maxAttempts = 30
        
        for attempt in 1...maxAttempts {
            if await checkOllamaRunning() {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            let currentAttempt = attempt // Capture for safe closure use
            await MainActor.run {
                statusMessage = "Waiting for Ollama to start... (\(currentAttempt)/\(maxAttempts))"
            }
        }
        
        throw OllamaError.startupTimeout
    }
    
    private func installVibeCaaSModel() async throws {
        await MainActor.run {
            statusMessage = "Downloading VibeCaaS-vl:2b from Ollama Hub..."
            downloadProgress = 0.5
        }
        
        // Pull the VibeCaaS-vl:2b model directly from Ollama Hub
        // This is the official model: NeuroEquality/VibeCaaS-vl:2b
        try await pullModel(OllamaManager.vibeCaaSModelName)
        
        await MainActor.run {
            downloadProgress = 0.95
            statusMessage = "VibeCaaS-vl:2b downloaded successfully!"
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
        
        // Use the VibeCaaS model from Ollama Hub: NeuroEquality/VibeCaaS-vl:2b
        let body: [String: Any] = [
            "model": OllamaManager.vibeCaaSModelName,
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
        
        // Use the VibeCaaS model from Ollama Hub: NeuroEquality/VibeCaaS-vl:2b
        let body: [String: Any] = [
            "model": OllamaManager.vibeCaaSModelName,
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

