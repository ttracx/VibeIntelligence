//
//  OnboardingView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var currentStep = 0
    @State private var apiKey = ""
    @State private var selectedProvider: AIProvider = .auto
    @EnvironmentObject var configManager: ConfigManager
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.vibePurple.opacity(0.15),
                    Color.aquaTeal.opacity(0.1),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.vibePurple : Color.secondary.opacity(0.3))
                            .frame(width: step == currentStep ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Content
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    FeaturesStep()
                        .tag(1)
                    
                    ProviderSetupStep(selectedProvider: $selectedProvider, apiKey: $apiKey)
                        .tag(2)
                    
                    GetStartedStep()
                        .tag(3)
                }
                .tabViewStyle(.automatic)
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                // Navigation
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < totalSteps - 1 {
                        Button("Continue") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.vibePurple)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.vibePurple)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func completeOnboarding() {
        // Save provider selection
        configManager.setProvider(selectedProvider)
        
        // Save API key if provided
        if !apiKey.isEmpty {
            configManager.saveAPIKey(apiKey)
        }
        
        // Mark onboarding complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        withAnimation {
            isFirstLaunch = false
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStep: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated Logo
            ZStack {
                Circle()
                    .fill(LinearGradient.vibePrimary)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.vibePurple.opacity(0.4), radius: 20, y: 10)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateIcon)
            }
            .onAppear {
                animateIcon = true
            }
            
            VStack(spacing: 12) {
                Text("Welcome to VibeIntelligence")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Code the Vibe. Deploy the Dream.")
                    .font(.title3)
                    .foregroundColor(.vibePurple)
            }
            
            Text("AI-powered text transformation that lives in your menu bar and dock.\nTransform prompts, create specs, and enhance your workflow.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)
            
            Spacer()
            
            HStack(spacing: 24) {
                FeaturePill(icon: "menubar.rectangle", text: "Menu Bar")
                FeaturePill(icon: "dock.rectangle", text: "Dock App")
                FeaturePill(icon: "keyboard", text: "Shortcuts")
            }
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Features Step
struct FeaturesStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Powerful Features")
                .font(.system(size: 28, weight: .bold))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                FeatureCard(
                    icon: "sparkles",
                    title: "Enhance",
                    description: "Make prompts comprehensive and actionable",
                    color: .vibePurple
                )
                
                FeatureCard(
                    icon: "cpu",
                    title: "Agent Prompt",
                    description: "Optimize for AI coding assistants",
                    color: .blue
                )
                
                FeatureCard(
                    icon: "doc.text",
                    title: "Technical Spec",
                    description: "Expand ideas into full specifications",
                    color: .orange
                )
                
                FeatureCard(
                    icon: "arrow.down.right.and.arrow.up.left",
                    title: "Simplify",
                    description: "Strip text to its essential message",
                    color: .green
                )
            }
            .frame(maxWidth: 600)
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Provider Setup Step
struct ProviderSetupStep: View {
    @Binding var selectedProvider: AIProvider
    @Binding var apiKey: String
    @State private var showAPIKey = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Choose Your AI Provider")
                .font(.system(size: 28, weight: .bold))
            
            Text("VibeIntelligence works with local and cloud AI providers")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Provider Selection
            VStack(spacing: 12) {
                ProviderOption(
                    provider: .auto,
                    isSelected: selectedProvider == .auto,
                    action: { selectedProvider = .auto }
                )
                
                ProviderOption(
                    provider: .ollama,
                    isSelected: selectedProvider == .ollama,
                    action: { selectedProvider = .ollama }
                )
                
                ProviderOption(
                    provider: .lmstudio,
                    isSelected: selectedProvider == .lmstudio,
                    action: { selectedProvider = .lmstudio }
                )
                
                ProviderOption(
                    provider: .anthropic,
                    isSelected: selectedProvider == .anthropic,
                    action: { selectedProvider = .anthropic }
                )
            }
            .frame(maxWidth: 500)
            
            // API Key input for Anthropic
            if selectedProvider == .anthropic || selectedProvider == .auto {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anthropic API Key (optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if showAPIKey {
                            TextField("sk-ant-...", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("sk-ant-...", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(showAPIKey ? "Hide" : "Show") {
                            showAPIKey.toggle()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    Link("Get an API key from Anthropic →", destination: URL(string: "https://console.anthropic.com/")!)
                        .font(.caption)
                        .foregroundColor(.aquaTeal)
                }
                .frame(maxWidth: 500)
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Get Started Step
struct GetStartedStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient.vibePrimary)
            
            Text("You're All Set!")
                .font(.system(size: 32, weight: .bold))
            
            VStack(alignment: .leading, spacing: 16) {
                ShortcutRow(keys: "⌃⌥E", description: "Enhance clipboard text")
                ShortcutRow(keys: "⌃⌥A", description: "Convert to Agent Prompt")
                ShortcutRow(keys: "⌃⌥S", description: "Generate Technical Spec")
                ShortcutRow(keys: "⌃⌥D", description: "Simplify text")
            }
            .padding(24)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(12)
            
            Text("Access VibeIntelligence from the menu bar icon or dock.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Supporting Views
struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.vibePurple.opacity(0.1))
        .foregroundColor(.vibePurple)
        .cornerRadius(20)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProviderOption: View {
    let provider: AIProvider
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: provider.icon)
                    .font(.system(size: 20))
                    .frame(width: 32)
                    .foregroundColor(isSelected ? .white : .vibePurple)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(providerDescription)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.vibePurple : Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var providerDescription: String {
        switch provider {
        case .auto: return "Automatically detect best available"
        case .anthropic: return "Cloud-based, requires API key"
        case .openai: return "OpenAI GPT-4o, requires API key"
        case .gemini: return "Google Gemini, requires API key"
        case .ollama: return "Local, runs on your machine"
        case .lmstudio: return "Local, GUI-based model runner"
        }
    }
}

struct ShortcutRow: View {
    let keys: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(keys)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.vibePurple)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardingView(isFirstLaunch: .constant(true))
        .environmentObject(ConfigManager.shared)
        .frame(width: 800, height: 600)
}

