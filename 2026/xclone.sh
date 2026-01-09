#!/bin/bash

# GitHub Directory Downloader
# Usage: ./gh-dir-download.sh <github_url> [output_dir]
# Example: ./gh-dir-download.sh https://github.com/docker/awesome-compose/tree/master/nginx-nodejs-redis

set -euo pipefail

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it:"
    echo "  macOS:  brew install jq"
    echo "  Debian: sudo apt-get install jq"
    echo "  Alpine: apk add jq"
    exit 1
fi

# Check for input URL
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <github_url> [output_dir]"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/docker/awesome-compose/tree/master/nginx-nodejs-redis"
    echo "  $0 https://github.com/docker/awesome-compose/tree/main/nginx-nodejs-redis ./my-output"
    exit 1
fi

SOURCE_URL="$1"
OUTPUT_DIR="${2:-}"

# Parse GitHub URL
# Supports: https://github.com/{owner}/{repo}/tree/{branch}/{path}
if [[ "$SOURCE_URL" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    DIR_PATH="${BASH_REMATCH[4]}"
elif [[ "$SOURCE_URL" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)$ ]]; then
    # Root of a branch
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    DIR_PATH=""
else
    echo "Error: Invalid GitHub URL format."
    echo "Expected: https://github.com/{owner}/{repo}/tree/{branch}/{path}"
    exit 1
fi

# Set output directory (default to the last component of DIR_PATH or REPO)
if [ -z "$OUTPUT_DIR" ]; then
    if [ -n "$DIR_PATH" ]; then
        OUTPUT_DIR=$(basename "$DIR_PATH")
    else
        OUTPUT_DIR="$REPO"
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Owner:   $OWNER"
echo "Repo:    $REPO"
echo "Branch:  $BRANCH"
echo "Path:    ${DIR_PATH:-<root>}"
echo "Output:  $OUTPUT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Construct GitHub API URL
API_URL="https://api.github.com/repos/${OWNER}/${REPO}/contents/${DIR_PATH}?ref=${BRANCH}"

echo ""
echo "Fetching file list from GitHub API..."

# Fetch directory contents
RESPONSE=$(curl -sL -w "\n%{http_code}" "$API_URL")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: GitHub API returned HTTP $HTTP_CODE"
    echo "$BODY" | jq -r '.message // .' 2>/dev/null || echo "$BODY"
    exit 1
fi

# Check if response is an array (directory) or object (single file)
IS_ARRAY=$(echo "$BODY" | jq 'if type == "array" then true else false end')

if [ "$IS_ARRAY" != "true" ]; then
    echo "Error: Path does not appear to be a directory."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to recursively download contents
download_contents() {
    local api_url="$1"
    local local_path="$2"
    
    local response
    response=$(curl -sL "$api_url")
    
    echo "$response" | jq -c '.[]' | while read -r item; do
        local name type download_url item_path
        name=$(echo "$item" | jq -r '.name')
        type=$(echo "$item" | jq -r '.type')
        download_url=$(echo "$item" | jq -r '.download_url // empty')
        item_path=$(echo "$item" | jq -r '.path')
        
        if [ "$type" = "file" ]; then
            echo "  ↓ $local_path/$name"
            if ! curl -sfL --retry 3 --retry-delay 1 "$download_url" -o "$local_path/$name"; then
                echo "    ⚠ Failed to download $name, retrying..."
                sleep 1
                curl -sfL "$download_url" -o "$local_path/$name" || echo "    ✗ Failed: $name"
            fi
        elif [ "$type" = "dir" ]; then
            echo "  📁 $local_path/$name/"
            mkdir -p "$local_path/$name"
            local subdir_api="https://api.github.com/repos/${OWNER}/${REPO}/contents/${item_path}?ref=${BRANCH}"
            download_contents "$subdir_api" "$local_path/$name"
        fi
    done
}

echo "Downloading files..."
download_contents "$API_URL" "$OUTPUT_DIR"

echo ""
echo "✓ Download complete: $OUTPUT_DIR/"
echo ""
ls -la "$OUTPUT_DIR"
