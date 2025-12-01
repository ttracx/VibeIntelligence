#!/bin/bash
#
# Sync Swift files with Xcode project
# Usage: ./scripts/sync-project.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔄 Syncing Xcode project..."

# Run the Python sync script
python3 "$SCRIPT_DIR/sync_xcode_project.py"

echo ""
echo "💡 Tip: Run 'xcodebuild -project App/VibeIntelligence.xcodeproj -scheme VibeIntelligence build' to verify"

