//
//  TemplatesView.swift
//  VibeIntelligence
//
//  Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."
//  © 2025 NeuralQuantum.ai LLC
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var templates: [Template] = []
    @State private var selectedTemplate: Template?
    @State private var searchText = ""
    @State private var isCreatingNew = false
    @State private var newTemplateName = ""
    
    var filteredTemplates: [Template] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        HSplitView {
            // Template List
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Templates")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        isCreatingNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding()
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search templates...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                
                // Built-in Templates Section
                List(selection: $selectedTemplate) {
                    Section("Built-in") {
                        ForEach(builtInTemplates) { template in
                            TemplateRow(template: template, isSelected: selectedTemplate?.id == template.id)
                                .tag(template)
                        }
                    }
                    
                    if !filteredTemplates.filter({ !$0.isBuiltIn }).isEmpty {
                        Section("Custom") {
                            ForEach(filteredTemplates.filter { !$0.isBuiltIn }) { template in
                                TemplateRow(template: template, isSelected: selectedTemplate?.id == template.id)
                                    .tag(template)
                                    .contextMenu {
                                        Button("Edit") {
                                            openTemplateInEditor(template)
                                        }
                                        Button("Duplicate") {
                                            duplicateTemplate(template)
                                        }
                                        Divider()
                                        Button("Delete", role: .destructive) {
                                            deleteTemplate(template)
                                        }
                                    }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 220, maxWidth: 300)
            
            // Template Detail/Editor
            if let template = selectedTemplate {
                TemplateDetailView(template: template)
            } else {
                noSelectionView
            }
        }
        .onAppear {
            loadTemplates()
        }
        .sheet(isPresented: $isCreatingNew) {
            CreateTemplateSheet(isPresented: $isCreatingNew) { name in
                createNewTemplate(name: name)
            }
        }
    }
    
    private var builtInTemplates: [Template] {
        [
            Template(id: "enhance", name: "Enhance", description: "Make prompts comprehensive and actionable", icon: "sparkles", isBuiltIn: true),
            Template(id: "agent", name: "Agent Prompt", description: "Optimize for AI coding assistants", icon: "cpu", isBuiltIn: true),
            Template(id: "spec", name: "Technical Spec", description: "Expand into detailed specifications", icon: "doc.text", isBuiltIn: true),
            Template(id: "simplify", name: "Simplify", description: "Strip to essential message", icon: "arrow.down.right.and.arrow.up.left", isBuiltIn: true),
            Template(id: "proofread", name: "Proofread", description: "Fix grammar and polish text", icon: "checkmark.circle", isBuiltIn: true)
        ]
    }
    
    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Select a Template")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Choose a template to view details\nor create a new one")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func loadTemplates() {
        let templatesDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        
        templates = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: templatesDir, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files where file.pathExtension == "md" {
            let name = file.deletingPathExtension().lastPathComponent
            let content = (try? String(contentsOf: file, encoding: .utf8)) ?? ""
            
            // Parse description from first line if it's a comment
            var description = "Custom template"
            if content.hasPrefix("<!--") {
                if let endRange = content.range(of: "-->") {
                    description = String(content[content.index(content.startIndex, offsetBy: 4)..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            templates.append(Template(
                id: name,
                name: name.replacingOccurrences(of: "-", with: " ").capitalized,
                description: description,
                icon: "doc.text",
                isBuiltIn: false,
                fileURL: file,
                content: content
            ))
        }
    }
    
    private func createNewTemplate(name: String) {
        let templatesDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        
        let filename = name.lowercased().replacingOccurrences(of: " ", with: "-") + ".md"
        let fileURL = templatesDir.appendingPathComponent(filename)
        
        let content = """
        <!-- \(name) Template -->
        # \(name)
        
        You are VibeIntelligence from VibeCaaS.com ("Code the Vibe. Deploy the Dream.").
        
        [Describe what this template should do]
        
        Output ONLY the result, no explanations.
        """
        
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
        loadTemplates()
        
        // Select the new template
        if let newTemplate = templates.first(where: { $0.id == name.lowercased().replacingOccurrences(of: " ", with: "-") }) {
            selectedTemplate = newTemplate
        }
    }
    
    private func openTemplateInEditor(_ template: Template) {
        if let url = template.fileURL {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func duplicateTemplate(_ template: Template) {
        guard let url = template.fileURL,
              let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        
        let newName = template.name + " Copy"
        createNewTemplate(name: newName)
        
        // Update content
        let templatesDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/VibeIntelligence/templates")
        let filename = newName.lowercased().replacingOccurrences(of: " ", with: "-") + ".md"
        let newURL = templatesDir.appendingPathComponent(filename)
        
        try? content.write(to: newURL, atomically: true, encoding: .utf8)
        loadTemplates()
    }
    
    private func deleteTemplate(_ template: Template) {
        if let url = template.fileURL {
            try? FileManager.default.removeItem(at: url)
            loadTemplates()
            if selectedTemplate?.id == template.id {
                selectedTemplate = nil
            }
        }
    }
}

// MARK: - Template Model
struct Template: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isBuiltIn: Bool
    var fileURL: URL?
    var content: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Template, rhs: Template) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Template Row
struct TemplateRow: View {
    let template: Template
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.icon)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .vibePurple)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(template.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if template.isBuiltIn {
                Text("Built-in")
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Template Detail View
struct TemplateDetailView: View {
    let template: Template
    @State private var testInput = ""
    @State private var testOutput = ""
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: template.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.vibePurple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !template.isBuiltIn, let url = template.fileURL {
                    Button {
                        NSWorkspace.shared.open(url)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let content = template.content {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Template Content")
                                .font(.headline)
                            
                            Text(content)
                                .font(.system(size: 12, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(8)
                        }
                    } else {
                        // Show description for built-in templates
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.headline)
                            
                            Text(builtInDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Test Area
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Test Template")
                            .font(.headline)
                        
                        TextEditor(text: $testInput)
                            .font(.system(size: 12, design: .monospaced))
                            .scrollContentBackground(.hidden)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.vibePurple.opacity(0.2), lineWidth: 1)
                            )
                        
                        Button {
                            testTemplate()
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                                Text(isProcessing ? "Processing..." : "Test")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.vibePurple)
                        .disabled(testInput.isEmpty || isProcessing)
                        
                        if !testOutput.isEmpty {
                            TextEditor(text: $testOutput)
                                .font(.system(size: 12, design: .monospaced))
                                .scrollContentBackground(.hidden)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(8)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.aquaTeal.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    private var builtInDescription: String {
        switch template.id {
        case "enhance":
            return "Rewrites text to be more comprehensive, clear, and robust. Adds explicit requirements, edge cases, and clear structure while maintaining the original intent."
        case "agent":
            return "Transforms text into a well-structured prompt optimized for AI coding agents like Cursor, Claude Code, and GitHub Copilot. Includes goals, requirements, constraints, and verification checklists."
        case "spec":
            return "Expands brief descriptions into detailed technical specifications with functional requirements, non-functional requirements, data models, and testing requirements."
        case "simplify":
            return "Simplifies and clarifies text by removing redundancy, using plain language, and improving readability while keeping all essential information."
        case "proofread":
            return "Fixes spelling, grammar, and punctuation errors. Improves awkward phrasing while maintaining the original voice and intent."
        default:
            return template.description
        }
    }
    
    private func testTemplate() {
        guard !testInput.isEmpty else { return }
        
        isProcessing = true
        
        // Map template ID to ProcessingMode
        let mode: ProcessingMode
        switch template.id {
        case "enhance": mode = .enhance
        case "agent": mode = .agent
        case "spec": mode = .spec
        case "simplify": mode = .simplify
        case "proofread": mode = .proofread
        default: mode = .enhance
        }
        
        Task {
            do {
                let result = try await VibeIntelligenceService.shared.process(
                    text: testInput,
                    mode: mode
                )
                await MainActor.run {
                    testOutput = result
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    testOutput = "Error: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Create Template Sheet
struct CreateTemplateSheet: View {
    @Binding var isPresented: Bool
    let onCreate: (String) -> Void
    
    @State private var templateName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Template")
                .font(.headline)
            
            TextField("Template Name", text: $templateName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Create") {
                    onCreate(templateName)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.vibePurple)
                .disabled(templateName.isEmpty)
            }
        }
        .padding(30)
    }
}

#Preview {
    TemplatesView()
        .environmentObject(ConfigManager.shared)
        .frame(width: 800, height: 500)
}

