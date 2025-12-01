# VibeIntelligence Scripts

This directory contains automation scripts for the VibeIntelligence macOS app development.

## Available Scripts

### 🔄 sync-project.sh

Synchronizes Swift files with the Xcode project. Automatically detects new `.swift` files in the source directory and adds them to `project.pbxproj`.

```bash
./scripts/sync-project.sh
```

**What it does:**
- Scans `App/VibeIntelligence/` for Swift files
- Compares against files already in the Xcode project
- Adds missing files to all required sections:
  - `PBXBuildFile`
  - `PBXFileReference`
  - `PBXGroup` (children)
  - `PBXSourcesBuildPhase` (files)
- Creates a backup before modifying

---

### 📱 new-view.sh

Creates a new SwiftUI View file and automatically adds it to the Xcode project.

```bash
./scripts/new-view.sh ViewName
```

**Example:**
```bash
./scripts/new-view.sh ProfileView
# Creates: App/VibeIntelligence/ProfileView.swift
```

**Generated file includes:**
- Standard header with date and copyright
- SwiftUI import
- `@EnvironmentObject var configManager: ConfigManager`
- Basic view structure with placeholder content
- Preview provider

---

### 📦 new-model.sh

Creates a new Swift model or service class and adds it to the Xcode project.

```bash
# Create a Codable struct
./scripts/new-model.sh ModelName

# Create an ObservableObject class
./scripts/new-model.sh ServiceName --observable
```

**Examples:**
```bash
./scripts/new-model.sh UserProfile
# Creates a Codable, Identifiable struct

./scripts/new-model.sh DataService --observable
# Creates an ObservableObject singleton with async loading pattern
```

---

### 🐍 sync_xcode_project.py

The Python backend that powers the sync functionality. Can be run directly:

```bash
python3 scripts/sync_xcode_project.py
```

**Features:**
- Generates unique UUIDs for new file references
- Handles both quoted and unquoted path formats
- Creates backups before modifying
- Provides detailed summary output

---

## Usage Tips

1. **After creating files manually**: Run `sync-project.sh` to add them to Xcode
2. **For new views**: Use `new-view.sh` for a complete workflow
3. **Always backup**: The scripts create `.backup` files automatically
4. **Verify builds**: Run `xcodebuild` after syncing to confirm

## Requirements

- Python 3.x
- macOS with Xcode installed
- Bash shell

## Troubleshooting

### Files not being detected
- Ensure files are in `App/VibeIntelligence/`
- Check file extension is `.swift`

### Build errors after sync
- Restore from backup: `cp project.pbxproj.backup project.pbxproj`
- Check for duplicate entries in the project file
- Run `xcodebuild clean` and rebuild

### Permission denied
```bash
chmod +x scripts/*.sh scripts/*.py
```

