# AURA Testnet State Sync

State sync allows rapid bootstrapping of new nodes by fetching a snapshot from peers.

## Current Values (Auto-Updated)

```toml
[statesync]
enable = true
rpc_servers = "https://testnet-rpc.aurablockchain.org:443,https://testnet-rpc.aurablockchain.org:443"
trust_height = 15453
trust_hash = "325E293C5802AD61A4211A1958E7A03952206565B29486F0731CC1EB47F82DF4"
trust_period = "168h0m0s"
```

*Last updated: 2026-01-14*

## Get Fresh Trust Values

Run this script to get the latest values:

```bash
#!/bin/bash
RPC="https://testnet-rpc.aurablockchain.org"
LATEST=$(curl -s "$RPC/block" | jq -r '.result.block.header.height')
TRUST_HEIGHT=$((LATEST - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r '.result.block_id.hash')
echo "trust_height = $TRUST_HEIGHT"
echo "trust_hash = \"$TRUST_HASH\""
```

## Quick Setup

```bash
# Stop node
sudo systemctl stop aurad

# Reset data (keeps config)
aurad tendermint unsafe-reset-all --home ~/.aura --keep-addr-book

# Get trust values and update config
RPC="https://testnet-rpc.aurablockchain.org"
LATEST=$(curl -s "$RPC/block" | jq -r '.result.block.header.height')
TRUST_HEIGHT=$((LATEST - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r '.result.block_id.hash')

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC:443,$RPC:443\"|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.aura/config/config.toml

# Start node
sudo systemctl start aurad
```

## Verification

Check sync progress:

```bash
# Via public RPC
curl -s https://testnet-rpc.aurablockchain.org/status | jq '.result.sync_info'

# Local (if node is running)
curl -s localhost:26657/status | jq '.result.sync_info'
```

## Troubleshooting

If state sync fails:
1. Ensure your node has the correct genesis file
2. Check that persistent peers are configured
3. Try with fresh trust values (may have expired)
4. Check firewall allows outbound connections

```bash
# Check peers
curl -s localhost:26657/net_info | jq '.result.n_peers'
```
