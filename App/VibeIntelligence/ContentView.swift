//
//  ContentView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

// ContentView now redirects to MainWindowView for a unified experience
struct ContentView: View {
    @EnvironmentObject var configManager: ConfigManager
    
    var body: some View {
        MainWindowView()
            .environmentObject(configManager)
            .environmentObject(WindowManager.shared)
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
    
    var description: String {
        switch self {
        case .enhance: return "Make prompts comprehensive and actionable"
        case .agent: return "Optimize for AI coding assistants"
        case .spec: return "Expand into detailed specifications"
        case .simplify: return "Strip to essential message"
        case .proofread: return "Fix grammar and polish text"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigManager.shared)
}
