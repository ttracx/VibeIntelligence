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
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @State private var isProcessing = false
    @State private var processingMode: ProcessingMode?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
            
            // Quick Actions
            quickActions
            
            Divider()
            
            // Status (if processing)
            if isProcessing, let mode = processingMode {
                processingStatus(mode: mode)
                Divider()
            }
            
            // Navigation
            navigationSection
            
            Divider()
            
            // Provider Status & Footer
            footer
            
            Divider()
            
            // Quit
            quitButton
        }
        .frame(width: 320)
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient.vibePrimary)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("VibeIntelligence")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("Code the Vibe. Deploy the Dream.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick Transform Button
                Button {
                    openWindow(id: "quick")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LinearGradient.vibePrimary)
                }
                .buttonStyle(.plain)
                .help("Quick Transform")
            }
        }
        .padding(16)
        .background(Color.vibePurple.opacity(0.08))
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 2) {
            SectionHeader(title: "QUICK ACTIONS (FROM CLIPBOARD)")
            
            MenuActionButton(
                icon: "sparkles",
                title: "Enhance",
                shortcut: "⌃⌥E",
                color: .vibePurple,
                isProcessing: isProcessing && processingMode == .enhance
            ) {
                await processClipboard(mode: .enhance)
            }
            
            MenuActionButton(
                icon: "cpu",
                title: "Agent Prompt",
                shortcut: "⌃⌥A",
                color: .blue,
                isProcessing: isProcessing && processingMode == .agent
            ) {
                await processClipboard(mode: .agent)
            }
            
            MenuActionButton(
                icon: "doc.text",
                title: "Technical Spec",
                shortcut: "⌃⌥S",
                color: .orange,
                isProcessing: isProcessing && processingMode == .spec
            ) {
                await processClipboard(mode: .spec)
            }
            
            MenuActionButton(
                icon: "arrow.down.right.and.arrow.up.left",
                title: "Simplify",
                shortcut: "⌃⌥D",
                color: .green,
                isProcessing: isProcessing && processingMode == .simplify
            ) {
                await processClipboard(mode: .simplify)
            }
            
            MenuActionButton(
                icon: "checkmark.circle",
                title: "Proofread",
                shortcut: nil,
                color: .aquaTeal,
                isProcessing: isProcessing && processingMode == .proofread
            ) {
                await processClipboard(mode: .proofread)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Processing Status
    private func processingStatus(mode: ProcessingMode) -> some View {
        HStack(spacing: 10) {
            ProgressView()
                .scaleEffect(0.7)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mixing your vibe...")
                    .font(.system(size: 12, weight: .medium))
                
                Text("Processing with \(mode.displayName)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.vibePurple.opacity(0.05))
    }
    
    // MARK: - Navigation Section
    private var navigationSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            SectionHeader(title: "NAVIGATION")
            
            MenuActionButton(icon: "macwindow", title: "Open Main Window", color: .vibePurple) {
                windowManager.showMainWindow()
            }
            
            MenuActionButton(icon: "clock.arrow.circlepath", title: "History", color: .blue) {
                openWindow(id: "history")
                NSApp.activate(ignoringOtherApps: true)
            }
            
            MenuActionButton(icon: "folder", title: "Open Templates Folder", color: .orange) {
                openTemplatesFolder()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            MenuActionButton(icon: "gearshape", title: "Settings...", shortcut: "⌘,", color: .secondary) {
                openSettings()
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Footer
    private var footer: some View {
        HStack {
            // Provider Status
            HStack(spacing: 8) {
                Circle()
                    .fill(configManager.isProviderAvailable ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(configManager.currentProvider.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Dock Status
            HStack(spacing: 4) {
                Image(systemName: windowManager.showDockIcon ? "dock.rectangle" : "dock.arrow.up.rectangle")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Text(windowManager.showDockIcon ? "Dock" : "Menu Only")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Link("VibeCaaS.com", destination: URL(string: "https://vibecaas.com")!)
                .font(.system(size: 10))
                .foregroundColor(.aquaTeal)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    // MARK: - Quit Button
    private var quitButton: some View {
        Button(action: { NSApplication.shared.terminate(nil) }) {
            HStack {
                Image(systemName: "power")
                    .foregroundColor(.secondary)
                Text("Quit VibeIntelligence")
                    .font(.system(size: 13))
                Spacer()
                Text("⌘Q")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func processClipboard(mode: ProcessingMode) async {
        guard let clipboard = NSPasteboard.general.string(forType: .string), !clipboard.isEmpty else {
            AppDelegate.showNotification(title: "VibeIntelligence", message: "Clipboard is empty")
            return
        }
        
        isProcessing = true
        processingMode = mode
        
        do {
            let result = try await VibeIntelligenceService.shared.process(text: clipboard, mode: mode)
            
            // Copy to clipboard
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(result, forType: .string)
            
            AppDelegate.showNotification(title: "VibeIntelligence", message: mode.successMessage)
            
            // Save to history
            configManager.saveToHistory(mode: mode.rawValue, input: clipboard, output: result)
        } catch {
            AppDelegate.showNotification(title: "VibeIntelligence", message: "Hit a skip in the track. Let's retry.")
        }
        
        isProcessing = false
        processingMode = nil
    }
    
    private func openTemplatesFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.secondary.opacity(0.8))
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 4)
    }
}

// MARK: - Menu Action Button
struct MenuActionButton: View {
    let icon: String
    let title: String
    var shortcut: String? = nil
    var color: Color = .vibePurple
    var isProcessing: Bool = false
    let action: () async -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.6)
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 13))
                            .foregroundColor(color)
                    }
                }
                .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13))
                
                Spacer()
                
                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? color.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
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
        .environmentObject(WindowManager.shared)
}
