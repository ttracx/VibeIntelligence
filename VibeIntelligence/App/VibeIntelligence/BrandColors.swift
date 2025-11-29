//
//  BrandColors.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

// MARK: - VibeCaaS Brand Colors
extension Color {
    /// Vibe Purple - Primary brand color (#6D4AFF)
    static let vibePurple = Color(red: 109/255, green: 74/255, blue: 255/255)
    
    /// Aqua Teal - Secondary brand color (#14B8A6)
    static let aquaTeal = Color(red: 20/255, green: 184/255, blue: 166/255)
    
    /// Signal Amber - Accent color (#FF8C00)
    static let signalAmber = Color(red: 255/255, green: 140/255, blue: 0/255)
}

// MARK: - NSColor Extensions
extension NSColor {
    static let vibePurple = NSColor(red: 109/255, green: 74/255, blue: 255/255, alpha: 1.0)
    static let aquaTeal = NSColor(red: 20/255, green: 184/255, blue: 166/255, alpha: 1.0)
    static let signalAmber = NSColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1.0)
}

// MARK: - Brand Gradients
extension LinearGradient {
    static let vibePrimary = LinearGradient(
        colors: [.vibePurple, .aquaTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let vibeAccent = LinearGradient(
        colors: [.vibePurple, .signalAmber],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let vibeBackground = LinearGradient(
        colors: [
            Color.vibePurple.opacity(0.1),
            Color.aquaTeal.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Brand Fonts
extension Font {
    /// Inter - Primary sans-serif font
    static func vibeSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    /// JetBrains Mono - Monospace font for code
    static func vibeMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Brand Messages
struct BrandMessages {
    // Success Messages
    static let enhanceSuccess = "Your prompt is now in rhythm ✨"
    static let agentSuccess = "Tuned for AI agents 🎧"
    static let specSuccess = "Expanded to full composition 📝"
    static let simplifySuccess = "Stripped to the beat 🎵"
    static let proofreadSuccess = "Polished to perfection 💎"
    static let customSuccess = "Custom vibe applied 🎨"
    
    // Processing Messages
    static let processing = "Mixing your vibe..."
    
    // Error Messages
    static let error = "Hit a skip in the track. Let's retry."
    static let apiError = "The vibe got interrupted. Check your connection."
    static let noInput = "No text to transform"
    
    // Taglines
    static let tagline = "Code the Vibe. Deploy the Dream."
    static let poweredBy = "Powered by VibeCaaS.com"
}
