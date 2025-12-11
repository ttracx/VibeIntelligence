//
//  ProcessingOverlayView.swift
//  VibeIntelligence
//
//  Processing animation overlay for text transformation
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC. All rights reserved.
//

import SwiftUI
import AppKit

// MARK: - Processing Overlay View

struct ProcessingOverlayView: View {
    @ObservedObject var controller: ProcessingOverlayController
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background blur
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.95)
            
            VStack(spacing: 16) {
                // Animated Logo
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.vibePurple, .aquaTeal, .vibePurple],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(rotation))
                        .blur(radius: 2)
                        .opacity(glowOpacity)
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.vibePurple.opacity(0.8), .aquaTeal.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-rotation * 0.7))
                    
                    // Inner pulsing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.vibePurple.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(scale)
                    
                    // Center icon
                    Image(systemName: modeIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.vibePurple, .aquaTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale * 0.9)
                    
                    // Orbiting particles
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == 0 ? Color.vibePurple : (index == 1 ? Color.aquaTeal : Color.white))
                            .frame(width: 6, height: 6)
                            .offset(x: 40)
                            .rotationEffect(.degrees(rotation + Double(index) * 120))
                            .opacity(0.8)
                    }
                }
                .frame(width: 90, height: 90)
                
                // Status text
                VStack(spacing: 4) {
                    Text(controller.modeName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(controller.statusMessage)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    // Progress dots
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.vibePurple)
                                .frame(width: 5, height: 5)
                                .opacity(progressDotOpacity(for: index))
                        }
                    }
                    .padding(.top, 4)
                }
                
                // Brand footer
                Text("VibeIntelligence")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .frame(width: 180, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.vibePurple.opacity(0.5), .aquaTeal.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .vibePurple.opacity(0.3), radius: 20, y: 5)
        .onAppear {
            startAnimations()
        }
    }
    
    private var modeIcon: String {
        switch controller.currentMode {
        case "enhance": return "wand.and.stars"
        case "agent": return "cpu"
        case "spec": return "doc.text.magnifyingglass"
        case "simplify": return "text.alignleft"
        case "proofread": return "checkmark.seal"
        case "custom": return "slider.horizontal.3"
        default: return "sparkles"
        }
    }
    
    private func progressDotOpacity(for index: Int) -> Double {
        let phase = (rotation / 120).truncatingRemainder(dividingBy: 3)
        let distance = abs(Double(index) - phase)
        return max(0.3, 1.0 - distance * 0.3)
    }
    
    private func startAnimations() {
        // Rotation animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            scale = 1.15
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }
}

// MARK: - Processing Overlay Controller

class ProcessingOverlayController: ObservableObject {
    static let shared = ProcessingOverlayController()
    
    @Published var isVisible = false
    @Published var currentMode = "enhance"
    @Published var statusMessage = "Transforming text..."
    
    private var overlayWindow: NSWindow?
    private var startTime: Date?
    
    var modeName: String {
        switch currentMode {
        case "enhance": return "Enhancing"
        case "agent": return "Agent Optimizing"
        case "spec": return "Generating Spec"
        case "simplify": return "Simplifying"
        case "proofread": return "Proofreading"
        case "custom": return "Custom Transform"
        default: return "Processing"
        }
    }
    
    private init() {
        setupFileObserver()
    }
    
    // MARK: - Public Methods
    
    func show(mode: String = "enhance") {
        DispatchQueue.main.async {
            self.currentMode = mode
            self.statusMessage = "Transforming text..."
            self.startTime = Date()
            self.isVisible = true
            self.createAndShowWindow()
        }
    }
    
    func hide(success: Bool = true) {
        DispatchQueue.main.async {
            if let startTime = self.startTime {
                let duration = Date().timeIntervalSince(startTime)
                self.statusMessage = success ? String(format: "Done in %.1fs", duration) : "Error occurred"
            }
            
            // Brief delay to show completion status
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissWindow()
                self.isVisible = false
            }
        }
    }
    
    func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = message
        }
    }
    
    // MARK: - Window Management
    
    private func createAndShowWindow() {
        guard overlayWindow == nil else {
            overlayWindow?.orderFront(nil)
            return
        }
        
        let contentView = ProcessingOverlayView(controller: self)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 180, height: 200),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.contentView = NSHostingView(rootView: contentView)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.hasShadow = true
        window.ignoresMouseEvents = true
        
        // Position in top-right corner
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = window.frame
            let x = screenRect.maxX - windowRect.width - 20
            let y = screenRect.maxY - windowRect.height - 20
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        overlayWindow = window
        
        // Animate in
        window.alphaValue = 0
        window.orderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1
        }
    }
    
    private func dismissWindow() {
        guard let window = overlayWindow else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
        }, completionHandler: {
            window.orderOut(nil)
            self.overlayWindow = nil
        })
    }
    
    // MARK: - File-based IPC for CLI Communication
    
    private let processingFlagPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/VibeIntelligence/.processing")
    
    private var fileObserver: DispatchSourceFileSystemObject?
    
    private func setupFileObserver() {
        let dirPath = processingFlagPath.deletingLastPathComponent()
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true)
        
        // Watch for file changes
        startWatching()
    }
    
    private func startWatching() {
        let dirPath = processingFlagPath.deletingLastPathComponent().path
        
        let dirFD = open(dirPath, O_EVTONLY)
        guard dirFD >= 0 else { return }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: dirFD,
            eventMask: [.write, .delete, .rename],
            queue: .main
        )
        
        source.setEventHandler { [weak self] in
            self?.checkProcessingFlag()
        }
        
        source.setCancelHandler {
            close(dirFD)
        }
        
        source.resume()
        fileObserver = source
        
        // Initial check
        checkProcessingFlag()
    }
    
    private func checkProcessingFlag() {
        if FileManager.default.fileExists(atPath: processingFlagPath.path) {
            // Read mode from file
            if let content = try? String(contentsOf: processingFlagPath, encoding: .utf8) {
                let mode = content.trimmingCharacters(in: .whitespacesAndNewlines)
                if !isVisible {
                    show(mode: mode.isEmpty ? "enhance" : mode)
                }
            }
        } else {
            if isVisible {
                hide(success: true)
            }
        }
    }
}

// MARK: - Visual Effect View (if not already defined elsewhere)

struct ProcessingVisualEffectView: NSViewRepresentable {
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

// MARK: - Preview

#Preview {
    ProcessingOverlayView(controller: ProcessingOverlayController.shared)
        .frame(width: 200, height: 220)
        .background(Color.black.opacity(0.5))
}

