//
//  APIKeysView.swift
//  VibeIntelligence
//
//  Created on 12/01/25.
//  Copyright © 2025 NeuralQuantum.ai LLC. All rights reserved.
//

import SwiftUI

struct APIKeysView: View {
    @State private var anthropicKey = ""
    @State private var openaiKey = ""
    @State private var geminiKey = ""
    
    @State private var showAnthropicKey = false
    @State private var showOpenAIKey = false
    @State private var showGeminiKey = false
    
    @State private var saveStatus: SaveStatus = .idle
    @State private var errorMessage: String?
    
    private let keychain = KeychainManager.shared
    
    enum SaveStatus {
        case idle
        case saving
        case saved
        case error
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("API Keys are stored securely in your macOS Keychain", systemImage: "lock.shield.fill")
                        .font(.callout)
                        .foregroundColor(.green)
                    
                    Text("Your keys never leave your device and are encrypted by the system.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Anthropic (Claude)") {
                apiKeyField(
                    key: $anthropicKey,
                    showKey: $showAnthropicKey,
                    provider: .anthropic
                )
            }
            
            Section("OpenAI (GPT-4)") {
                apiKeyField(
                    key: $openaiKey,
                    showKey: $showOpenAIKey,
                    provider: .openai
                )
            }
            
            Section("Google (Gemini)") {
                apiKeyField(
                    key: $geminiKey,
                    showKey: $showGeminiKey,
                    provider: .gemini
                )
            }
            
            Section {
                HStack {
                    Button("Save All Keys") {
                        saveAllKeys()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(saveStatus == .saving)
                    
                    if saveStatus == .saved {
                        Label("Saved!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    Button("Clear All Keys", role: .destructive) {
                        clearAllKeys()
                    }
                    .buttonStyle(.bordered)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            loadExistingKeys()
        }
        .animation(.easeInOut, value: saveStatus)
    }
    
    @ViewBuilder
    private func apiKeyField(
        key: Binding<String>,
        showKey: Binding<Bool>,
        provider: KeychainManager.APIProvider
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Group {
                    if showKey.wrappedValue {
                        TextField(provider.placeholder, text: key)
                    } else {
                        SecureField(provider.placeholder, text: key)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                
                Button {
                    showKey.wrappedValue.toggle()
                } label: {
                    Image(systemName: showKey.wrappedValue ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help(showKey.wrappedValue ? "Hide key" : "Show key")
            }
            
            HStack {
                if keychain.hasAPIKey(for: provider) {
                    Label("Key stored", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("No key stored", systemImage: "circle.dashed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let url = provider.helpURL {
                    Link("Get API Key →", destination: url)
                        .font(.caption)
                }
            }
        }
    }
    
    private func loadExistingKeys() {
        // Load masked versions or empty
        if keychain.hasAPIKey(for: .anthropic) {
            anthropicKey = "••••••••••••••••" // Show masked
        }
        if keychain.hasAPIKey(for: .openai) {
            openaiKey = "••••••••••••••••"
        }
        if keychain.hasAPIKey(for: .gemini) {
            geminiKey = "••••••••••••••••"
        }
    }
    
    private func saveAllKeys() {
        saveStatus = .saving
        errorMessage = nil
        
        do {
            // Only save if the key has been modified (not masked)
            if !anthropicKey.isEmpty && !anthropicKey.contains("•") {
                if keychain.validateKeyFormat(anthropicKey, for: .anthropic) {
                    try keychain.saveAPIKey(anthropicKey, for: .anthropic)
                } else if !anthropicKey.isEmpty {
                    throw NSError(domain: "", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid Anthropic API key format"
                    ])
                }
            }
            
            if !openaiKey.isEmpty && !openaiKey.contains("•") {
                if keychain.validateKeyFormat(openaiKey, for: .openai) {
                    try keychain.saveAPIKey(openaiKey, for: .openai)
                } else if !openaiKey.isEmpty {
                    throw NSError(domain: "", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid OpenAI API key format"
                    ])
                }
            }
            
            if !geminiKey.isEmpty && !geminiKey.contains("•") {
                if keychain.validateKeyFormat(geminiKey, for: .gemini) {
                    try keychain.saveAPIKey(geminiKey, for: .gemini)
                } else if !geminiKey.isEmpty {
                    throw NSError(domain: "", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid Gemini API key format"
                    ])
                }
            }
            
            saveStatus = .saved
            loadExistingKeys() // Refresh to show masked
            
            // Reset status after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if saveStatus == .saved {
                    saveStatus = .idle
                }
            }
        } catch {
            saveStatus = .error
            errorMessage = error.localizedDescription
        }
    }
    
    private func clearAllKeys() {
        do {
            try keychain.deleteAPIKey(for: .anthropic)
            try keychain.deleteAPIKey(for: .openai)
            try keychain.deleteAPIKey(for: .gemini)
            
            anthropicKey = ""
            openaiKey = ""
            geminiKey = ""
            
            saveStatus = .idle
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    APIKeysView()
        .frame(width: 500, height: 600)
}

