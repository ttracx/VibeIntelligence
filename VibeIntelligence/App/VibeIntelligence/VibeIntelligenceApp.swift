//
//  VibeIntelligenceApp.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

@main
struct VibeIntelligenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var configManager = ConfigManager.shared
    
    var body: some Scene {
        // Menu Bar Extra with window style
        MenuBarExtra {
            MenuBarView()
                .environmentObject(configManager)
        } label: {
            Label("VibeIntelligence", systemImage: "waveform.circle.fill")
        }
        .menuBarExtraStyle(.window)
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(configManager)
        }
        
        // Main Window (optional - for dock access)
        Window("VibeIntelligence", id: "main") {
            ContentView()
                .environmentObject(configManager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 600, height: 500)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure config directories exist
        ConfigManager.shared.ensureDirectoriesExist()
        
        // Set activation policy to accessory (menu bar app)
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running in menu bar
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show main window when clicking dock icon
        if !flag {
            for window in sender.windows {
                if window.identifier?.rawValue == "main" {
                    window.makeKeyAndOrderFront(self)
                    NSApp.setActivationPolicy(.regular)
                    return true
                }
            }
        }
        return true
    }
}
