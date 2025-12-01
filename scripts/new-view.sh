#!/bin/bash
#
# Create a new SwiftUI View and add it to the Xcode project
# Usage: ./scripts/new-view.sh ViewName
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$PROJECT_ROOT/App/VibeIntelligence"

# Check argument
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <ViewName>"
    echo "   Example: $0 ProfileView"
    exit 1
fi

VIEW_NAME="$1"
FILE_NAME="${VIEW_NAME}.swift"
FILE_PATH="$SOURCE_DIR/$FILE_NAME"

# Check if file already exists
if [ -f "$FILE_PATH" ]; then
    echo "❌ File already exists: $FILE_PATH"
    exit 1
fi

# Get current date for header
CURRENT_DATE=$(date "+%m/%d/%y")
CURRENT_YEAR=$(date "+%Y")

# Create the SwiftUI view file
cat > "$FILE_PATH" << EOF
//
//  ${FILE_NAME}
//  VibeIntelligence
//
//  Created on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} NeuralQuantum.ai LLC. All rights reserved.
//

import SwiftUI

struct ${VIEW_NAME}: View {
    @EnvironmentObject var configManager: ConfigManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("${VIEW_NAME}")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Add your content here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    ${VIEW_NAME}()
        .environmentObject(ConfigManager.shared)
}
EOF

echo "✅ Created: $FILE_PATH"

# Sync with Xcode project
echo ""
echo "🔄 Syncing with Xcode project..."
python3 "$SCRIPT_DIR/sync_xcode_project.py"

echo ""
echo "🎉 Done! Your new view is ready:"
echo "   • File: App/VibeIntelligence/${FILE_NAME}"
echo "   • Open in Xcode and start editing"

