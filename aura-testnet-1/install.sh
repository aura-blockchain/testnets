#!/usr/bin/env bash
# AURA Testnet One-Line Installer
# Usage: curl -sL https://get.aurablockchain.org | bash
#
# Environment variables (optional):
#   MONIKER     - Node name (default: aura-<hostname>)
#   STATE_SYNC  - Enable state sync (default: true)
#   MODE        - full or light (default: full)

set -euo pipefail

CHAIN_ID="aura-testnet-1"
MONIKER="${MONIKER:-aura-$(hostname)}"
AURA_HOME="${AURA_HOME:-$HOME/.aura}"
BINARY="aurad"
ARTIFACTS_URL="https://artifacts.aurablockchain.org"
RPC_URL="https://testnet-rpc.aurablockchain.org"
STATE_SYNC="${STATE_SYNC:-true}"
MODE="${MODE:-full}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}>>>${NC} $1"; }
warn() { echo -e "${YELLOW}>>>${NC} $1"; }
err() { echo -e "${RED}>>>${NC} $1" >&2; exit 1; }

# Check dependencies
command -v curl >/dev/null || err "curl is required"
command -v jq >/dev/null || err "jq is required (apt install jq)"

log "Installing AURA Testnet Node"
echo "Chain ID: $CHAIN_ID"
echo "Moniker:  $MONIKER"
echo "Home:     $AURA_HOME"
echo "Mode:     $MODE (state sync: $STATE_SYNC)"
echo ""

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) err "Unsupported architecture: $ARCH" ;;
esac

BINARY_URL="${ARTIFACTS_URL}/bin/${BINARY}-${OS}-${ARCH}"
log "Downloading $BINARY for $OS/$ARCH..."
curl -fsSL "$BINARY_URL" -o /tmp/$BINARY || err "Failed to download binary"
chmod +x /tmp/$BINARY
sudo mv /tmp/$BINARY /usr/local/bin/
log "Installed $BINARY to /usr/local/bin/"

# Initialize
if [ ! -f "$AURA_HOME/config/genesis.json" ]; then
  log "Initializing node..."
  $BINARY init "$MONIKER" --chain-id "$CHAIN_ID" --home "$AURA_HOME" >/dev/null
fi

# Download genesis
log "Downloading genesis..."
curl -fsSL "${ARTIFACTS_URL}/genesis.json" -o "$AURA_HOME/config/genesis.json"

# Download recommended configs
log "Downloading configs..."
curl -fsSL "${ARTIFACTS_URL}/config/app.toml" -o "$AURA_HOME/config/app.toml"
curl -fsSL "${ARTIFACTS_URL}/config/config.toml" -o "$AURA_HOME/config/config.toml"

# Configure peers
log "Configuring peers..."
PEERS=$(curl -fsSL "${ARTIFACTS_URL}/peers.txt" | tr '\n' ',' | sed 's/,$//')
sed -i.bak -E "s|^persistent_peers = \".*\"|persistent_peers = \"$PEERS\"|" "$AURA_HOME/config/config.toml"

# State sync
if [ "$STATE_SYNC" = "true" ]; then
  log "Configuring state sync..."
  LATEST=$(curl -s "$RPC_URL/block" | jq -r '.result.block.header.height')
  TRUST_HEIGHT=$((LATEST - 1000))
  TRUST_HASH=$(curl -s "$RPC_URL/block?height=$TRUST_HEIGHT" | jq -r '.result.block_id.hash')

  sed -i.bak -E "s|^enable = false|enable = true|" "$AURA_HOME/config/config.toml"
  sed -i.bak -E "s|^rpc_servers = \"\"|rpc_servers = \"$RPC_URL,$RPC_URL\"|" "$AURA_HOME/config/config.toml"
  sed -i.bak -E "s|^trust_height = 0|trust_height = $TRUST_HEIGHT|" "$AURA_HOME/config/config.toml"
  sed -i.bak -E "s|^trust_hash = \"\"|trust_hash = \"$TRUST_HASH\"|" "$AURA_HOME/config/config.toml"
fi

# Pruning for light mode
if [ "$MODE" = "light" ]; then
  log "Configuring light mode pruning..."
  sed -i.bak -E 's|^pruning = ".*"|pruning = "custom"|' "$AURA_HOME/config/app.toml"
  sed -i.bak -E 's|^pruning-keep-recent = ".*"|pruning-keep-recent = "1000"|' "$AURA_HOME/config/app.toml"
fi

# Create systemd service
log "Creating systemd service..."
sudo tee /etc/systemd/system/aurad.service > /dev/null <<EOF
[Unit]
Description=AURA Blockchain Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/aurad start --home $AURA_HOME
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable aurad

log "Installation complete!"
echo ""
echo "Start the node:"
echo "  sudo systemctl start aurad"
echo ""
echo "View logs:"
echo "  sudo journalctl -u aurad -f"
echo ""
echo "Check sync status:"
echo "  curl -s localhost:26657/status | jq '.result.sync_info'"
echo ""
echo "Get testnet tokens:"
echo "  https://testnet-faucet.aurablockchain.org"
