# 🎧 VibeIntelligence

**AI-Powered Text Enhancement for macOS**

*Part of the [VibeCaaS](https://vibecaas.com) ecosystem*

> "Code the Vibe. Deploy the Dream."

---

## What is VibeIntelligence?

VibeIntelligence adds Apple Intelligence-style writing tools to your right-click context menu. Select any text, right-click, and transform it instantly with AI.

**Perfect for:**
- 🤖 **AI Agents** — Optimize prompts for Cursor, Claude Code, Copilot, Windsurf
- 📝 **Technical Specs** — Expand ideas into detailed specifications
- ✨ **Enhancement** — Make vague requirements crystal clear
- 🎯 **Simplification** — Strip text to its essential message

## ✨ Features

- **Right-click integration** — Access AI tools from any app's context menu
- **Multiple modes** — Enhance, Agent Prompt, Technical Spec, Simplify, Proofread
- **Local AI support** — Works with Ollama and LM Studio
- **Custom templates** — Create your own transformation templates
- **History tracking** — Review and reuse past transformations
- **VibeCaaS branded** — Consistent messaging with music/flow metaphors

## 🚀 Quick Start

### Installation

```bash
cd ~/Projects/VibeIntelligence
chmod +x install.sh
./install.sh
```

### Setup

1. **Set your API key** (choose one method):

   ```bash
   # Environment variable
   export ANTHROPIC_API_KEY='your-key-here'
   
   # Or add to config file
   # ~/.config/VibeIntelligence/config.json
   ```

2. **Enable Services**:
   - System Settings → Privacy & Security → Accessibility
   - Allow Automator to control your computer
   - System Settings → Keyboard → Keyboard Shortcuts → Services
   - Enable all "VibeIntelligence" services

3. **Test it**:
   - Select text anywhere
   - Right-click → Services → VibeIntelligence - Enhance
   - Watch your text transform! ✨

## 🎛️ Modes

| Mode | Service | Description |
|------|---------|-------------|
| **Enhance** | VibeIntelligence - Enhance | Make text comprehensive and robust |
| **Agent Prompt** | VibeIntelligence - Agent Prompt | Optimize for AI coding agents |
| **Technical Spec** | VibeIntelligence - Technical Spec | Expand to full specification |
| **Simplify** | VibeIntelligence - Simplify | Strip to essential clarity |
| **Custom** | VibeIntelligence - Custom | Use your own template |

## ⌨️ Recommended Shortcuts

Set these in System Settings → Keyboard → Keyboard Shortcuts → Services:

| Shortcut | Service |
|----------|---------|
| `⌃⌥E` | VibeIntelligence - Enhance |
| `⌃⌥A` | VibeIntelligence - Agent Prompt |
| `⌃⌥S` | VibeIntelligence - Technical Spec |
| `⌃⌥D` | VibeIntelligence - Simplify |
| `⌃⌥C` | VibeIntelligence - Custom |

## 💻 CLI Usage

VibeIntelligence also works from the command line:

```bash
# Enhance text from clipboard
VibeIntelligence --mode enhance --notify

# Optimize for AI agents
echo "create login form" | VibeIntelligence -m agent

# Generate spec from file, save to file
VibeIntelligence -m spec -f idea.txt -o file:spec.md

# Use local Ollama
VibeIntelligence -m enhance -p ollama

# Show before/after diff
pbpaste | VibeIntelligence -m simplify -d
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

## 🤖 Local AI Support

### Ollama

```bash
# Install Ollama
brew install ollama

# Pull a model
ollama pull llama3.2

# Use with VibeIntelligence
VibeIntelligence -m enhance -p ollama

# Or set default
export OLLAMA_MODEL=llama3.2
export AI_PROVIDER=ollama
```

### LM Studio

1. Download and install [LM Studio](https://lmstudio.ai)
2. Start the local server (default: http://localhost:1234)
3. Use with VibeIntelligence:

```bash
VibeIntelligence -m enhance -p lmstudio
```

## 📝 Custom Templates

Create templates in `~/.config/VibeIntelligence/templates/`:

```markdown
---
name: My Template
description: What it does
author: Your Name
version: 1.0.0
---
You are VibeIntelligence from VibeCaaS.com.

Your system prompt here...

Transform the input according to your rules.

Output ONLY the transformed text.
```

### Included Templates

- `api-endpoint.md` — REST API endpoint specification
- `react-component.md` — React/TypeScript component spec
- `user-story.md` — Agile user story format
- `code-review.md` — Code review feedback
- `bug-report.md` — Bug report template
- `default.md` — General enhancement

Use with:
```bash
VibeIntelligence -m custom -T api-endpoint
```

## 🎨 Brand Identity

VibeIntelligence follows VibeCaaS design language:

| Element | Value |
|---------|-------|
| **Primary** | Vibe Purple `#6D4AFF` |
| **Secondary** | Aqua Teal `#14B8A6` |
| **Accent** | Signal Amber `#FF8C00` |
| **Font (Sans)** | Inter |
| **Font (Mono)** | JetBrains Mono |

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
├── Services/                    # macOS Automator workflows
│   ├── VibeIntelligence - Enhance.workflow
│   ├── VibeIntelligence - Agent Prompt.workflow
│   ├── VibeIntelligence - Technical Spec.workflow
│   ├── VibeIntelligence - Simplify.workflow
│   └── VibeIntelligence - Custom.workflow
├── bin/
│   └── VibeIntelligence         # Core CLI engine
├── config/
│   ├── config.json              # User preferences
│   ├── brand.json               # VibeCaaS brand tokens
│   └── templates/               # Custom prompt templates
├── logs/
│   └── VibeIntelligence.log     # Activity log
├── assets/
│   └── icon.png                 # App icon
├── install.sh                   # Installation script
├── uninstall.sh                 # Clean removal
└── README.md                    # This file
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
    "brand_context": true
}
```

## 🐛 Troubleshooting

### Services not appearing

1. Restart the Services database:
   ```bash
   /System/Library/CoreServices/pbs -flush
   ```

2. Log out and log back in

3. Check permissions in System Settings → Privacy & Security

### API errors

1. Verify API key is set:
   ```bash
   echo $ANTHROPIC_API_KEY
   ```

2. Check logs:
   ```bash
   tail -f ~/Projects/VibeIntelligence/logs/VibeIntelligence.log
   ```

### Text not replaced

1. Ensure the app has accessibility permissions
2. Try using clipboard mode instead of replace mode
3. Some apps (like Terminal) don't support text replacement

## 🗑️ Uninstallation

```bash
cd ~/Projects/VibeIntelligence
./uninstall.sh
```

## 📜 License

© 2025 NeuralQuantum.ai LLC. All rights reserved.

Part of the VibeCaaS ecosystem — [vibecaas.com](https://vibecaas.com)

---

<p align="center">
  <strong>🎵 Your prompts are about to hit different.</strong><br>
  <em>VibeCaaS.com — Code the Vibe. Deploy the Dream.</em>
</p>
