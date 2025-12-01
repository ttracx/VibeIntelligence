//
//  QuickTransformView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct QuickTransformView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var selectedMode: ProcessingMode = .enhance
    @State private var isProcessing = false
    @State private var showCopied = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with drag area
            header
            
            Divider()
            
            // Mode Selector
            modeSelector
            
            Divider()
            
            // Content
            content
            
            // Footer
            footer
        }
        .frame(width: 500, height: 400)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }
    
    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(LinearGradient.vibePrimary)
                
                Text("Quick Transform")
                    .font(.system(size: 13, weight: .semibold))
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }
    
    private var modeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProcessingMode.allCases, id: \.self) { mode in
                    ModeButton(
                        mode: mode,
                        isSelected: selectedMode == mode
                    ) {
                        selectedMode = mode
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    private var content: some View {
        VStack(spacing: 12) {
            // Input
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Input")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        if let clipboard = NSPasteboard.general.string(forType: .string) {
                            inputText = clipboard
                        }
                    } label: {
                        Text("Paste")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
                
                TextEditor(text: $inputText)
                    .font(.system(size: 12, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                    .frame(height: 100)
            }
            
            // Transform Button
            Button(action: processText) {
                HStack(spacing: 6) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.6)
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: "arrow.down")
                    }
                    Text(isProcessing ? "Processing..." : "Transform")
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.vibePurple)
            .disabled(inputText.isEmpty || isProcessing)
            .keyboardShortcut(.return, modifiers: .command)
            
            // Output
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Output")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if showCopied {
                        Text("Copied!")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
                        showCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopied = false
                        }
                    } label: {
                        Text("Copy")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .disabled(outputText.isEmpty)
                }
                
                TextEditor(text: $outputText)
                    .font(.system(size: 12, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                    .frame(height: 100)
            }
        }
        .padding(16)
    }
    
    private var footer: some View {
        HStack {
            Text("⌘↩ to transform")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(configManager.currentProvider.displayName)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.3))
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
                    outputText = result
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    outputText = "Error: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Mode Button
struct ModeButton: View {
    let mode: ProcessingMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 10))
                Text(mode.displayName)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.vibePurple : Color(nsColor: .controlBackgroundColor))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickTransformView()
        .environmentObject(ConfigManager.shared)
}

