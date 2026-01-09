#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/GallopingDino/analyze-aab"

# Platform-specific paths
case "$(uname -s)" in
    Darwin)
        DEFAULT_INSTALL_DIR="$HOME/.local/bin"
        DEFAULT_DATA_DIR="$HOME/Library/Application Support/analyze-aab"
        ;;
    *)
        DEFAULT_INSTALL_DIR="$HOME/.local/bin"
        DEFAULT_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/analyze-aab"
        ;;
esac

INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
DATA_DIR="${DATA_DIR:-$DEFAULT_DATA_DIR}"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { printf "${BLUE}%s${NC}\n" "$1"; }
success() { printf "${GREEN}%s${NC}\n" "$1"; }
error() { printf "${RED}Error: %s${NC}\n" "$1" >&2; exit 1; }

# Handle uninstall
if [[ "${1:-}" == "uninstall" ]]; then
    info "Uninstalling analyze-aab..."
    rm -f "$INSTALL_DIR/analyze-aab" "$INSTALL_DIR/compare-reports"
    rm -rf "$DATA_DIR"
    success "Uninstalled."
    exit 0
fi

# Check dependencies
command -v curl &>/dev/null || error "curl is required"
command -v java &>/dev/null || echo "Warning: Java not found. Required for bundletool."

# Create directories
mkdir -p "$INSTALL_DIR" "$DATA_DIR"

# Download and extract
info "Downloading analyze-aab..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$REPO_URL/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP_DIR" --strip-components=1

# Install
install -m 755 "$TMP_DIR/bin/analyze-aab" "$INSTALL_DIR/"
install -m 755 "$TMP_DIR/bin/compare-reports" "$INSTALL_DIR/"
cp -r "$TMP_DIR/devices" "$DATA_DIR/"

success "Installed to $INSTALL_DIR"

# PATH check
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Add to your shell profile (~/.bashrc or ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
