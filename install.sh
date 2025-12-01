#!/bin/zsh
# VibeIntelligence Installer
# VibeCaaS.com - "Code the Vibe. Deploy the Dream."
# © 2025 NeuralQuantum.ai LLC

set -e

# ============================================================================
# BRAND COLORS (ANSI 24-bit)
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
INSTALL_DIR="$HOME/Projects/VibeIntelligence"
SERVICES_DIR="$HOME/Library/Services"
CONFIG_DIR="$HOME/.config/VibeIntelligence"
BIN_DIR="$HOME/bin"

# ============================================================================
# BANNER
# ============================================================================
print_banner() {
    echo ""
    echo "${VIBE_PURPLE}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                          ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}🎧 VibeIntelligence${VIBE_PURPLE}                                     ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${RESET}AI-Powered Text Enhancement${VIBE_PURPLE}                          ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                          ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${DIM}Code the Vibe. Deploy the Dream.${VIBE_PURPLE}                    ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${SIGNAL_AMBER}Powered by VibeCaaS.com${VIBE_PURPLE}                             ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                          ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ============================================================================
# HELPERS
# ============================================================================
log_step() {
    echo "  ${VIBE_PURPLE}►${RESET} $1"
}

log_success() {
    echo "  ${AQUA_TEAL}✓${RESET} $1"
}

log_warning() {
    echo "  ${SIGNAL_AMBER}⚠${RESET} $1"
}

log_error() {
    echo "  ${SIGNAL_AMBER}✗${RESET} $1"
}

# ============================================================================
# CHECKS
# ============================================================================
check_dependencies() {
    log_step "Checking dependencies..."
    
    local missing=()
    
    # Required
    if ! command -v curl &>/dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi
    
    if (( ${#missing[@]} > 0 )); then
        log_warning "Missing dependencies: ${missing[*]}"
        echo ""
        echo "  Install with Homebrew:"
        echo "    ${BOLD}brew install ${missing[*]}${RESET}"
        echo ""
        
        # Try to install with Homebrew if available
        if command -v brew &>/dev/null; then
            read -q "REPLY?  Install now with Homebrew? [y/N] "
            echo ""
            if [[ "$REPLY" == "y" ]]; then
                brew install "${missing[@]}"
            else
                echo "  Continuing without installing dependencies..."
            fi
        fi
    else
        log_success "All dependencies found"
    fi
}

check_api_key() {
    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        log_success "ANTHROPIC_API_KEY found in environment"
        return 0
    fi
    
    if [[ -f "$CONFIG_DIR/config.json" ]] && command -v jq &>/dev/null; then
        local config_key=$(jq -r '.api_key // empty' "$CONFIG_DIR/config.json" 2>/dev/null)
        if [[ -n "$config_key" ]]; then
            log_success "API key found in config"
            return 0
        fi
    fi
    
    return 1
}

# ============================================================================
# INSTALLATION
# ============================================================================
create_directories() {
    log_step "Creating directories..."
    
    mkdir -p "$CONFIG_DIR/templates"
    mkdir -p "$CONFIG_DIR/history"
    mkdir -p "$INSTALL_DIR/logs"
    mkdir -p "$BIN_DIR"
    mkdir -p "$SERVICES_DIR"
    
    log_success "Directories created"
}

install_cli() {
    log_step "Installing CLI tool..."
    
    if [[ ! -f "$INSTALL_DIR/bin/VibeIntelligence" ]]; then
        log_error "CLI tool not found at $INSTALL_DIR/bin/VibeIntelligence"
        exit 1
    fi
    
    chmod +x "$INSTALL_DIR/bin/VibeIntelligence"
    ln -sf "$INSTALL_DIR/bin/VibeIntelligence" "$BIN_DIR/VibeIntelligence"
    ln -sf "$INSTALL_DIR/bin/VibeIntelligence" "$BIN_DIR/vibe"  # Short alias
    
    log_success "CLI installed (VibeIntelligence, vibe)"
}

install_services() {
    log_step "Installing macOS Services..."
    
    local count=0
    for workflow in "$INSTALL_DIR/Services/"*.workflow; do
        if [[ -d "$workflow" ]]; then
            local name=$(basename "$workflow")
            cp -R "$workflow" "$SERVICES_DIR/"
            ((count++))
        fi
    done
    
    if (( count > 0 )); then
        log_success "Installed $count Services"
    else
        log_warning "No Services found to install"
    fi
}

install_config() {
    log_step "Installing configuration..."
    
    # Copy brand config
    if [[ -f "$INSTALL_DIR/config/brand.json" ]]; then
        cp "$INSTALL_DIR/config/brand.json" "$CONFIG_DIR/"
        log_success "Brand configuration installed"
    fi
    
    # Create default config if not exists
    if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
        cp "$INSTALL_DIR/config/config.json" "$CONFIG_DIR/"
        log_success "Default configuration created"
    else
        log_success "Existing configuration preserved"
    fi
    
    # Copy templates
    if [[ -d "$INSTALL_DIR/config/templates" ]]; then
        cp -n "$INSTALL_DIR/config/templates/"*.md "$CONFIG_DIR/templates/" 2>/dev/null || true
        log_success "Templates installed"
    fi
}

refresh_services() {
    log_step "Refreshing macOS Services..."
    
    # Try to refresh the services menu
    if [[ -f "/System/Library/CoreServices/pbs" ]]; then
        /System/Library/CoreServices/pbs -flush 2>/dev/null || true
        log_success "Services refreshed"
    else
        log_warning "Could not refresh services (not on macOS?)"
    fi
}

add_to_path() {
    log_step "Checking PATH..."
    
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        local shell_rc=""
        
        if [[ -f "$HOME/.zshrc" ]]; then
            shell_rc="$HOME/.zshrc"
        elif [[ -f "$HOME/.bashrc" ]]; then
            shell_rc="$HOME/.bashrc"
        fi
        
        if [[ -n "$shell_rc" ]]; then
            if ! grep -q "export PATH.*$BIN_DIR" "$shell_rc" 2>/dev/null; then
                echo "" >> "$shell_rc"
                echo "# VibeIntelligence" >> "$shell_rc"
                echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$shell_rc"
                log_success "Added ~/bin to PATH in $(basename "$shell_rc")"
            fi
        fi
    else
        log_success "PATH already includes ~/bin"
    fi
}

# ============================================================================
# POST-INSTALL
# ============================================================================
print_next_steps() {
    echo ""
    echo "${AQUA_TEAL}${BOLD}✅ VibeIntelligence installed successfully!${RESET}"
    echo ""
    echo "${VIBE_PURPLE}${BOLD}📋 Next steps:${RESET}"
    echo ""
    
    # API Key setup
    if ! check_api_key 2>/dev/null; then
        echo "  ${SIGNAL_AMBER}1.${RESET} Set your API key (choose one):"
        echo ""
        echo "     ${BOLD}Option A: Environment variable${RESET}"
        echo "     export ANTHROPIC_API_KEY='your-key-here'"
        echo ""
        echo "     ${BOLD}Option B: Config file${RESET}"
        echo "     Edit ${CONFIG_DIR}/config.json"
        echo "     Add: \"api_key\": \"your-key-here\""
        echo ""
        echo "     ${BOLD}Option C: Use local AI (Ollama/LM Studio)${RESET}"
        echo "     No API key needed for local models"
        echo ""
    else
        echo "  ${AQUA_TEAL}1.${RESET} API key configured ✓"
        echo ""
    fi
    
    echo "  ${SIGNAL_AMBER}2.${RESET} Enable Services in System Settings:"
    echo "     ${DIM}Settings → Privacy & Security → Accessibility${RESET}"
    echo "     ${DIM}(Allow Automator to control your computer)${RESET}"
    echo ""
    echo "     ${DIM}Settings → Keyboard → Keyboard Shortcuts → Services${RESET}"
    echo "     ${DIM}Enable all '${VIBE_PURPLE}VibeIntelligence${RESET}${DIM}' services${RESET}"
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
    echo "     Or use the CLI:"
    echo "     ${BOLD}echo \"make a login form\" | VibeIntelligence -m agent${RESET}"
    echo ""
    
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "  ${SIGNAL_AMBER}5.${RESET} Restart your terminal or run:"
        echo "     ${BOLD}source ~/.zshrc${RESET}"
        echo ""
    fi
    
    echo "${VIBE_PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo "${VIBE_PURPLE}${BOLD}🎵 Your prompts are about to hit different.${RESET}"
    echo "${DIM}   VibeCaaS.com — Code the Vibe. Deploy the Dream.${RESET}"
    echo "${VIBE_PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    print_banner
    
    echo "${AQUA_TEAL}🎧 Installing VibeIntelligence...${RESET}"
    echo ""
    
    check_dependencies
    create_directories
    install_cli
    install_services
    install_config
    refresh_services
    add_to_path
    
    print_next_steps
}

main "$@"
