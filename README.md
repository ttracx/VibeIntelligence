# 🎧 VibeIntelligence

**AI-Powered Text Enhancement for macOS**

*Part of the [VibeCaaS](https://vibecaas.com) ecosystem*

> "Code the Vibe. Deploy the Dream."

---

## What is VibeIntelligence?

VibeIntelligence is a native macOS app that brings AI-powered text transformation to your fingertips. Access it from the **menu bar**, **dock**, or **right-click context menu**. Select any text, transform it instantly with AI.

**Perfect for:**
- 🤖 **AI Agents** — Optimize prompts for Cursor, Claude Code, Copilot, Windsurf
- 📝 **Technical Specs** — Expand ideas into detailed specifications
- ✨ **Enhancement** — Make vague requirements crystal clear
- 🎯 **Simplification** — Strip text to its essential message

## ✨ Features

### 🖥️ Native macOS App
- **Menu Bar + Dock** — Choose your preferred access method
- **Beautiful UI** — Modern, native SwiftUI interface
- **Quick Actions** — Transform clipboard text instantly
- **Drag & Drop** — Drop text files directly into the app

### 🎛️ Transformation Modes
- **Enhance** — Make text comprehensive and robust
- **Agent Prompt** — Optimize for AI coding agents
- **Technical Spec** — Expand to full specification
- **Simplify** — Strip to essential clarity
- **Proofread** — Fix grammar and polish

### 🔧 Additional Features
- **Right-click integration** — Access AI tools from any app's context menu
- **Local AI support** — Works with Ollama and LM Studio
- **Custom templates** — Create your own transformation templates
- **History tracking** — Review and reuse past transformations
- **Keyboard shortcuts** — Fast access with configurable hotkeys

## 🚀 Quick Start

### Building the App

```bash
cd ~/VibeIntelligence/App
xcodebuild -project VibeIntelligence.xcodeproj -scheme VibeIntelligence -configuration Release build
```

Or open `VibeIntelligence.xcodeproj` in Xcode and press ⌘B.

### Running the App

1. **Open the built app** from `~/VibeIntelligence/App/VibeIntelligence.app`
2. **Complete the onboarding** — Select your AI provider and configure settings
3. **Start transforming!** — Use the menu bar icon or dock app

### Services Installation (Optional)

For right-click context menu integration:

```bash
cd ~/VibeIntelligence
chmod +x install.sh
./install.sh
```

## ⌨️ Keyboard Shortcuts

### Global Shortcuts (from Services)
| Shortcut | Action |
|----------|--------|
| `⌃⌥E` | Enhance selected text |
| `⌃⌥A` | Convert to Agent Prompt |
| `⌃⌥S` | Generate Technical Spec |
| `⌃⌥D` | Simplify text |

### In-App Shortcuts
| Shortcut | Action |
|----------|--------|
| `⌘↩` | Transform text |
| `⌘N` | New transformation |
| `⌘,` | Open Settings |
| `⌘Q` | Quit app |

## 🎛️ App Settings

### General
- **Show in Dock** — Toggle dock icon visibility
- **Launch at Login** — Start with macOS
- **Notifications** — Enable/disable transformation notifications
- **History** — Configure history retention

### AI Provider
- **Auto-detect** — Automatically use best available provider
- **Anthropic Claude** — Cloud-based, requires API key
- **Ollama** — Local AI, runs on your machine
- **LM Studio** — Local AI with GUI

## 🤖 AI Provider Setup

### Anthropic Claude (Cloud)

1. Get an API key from [console.anthropic.com](https://console.anthropic.com)
2. Open VibeIntelligence Settings → AI Provider
3. Enter your API key and click Save

### Ollama (Local)

```bash
# Install Ollama
brew install ollama

# Pull a model
ollama pull llama3.2

# Ollama runs on http://localhost:11434
```

### LM Studio (Local)

1. Download [LM Studio](https://lmstudio.ai)
2. Load a model and start the local server
3. Server runs on http://localhost:1234

## 📝 Custom Templates

Create templates in `~/.config/VibeIntelligence/templates/`:

```markdown
<!-- My Custom Template -->
# Custom Template Name

You are VibeIntelligence from VibeCaaS.com.

Your system prompt here...

Transform the input according to your rules.

Output ONLY the transformed text.
```

### Included Templates

- `default.md` — General enhancement
- `api-endpoint.md` — REST API endpoint specification
- `react-component.md` — React/TypeScript component spec
- `user-story.md` — Agile user story format
- `code-review.md` — Code review feedback
- `bug-report.md` — Bug report template

## 💻 CLI Usage

VibeIntelligence also works from the command line:

```bash
# Enhance text from clipboard
VibeIntelligence --mode enhance --notify

# Optimize for AI agents
echo "create login form" | VibeIntelligence -m agent

# Generate spec from file
VibeIntelligence -m spec -f idea.txt -o file:spec.md

# Use local Ollama
VibeIntelligence -m enhance -p ollama
```

### CLI Options

```
INPUT (priority order)
    --text, -t STRING     Direct text input
    --file, -f PATH       Read from file
    <stdin>               Piped input
    <clipboard>           Fallback to pbpaste

MODES
    --mode, -m MODE       enhance | agent | spec | simplify | proofread | custom

OUTPUT
    --output, -o MODE     clipboard | replace | stdout | file:PATH

AI PROVIDER
    --provider, -p NAME   auto | anthropic | ollama | lmstudio

OPTIONS
    --template, -T PATH   Custom template for 'custom' mode
    --notify, -n          Show macOS notification
    --quiet, -q           Suppress status messages
    --diff, -d            Show before/after comparison
    --no-history          Don't save to history
    --help, -h            Show help
```

## 🎨 Brand Identity

VibeIntelligence follows VibeCaaS design language:

| Element | Value |
|---------|-------|
| **Primary** | Vibe Purple `#6D4AFF` |
| **Secondary** | Aqua Teal `#14B8A6` |
| **Accent** | Signal Amber `#FF8C00` |

### Notification Messages

- ✨ **Enhance**: "Your prompt is now in rhythm"
- 🎧 **Agent**: "Tuned for AI agents"
- 📝 **Spec**: "Expanded to full composition"
- 🎵 **Simplify**: "Stripped to the beat"
- ⏳ **Processing**: "Mixing your vibe..."
- ❌ **Error**: "Hit a skip in the track. Let's retry."

## 📁 Project Structure

```
VibeIntelligence/
├── App/                            # macOS Native App
│   ├── VibeIntelligence.xcodeproj
│   ├── VibeIntelligence/
│   │   ├── VibeIntelligenceApp.swift
│   │   ├── MainWindowView.swift    # Main dashboard
│   │   ├── MenuBarView.swift       # Menu bar popover
│   │   ├── SettingsView.swift      # App settings
│   │   ├── HistoryView.swift       # Transformation history
│   │   ├── TemplatesView.swift     # Template management
│   │   ├── OnboardingView.swift    # First-run setup
│   │   ├── QuickTransformView.swift
│   │   ├── ConfigManager.swift
│   │   ├── VibeIntelligenceService.swift
│   │   └── BrandColors.swift
│   └── VibeIntelligence.app        # Built app
├── Services/                       # macOS Automator workflows
│   ├── VibeIntelligence - Enhance.workflow
│   ├── VibeIntelligence - Agent Prompt.workflow
│   ├── VibeIntelligence - Technical Spec.workflow
│   ├── VibeIntelligence - Simplify.workflow
│   └── VibeIntelligence - Custom.workflow
├── bin/
│   └── VibeIntelligence            # Core CLI engine
├── config/
│   ├── config.json
│   ├── brand.json
│   └── templates/
├── logs/
│   └── VibeIntelligence.log
├── assets/
│   └── icon.svg
├── install.sh
├── uninstall.sh
└── README.md
```

## 🔧 Configuration

User config: `~/.config/VibeIntelligence/config.json`

```json
{
    "model": "claude-sonnet-4-20250514",
    "default_mode": "enhance",
    "notify": true,
    "history_enabled": true,
    "max_history": 100,
    "show_dock_icon": true
}
```

## 🐛 Troubleshooting

### App doesn't appear in dock
- Open Settings → Appearance → Enable "Show in Dock"

### Services not appearing in context menu
1. Restart the Services database:
   ```bash
   /System/Library/CoreServices/pbs -flush
   ```
2. Log out and log back in
3. Check permissions in System Settings → Privacy & Security

### API errors
1. Verify API key is set in Settings → AI Provider
2. Test connection using the "Test Provider" button
3. Check logs: `~/.config/VibeIntelligence/logs/`

### Local AI not detected
1. Ensure Ollama or LM Studio is running
2. Check that local server is accessible
3. Try the Test Connection button in Settings

## 🗑️ Uninstallation

```bash
cd ~/VibeIntelligence
./uninstall.sh
```

Or manually:
1. Quit the app
2. Delete `~/VibeIntelligence/App/VibeIntelligence.app`
3. Delete `~/.config/VibeIntelligence/` (optional, keeps your settings)

## 📜 License

© 2025 NeuralQuantum.ai LLC. All rights reserved.

Part of the VibeCaaS ecosystem — [vibecaas.com](https://vibecaas.com)

---

<p align="center">
  <strong>🎵 Your prompts are about to hit different.</strong><br>
  <em>VibeCaaS.com — Code the Vibe. Deploy the Dream.</em>
</p>
