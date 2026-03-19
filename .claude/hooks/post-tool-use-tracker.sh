#!/bin/bash
set -e

# Post-tool-use hook that tracks edited files
# This runs after Edit, MultiEdit, or Write tools complete successfully

# Read tool information from stdin
tool_info=$(cat)

# Extract relevant data
tool_name=$(echo "$tool_info" | jq -r '.tool_name // empty')
file_path=$(echo "$tool_info" | jq -r '.tool_input.file_path // empty')
session_id=$(echo "$tool_info" | jq -r '.session_id // empty')

# Skip if not an edit tool or no file path
if [[ ! "$tool_name" =~ ^(Edit|MultiEdit|Write)$ ]] || [[ -z "$file_path" ]]; then
    exit 0
fi

# Skip markdown files
if [[ "$file_path" =~ \.(md|markdown)$ ]]; then
    exit 0
fi

# Create cache directory in project
cache_dir="$CLAUDE_PROJECT_DIR/.claude/cache/${session_id:-default}"
mkdir -p "$cache_dir"

# Function to detect module from file path
detect_module() {
    local file="$1"
    local project_root="$CLAUDE_PROJECT_DIR"

    # Remove project root from path
    local relative_path="${file#$project_root/}"

    # Extract first directory component
    local module=$(echo "$relative_path" | cut -d'/' -f1)

    # Flutter project directory patterns
    case "$module" in
        lib|test|integration_test|android|ios|web|macos|linux|windows)
            echo "$module"
            ;;
        *)
            # Check if it's a source file in root
            if [[ ! "$relative_path" =~ / ]]; then
                echo "root"
            else
                echo "$module"
            fi
            ;;
    esac
}

# Detect module
module=$(detect_module "$file_path")

# Skip if unknown
if [[ -z "$module" ]]; then
    exit 0
fi

# Log edited file
echo "$(date +%s):$file_path:$module" >> "$cache_dir/edited-files.log"

# Update affected modules list
if ! grep -q "^$module$" "$cache_dir/affected-modules.txt" 2>/dev/null; then
    echo "$module" >> "$cache_dir/affected-modules.txt"
fi

# Exit cleanly
exit 0