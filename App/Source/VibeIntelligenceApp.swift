//
//  VibeIntelligenceApp.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

@main
struct VibeIntelligenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        
        MenuBarExtra("VibeIntelligence", systemImage: "waveform.circle.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure config directory exists
        let configDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence")
        try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - Brand Colors
extension Color {
    static let vibePurple = Color(red: 109/255, green: 74/255, blue: 255/255)
    static let aquaTeal = Color(red: 20/255, green: 184/255, blue: 166/255)
    static let signalAmber = Color(red: 255/255, green: 140/255, blue: 0/255)
}

// MARK: - Menu Bar View
struct MenuBarView: View {
    @State private var isProcessing = false
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.title2)
                        .foregroundColor(.vibePurple)
                    Text("VibeIntelligence")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.vibePurple.opacity(0.1))
            
            Divider()
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Actions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                MenuButton(icon: "sparkles", title: "Enhance from Clipboard", shortcut: "E") {
                    runVibeIntelligence(mode: "enhance")
                }
                
                MenuButton(icon: "cpu", title: "Agent Prompt", shortcut: "A") {
                    runVibeIntelligence(mode: "agent")
                }
                
                MenuButton(icon: "doc.text", title: "Technical Spec", shortcut: "S") {
                    runVibeIntelligence(mode: "spec")
                }
                
                MenuButton(icon: "arrow.down.right.and.arrow.up.left", title: "Simplify", shortcut: "D") {
                    runVibeIntelligence(mode: "simplify")
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Configuration
            VStack(alignment: .leading, spacing: 2) {
                Text("Configuration")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                MenuButton(icon: "gearshape", title: "Settings...") {
                    openSettings()
                }
                
                MenuButton(icon: "folder", title: "Open Templates") {
                    openTemplatesFolder()
                }
                
                MenuButton(icon: "clock.arrow.circlepath", title: "View History") {
                    openHistoryFolder()
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Links
            HStack(spacing: 16) {
                Button("Documentation") {
                    openDocumentation()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.vibePurple)
                
                Button("VibeCaaS.com") {
                    openWebsite()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.aquaTeal)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Quit
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Text("Quit VibeIntelligence")
                    Spacer()
                    Text("⌘Q")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
    }
    
    // MARK: - Actions
    func runVibeIntelligence(mode: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", "$HOME/Projects/VibeIntelligence/bin/VibeIntelligence --mode \(mode) --notify"]
        try? task.run()
    }
    
    func openTemplatesFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        NSWorkspace.shared.open(url)
    }
    
    func openHistoryFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/history")
        NSWorkspace.shared.open(url)
    }
    
    func openDocumentation() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Projects/VibeIntelligence/README.md")
        NSWorkspace.shared.open(url)
    }
    
    func openWebsite() {
        if let url = URL(string: "https://vibecaas.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Menu Button Component
struct MenuButton: View {
    let icon: String
    let title: String
    var shortcut: String? = nil
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(.vibePurple)
                Text(title)
                Spacer()
                if let shortcut = shortcut {
                    Text("⌃⌥\(shortcut)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(isHovered ? Color.vibePurple.opacity(0.1) : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("defaultMode") private var defaultMode = "enhance"
    @AppStorage("notifyEnabled") private var notifyEnabled = true
    @AppStorage("historyEnabled") private var historyEnabled = true
    @AppStorage("aiProvider") private var aiProvider = "auto"
    @State private var apiKey = ""
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                defaultMode: $defaultMode,
                notifyEnabled: $notifyEnabled,
                historyEnabled: $historyEnabled
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            AIProviderSettingsView(
                aiProvider: $aiProvider,
                apiKey: $apiKey
            )
            .tabItem {
                Label("AI Provider", systemImage: "cpu")
            }
            
            AboutView()
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @Binding var defaultMode: String
    @Binding var notifyEnabled: Bool
    @Binding var historyEnabled: Bool
    
    let modes = ["enhance", "agent", "spec", "simplify", "proofread"]
    
    var body: some View {
        Form {
            Section("Default Behavior") {
                Picker("Default Mode", selection: $defaultMode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode.capitalized).tag(mode)
                    }
                }
                
                Toggle("Show Notifications", isOn: $notifyEnabled)
                Toggle("Save History", isOn: $historyEnabled)
            }
            
            Section("Services") {
                Text("Manage keyboard shortcuts in System Settings → Keyboard → Keyboard Shortcuts → Services")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Open Keyboard Settings") {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.keyboard?Shortcuts")!)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - AI Provider Settings
struct AIProviderSettingsView: View {
    @Binding var aiProvider: String
    @Binding var apiKey: String
    
    var body: some View {
        Form {
            Section("Provider") {
                Picker("AI Provider", selection: $aiProvider) {
                    Text("Auto-detect").tag("auto")
                    Text("Anthropic Claude").tag("anthropic")
                    Text("Ollama (Local)").tag("ollama")
                    Text("LM Studio (Local)").tag("lmstudio")
                }
                .pickerStyle(.radioGroup)
            }
            
            if aiProvider == "anthropic" || aiProvider == "auto" {
                Section("Anthropic API") {
                    SecureField("API Key", text: $apiKey)
                    
                    HStack {
                        Text("Get your API key from")
                        Link("console.anthropic.com", destination: URL(string: "https://console.anthropic.com/")!)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            if aiProvider == "ollama" {
                Section("Ollama") {
                    Text("Make sure Ollama is running with a model loaded.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Link("Download Ollama", destination: URL(string: "https://ollama.ai")!)
                }
            }
            
            if aiProvider == "lmstudio" {
                Section("LM Studio") {
                    Text("Start the local server in LM Studio settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Link("Download LM Studio", destination: URL(string: "https://lmstudio.ai")!)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.vibePurple, .aquaTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("VibeIntelligence")
                .font(.title)
                .fontWeight(.bold)
            
            Text("AI-Powered Text Enhancement")
                .foregroundColor(.secondary)
            
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
                .frame(width: 200)
            
            VStack(spacing: 8) {
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.headline)
                    .foregroundColor(.vibePurple)
                
                Link("VibeCaaS.com", destination: URL(string: "https://vibecaas.com")!)
                    .foregroundColor(.aquaTeal)
            }
            
            Spacer()
            
            Text("© 2025 NeuralQuantum.ai LLC")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
