//
//  SettingsView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var configManager: ConfigManager
    
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            AIProviderSettingsTab()
                .tabItem {
                    Label("AI Provider", systemImage: "cpu")
                }
            
            TemplatesSettingsTab()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }
            
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 550, height: 450)
    }
}

// MARK: - General Settings
struct GeneralSettingsTab: View {
    @AppStorage("defaultMode") private var defaultMode = "enhance"
    @AppStorage("notifyEnabled") private var notifyEnabled = true
    @AppStorage("historyEnabled") private var historyEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    let modes = ["enhance", "agent", "spec", "simplify", "proofread"]
    
    var body: some View {
        Form {
            Section("Default Behavior") {
                Picker("Default Mode", selection: $defaultMode) {
                    Text("Enhance").tag("enhance")
                    Text("Agent Prompt").tag("agent")
                    Text("Technical Spec").tag("spec")
                    Text("Simplify").tag("simplify")
                    Text("Proofread").tag("proofread")
                }
                
                Toggle("Show Notifications", isOn: $notifyEnabled)
                Toggle("Save History", isOn: $historyEnabled)
                Toggle("Launch at Login", isOn: $launchAtLogin)
            }
            
            Section("Keyboard Shortcuts") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configure shortcuts in System Settings:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Settings → Keyboard → Keyboard Shortcuts → Services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Open Keyboard Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts")!)
                    }
                    .padding(.top, 4)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                    GridRow {
                        Text("⌃⌥E")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                        Text("Enhance")
                    }
                    GridRow {
                        Text("⌃⌥A")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                        Text("Agent Prompt")
                    }
                    GridRow {
                        Text("⌃⌥S")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                        Text("Technical Spec")
                    }
                    GridRow {
                        Text("⌃⌥D")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                        Text("Simplify")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - AI Provider Settings
struct AIProviderSettingsTab: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var apiKey = ""
    @State private var showingAPIKey = false
    @State private var ollamaModel = "llama3.2"
    @State private var testStatus: TestStatus = .idle
    
    enum TestStatus {
        case idle, testing, success, failure
    }
    
    var body: some View {
        Form {
            Section("Provider Selection") {
                Picker("AI Provider", selection: $configManager.currentProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Label(provider.displayName, systemImage: provider.icon)
                            .tag(provider)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            if configManager.currentProvider == .anthropic || configManager.currentProvider == .auto {
                Section("Anthropic API") {
                    HStack {
                        if showingAPIKey {
                            TextField("API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(showingAPIKey ? "Hide" : "Show") {
                            showingAPIKey.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Button("Save API Key") {
                            configManager.saveAPIKey(apiKey)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.vibePurple)
                        .disabled(apiKey.isEmpty)
                        
                        Link("Get API Key", destination: URL(string: "https://console.anthropic.com/")!)
                            .buttonStyle(.bordered)
                    }
                }
            }
            
            if configManager.currentProvider == .ollama || configManager.currentProvider == .auto {
                Section("Ollama") {
                    TextField("Model Name", text: $ollamaModel)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Circle()
                            .fill(configManager.isOllamaAvailable ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text(configManager.isOllamaAvailable ? "Ollama is running" : "Ollama not detected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Link("Download Ollama", destination: URL(string: "https://ollama.ai")!)
                            .font(.caption)
                    }
                }
            }
            
            if configManager.currentProvider == .lmstudio || configManager.currentProvider == .auto {
                Section("LM Studio") {
                    HStack {
                        Circle()
                            .fill(configManager.isLMStudioAvailable ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text(configManager.isLMStudioAvailable ? "LM Studio server is running" : "LM Studio not detected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Link("Download LM Studio", destination: URL(string: "https://lmstudio.ai")!)
                            .font(.caption)
                    }
                }
            }
            
            Section("Test Connection") {
                HStack {
                    Button("Test Provider") {
                        testConnection()
                    }
                    .buttonStyle(.bordered)
                    
                    switch testStatus {
                    case .idle:
                        EmptyView()
                    case .testing:
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Testing...")
                            .foregroundColor(.secondary)
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Connection successful!")
                            .foregroundColor(.green)
                    case .failure:
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Connection failed")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            apiKey = configManager.loadAPIKey() ?? ""
        }
    }
    
    private func testConnection() {
        testStatus = .testing
        
        Task {
            do {
                _ = try await VibeIntelligenceService.shared.process(text: "Hello", mode: .enhance)
                await MainActor.run {
                    testStatus = .success
                }
            } catch {
                await MainActor.run {
                    testStatus = .failure
                }
            }
            
            // Reset after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                testStatus = .idle
            }
        }
    }
}

// MARK: - Templates Settings
struct TemplatesSettingsTab: View {
    @State private var templates: [TemplateInfo] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Custom Templates")
                    .font(.headline)
                
                Spacer()
                
                Button("Open Templates Folder") {
                    let url = FileManager.default.homeDirectoryForCurrentUser
                        .appendingPathComponent(".config/VibeIntelligence/templates")
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.bordered)
                
                Button("Refresh") {
                    loadTemplates()
                }
                .buttonStyle(.bordered)
            }
            
            if templates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No custom templates found")
                        .foregroundColor(.secondary)
                    
                    Text("Add .md files to ~/.config/VibeIntelligence/templates/")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(templates, id: \.name) { template in
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.vibePurple)
                        
                        VStack(alignment: .leading) {
                            Text(template.name)
                                .fontWeight(.medium)
                            Text(template.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            NSWorkspace.shared.open(template.url)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .onAppear {
            loadTemplates()
        }
    }
    
    private func loadTemplates() {
        let templatesDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        
        templates = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: templatesDir, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files where file.pathExtension == "md" {
            let name = file.deletingPathExtension().lastPathComponent
            templates.append(TemplateInfo(name: name, description: "Custom template", url: file))
        }
    }
}

struct TemplateInfo {
    let name: String
    let description: String
    let url: URL
}

// MARK: - About Tab
struct AboutTab: View {
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.vibePurple, .aquaTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Title
            VStack(spacing: 4) {
                Text("VibeIntelligence")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AI-Powered Text Enhancement")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Divider()
                .frame(width: 200)
            
            // Brand
            VStack(spacing: 8) {
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.headline)
                    .foregroundColor(.vibePurple)
                
                HStack(spacing: 16) {
                    Link("VibeCaaS.com", destination: URL(string: "https://vibecaas.com")!)
                        .foregroundColor(.aquaTeal)
                    
                    Link("Documentation", destination: URL(string: "https://github.com/vibecaas/vibeintelligence")!)
                        .foregroundColor(.aquaTeal)
                }
            }
            
            Spacer()
            
            // Copyright
            VStack(spacing: 4) {
                Text("© 2025 NeuralQuantum.ai LLC")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Part of the VibeCaaS ecosystem")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ConfigManager.shared)
}
