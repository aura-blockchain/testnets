# AURA Testnet State Sync

State sync allows rapid bootstrapping of new nodes by fetching a snapshot from peers.

## Configuration

Add these settings to `~/.aura/config/config.toml`:

```toml
[statesync]
enable = true
rpc_servers = "https://testnet-rpc.aurablockchain.org:443,https://testnet-rpc.aurablockchain.org:443"
trust_height = TRUST_HEIGHT
trust_hash = "TRUST_HASH"
trust_period = "168h0m0s"
```

## Get Trust Height and Hash

Run this script to get current values:

```bash
#!/bin/bash
SNAP_RPC="https://testnet-rpc.aurablockchain.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo "trust_height = $BLOCK_HEIGHT"
echo "trust_hash = \"$TRUST_HASH\""
```

## Quick Setup

```bash
# Stop node
sudo systemctl stop aurad

# Reset data (keeps config)
aurad tendermint unsafe-reset-all --home ~/.aura --keep-addr-book

# Get trust values and update config
SNAP_RPC="https://testnet-rpc.aurablockchain.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.aura/config/config.toml

# Start node
sudo systemctl start aurad
```

## Verification

Check sync progress:

```bash
curl -s localhost:10657/status | jq .result.sync_info
```
