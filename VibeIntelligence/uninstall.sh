#!/usr/bin/env bash
set -e

# VibeIntelligence Uninstaller
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
SERVICES_DIR="$HOME/Library/Services"
CONFIG_DIR="$HOME/.config/VibeIntelligence"
BIN_DIR="$HOME/bin"
INSTALL_DIR="$HOME/Projects/VibeIntelligence"

# ============================================================================
# BANNER
# ============================================================================
print_banner() {
    echo ""
    echo "${VIBE_PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                              ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${AQUA_TEAL}VibeIntelligence${VIBE_PURPLE}                                          ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║   ${RESET}Uninstaller${VIBE_PURPLE}                                                ║${RESET}"
    echo "${VIBE_PURPLE}${BOLD}║                                                              ║${RESET}"
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

confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        printf "  %s [Y/n]: " "$message"
    else
        printf "  %s [y/N]: " "$message"
    fi
    
    read -r response
    response="${response:-$default}"
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# MAIN UNINSTALLATION
# ============================================================================
main() {
    print_banner
    
    echo "${SIGNAL_AMBER}⚠ This will remove VibeIntelligence from your system.${RESET}"
    echo ""
    
    if ! confirm "Are you sure you want to continue?" "n"; then
        echo ""
        echo "  Uninstallation cancelled."
        echo ""
        exit 0
    fi
    
    echo ""
    echo "${AQUA_TEAL}🧹 Uninstalling VibeIntelligence...${RESET}"
    echo ""
    
    # 1. Remove Services
    echo "${BOLD}Removing macOS Services...${RESET}"
    local services_removed=0
    for service in "VibeIntelligence - Enhance" "VibeIntelligence - Agent Prompt" "VibeIntelligence - Technical Spec" "VibeIntelligence - Simplify" "VibeIntelligence - Custom"; do
        local service_path="$SERVICES_DIR/${service}.workflow"
        if [[ -d "$service_path" ]]; then
            print_step "Removing: ${service}.workflow"
            rm -rf "$service_path"
            ((services_removed++))
        fi
    done
    if [[ $services_removed -gt 0 ]]; then
        print_success "$services_removed services removed"
    else
        print_warning "No services found to remove"
    fi
    echo ""
    
    # 2. Remove CLI symlink
    echo "${BOLD}Removing CLI tool...${RESET}"
    if [[ -L "$BIN_DIR/VibeIntelligence" ]]; then
        print_step "Removing symlink..."
        rm -f "$BIN_DIR/VibeIntelligence"
        print_success "CLI symlink removed"
    else
        print_warning "CLI symlink not found"
    fi
    echo ""
    
    # 3. Ask about config removal
    echo "${BOLD}Configuration files...${RESET}"
    if [[ -d "$CONFIG_DIR" ]]; then
        echo ""
        if confirm "Remove configuration and history? (includes API keys)" "n"; then
            print_step "Removing config directory..."
            rm -rf "$CONFIG_DIR"
            print_success "Configuration removed"
        else
            print_warning "Configuration preserved at: $CONFIG_DIR"
        fi
    else
        print_warning "No configuration found"
    fi
    echo ""
    
    # 4. Ask about project removal
    echo "${BOLD}Project files...${RESET}"
    if [[ -d "$INSTALL_DIR" ]]; then
        echo ""
        if confirm "Remove project directory? ($INSTALL_DIR)" "n"; then
            print_step "Removing project directory..."
            rm -rf "$INSTALL_DIR"
            print_success "Project directory removed"
        else
            print_warning "Project preserved at: $INSTALL_DIR"
        fi
    else
        print_warning "Project directory not found"
    fi
    echo ""
    
    # 5. Refresh Services
    echo "${BOLD}Refreshing macOS Services...${RESET}"
    if [[ "$(uname)" == "Darwin" ]]; then
        print_step "Flushing pasteboard services..."
        /System/Library/CoreServices/pbs -flush 2>/dev/null || true
        print_success "Services refreshed"
    fi
    echo ""
    
    # ============================================================================
    # SUCCESS MESSAGE
    # ============================================================================
    echo "${AQUA_TEAL}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "${AQUA_TEAL}${BOLD}✅ VibeIntelligence has been uninstalled.${RESET}"
    echo ""
    echo "  ${DIM}We're sad to see you go! 😢${RESET}"
    echo ""
    echo "  ${DIM}If you change your mind, you can reinstall anytime:${RESET}"
    echo "  ${DIM}git clone <repo> && cd VibeIntelligence && ./install.sh${RESET}"
    echo ""
    echo "${DIM}Thank you for vibing with us! 🎵${RESET}"
    echo "${DIM}VibeCaaS.com | © 2025 NeuralQuantum.ai LLC${RESET}"
    echo ""
}

# Run main uninstallation
main "$@"
