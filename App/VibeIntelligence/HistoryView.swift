//
//  HistoryView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var historyItems: [HistoryItem] = []
    @State private var selectedItem: HistoryItem?
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .newest
    
    enum SortOrder: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case mode = "Mode"
    }
    
    var filteredItems: [HistoryItem] {
        var items = historyItems
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.input.localizedCaseInsensitiveContains(searchText) ||
                item.output.localizedCaseInsensitiveContains(searchText) ||
                item.mode.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOrder {
        case .newest:
            items.sort { $0.timestamp > $1.timestamp }
        case .oldest:
            items.sort { $0.timestamp < $1.timestamp }
        case .mode:
            items.sort { $0.mode < $1.mode }
        }
        
        return items
    }
    
    var body: some View {
        HSplitView {
            // List
            VStack(spacing: 0) {
                // Search & Filter Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search history...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                    
                    Picker("Sort", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                }
                .padding()
                
                Divider()
                
                if filteredItems.isEmpty {
                    emptyState
                } else {
                    List(filteredItems, selection: $selectedItem) { item in
                        HistoryRow(item: item, isSelected: selectedItem?.id == item.id)
                            .tag(item)
                    }
                    .listStyle(.sidebar)
                }
            }
            .frame(minWidth: 280, maxWidth: 400)
            
            // Detail View
            if let item = selectedItem {
                HistoryDetailView(item: item)
            } else {
                noSelectionView
            }
        }
        .onAppear {
            loadHistory()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No History Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your transformations will appear here")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Select an item")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Choose a history item to view details")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func loadHistory() {
        let historyDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/history")
        
        historyItems = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: historyDir, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }
            
            let timestamp = json["timestamp"] as? String ?? ""
            let mode = json["mode"] as? String ?? "unknown"
            let input = json["input"] as? String ?? ""
            let output = json["output"] as? String ?? ""
            
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: timestamp) ?? Date()
            
            let item = HistoryItem(
                id: file.lastPathComponent,
                timestamp: date,
                mode: mode,
                input: input,
                output: output,
                fileURL: file
            )
            
            historyItems.append(item)
        }
        
        // Sort by newest first
        historyItems.sort { $0.timestamp > $1.timestamp }
    }
}

// MARK: - History Item Model
struct HistoryItem: Identifiable, Hashable {
    let id: String
    let timestamp: Date
    let mode: String
    let input: String
    let output: String
    let fileURL: URL
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let item: HistoryItem
    let isSelected: Bool
    
    private var modeIcon: String {
        switch item.mode {
        case "enhance": return "sparkles"
        case "agent": return "cpu"
        case "spec": return "doc.text"
        case "simplify": return "arrow.down.right.and.arrow.up.left"
        case "proofread": return "checkmark.circle"
        default: return "waveform"
        }
    }
    
    private var modeColor: Color {
        switch item.mode {
        case "enhance": return .vibePurple
        case "agent": return .blue
        case "spec": return .orange
        case "simplify": return .green
        case "proofread": return .aquaTeal
        default: return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: modeIcon)
                    .font(.system(size: 10))
                    .foregroundColor(modeColor)
                    .frame(width: 16)
                
                Text(item.mode.capitalized)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(modeColor)
                
                Spacer()
                
                Text(item.timestamp, style: .relative)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Text(item.input.prefix(80) + (item.input.count > 80 ? "..." : ""))
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.8))
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - History Detail View
struct HistoryDetailView: View {
    let item: HistoryItem
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: modeIcon)
                            .foregroundColor(.vibePurple)
                        Text(item.mode.capitalized)
                            .font(.headline)
                    }
                    
                    Text(item.timestamp, format: .dateTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button {
                        // Copy input
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.input, forType: .string)
                    } label: {
                        Label("Copy Input", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button {
                        // Copy output
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.output, forType: .string)
                    } label: {
                        Label("Copy Output", systemImage: "doc.on.doc.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.vibePurple)
                    .controlSize(.small)
                    
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Input", systemImage: "text.alignleft")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text(item.input)
                            .font(.system(size: 13, design: .monospaced))
                            .textSelection(.enabled)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.vibePurple.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Arrow
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LinearGradient.vibePrimary)
                        Spacer()
                    }
                    
                    // Output Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Output", systemImage: "text.badge.checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text(item.output)
                            .font(.system(size: 13, design: .monospaced))
                            .textSelection(.enabled)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.aquaTeal.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Stats
                    HStack(spacing: 24) {
                        StatBadge(label: "Input", value: "\(item.input.count) chars")
                        StatBadge(label: "Output", value: "\(item.output.count) chars")
                        StatBadge(label: "Ratio", value: String(format: "%.1fx", Double(item.output.count) / max(Double(item.input.count), 1)))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .alert("Delete History Item?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var modeIcon: String {
        switch item.mode {
        case "enhance": return "sparkles"
        case "agent": return "cpu"
        case "spec": return "doc.text"
        case "simplify": return "arrow.down.right.and.arrow.up.left"
        case "proofread": return "checkmark.circle"
        default: return "waveform"
        }
    }
    
    private func deleteItem() {
        try? FileManager.default.removeItem(at: item.fileURL)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    HistoryView()
        .environmentObject(ConfigManager.shared)
        .frame(width: 700, height: 500)
}

