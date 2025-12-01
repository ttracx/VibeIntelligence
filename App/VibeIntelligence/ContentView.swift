//
//  ContentView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var selectedMode: ProcessingMode = .enhance
    @State private var isProcessing = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            Divider()
            
            // Main Content
            HSplitView {
                // Input Panel
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Input")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Paste") {
                            if let clipboard = NSPasteboard.general.string(forType: .string) {
                                inputText = clipboard
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.vibePurple.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
                .frame(minWidth: 250)
                
                // Output Panel
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Output")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Copy") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(outputText, forType: .string)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(outputText.isEmpty)
                    }
                    
                    TextEditor(text: $outputText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.aquaTeal.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
                .frame(minWidth: 250)
            }
            
            Divider()
            
            // Controls
            HStack(spacing: 16) {
                // Mode Picker
                Picker("Mode", selection: $selectedMode) {
                    ForEach(ProcessingMode.allCases, id: \.self) { mode in
                        Label(mode.displayName, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                
                Spacer()
                
                // Process Button
                Button(action: processText) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.7)
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "waveform")
                        }
                        Text(isProcessing ? "Mixing..." : "Transform")
                    }
                    .frame(width: 120)
                }
                .buttonStyle(.borderedProminent)
                .tint(.vibePurple)
                .disabled(inputText.isEmpty || isProcessing)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(
            LinearGradient(
                colors: [
                    Color.vibePurple.opacity(0.05),
                    Color.aquaTeal.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func processText() {
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

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.vibePurple, .aquaTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("VibeIntelligence")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Link(destination: URL(string: "https://vibecaas.com")!) {
                Text("VibeCaaS.com")
                    .font(.caption)
                    .foregroundColor(.aquaTeal)
            }
        }
        .padding()
        .background(Color.vibePurple.opacity(0.08))
    }
}

// MARK: - Processing Mode
enum ProcessingMode: String, CaseIterable {
    case enhance
    case agent
    case spec
    case simplify
    case proofread
    
    var displayName: String {
        switch self {
        case .enhance: return "Enhance"
        case .agent: return "Agent Prompt"
        case .spec: return "Technical Spec"
        case .simplify: return "Simplify"
        case .proofread: return "Proofread"
        }
    }
    
    var icon: String {
        switch self {
        case .enhance: return "sparkles"
        case .agent: return "cpu"
        case .spec: return "doc.text"
        case .simplify: return "arrow.down.right.and.arrow.up.left"
        case .proofread: return "checkmark.circle"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigManager.shared)
}
