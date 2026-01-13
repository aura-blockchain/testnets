#!/bin/bash
# AURA Testnet Node Quick Install Script
# Usage: curl -sL https://artifacts.aurablockchain.org/install.sh | bash

set -e

CHAIN_ID="aura-testnet-1"
ARTIFACTS_URL="https://artifacts.aurablockchain.org"
DAEMON="aurad"
HOME_DIR="$HOME/.aura"

echo "======================================"
echo "  AURA Testnet Node Quick Installer"
echo "======================================"
echo ""

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case $OS in
    linux|darwin)
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

BINARY_NAME="${DAEMON}-${OS}-${ARCH}"
BINARY_URL="${ARTIFACTS_URL}/binaries/${BINARY_NAME}"

echo "Detected: ${OS}/${ARCH}"
echo "Downloading: ${BINARY_NAME}"
echo ""

# Create directories
mkdir -p "$HOME_DIR/config"
mkdir -p "$HOME_DIR/data"
mkdir -p "$HOME/bin"

# Download binary
echo "Downloading binary..."
curl -sL "$BINARY_URL" -o "$HOME/bin/$DAEMON"
chmod +x "$HOME/bin/$DAEMON"

# Verify binary
echo "Verifying binary..."
if ! "$HOME/bin/$DAEMON" version >/dev/null 2>&1; then
    echo "ERROR: Binary verification failed"
    exit 1
fi

VERSION=$("$HOME/bin/$DAEMON" version 2>/dev/null || echo "unknown")
echo "Installed version: $VERSION"
echo ""

# Download genesis
echo "Downloading genesis..."
curl -sL "${ARTIFACTS_URL}/genesis.json" -o "$HOME_DIR/config/genesis.json"

# Download address book
echo "Downloading address book..."
curl -sL "${ARTIFACTS_URL}/addrbook.json" -o "$HOME_DIR/config/addrbook.json"

# Get persistent peers
echo "Configuring peers..."
PEERS=$(curl -sL "${ARTIFACTS_URL}/peers.txt" | grep -v '^#' | tr '\n' ',' | sed 's/,$//')

# Initialize if needed
if [ ! -f "$HOME_DIR/config/config.toml" ]; then
    echo "Initializing node..."
    "$HOME/bin/$DAEMON" init "my-node" --chain-id "$CHAIN_ID" --home "$HOME_DIR" >/dev/null 2>&1
    # Re-download genesis after init (init creates a default one)
    curl -sL "${ARTIFACTS_URL}/genesis.json" -o "$HOME_DIR/config/genesis.json"
fi

# Update config with peers
if [ -n "$PEERS" ]; then
    sed -i.bak "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME_DIR/config/config.toml"
fi

echo ""
echo "======================================"
echo "  Installation Complete!"
echo "======================================"
echo ""
echo "Binary location: $HOME/bin/$DAEMON"
echo "Home directory:  $HOME_DIR"
echo "Chain ID:        $CHAIN_ID"
echo ""
echo "Add to PATH:"
echo "  export PATH=\"\$HOME/bin:\$PATH\""
echo ""
echo "Start node:"
echo "  $DAEMON start --home $HOME_DIR"
echo ""
echo "For faster sync, consider using a snapshot:"
echo "  ${ARTIFACTS_URL}/snapshots/"
echo ""
echo "Get testnet tokens from the faucet:"
echo "  https://testnet-faucet.aurablockchain.org"
echo ""
