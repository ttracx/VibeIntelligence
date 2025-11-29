# VibeIntelligence 🎧

**AI-Powered Text Enhancement for macOS**

*Part of the [VibeCaaS](https://vibecaas.com) ecosystem*

> "Code the Vibe. Deploy the Dream."

---

## What is VibeIntelligence?

VibeIntelligence adds Apple Intelligence-style writing tools to your right-click menu. Select any text, right-click, and transform it instantly with AI.

**Perfect for:**
- 🤖 Enhancing prompts for AI coding agents (Cursor, Claude Code, Copilot)
- 📝 Expanding ideas into technical specifications
- ✨ Making vague requirements crystal clear
- 🎯 Simplifying complex text

## Features

- **Context Menu Integration** - Right-click any selected text
- **Multiple Modes** - Enhance, Agent Prompt, Technical Spec, Simplify, Proofread
- **Custom Templates** - Create your own transformation templates
- **Local Model Support** - Works with Ollama and LM Studio
- **History Tracking** - Review past transformations
- **Brand-Aligned** - VibeCaaS design language throughout

---

## Installation

```bash
cd ~/Projects/VibeIntelligence
chmod +x install.sh
./install.sh
```

### Post-Installation

1. **Set your API key** (choose one method):
   
   ```bash
   # Environment variable
   export ANTHROPIC_API_KEY='your-key-here'
   ```
   
   Or add to `~/.config/VibeIntelligence/config.json`

2. **Enable Services**:
   - System Settings → Keyboard → Keyboard Shortcuts → Services
   - Enable all "VibeIntelligence" services

3. **Test it**:
   - Select text anywhere
   - Right-click → Services → VibeIntelligence

---

## Modes

| Mode | Shortcut | Description |
|------|----------|-------------|
| **Enhance** | ⌃⌥E | Make text comprehensive and robust |
| **Agent Prompt** | ⌃⌥A | Optimize for AI coding agents |
| **Technical Spec** | ⌃⌥S | Expand to full specification |
| **Simplify** | ⌃⌥D | Strip to essential clarity |
| **Proofread** | - | Fix grammar and spelling |
| **Custom** | ⌃⌥C | Use your own template |

---

## CLI Usage

VibeIntelligence also works from the command line:

```bash
# Enhance text from clipboard
pbpaste | VibeIntelligence --mode enhance | pbcopy

# Convert to agent prompt
VibeIntelligence -t "create a login form" -m agent

# Use Ollama locally
VibeIntelligence -t "fix this code" -p ollama -m simplify

# Save spec to file
VibeIntelligence -f requirements.txt -m spec -o file:spec.md

# Show help
VibeIntelligence --help
```

### CLI Options

```
INPUT OPTIONS:
    --text, -t TEXT       Direct text input
    --file, -f PATH       Read input from file
    (stdin)               Piped input
    (clipboard)           Fallback: read from pbpaste

MODE OPTIONS:
    --mode, -m MODE       enhance|agent|spec|simplify|proofread|custom

OUTPUT OPTIONS:
    --output, -o MODE     clipboard|replace|stdout|file:PATH

PROVIDER OPTIONS:
    --provider, -p PROV   claude|ollama|lmstudio

OTHER OPTIONS:
    --template, -T NAME   Custom template name
    --notify              Show macOS notification
    --diff                Show before/after comparison
    --history             Show rewrite history
    --list-templates      List available templates
```

---

## Local Models

VibeIntelligence supports local AI models for privacy and offline use.

### Ollama

```bash
# Install Ollama
brew install ollama

# Pull a model
ollama pull llama3.2

# Use with VibeIntelligence
VibeIntelligence -p ollama -t "your text" -m enhance

# Configure in environment
export OLLAMA_HOST="http://localhost:11434"
export OLLAMA_MODEL="llama3.2"
```

### LM Studio

```bash
# Start LM Studio server on port 1234

# Use with VibeIntelligence
VibeIntelligence -p lmstudio -t "your text" -m enhance

# Configure in environment
export LMSTUDIO_HOST="http://localhost:1234"
export LMSTUDIO_MODEL="local-model"
```

---

## Custom Templates

Create your own transformation templates in `~/.config/VibeIntelligence/templates/`:

```markdown
---
name: My Custom Template
description: What it does
author: Your Name
version: 1.0.0
---
You are VibeIntelligence from VibeCaaS.com.

[Your system prompt here...]

Output ONLY the transformed text.
```

### Built-in Templates

- `api-endpoint` - REST API endpoint specification
- `react-component` - React/TypeScript component spec
- `database-schema` - Database schema specification
- `user-story` - User story with acceptance criteria

List templates:
```bash
VibeIntelligence --list-templates
```

---

## Configuration

Configuration file: `~/.config/VibeIntelligence/config.json`

```json
{
    "model": "claude-sonnet-4-20250514",
    "default_mode": "enhance",
    "notify": true,
    "history_enabled": true,
    "max_history": 100,
    "providers": {
        "claude": {
            "enabled": true,
            "model": "claude-sonnet-4-20250514"
        },
        "ollama": {
            "enabled": true,
            "host": "http://localhost:11434",
            "model": "llama3.2"
        },
        "lmstudio": {
            "enabled": true,
            "host": "http://localhost:1234",
            "model": "local-model"
        }
    }
}
```

---

## Keyboard Shortcuts

Recommended shortcuts (set in System Settings → Keyboard → Keyboard Shortcuts → Services):

| Shortcut | Service |
|----------|---------|
| ⌃⌥E | VibeIntelligence - Enhance |
| ⌃⌥A | VibeIntelligence - Agent Prompt |
| ⌃⌥S | VibeIntelligence - Technical Spec |
| ⌃⌥D | VibeIntelligence - Simplify |
| ⌃⌥C | VibeIntelligence - Custom |

---

## Troubleshooting

### Services not appearing
1. Run `./install.sh` again
2. Log out and back in
3. Check System Settings → Keyboard → Keyboard Shortcuts → Services

### API errors
1. Verify your API key: `echo $ANTHROPIC_API_KEY`
2. Check logs: `tail -f ~/Projects/VibeIntelligence/logs/VibeIntelligence.log`
3. Test with: `curl -s https://api.anthropic.com/v1/messages -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01"`

### Text not replaced
1. Ensure the application supports Services
2. Try in TextEdit first (most compatible)
3. Check if service is enabled in System Settings

### Local models not working
1. Verify Ollama/LM Studio is running
2. Check the host URL and port
3. Test: `curl http://localhost:11434/api/tags` (Ollama)

---

## Brand

VibeIntelligence follows VibeCaaS design language:

| Element | Value |
|---------|-------|
| **Primary** | Vibe Purple `#6D4AFF` |
| **Secondary** | Aqua Teal `#14B8A6` |
| **Accent** | Signal Amber `#FF8C00` |
| **Font (Sans)** | Inter |
| **Font (Mono)** | JetBrains Mono |

### Brand Messages

- Success: "Your prompt is now in rhythm ✨"
- Processing: "Mixing your vibe..."
- Error: "Hit a skip in the track. Let's retry."

---

## Uninstallation

```bash
cd ~/Projects/VibeIntelligence
./uninstall.sh
```

---

## Project Structure

```
VibeIntelligence/
├── Services/                    # macOS Automator workflows
│   ├── VibeIntelligence - Enhance.workflow/
│   ├── VibeIntelligence - Agent Prompt.workflow/
│   ├── VibeIntelligence - Technical Spec.workflow/
│   ├── VibeIntelligence - Simplify.workflow/
│   └── VibeIntelligence - Custom.workflow/
├── bin/
│   └── VibeIntelligence         # Core CLI engine
├── config/
│   ├── config.json              # Default user preferences
│   ├── brand.json               # VibeCaaS brand tokens
│   └── templates/               # Custom prompt templates
├── logs/
│   └── VibeIntelligence.log
├── assets/
│   └── icon.png                 # VibeCaaS branded icon
├── install.sh                   # Installation script
├── uninstall.sh                 # Clean removal
└── README.md
```

---

## License

Proprietary - © 2025 NeuralQuantum.ai LLC

---

## Links

- **VibeCaaS**: [vibecaas.com](https://vibecaas.com)
- **NeuralQuantum.ai**: [neuralquantum.ai](https://neuralquantum.ai)

---

**Powered by [VibeCaaS.com](https://vibecaas.com)** — a division of [NeuralQuantum.ai](https://neuralquantum.ai) LLC

© 2025 NeuralQuantum.ai LLC. All rights reserved.

---

*🎵 Your prompts are about to hit different.*
