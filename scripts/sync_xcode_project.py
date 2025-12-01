#!/usr/bin/env python3
"""
Xcode Project Sync Script
Automatically adds new Swift/SwiftUI files to the Xcode project.

Usage:
    python3 scripts/sync_xcode_project.py
    
Or make executable:
    chmod +x scripts/sync_xcode_project.py
    ./scripts/sync_xcode_project.py
"""

import os
import re
import uuid
import hashlib
from pathlib import Path
from typing import Dict, List, Set, Tuple

# Configuration
PROJECT_ROOT = Path(__file__).parent.parent
XCODE_PROJECT = PROJECT_ROOT / "App" / "VibeIntelligence.xcodeproj" / "project.pbxproj"
SOURCE_DIR = PROJECT_ROOT / "App" / "VibeIntelligence"
TARGET_NAME = "VibeIntelligence"

# File extensions to track
SWIFT_EXTENSIONS = {".swift"}
RESOURCE_EXTENSIONS = {".xcassets", ".storyboard", ".xib", ".plist"}


def generate_uuid() -> str:
    """Generate a 24-character UUID for Xcode project files."""
    return hashlib.md5(uuid.uuid4().bytes).hexdigest()[:24].upper()


def read_pbxproj(path: Path) -> str:
    """Read the project.pbxproj file."""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_pbxproj(path: Path, content: str) -> None:
    """Write the project.pbxproj file."""
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def get_existing_files(content: str) -> Set[str]:
    """Extract file names already in the project."""
    # Match file references like: 
    # path = FileName.swift; (without quotes)
    # path = "FileName.swift"; (with quotes)
    # name = "FileName.swift"; (with quotes)
    patterns = [
        r'path\s*=\s*([A-Za-z0-9_]+\.swift)\s*;',  # Without quotes
        r'path\s*=\s*"([^"]+\.swift)"\s*;',         # With quotes
        r'name\s*=\s*"([^"]+\.swift)"\s*;',         # Name with quotes
    ]
    
    matches = set()
    for pattern in patterns:
        matches.update(re.findall(pattern, content))
    
    return matches


def get_swift_files(source_dir: Path) -> List[Path]:
    """Get all Swift files in the source directory."""
    swift_files = []
    for ext in SWIFT_EXTENSIONS:
        swift_files.extend(source_dir.glob(f"*{ext}"))
    return sorted(swift_files)


def find_section(content: str, section_name: str) -> Tuple[int, int]:
    """Find the start and end positions of a section in the pbxproj file."""
    # Pattern to find section start
    start_pattern = rf'/\* Begin {section_name} section \*/'
    end_pattern = rf'/\* End {section_name} section \*/'
    
    start_match = re.search(start_pattern, content)
    end_match = re.search(end_pattern, content)
    
    if start_match and end_match:
        return start_match.end(), end_match.start()
    return -1, -1


def find_sources_build_phase(content: str) -> Tuple[str, int, int]:
    """Find the PBXSourcesBuildPhase section and its files array."""
    # Find the Sources build phase
    pattern = r'([A-F0-9]{24})\s*/\* Sources \*/ = \{[^}]*files = \('
    match = re.search(pattern, content)
    
    if match:
        phase_uuid = match.group(1)
        files_start = match.end()
        # Find the closing parenthesis
        depth = 1
        pos = files_start
        while depth > 0 and pos < len(content):
            if content[pos] == '(':
                depth += 1
            elif content[pos] == ')':
                depth -= 1
            pos += 1
        return phase_uuid, files_start, pos - 1
    
    return "", -1, -1


def find_main_group(content: str) -> Tuple[str, int, int]:
    """Find the main source group's children array."""
    # Look for the VibeIntelligence group that contains Swift files
    # Pattern: UUID /* VibeIntelligence */ = { ... children = ( ... ); ... sourceTree = "<group>"; };
    
    # First find the group that has VibeIntelligenceApp.swift
    pattern = r'([A-F0-9]{24})\s*/\* VibeIntelligence \*/ = \{[^}]*isa = PBXGroup[^}]*children = \('
    
    for match in re.finditer(pattern, content):
        group_uuid = match.group(1)
        children_start = match.end()
        
        # Find the closing parenthesis
        depth = 1
        pos = children_start
        while depth > 0 and pos < len(content):
            if content[pos] == '(':
                depth += 1
            elif content[pos] == ')':
                depth -= 1
            pos += 1
        
        children_end = pos - 1
        children_content = content[children_start:children_end]
        
        # Check if this group contains Swift files
        if "VibeIntelligenceApp.swift" in children_content:
            return group_uuid, children_start, children_end
    
    return "", -1, -1


