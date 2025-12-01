//
//  KeychainManager.swift
//  VibeIntelligence
//
//  Created on 12/01/25.
//  Copyright © 2025 NeuralQuantum.ai LLC. All rights reserved.
//

import Foundation
import Security

/// Secure storage for API keys using macOS Keychain
final class KeychainManager {
    static let shared = KeychainManager()
    
    private let serviceName = "com.vibecaas.vibeintelligence"
    
    enum APIProvider: String, CaseIterable, Identifiable {
        case anthropic = "anthropic_api_key"
        case openai = "openai_api_key"
        case gemini = "gemini_api_key"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .anthropic: return "Anthropic (Claude)"
            case .openai: return "OpenAI (GPT)"
            case .gemini: return "Google (Gemini)"
            }
        }
        
        var placeholder: String {
            switch self {
            case .anthropic: return "sk-ant-api03-..."
            case .openai: return "sk-proj-..."
            case .gemini: return "AIzaSy..."
            }
        }
        
        var helpURL: URL? {
            switch self {
            case .anthropic: return URL(string: "https://console.anthropic.com/settings/keys")
            case .openai: return URL(string: "https://platform.openai.com/api-keys")
            case .gemini: return URL(string: "https://aistudio.google.com/app/apikey")
            }
        }
    }
    
    private init() {}
    
    // MARK: - Public API
    
    /// Save an API key securely to Keychain
    func saveAPIKey(_ key: String, for provider: APIProvider) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: provider.rawValue,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status)
        }
    }
    
    /// Retrieve an API key from Keychain
    func getAPIKey(for provider: APIProvider) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: provider.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    /// Delete an API key from Keychain
    func deleteAPIKey(for provider: APIProvider) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: provider.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status)
        }
    }
    
    /// Check if an API key exists for a provider
    func hasAPIKey(for provider: APIProvider) -> Bool {
        return getAPIKey(for: provider) != nil
    }
    
    /// Get the preferred/active provider (first one with a valid key)
    func getPreferredProvider() -> APIProvider? {
        // Check in order of preference
        let preferredOrder: [APIProvider] = [.anthropic, .openai, .gemini]
        return preferredOrder.first { hasAPIKey(for: $0) }
    }
    
    /// Validate API key format (basic validation)
    func validateKeyFormat(_ key: String, for provider: APIProvider) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        
        switch provider {
        case .anthropic:
            return trimmed.hasPrefix("sk-ant-")
        case .openai:
            return trimmed.hasPrefix("sk-")
        case .gemini:
            return trimmed.hasPrefix("AIza")
        }
    }
}

// MARK: - Errors

enum KeychainError: LocalizedError {
    case unableToSave(OSStatus)
    case unableToDelete(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .unableToSave(let status):
            return "Unable to save to Keychain (status: \(status))"
        case .unableToDelete(let status):
            return "Unable to delete from Keychain (status: \(status))"
        }
    }
}

