//
//  OllamaSetupView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC. All rights reserved.
//

import SwiftUI

struct OllamaSetupView: View {
    @StateObject private var ollamaManager = OllamaManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.vibePurple, .aquaTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("VibeCaaS-vl:2b")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("On-Device Vision Intelligence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Status
            VStack(spacing: 16) {
                statusRow(
                    "Ollama Runtime",
                    isComplete: ollamaManager.isOllamaInstalled,
                    isActive: ollamaManager.isDownloading && ollamaManager.downloadProgress < 0.3
                )
                
                statusRow(
                    "Ollama Server",
                    isComplete: ollamaManager.isOllamaRunning,
                    isActive: ollamaManager.isDownloading && ollamaManager.downloadProgress >= 0.3 && ollamaManager.downloadProgress < 0.4
                )
                
                statusRow(
                    "VibeCaaS-vl:2b Model",
                    isComplete: ollamaManager.isModelInstalled,
                    isActive: ollamaManager.isDownloading && ollamaManager.downloadProgress >= 0.4
                )
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            
            // Progress
            if ollamaManager.isDownloading {
                VStack(spacing: 8) {
                    ProgressView(value: ollamaManager.downloadProgress)
                        .progressViewStyle(.linear)
                        .tint(.vibePurple)
                    
                    Text(ollamaManager.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Error Message
            if let error = ollamaManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Model Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Model Capabilities")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    capabilityChip("Vision", icon: "eye")
                    capabilityChip("OCR", icon: "doc.text.viewfinder")
                    capabilityChip("UI Analysis", icon: "rectangle.on.rectangle")
                }
                
                HStack(spacing: 16) {
                    capabilityChip("2B Params", icon: "cpu")
                    capabilityChip("~4GB RAM", icon: "memorychip")
                    capabilityChip("On-Device", icon: "lock.shield")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vibePurple.opacity(0.1))
            .cornerRadius(12)
            
            // Actions
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    Task {
                        await ollamaManager.setupVibeCaaSVision()
                    }
                }) {
                    HStack {
                        if ollamaManager.isDownloading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "arrow.down.circle")
                        }
                        Text(buttonText)
                    }
                    .frame(minWidth: 150)
                }
                .buttonStyle(.borderedProminent)
                .tint(.vibePurple)
                .disabled(ollamaManager.isDownloading || ollamaManager.isModelInstalled)
            }
            
            // Footer
            Text("Powered by VibeCaaS.com • NeuralQuantum.ai LLC")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(width: 450, height: 550)
        .onAppear {
            ollamaManager.checkStatus()
        }
    }
    
    private var buttonText: String {
        if ollamaManager.isModelInstalled {
            return "Installed ✓"
        } else if ollamaManager.isDownloading {
            return "Installing..."
        } else if !ollamaManager.isOllamaInstalled {
            return "Install Ollama & Model"
        } else if !ollamaManager.isOllamaRunning {
            return "Start & Install Model"
        } else {
            return "Install VibeCaaS-vl:2b"
        }
    }
    
    @ViewBuilder
    private func statusRow(_ title: String, isComplete: Bool, isActive: Bool) -> some View {
        HStack {
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isActive {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            if isComplete {
                Text("Ready")
                    .font(.caption)
                    .foregroundColor(.green)
            } else if isActive {
                Text("In Progress")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Text("Pending")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func capabilityChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
}

// MARK: - Settings Integration

struct OllamaSettingsSection: View {
    @StateObject private var ollamaManager = OllamaManager.shared
    @State private var showSetup = false
    
    var body: some View {
        Section("On-Device Vision (VibeCaaS-vl:2b)") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(ollamaManager.statusMessage)
                            .font(.body)
                    }
                    
                    Text("Powered by VibeCaaS.com • NeuralQuantum.ai")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(ollamaManager.isModelInstalled ? "Reinstall" : "Setup") {
                    showSetup = true
                }
                .buttonStyle(.bordered)
            }
            
            if ollamaManager.isModelInstalled {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Capabilities")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("• Image analysis and description")
                    Text("• OCR and text extraction")
                    Text("• UI/UX analysis")
                    Text("• Design feedback")
                }
                .font(.caption)
            }
        }
        .sheet(isPresented: $showSetup) {
            OllamaSetupView()
        }
        .onAppear {
            ollamaManager.checkStatus()
        }
    }
    
    private var statusColor: Color {
        if ollamaManager.isModelInstalled {
            return .green
        } else if ollamaManager.isOllamaRunning {
            return .yellow
        } else if ollamaManager.isOllamaInstalled {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    OllamaSetupView()
}

