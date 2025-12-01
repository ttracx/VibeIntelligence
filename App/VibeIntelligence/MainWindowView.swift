//
//  MainWindowView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI
import UniformTypeIdentifiers

struct MainWindowView: View {
    @EnvironmentObject var configManager: ConfigManager
    @EnvironmentObject var windowManager: WindowManager
    @State private var selectedTab: MainTab = .transform
    @State private var isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    enum MainTab: String, CaseIterable {
        case transform = "Transform"
        case history = "History"
        case templates = "Templates"
        
        var icon: String {
            switch self {
            case .transform: return "waveform"
            case .history: return "clock.arrow.circlepath"
            case .templates: return "doc.text"
            }
        }
    }
    
    var body: some View {
        Group {
            if isFirstLaunch {
                OnboardingView(isFirstLaunch: $isFirstLaunch)
            } else {
                mainContent
            }
        }
        .frame(minWidth: 800, minHeight: 550)
    }
    
    private var mainContent: some View {
        HSplitView {
            // Sidebar
            sidebar
                .frame(width: 220)
            
            // Main Content
            ZStack {
                backgroundGradient
                
                switch selectedTab {
                case .transform:
                    TransformView()
                case .history:
                    HistoryView()
                case .templates:
                    TemplatesView()
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // App Header
            appHeader
                .padding(.bottom, 16)
            
            // Navigation
            VStack(spacing: 4) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    SidebarButton(
                        title: tab.rawValue,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Quick Actions
            quickActionsSection
            
            Divider()
                .padding(.horizontal, 16)
            
            // Provider Status
            providerStatus
                .padding(16)
        }
        .background(
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
        )
    }
    
    private var appHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.vibePrimary)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("VibeIntelligence")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Text("Code the Vibe")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUICK ACTIONS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 2) {
                QuickActionRow(icon: "sparkles", title: "Enhance", shortcut: "⌃⌥E") {
                    processClipboard(mode: .enhance)
                }
                
                QuickActionRow(icon: "cpu", title: "Agent Prompt", shortcut: "⌃⌥A") {
                    processClipboard(mode: .agent)
                }
                
                QuickActionRow(icon: "doc.text", title: "Tech Spec", shortcut: "⌃⌥S") {
                    processClipboard(mode: .spec)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 16)
    }
    
    private var providerStatus: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(configManager.isProviderAvailable ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(configManager.currentProvider.displayName)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.vibePurple.opacity(0.03),
                Color.aquaTeal.opacity(0.03)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private func processClipboard(mode: ProcessingMode) {
        Task {
            guard let clipboard = NSPasteboard.general.string(forType: .string), !clipboard.isEmpty else {
                AppDelegate.showNotification(title: "VibeIntelligence", message: "Clipboard is empty")
                return
            }
            
            do {
                let result = try await VibeIntelligenceService.shared.process(text: clipboard, mode: mode)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(result, forType: .string)
                AppDelegate.showNotification(title: "VibeIntelligence", message: mode.successMessage)
            } catch {
                AppDelegate.showNotification(title: "VibeIntelligence", message: "Processing failed")
            }
        }
    }
}

// MARK: - Sidebar Button
struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                    .foregroundColor(isSelected ? .white : .vibePurple)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.vibePurple : (isHovered ? Color.vibePurple.opacity(0.1) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Quick Action Row
struct QuickActionRow: View {
    let icon: String
    let title: String
    let shortcut: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .frame(width: 16)
                    .foregroundColor(.vibePurple)
                
                Text(title)
                    .font(.system(size: 11))
                
                Spacer()
                
                Text(shortcut)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.vibePurple.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Transform View (Main Working Area)
struct TransformView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var selectedMode: ProcessingMode = .enhance
    @State private var isProcessing = false
    @State private var isDraggingOver = false
    @State private var showCopiedToast = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar
            
            Divider()
            
            // Content Area
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Input Panel
                    inputPanel
                        .frame(width: geometry.size.width / 2)
                    
                    // Center Divider with Transform Button
                    centerDivider
                    
                    // Output Panel
                    outputPanel
                        .frame(width: geometry.size.width / 2)
                }
            }
        }
        .overlay(copiedToast, alignment: .top)
    }
    
    private var toolbar: some View {
        HStack(spacing: 16) {
            // Mode Picker
            HStack(spacing: 8) {
                Text("Mode:")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Picker("", selection: $selectedMode) {
                    ForEach(ProcessingMode.allCases, id: \.self) { mode in
                        Label(mode.displayName, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 160)
            }
            
            Spacer()
            
            // Character Count
            HStack(spacing: 16) {
                Text("\(inputText.count) chars")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                
                if !outputText.isEmpty {
                    Text("→ \(outputText.count) chars")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.aquaTeal)
                }
            }
            
            // Clear Button
            Button("Clear All") {
                withAnimation {
                    inputText = ""
                    outputText = ""
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(inputText.isEmpty && outputText.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
    
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Input", systemImage: "text.alignleft")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    if let clipboard = NSPasteboard.general.string(forType: .string) {
                        inputText = clipboard
                    }
                } label: {
                    Label("Paste", systemImage: "doc.on.clipboard")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $inputText)
                    .font(.system(size: 13, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isDraggingOver ? Color.vibePurple : Color.vibePurple.opacity(0.2), lineWidth: isDraggingOver ? 2 : 1)
                    )
                
                if inputText.isEmpty {
                    Text("Enter your text here, paste from clipboard, or drop a file...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .onDrop(of: [UTType.plainText, UTType.fileURL], isTargeted: $isDraggingOver) { providers in
                handleDrop(providers: providers)
            }
        }
        .padding(16)
    }
    
    private var centerDivider: some View {
        VStack {
            Spacer()
            
            Button(action: processText) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.vibePrimary)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.vibePurple.opacity(0.3), radius: 8, y: 4)
                    
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                            .colorInvert()
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty || isProcessing)
            .keyboardShortcut(.return, modifiers: .command)
            .help("Transform (⌘↩)")
            
            Text(isProcessing ? "Mixing..." : "Transform")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(width: 80)
    }
    
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Output", systemImage: "text.badge.checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(outputText, forType: .string)
                    withAnimation {
                        showCopiedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopiedToast = false
                        }
                    }
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(outputText.isEmpty)
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $outputText)
                    .font(.system(size: 13, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.aquaTeal.opacity(0.2), lineWidth: 1)
                    )
                
                if outputText.isEmpty && !isProcessing {
                    Text("Transformed text will appear here...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(16)
    }
    
    private var copiedToast: some View {
        Group {
            if showCopiedToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Copied to clipboard")
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                )
                .padding(.top, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func processText() {
        guard !inputText.isEmpty else { return }
        
        isProcessing = true
        
        Task {
            do {
                let result = try await VibeIntelligenceService.shared.process(
                    text: inputText,
                    mode: selectedMode
                )
                await MainActor.run {
                    withAnimation {
                        outputText = result
                        isProcessing = false
                    }
                    // Save to history
                    configManager.saveToHistory(mode: selectedMode.rawValue, input: inputText, output: result)
                }
            } catch {
                await MainActor.run {
                    outputText = "Error: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, error in
                    if let data = data as? Data, let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            inputText = text
                        }
                    }
                }
                return true
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                    if let data = data as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil),
                       let text = try? String(contentsOf: url, encoding: .utf8) {
                        DispatchQueue.main.async {
                            inputText = text
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}

#Preview {
    MainWindowView()
        .environmentObject(ConfigManager.shared)
        .environmentObject(WindowManager.shared)
        .frame(width: 900, height: 650)
}

