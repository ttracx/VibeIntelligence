//
//  SettingsView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var configManager: ConfigManager
    @EnvironmentObject var windowManager: WindowManager
    
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .environmentObject(windowManager)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            AppearanceSettingsTab()
                .environmentObject(windowManager)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            APIKeysView()
                .tabItem {
                    Label("API Keys", systemImage: "key.fill")
                }
            
            AIProviderSettingsTab()
                .tabItem {
                    Label("AI Provider", systemImage: "cpu")
                }
            
            TemplatesSettingsTab()
                .tabItem {
                    Label("Templates", systemImage: "doc.text")
                }
            
            ShortcutsSettingsTab()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
            
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 480)
    }
}

// MARK: - General Settings
struct GeneralSettingsTab: View {
    @EnvironmentObject var windowManager: WindowManager
    @AppStorage("defaultMode") private var defaultMode = "enhance"
    @AppStorage("notifyEnabled") private var notifyEnabled = true
    @AppStorage("historyEnabled") private var historyEnabled = true
    @AppStorage("historyRetention") private var historyRetention = 100
    @State private var launchAtLogin = false
    
    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
                
                Toggle("Show Onboarding on First Launch", isOn: .constant(false))
                    .disabled(true)
                    .help("Onboarding is shown automatically on first launch")
            }
            
            Section("Default Behavior") {
                Picker("Default Mode", selection: $defaultMode) {
                    Text("Enhance").tag("enhance")
                    Text("Agent Prompt").tag("agent")
                    Text("Technical Spec").tag("spec")
                    Text("Simplify").tag("simplify")
                    Text("Proofread").tag("proofread")
                }
                .pickerStyle(.menu)
            }
            
            Section("Notifications") {
                Toggle("Show Notifications", isOn: $notifyEnabled)
                
                Text("Notifications inform you when transformations complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("History") {
                Toggle("Save Transformation History", isOn: $historyEnabled)
                
                if historyEnabled {
                    Picker("Keep History", selection: $historyRetention) {
                        Text("Last 25 items").tag(25)
                        Text("Last 50 items").tag(50)
                        Text("Last 100 items").tag(100)
                        Text("Last 250 items").tag(250)
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Button("Clear History") {
                            clearHistory()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Open History Folder") {
                            openHistoryFolder()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            Section("Data") {
                Button("Reset All Settings") {
                    resetSettings()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            // Check current launch at login status
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
    
    private func clearHistory() {
        let historyDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/history")
        
        if let files = try? FileManager.default.contentsOfDirectory(at: historyDir, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    private func openHistoryFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/history")
        NSWorkspace.shared.open(url)
    }
    
    private func resetSettings() {
        // Reset UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsTab: View {
    @EnvironmentObject var windowManager: WindowManager
    @AppStorage("accentColorChoice") private var accentColor = "purple"
    
    var body: some View {
        Form {
            Section("App Visibility") {
                Toggle("Show in Dock", isOn: $windowManager.showDockIcon)
                
                Text("When disabled, the app runs only in the menu bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("Show in Menu Bar", isOn: $windowManager.showMenuBarIcon)
                    .disabled(true) // Menu bar is always shown
                
                Text("Menu bar icon is always visible")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Visual Style") {
                Picker("Accent Color", selection: $accentColor) {
                    HStack {
                        Circle().fill(Color.vibePurple).frame(width: 12, height: 12)
                        Text("Vibe Purple")
                    }.tag("purple")
                    
                    HStack {
                        Circle().fill(Color.aquaTeal).frame(width: 12, height: 12)
                        Text("Aqua Teal")
                    }.tag("teal")
                    
                    HStack {
                        Circle().fill(Color.signalAmber).frame(width: 12, height: 12)
                        Text("Signal Amber")
                    }.tag("amber")
                }
                .pickerStyle(.radioGroup)
            }
            
            Section("Window Behavior") {
                Text("Main window can be opened from the menu bar or dock icon.")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                .onChange(of: configManager.currentProvider) { _, newValue in
                    configManager.setProvider(newValue)
                }
                
                Text("Auto-detect tries local providers first, then cloud")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                        
                        if configManager.loadAPIKey() != nil {
                            Button("Remove Key") {
                                configManager.deleteAPIKey()
                                apiKey = ""
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Link("Get API Key →", destination: URL(string: "https://console.anthropic.com/")!)
                            .buttonStyle(.bordered)
                    }
                }
            }
            
            if configManager.currentProvider == .ollama || configManager.currentProvider == .auto {
                Section("Ollama") {
                    HStack {
                        TextField("Model Name", text: $ollamaModel)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Save") {
                            configManager.ollamaModel = ollamaModel
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Circle()
                            .fill(configManager.isOllamaAvailable ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text(configManager.isOllamaAvailable ? "Ollama is running" : "Ollama not detected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Link("Download Ollama →", destination: URL(string: "https://ollama.ai")!)
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
                        
                        Link("Download LM Studio →", destination: URL(string: "https://lmstudio.ai")!)
                            .font(.caption)
                    }
                    
                    Text("Start the local server in LM Studio to use it")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            ollamaModel = configManager.ollamaModel
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

// MARK: - Shortcuts Settings
struct ShortcutsSettingsTab: View {
    var body: some View {
        Form {
            Section("System Shortcuts") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configure shortcuts in System Settings:")
                        .font(.body)
                    
                    Text("Settings → Keyboard → Keyboard Shortcuts → Services → VibeIntelligence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Open Keyboard Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts")!)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.vibePurple)
                }
            }
            
            Section("Default Shortcuts") {
                Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
                    GridRow {
                        Text("⌃⌥E")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                            .frame(width: 60, alignment: .leading)
                        Text("Enhance selected text")
                    }
                    GridRow {
                        Text("⌃⌥A")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                            .frame(width: 60, alignment: .leading)
                        Text("Convert to Agent Prompt")
                    }
                    GridRow {
                        Text("⌃⌥S")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                            .frame(width: 60, alignment: .leading)
                        Text("Generate Technical Spec")
                    }
                    GridRow {
                        Text("⌃⌥D")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.vibePurple)
                            .frame(width: 60, alignment: .leading)
                        Text("Simplify text")
                    }
                }
            }
            
            Section("In-App Shortcuts") {
                Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
                    GridRow {
                        Text("⌘↩")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.aquaTeal)
                            .frame(width: 60, alignment: .leading)
                        Text("Transform text")
                    }
                    GridRow {
                        Text("⌘N")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.aquaTeal)
                            .frame(width: 60, alignment: .leading)
                        Text("New transformation")
                    }
                    GridRow {
                        Text("⌘,")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.aquaTeal)
                            .frame(width: 60, alignment: .leading)
                        Text("Open Settings")
                    }
                    GridRow {
                        Text("⌘Q")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.aquaTeal)
                            .frame(width: 60, alignment: .leading)
                        Text("Quit app")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About Tab
struct AboutTab: View {
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            ZStack {
                Circle()
                    .fill(LinearGradient.vibePrimary)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.vibePurple.opacity(0.3), radius: 15, y: 8)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Title
            VStack(spacing: 4) {
                Text("VibeIntelligence")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AI-Powered Text Enhancement")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("Version 1.0.0 (Build 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Divider()
                .frame(width: 200)
            
            // Brand
            VStack(spacing: 12) {
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.headline)
                    .foregroundStyle(LinearGradient.vibePrimary)
                
                HStack(spacing: 20) {
                    Link(destination: URL(string: "https://vibecaas.com")!) {
                        Label("VibeCaaS.com", systemImage: "globe")
                    }
                    .foregroundColor(.aquaTeal)
                    
                    Link(destination: URL(string: "https://github.com/vibecaas/vibeintelligence")!) {
                        Label("GitHub", systemImage: "link")
                    }
                    .foregroundColor(.aquaTeal)
                }
                .font(.caption)
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
        .environmentObject(WindowManager.shared)
}
