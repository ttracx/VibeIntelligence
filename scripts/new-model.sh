#!/bin/bash
#
# Create a new Swift model/class and add it to the Xcode project
# Usage: ./scripts/new-model.sh ModelName [--observable]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$PROJECT_ROOT/App/VibeIntelligence"

# Check argument
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <ModelName> [--observable]"
    echo "   Example: $0 UserProfile"
    echo "   Example: $0 DataService --observable"
    exit 1
fi

MODEL_NAME="$1"
IS_OBSERVABLE=false

if [ "$2" == "--observable" ]; then
    IS_OBSERVABLE=true
fi

FILE_NAME="${MODEL_NAME}.swift"
FILE_PATH="$SOURCE_DIR/$FILE_NAME"

# Check if file already exists
if [ -f "$FILE_PATH" ]; then
    echo "❌ File already exists: $FILE_PATH"
    exit 1
fi

# Get current date for header
CURRENT_DATE=$(date "+%m/%d/%y")
CURRENT_YEAR=$(date "+%Y")

if [ "$IS_OBSERVABLE" = true ]; then
    # Create an ObservableObject class
    cat > "$FILE_PATH" << EOF
//
//  ${FILE_NAME}
//  VibeIntelligence
//
//  Created on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} NeuralQuantum.ai LLC. All rights reserved.
//

import Foundation
import SwiftUI

class ${MODEL_NAME}: ObservableObject {
    static let shared = ${MODEL_NAME}()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Initialize
    }
    
    // MARK: - Public Methods
    
    func load() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Add your loading logic here
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
EOF
else
    # Create a simple struct/model
    cat > "$FILE_PATH" << EOF
//
//  ${FILE_NAME}
//  VibeIntelligence
//
//  Created on ${CURRENT_DATE}.
//  Copyright © ${CURRENT_YEAR} NeuralQuantum.ai LLC. All rights reserved.
//

import Foundation

struct ${MODEL_NAME}: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Extensions

extension ${MODEL_NAME} {
    static var example: ${MODEL_NAME} {
        ${MODEL_NAME}(name: "Example")
    }
}
EOF
fi

echo "✅ Created: $FILE_PATH"

# Sync with Xcode project
echo ""
echo "🔄 Syncing with Xcode project..."
python3 "$SCRIPT_DIR/sync_xcode_project.py"

echo ""
echo "🎉 Done! Your new model is ready:"
echo "   • File: App/VibeIntelligence/${FILE_NAME}"
echo "   • Open in Xcode and start editing"

