#!/bin/zsh
# VibeIntelligence Uninstaller
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
    echo "${VIBE_PURPLE}${BOLD}║   ${SIGNAL_AMBER}🎧 VibeIntelligence Uninstaller${VIBE_PURPLE}                       ║${RESET}"
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

# ============================================================================
# UNINSTALLATION
# ============================================================================
remove_services() {
    log_step "Removing macOS Services..."
    
    local count=0
    for workflow in "$SERVICES_DIR/VibeIntelligence"*.workflow; do
        if [[ -d "$workflow" ]]; then
            rm -rf "$workflow"
            ((count++))
        fi
    done
    
    if (( count > 0 )); then
        log_success "Removed $count Services"
    else
        log_warning "No Services found"
    fi
}

remove_cli() {
    log_step "Removing CLI symlinks..."
    
    local removed=0
    
    if [[ -L "$BIN_DIR/VibeIntelligence" ]]; then
        rm "$BIN_DIR/VibeIntelligence"
        ((removed++))
    fi
    
    if [[ -L "$BIN_DIR/vibe" ]]; then
        rm "$BIN_DIR/vibe"
        ((removed++))
    fi
    
    if (( removed > 0 )); then
        log_success "Removed CLI symlinks"
    else
        log_warning "No CLI symlinks found"
    fi
}

remove_config() {
    local keep_config=true
    
    echo ""
    echo -n "  ${SIGNAL_AMBER}?${RESET} Remove configuration and history? [y/N] "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        keep_config=false
    fi
    
    if [[ "$keep_config" == false ]]; then
        log_step "Removing configuration..."
        
        if [[ -d "$CONFIG_DIR" ]]; then
            rm -rf "$CONFIG_DIR"
            log_success "Configuration removed"
        else
            log_warning "No configuration found"
        fi
    else
        log_success "Configuration preserved at $CONFIG_DIR"
    fi
}

remove_project() {
    local remove_project=false
    
    echo ""
    echo -n "  ${SIGNAL_AMBER}?${RESET} Remove project directory ($INSTALL_DIR)? [y/N] "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        remove_project=true
    fi
    
    if [[ "$remove_project" == true ]]; then
        log_step "Removing project directory..."
        
        if [[ -d "$INSTALL_DIR" ]]; then
            rm -rf "$INSTALL_DIR"
            log_success "Project directory removed"
        else
            log_warning "Project directory not found"
        fi
    else
        log_success "Project directory preserved"
    fi
}

refresh_services() {
    log_step "Refreshing macOS Services..."
    
    if [[ -f "/System/Library/CoreServices/pbs" ]]; then
        /System/Library/CoreServices/pbs -flush 2>/dev/null || true
        log_success "Services refreshed"
    fi
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    print_banner
    
    echo "${SIGNAL_AMBER}⚠  This will uninstall VibeIntelligence${RESET}"
    echo ""
    echo -n "  Continue? [y/N] "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo "  ${AQUA_TEAL}Uninstall cancelled.${RESET}"
        echo ""
        exit 0
    fi
    
    echo ""
    echo "${AQUA_TEAL}🎧 Uninstalling VibeIntelligence...${RESET}"
    echo ""
    
    remove_services
    remove_cli
    remove_config
    remove_project
    refresh_services
    
    echo ""
    echo "${AQUA_TEAL}${BOLD}✅ VibeIntelligence uninstalled${RESET}"
    echo ""
    echo "${DIM}We hope you enjoyed the vibe! 🎵${RESET}"
    echo "${DIM}Feedback? Visit vibecaas.com${RESET}"
    echo ""
}

main "$@"
