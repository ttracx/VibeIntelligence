//
//  MenuBarView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @State private var isProcessing = false
    @State private var lastResult: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.vibePurple, .aquaTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                SectionHeader(title: "Quick Actions (from Clipboard)")
                
                MenuActionButton(
                    icon: "sparkles",
                    title: "Enhance",
                    shortcut: "⌃⌥E",
                    isProcessing: isProcessing
                ) {
                    await processClipboard(mode: .enhance)
                }
                
                MenuActionButton(
                    icon: "cpu",
                    title: "Agent Prompt",
                    shortcut: "⌃⌥A",
                    isProcessing: isProcessing
                ) {
                    await processClipboard(mode: .agent)
                }
                
                MenuActionButton(
                    icon: "doc.text",
                    title: "Technical Spec",
                    shortcut: "⌃⌥S",
                    isProcessing: isProcessing
                ) {
                    await processClipboard(mode: .spec)
                }
                
                MenuActionButton(
                    icon: "arrow.down.right.and.arrow.up.left",
                    title: "Simplify",
                    shortcut: "⌃⌥D",
                    isProcessing: isProcessing
                ) {
                    await processClipboard(mode: .simplify)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Status
            if isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Mixing your vibe...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                Divider()
            }
            
            // Configuration
            VStack(alignment: .leading, spacing: 2) {
                SectionHeader(title: "Configuration")
                
                MenuActionButton(icon: "macwindow", title: "Open Main Window") {
                    openWindow(id: "main")
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
                
                MenuActionButton(icon: "gearshape", title: "Settings...") {
                    openSettings()
                }
                
                MenuActionButton(icon: "folder", title: "Open Templates") {
                    openTemplatesFolder()
                }
                
                MenuActionButton(icon: "clock.arrow.circlepath", title: "View History") {
                    openHistoryFolder()
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Provider Status
            HStack {
                Circle()
                    .fill(configManager.isProviderAvailable ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(configManager.currentProvider.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Link("VibeCaaS.com", destination: URL(string: "https://vibecaas.com")!)
                    .font(.caption)
                    .foregroundColor(.aquaTeal)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Quit
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Image(systemName: "power")
                        .foregroundColor(.secondary)
                    Text("Quit VibeIntelligence")
                    Spacer()
                    Text("⌘Q")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 300)
    }
    
    // MARK: - Actions
    
    private func processClipboard(mode: ProcessingMode) async {
        guard let clipboard = NSPasteboard.general.string(forType: .string), !clipboard.isEmpty else {
            showNotification(title: "VibeIntelligence", message: "Clipboard is empty")
            return
        }
        
        isProcessing = true
        
        do {
            let result = try await VibeIntelligenceService.shared.process(text: clipboard, mode: mode)
            
            // Copy to clipboard
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(result, forType: .string)
            
            lastResult = result
            showNotification(title: "VibeIntelligence", message: mode.successMessage)
        } catch {
            showNotification(title: "VibeIntelligence", message: "Hit a skip in the track. Let's retry.")
        }
        
        isProcessing = false
    }
    
    private func openTemplatesFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        NSWorkspace.shared.open(url)
    }
    
    private func openHistoryFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/history")
        NSWorkspace.shared.open(url)
    }
    
    private func showNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

// MARK: - Menu Action Button
struct MenuActionButton: View {
    let icon: String
    let title: String
    var shortcut: String? = nil
    var isProcessing: Bool = false
    let action: () async -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(.vibePurple)
                Text(title)
                Spacer()
                if let shortcut = shortcut {
                    Text(shortcut)
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
        .disabled(isProcessing)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Processing Mode Extension
extension ProcessingMode {
    var successMessage: String {
        switch self {
        case .enhance: return "Your prompt is now in rhythm ✨"
        case .agent: return "Tuned for AI agents 🎧"
        case .spec: return "Expanded to full composition 📝"
        case .simplify: return "Stripped to the beat 🎵"
        case .proofread: return "Polished to perfection 💎"
        }
    }
}

#Preview {
    MenuBarView()
        .environmentObject(ConfigManager.shared)
}
