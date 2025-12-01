//
//  VibeIntelligenceApp.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI
import UserNotifications

@main
struct VibeIntelligenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var configManager = ConfigManager.shared
    @StateObject private var windowManager = WindowManager.shared
    
    var body: some Scene {
        // Menu Bar Extra with popover style
        MenuBarExtra {
            MenuBarView()
                .environmentObject(configManager)
                .environmentObject(windowManager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "waveform.circle.fill")
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .menuBarExtraStyle(.window)
        
        // Main Window - Dashboard
        Window("VibeIntelligence", id: "main") {
            MainWindowView()
                .environmentObject(configManager)
                .environmentObject(windowManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 650)
        .defaultPosition(.center)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Transformation") {
                    windowManager.showMainWindow()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    // Future: implement update check
                }
            }
        }
        
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(configManager)
                .environmentObject(windowManager)
        }
        
        // History Window
        Window("History", id: "history") {
            HistoryView()
                .environmentObject(configManager)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 700, height: 500)
        
        // Quick Transform Window (floating panel)
        Window("Quick Transform", id: "quick") {
            QuickTransformView()
                .environmentObject(configManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 400)
    }
}

// MARK: - Window Manager
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    
    /// Flag to prevent didSet side effects during initialization
    private var isInitialized = false
    
    @Published var showDockIcon: Bool {
        didSet {
            guard isInitialized else { return }
            UserDefaults.standard.set(showDockIcon, forKey: "showDockIcon")
            updateDockVisibility()
        }
    }
    
    @Published var showMenuBarIcon: Bool {
        didSet {
            guard isInitialized else { return }
            UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon")
        }
    }
    
    @Published var isMainWindowVisible = false
    
    private init() {
        // Read from UserDefaults with defaults for first launch
        let dockIconValue = UserDefaults.standard.object(forKey: "showDockIcon") as? Bool ?? true
        let menuBarIconValue = UserDefaults.standard.object(forKey: "showMenuBarIcon") as? Bool ?? true
        
        // Assign values (didSet will fire but guard prevents side effects)
        self.showDockIcon = dockIconValue
        self.showMenuBarIcon = menuBarIconValue
        
        // Persist defaults on first launch
        if UserDefaults.standard.object(forKey: "showDockIcon") == nil {
            UserDefaults.standard.set(true, forKey: "showDockIcon")
        }
        if UserDefaults.standard.object(forKey: "showMenuBarIcon") == nil {
            UserDefaults.standard.set(true, forKey: "showMenuBarIcon")
        }
        
        // Mark initialization complete - future didSet calls will execute side effects
        isInitialized = true
        
        // Sync initial dock visibility state after initialization is complete
        updateDockVisibility()
    }
    
    func updateDockVisibility() {
        DispatchQueue.main.async {
            if self.showDockIcon {
                NSApp.setActivationPolicy(.regular)
            } else {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    func showMainWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("main") ?? false }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func hideMainWindow() {
        if !showDockIcon {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure config directories exist
        ConfigManager.shared.ensureDirectoriesExist()
        
        // Request notification permissions
        requestNotificationPermission()
        
        // Set initial activation policy based on user preference
        let showDockIcon = UserDefaults.standard.object(forKey: "showDockIcon") as? Bool ?? true
        if showDockIcon {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // Show onboarding on first launch
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WindowManager.shared.showMainWindow()
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running in menu bar
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show main window when clicking dock icon
        if !flag {
            WindowManager.shared.showMainWindow()
        }
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Modern Notifications
extension AppDelegate {
    static func showNotification(title: String, message: String, sound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        if sound {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
