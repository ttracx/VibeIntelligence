#!/usr/bin/env bash
set -e

# VibeIntelligence Installer
# VibeCaaS.com - "Code the Vibe. Deploy the Dream."
# © 2025 NeuralQuantum.ai LLC

# ============================================================================
# BRAND COLORS (ANSI)
# ============================================================================
VIBE_PURPLE='\033[38;2;109;74;255m'
AQUA_TEAL='\033[38;2;20;184;166m'
SIGNAL_AMBER='\033[38;2;255;140;0m'
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# ============================================================================
# CONFIGURATION
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/Projects/VibeIntelligence"
SERVICES_DIR="$HOME/Library/Services"
CONFIG_DIR="$HOME/.config/VibeIntelligence"
BIN_DIR="$HOME/bin"

# ============================================================================
# BANNER
# ============================================================================
print_banner() {
    echo ""
    echo "${VIBE_PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}██╗   ██╗██╗██████╗ ███████╗${VIBE_PURPLE}                            ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}██║   ██║██║██╔══██╗██╔════╝${VIBE_PURPLE}                            ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}██║   ██║██║██████╔╝█████╗${VIBE_PURPLE}                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}╚██╗ ██╔╝██║██╔══██╗██╔══╝${VIBE_PURPLE}                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL} ╚████╔╝ ██║██████╔╝███████╗${VIBE_PURPLE}                            ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}  ╚═══╝  ╚═╝╚═════╝ ╚══════╝${VIBE_PURPLE}  ${SIGNAL_AMBER}Intelligence${VIBE_PURPLE}           ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${RESET}AI-Powered Text Enhancement for macOS${VIBE_PURPLE}                    ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${DIM}Code the Vibe. Deploy the Dream.${RESET}${VIBE_PURPLE}                       ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${SIGNAL_AMBER}Powered by VibeCaaS.com${VIBE_PURPLE}                                ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
print_step() {
    echo "  ${VIBE_PURPLE}►${RESET} $1"
}

print_success() {
    echo "  ${AQUA_TEAL}✓${RESET} $1"
}

print_warning() {
    echo "  ${SIGNAL_AMBER}⚠${RESET} $1"
}

print_error() {
    echo "  ${SIGNAL_AMBER}✗${RESET} $1"
}

check_dependency() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &>/dev/null; then
        print_success "$name found"
        return 0
    else
        print_warning "$name not found (optional)"
        return 1
    fi
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================
main() {
    print_banner
    
    echo "${AQUA_TEAL}🎧 Installing VibeIntelligence...${RESET}"
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "$SCRIPT_DIR/bin/VibeIntelligence" ]]; then
        print_error "Installation files not found!"
        echo "    Please run this script from the VibeIntelligence directory."
        exit 1
    fi
    
    # 1. Check dependencies
    echo "${BOLD}Checking dependencies...${RESET}"
    check_dependency "curl" "curl" || true
    check_dependency "jq" "jq" || {
        print_warning "jq is recommended for full functionality"
        echo "    Install with: brew install jq"
    }
    echo ""
    
    # 2. Create directories
    echo "${BOLD}Creating directories...${RESET}"
    print_step "Creating config directory..."
    mkdir -p "$CONFIG_DIR/templates"
    mkdir -p "$CONFIG_DIR/history"
    print_success "Config directory created: $CONFIG_DIR"
    
    print_step "Creating logs directory..."
    mkdir -p "$INSTALL_DIR/logs"
    print_success "Logs directory created"
    
    print_step "Creating bin directory..."
    mkdir -p "$BIN_DIR"
    print_success "Bin directory created: $BIN_DIR"
    echo ""
    
    # 3. Install CLI tool
    echo "${BOLD}Installing CLI tool...${RESET}"
    print_step "Making CLI executable..."
    chmod +x "$SCRIPT_DIR/bin/VibeIntelligence"
    
    print_step "Creating symlink..."
    ln -sf "$SCRIPT_DIR/bin/VibeIntelligence" "$BIN_DIR/VibeIntelligence"
    print_success "CLI installed: $BIN_DIR/VibeIntelligence"
    echo ""
    
    # 4. Install Services (workflows)
    echo "${BOLD}Installing macOS Services...${RESET}"
    print_step "Creating Services directory..."
    mkdir -p "$SERVICES_DIR"
    
    local workflow_count=0
    for workflow in "$SCRIPT_DIR/Services/"*.workflow; do
        if [[ -d "$workflow" ]]; then
            local name=$(basename "$workflow")
            print_step "Installing: $name"
            cp -R "$workflow" "$SERVICES_DIR/"
            ((workflow_count++))
        fi
    done
    print_success "$workflow_count services installed"
    echo ""
    
    # 5. Create default config if not exists
    echo "${BOLD}Setting up configuration...${RESET}"
    if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
        print_step "Creating default configuration..."
        cat > "$CONFIG_DIR/config.json" << 'EOF'
{
    "model": "claude-sonnet-4-20250514",
    "default_mode": "enhance",
    "notify": true,
    "history_enabled": true,
    "max_history": 100,
    "brand_context": true,
    "custom_templates_dir": "~/.config/VibeIntelligence/templates",
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
EOF
        print_success "Default config created"
    else
        print_warning "Config already exists, preserving"
    fi
    
    # 6. Copy brand config
    print_step "Installing brand configuration..."
    cp "$SCRIPT_DIR/config/brand.json" "$CONFIG_DIR/"
    print_success "Brand config installed"
    
    # 7. Copy templates
    print_step "Installing custom templates..."
    if [[ -d "$SCRIPT_DIR/config/templates" ]]; then
        cp -n "$SCRIPT_DIR/config/templates/"*.md "$CONFIG_DIR/templates/" 2>/dev/null || true
        local template_count=$(ls -1 "$CONFIG_DIR/templates/"*.md 2>/dev/null | wc -l | tr -d ' ')
        print_success "$template_count templates installed"
    fi
    echo ""
    
    # 8. Refresh Services (macOS only)
    echo "${BOLD}Refreshing macOS Services...${RESET}"
    if [[ "$(uname)" == "Darwin" ]]; then
        print_step "Flushing pasteboard services..."
        /System/Library/CoreServices/pbs -flush 2>/dev/null || true
        print_success "Services refreshed"
    else
        print_warning "Not on macOS - skipping service refresh"
    fi
    echo ""
    
    # 9. Add to PATH if needed
    echo "${BOLD}Checking PATH...${RESET}"
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        print_warning "$BIN_DIR not in PATH"
        echo ""
        echo "    Add this to your ~/.zshrc or ~/.bashrc:"
        echo "    ${BOLD}export PATH=\"\$HOME/bin:\$PATH\"${RESET}"
        echo ""
    else
        print_success "PATH already includes $BIN_DIR"
    fi
    echo ""
    
    # ============================================================================
    # SUCCESS MESSAGE
    # ============================================================================
    echo "${AQUA_TEAL}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "${AQUA_TEAL}${BOLD}✅ VibeIntelligence installed successfully!${RESET}"
    echo ""
    echo "${VIBE_PURPLE}${BOLD}📋 Next steps:${RESET}"
    echo ""
    echo "  ${SIGNAL_AMBER}1.${RESET} Set your API key (choose one):"
    echo ""
    echo "     ${BOLD}Option A: Environment variable${RESET}"
    echo "     ${DIM}export ANTHROPIC_API_KEY='your-key-here'${RESET}"
    echo ""
    echo "     ${BOLD}Option B: Add to config file${RESET}"
    echo "     ${DIM}$CONFIG_DIR/config.json${RESET}"
    echo ""
    echo "     ${BOLD}Option C: Use local models (Ollama/LM Studio)${RESET}"
    echo "     ${DIM}VibeIntelligence -p ollama -t \"your text\"${RESET}"
    echo ""
    echo "  ${SIGNAL_AMBER}2.${RESET} Enable Services in System Settings:"
    echo "     ${DIM}System Settings → Privacy & Security → Extensions → Finder Extensions${RESET}"
    echo "     ${DIM}System Settings → Keyboard → Keyboard Shortcuts → Services${RESET}"
    echo "     Enable all '${VIBE_PURPLE}VibeIntelligence${RESET}' services"
    echo ""
    echo "  ${SIGNAL_AMBER}3.${RESET} (Optional) Assign keyboard shortcuts:"
    echo "     ${BOLD}⌃⌥E${RESET} - VibeIntelligence - Enhance"
    echo "     ${BOLD}⌃⌥A${RESET} - VibeIntelligence - Agent Prompt"
    echo "     ${BOLD}⌃⌥S${RESET} - VibeIntelligence - Technical Spec"
    echo "     ${BOLD}⌃⌥D${RESET} - VibeIntelligence - Simplify"
    echo "     ${BOLD}⌃⌥C${RESET} - VibeIntelligence - Custom"
    echo ""
    echo "  ${SIGNAL_AMBER}4.${RESET} Test it:"
    echo "     ${DIM}Select text anywhere → Right-click → Services → VibeIntelligence${RESET}"
    echo ""
    echo "     Or from terminal:"
    echo "     ${DIM}echo \"create a button\" | VibeIntelligence -m agent${RESET}"
    echo ""
    echo "${VIBE_PURPLE}${BOLD}🎵 Your prompts are about to hit different.${RESET}"
    echo ""
    echo "${DIM}Powered by VibeCaaS.com | © 2025 NeuralQuantum.ai LLC${RESET}"
    echo ""
}

# Run main installation
main "$@"
