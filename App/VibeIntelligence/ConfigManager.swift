//
//  ConfigManager.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import Foundation
import SwiftUI

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    // MARK: - Published Properties
    @Published var currentProvider: AIProvider = .auto
    @Published var isProviderAvailable = true
    @Published var isOllamaAvailable = false
    @Published var isLMStudioAvailable = false
    
    // MARK: - Configuration
    @AppStorage("aiProvider") private var storedProvider = "auto"
    @AppStorage("ollamaModel") var ollamaModel = "llama3.2"
    
    // MARK: - Paths
    private let configDir: URL
    private let configFile: URL
    private let templatesDir: URL
    private let historyDir: URL
    
    // MARK: - Keychain Service
    private let keychainService = "com.vibecaas.vibeintelligence"
    private let keychainAccount = "anthropic-api-key"
    
    private init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        configDir = home.appendingPathComponent(".config/VibeIntelligence")
        configFile = configDir.appendingPathComponent("config.json")
        templatesDir = configDir.appendingPathComponent("templates")
        historyDir = configDir.appendingPathComponent("history")
        
        loadProvider()
        checkProviderAvailability()
    }
    
    // MARK: - Directory Setup
    
    func ensureDirectoriesExist() {
        let fm = FileManager.default
        
        try? fm.createDirectory(at: configDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: templatesDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: historyDir, withIntermediateDirectories: true)
        
        // Copy default templates if needed
        copyDefaultTemplates()
    }
    
    private func copyDefaultTemplates() {
        let fm = FileManager.default
        let projectTemplates = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Projects/VibeIntelligence/config/templates")
        
        guard fm.fileExists(atPath: projectTemplates.path) else { return }
        
        if let files = try? fm.contentsOfDirectory(at: projectTemplates, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "md" {
                let destination = templatesDir.appendingPathComponent(file.lastPathComponent)
                if !fm.fileExists(atPath: destination.path) {
                    try? fm.copyItem(at: file, to: destination)
                }
            }
        }
    }
    
    // MARK: - Provider Management
    
    private func loadProvider() {
        if let provider = AIProvider(rawValue: storedProvider) {
            currentProvider = provider
        }
    }
    
    func setProvider(_ provider: AIProvider) {
        currentProvider = provider
        storedProvider = provider.rawValue
        checkProviderAvailability()
    }
    
    func checkProviderAvailability() {
        Task {
            let ollamaAvailable = await VibeIntelligenceService.shared.isOllamaAvailable()
            let lmstudioAvailable = await VibeIntelligenceService.shared.isLMStudioAvailable()
            
            await MainActor.run {
                self.isOllamaAvailable = ollamaAvailable
                self.isLMStudioAvailable = lmstudioAvailable
                
                switch currentProvider {
                case .auto:
                    let hasCloudKey = KeychainManager.shared.hasAPIKey(for: .anthropic) ||
                                      KeychainManager.shared.hasAPIKey(for: .openai) ||
                                      KeychainManager.shared.hasAPIKey(for: .gemini) ||
                                      loadAPIKey() != nil
                    isProviderAvailable = ollamaAvailable || lmstudioAvailable || hasCloudKey
                case .anthropic:
                    isProviderAvailable = KeychainManager.shared.hasAPIKey(for: .anthropic) || loadAPIKey() != nil
                case .openai:
                    isProviderAvailable = KeychainManager.shared.hasAPIKey(for: .openai)
                case .gemini:
                    isProviderAvailable = KeychainManager.shared.hasAPIKey(for: .gemini)
                case .vibecaas:
                    isProviderAvailable = ollamaAvailable && OllamaManager.shared.isModelInstalled
                case .ollama:
                    isProviderAvailable = ollamaAvailable
                case .lmstudio:
                    isProviderAvailable = lmstudioAvailable
                }
            }
        }
    }
    
    // MARK: - API Key Management (Keychain)
    
    func saveAPIKey(_ key: String) {
        let data = key.data(using: .utf8)!
        
        // Delete existing
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
        checkProviderAvailability()
    }
    
    func loadAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        // Fallback to environment variable
        return ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
    }
    
    func deleteAPIKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
        checkProviderAvailability()
    }
    
    // MARK: - Configuration File
    
    func loadConfig() -> [String: Any]? {
        guard let data = try? Data(contentsOf: configFile),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    func saveConfig(_ config: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: config, options: .prettyPrinted) else {
            return
        }
        try? data.write(to: configFile)
    }
    
    // MARK: - History
    
    func saveToHistory(mode: String, input: String, output: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "\(Date().timeIntervalSince1970)_\(mode).json"
        let historyFile = historyDir.appendingPathComponent(filename)
        
        let entry: [String: Any] = [
            "meta": [
                "tool": "VibeIntelligence",
                "brand": "VibeCaaS.com",
                "version": "1.0.0"
            ],
            "timestamp": timestamp,
            "mode": mode,
            "input": input,
            "output": output,
            "input_length": input.count,
            "output_length": output.count
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: entry, options: .prettyPrinted) {
            try? data.write(to: historyFile)
        }
        
        // Clean up old history using user-configured retention setting
        let historyRetention = UserDefaults.standard.integer(forKey: "historyRetention")
        let maxEntries = historyRetention > 0 ? historyRetention : 100 // Default to 100 if not set
        cleanupHistory(maxEntries: maxEntries)
    }
    
    private func cleanupHistory(maxEntries: Int) {
        guard let files = try? FileManager.default.contentsOfDirectory(at: historyDir, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        let sortedFiles = files.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            return date1 > date2
        }
        
        if sortedFiles.count > maxEntries {
            for file in sortedFiles.dropFirst(maxEntries) {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