def add_file_to_project(content: str, filename: str) -> Tuple[str, str, str]:
    """
    Add a new Swift file to the project.
    Returns (modified_content, file_ref_uuid, build_file_uuid)
    """
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    # 1. Add PBXBuildFile entry
    build_file_entry = f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
    
    build_start, build_end = find_section(content, "PBXBuildFile")
    if build_start > 0:
        # Insert before the end of section
        insert_pos = build_end
        # Find the last entry and insert after it
        last_entry = content.rfind("};", build_start, build_end)
        if last_entry > 0:
            insert_pos = last_entry + 2
        content = content[:insert_pos] + "\n" + build_file_entry + content[insert_pos:]
    
    # 2. Add PBXFileReference entry (no quotes around path to match Xcode style)
    file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
    
    ref_start, ref_end = find_section(content, "PBXFileReference")
    if ref_start > 0:
        # Find proper insertion point (after last entry)
        last_entry = content.rfind("};", ref_start, ref_end + 100)  # Adjust for added content
        if last_entry > 0:
            insert_pos = last_entry + 2
        content = content[:insert_pos] + "\n" + file_ref_entry + content[insert_pos:]
    
    # 3. Add to PBXGroup (children array)
    group_uuid, children_start, children_end = find_main_group(content)
    if children_start > 0:
        # Add reference to children array
        child_entry = f'\n\t\t\t\t{file_ref_uuid} /* {filename} */,'
        # Insert at end of children array
        content = content[:children_end] + child_entry + content[children_end:]
    
    # 4. Add to PBXSourcesBuildPhase
    phase_uuid, files_start, files_end = find_sources_build_phase(content)
    if files_start > 0:
        # Add to files array
        source_entry = f'\n\t\t\t\t{build_file_uuid} /* {filename} in Sources */,'
        # Find current end of files array (accounting for previous insertions)
        # Re-find the position since content has changed
        phase_uuid, files_start, files_end = find_sources_build_phase(content)
        if files_start > 0:
            content = content[:files_end] + source_entry + content[files_end:]
    
    return content, file_ref_uuid, build_file_uuid


def sync_project() -> Dict[str, List[str]]:
    """
    Synchronize Swift files with the Xcode project.
    Returns a dict with 'added' and 'existing' file lists.
    """
    result = {"added": [], "existing": [], "errors": []}
    
    if not XCODE_PROJECT.exists():
        result["errors"].append(f"Project file not found: {XCODE_PROJECT}")
        return result
    
    if not SOURCE_DIR.exists():
        result["errors"].append(f"Source directory not found: {SOURCE_DIR}")
        return result
    
    # Read current project
    content = read_pbxproj(XCODE_PROJECT)
    original_content = content
    
    # Get existing and actual files
    existing_files = get_existing_files(content)
    swift_files = get_swift_files(SOURCE_DIR)
    
    # Find files to add
    for swift_file in swift_files:
        filename = swift_file.name
        
        if filename in existing_files:
            result["existing"].append(filename)
        else:
            try:
                content, file_ref_uuid, build_file_uuid = add_file_to_project(content, filename)
                result["added"].append(filename)
                print(f"✓ Added: {filename}")
                print(f"  File Ref UUID: {file_ref_uuid}")
                print(f"  Build File UUID: {build_file_uuid}")
            except Exception as e:
                result["errors"].append(f"Failed to add {filename}: {e}")
    
    # Write updated project if changes were made
    if content != original_content:
        # Create backup
        backup_path = XCODE_PROJECT.with_suffix(".pbxproj.backup")
        write_pbxproj(backup_path, original_content)
        print(f"\n📁 Backup created: {backup_path}")
        
        # Write updated project
        write_pbxproj(XCODE_PROJECT, content)
        print(f"✅ Project updated: {XCODE_PROJECT}")
    else:
        print("✅ Project is already in sync - no changes needed")
    
    return result


def main():
    """Main entry point."""
    print("=" * 60)
    print("🔄 Xcode Project Sync")
    print("=" * 60)
    print(f"Project: {XCODE_PROJECT}")
    print(f"Source:  {SOURCE_DIR}")
    print("-" * 60)
    
    result = sync_project()
    
    print("\n" + "=" * 60)
    print("📊 Summary")
    print("=" * 60)
    
    if result["added"]:
        print(f"\n🆕 Added ({len(result['added'])} files):")
        for f in result["added"]:
            print(f"   • {f}")
    
    if result["existing"]:
        print(f"\n📦 Already in project ({len(result['existing'])} files):")
        for f in result["existing"]:
            print(f"   • {f}")
    
    if result["errors"]:
        print(f"\n❌ Errors ({len(result['errors'])}):")
        for e in result["errors"]:
            print(f"   • {e}")
    
    print("\n" + "=" * 60)
    
    # Return exit code based on errors
    return 1 if result["errors"] else 0


if __name__ == "__main__":
    exit(main())

