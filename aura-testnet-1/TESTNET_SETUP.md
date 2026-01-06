# AURA Testnet Setup Checklist

**Chain ID**: `aura-testnet-1`
**Validators**: 4 (staged deployment)
**Port Range**: 10000-10999

## Server Allocation

| Validator | Server | VPN IP | Ports |
|-----------|--------|--------|-------|
| val1 | aura-testnet | 10.10.0.1 | RPC:10657, P2P:10656, gRPC:10090, REST:10317 |
| val2 | aura-testnet | 10.10.0.1 | RPC:10757, P2P:10756, gRPC:10190, REST:10417 |
| val3 | services-testnet | 10.10.0.4 | RPC:10857, P2P:10856, gRPC:10290, REST:10517 |
| val4 | services-testnet | 10.10.0.4 | RPC:10957, P2P:10956, gRPC:10390, REST:10617 |

## Phase 1: Genesis Creation (Local)

```bash
# On bcpc (local machine)
cd ~/blockchain-projects/aura

# Build binary
make build

# Initialize 4 validator keys
for i in 1 2 3 4; do
  ./build/aurad init val${i} --chain-id aura-testnet-1 --home ~/.aura-val${i}
  ./build/aurad keys add val${i} --keyring-backend test --home ~/.aura-val${i}
done

# Add accounts to genesis with equal allocation
./build/aurad genesis add-genesis-account val1 1000000000000uaura --keyring-backend test --home ~/.aura-val1
./build/aurad genesis add-genesis-account val2 1000000000000uaura --keyring-backend test --home ~/.aura-val2
./build/aurad genesis add-genesis-account val3 1000000000000uaura --keyring-backend test --home ~/.aura-val3
./build/aurad genesis add-genesis-account val4 1000000000000uaura --keyring-backend test --home ~/.aura-val4

# Create gentxs (250B uaura each = 25% voting power)
./build/aurad genesis gentx val1 250000000000uaura --chain-id aura-testnet-1 --keyring-backend test --home ~/.aura-val1
./build/aurad genesis gentx val2 250000000000uaura --chain-id aura-testnet-1 --keyring-backend test --home ~/.aura-val2
./build/aurad genesis gentx val3 250000000000uaura --chain-id aura-testnet-1 --keyring-backend test --home ~/.aura-val3
./build/aurad genesis gentx val4 250000000000uaura --chain-id aura-testnet-1 --keyring-backend test --home ~/.aura-val4

# Collect all gentxs into final genesis
./build/aurad genesis collect-gentxs --home ~/.aura-val1
```

## Phase 2: Deploy Validators 1 & 2 (aura-testnet)

### 2.1 Copy Files to Server
```bash
# Copy binary and configs
scp build/aurad aura-testnet:~/.aura/cosmovisor/genesis/bin/
scp ~/.aura-val1/config/genesis.json aura-testnet:~/.aura-val1/config/
scp ~/.aura-val1/config/priv_validator_key.json aura-testnet:~/.aura-val1/config/
scp ~/.aura-val2/config/priv_validator_key.json aura-testnet:~/.aura-val2/config/
```

### 2.2 Configure Validator 1 (aura-testnet)
```bash
ssh aura-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:10657"/' ~/.aura-val1/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:10656"/' ~/.aura-val1/config/config.toml
sed -i 's/prometheus_listen_addr = "127.0.0.1:26660"/prometheus_listen_addr = "127.0.0.1:10660"/' ~/.aura-val1/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/127.0.0.1:10317"/' ~/.aura-val1/config/app.toml
sed -i 's/address = "localhost:9090"/address = "127.0.0.1:10090"/' ~/.aura-val1/config/app.toml
```

> Security note: For the public testnet, keep RPC/REST/gRPC bound to localhost
> on the validator hosts and expose them through the reverse proxy only.
> If you must bind to 0.0.0.0 for internal use, restrict access via firewall
> rules and do not expose validator ports directly to the Internet.

### 2.3 Configure Validator 2 (aura-testnet)
```bash
# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:10757"/' ~/.aura-val2/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:10756"/' ~/.aura-val2/config/config.toml
sed -i 's/prometheus_listen_addr = "127.0.0.1:26660"/prometheus_listen_addr = "127.0.0.1:10760"/' ~/.aura-val2/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/127.0.0.1:10417"/' ~/.aura-val2/config/app.toml
sed -i 's/address = "localhost:9090"/address = "127.0.0.1:10190"/' ~/.aura-val2/config/app.toml
```

### 2.4 Get Node IDs and Configure Peers
```bash
VAL1_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val1)
VAL2_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val2)

# Set persistent_peers for val1
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL2_ID}@127.0.0.1:10756\"/" ~/.aura-val1/config/config.toml

# Set persistent_peers for val2
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@127.0.0.1:10656\"/" ~/.aura-val2/config/config.toml
```

### 2.5 Start Validators 1 & 2
```bash
# Start val1
nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val1 > ~/.aura-val1/node.log 2>&1 &

# Wait 10 seconds
sleep 10

# Start val2
nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val2 > ~/.aura-val2/node.log 2>&1 &
```

### 2.6 CHECKPOINT: Verify 2-Validator Consensus
```bash
# Wait for blocks to produce
sleep 30

# Check block height advancing
curl -s http://127.0.0.1:10657/status | jq '.result.sync_info.latest_block_height'
curl -s http://127.0.0.1:10757/status | jq '.result.sync_info.latest_block_height'

# Verify both validators signing (should show 2 validators)
curl -s http://127.0.0.1:10657/validators | jq '.result.validators | length'

# Check consensus state - should show 50% voting power online
curl -s http://127.0.0.1:10657/consensus_state | jq '.result.round_state.votes'

# MUST SEE: Blocks advancing, 2 validators active, both signing
# If not working, DO NOT proceed to Phase 3
```

## Phase 3: Add Validator 3 (services-testnet)

### 3.1 Copy Files to Server
```bash
# From bcpc
scp build/aurad services-testnet:~/.aura/cosmovisor/genesis/bin/
scp ~/.aura-val1/config/genesis.json services-testnet:~/.aura-val3/config/
scp ~/.aura-val3/config/priv_validator_key.json services-testnet:~/.aura-val3/config/
```

### 3.2 Configure Validator 3 (services-testnet)
```bash
ssh services-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:10857"/' ~/.aura-val3/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:10856"/' ~/.aura-val3/config/config.toml
sed -i 's/prometheus_listen_addr = "127.0.0.1:26660"/prometheus_listen_addr = "127.0.0.1:10860"/' ~/.aura-val3/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/127.0.0.1:10517"/' ~/.aura-val3/config/app.toml
sed -i 's/address = "localhost:9090"/address = "127.0.0.1:10290"/' ~/.aura-val3/config/app.toml

# Get node ID
VAL3_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val3)

# Set persistent_peers (connect to val1 and val2 on aura-testnet via VPN)
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@10.10.0.1:10656,${VAL2_ID}@10.10.0.1:10756\"/" ~/.aura-val3/config/config.toml
```

### 3.3 Update Validators 1 & 2 with Val3 Peer
```bash
# On aura-testnet, add val3 to persistent_peers
ssh aura-testnet
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL2_ID}@127.0.0.1:10756,${VAL3_ID}@10.10.0.4:10856\"/" ~/.aura-val1/config/config.toml
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL1_ID}@127.0.0.1:10656,${VAL3_ID}@10.10.0.4:10856\"/" ~/.aura-val2/config/config.toml
```

### 3.4 Start Validator 3
```bash
ssh services-testnet
nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val3 > ~/.aura-val3/node.log 2>&1 &
```

### 3.5 CHECKPOINT: Verify 3-Validator Consensus
```bash
# Wait for sync
sleep 60

# Check all 3 validators
curl -s http://10.10.0.1:10657/validators | jq '.result.validators | length'
# Should return: 3

# Check val3 is synced
curl -s http://10.10.0.4:10857/status | jq '.result.sync_info'

# Verify 75% voting power (3 of 4 validators = enough for consensus)
curl -s http://10.10.0.1:10657/consensus_state | jq '.result.round_state'

# MUST SEE: 3 validators active, blocks advancing, val3 synced
# If not working, DO NOT proceed to Phase 4
```

## Phase 4: Add Validator 4 (services-testnet)

### 4.1 Copy Files
```bash
scp ~/.aura-val4/config/priv_validator_key.json services-testnet:~/.aura-val4/config/
scp ~/.aura-val1/config/genesis.json services-testnet:~/.aura-val4/config/
```

### 4.2 Configure Validator 4
```bash
ssh services-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/127.0.0.1:10957"/' ~/.aura-val4/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:10956"/' ~/.aura-val4/config/config.toml
sed -i 's/prometheus_listen_addr = "127.0.0.1:26660"/prometheus_listen_addr = "127.0.0.1:10960"/' ~/.aura-val4/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/127.0.0.1:10617"/' ~/.aura-val4/config/app.toml
sed -i 's/address = "localhost:9090"/address = "127.0.0.1:10390"/' ~/.aura-val4/config/app.toml

# Get node ID
VAL4_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val4)

# Set persistent_peers
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@10.10.0.1:10656,${VAL3_ID}@127.0.0.1:10856\"/" ~/.aura-val4/config/config.toml
```

### 4.3 Update All Validators with Val4 Peer
```bash
# Update val1, val2 on aura-testnet
ssh aura-testnet
# Add val4 to their peer lists

# Update val3 on services-testnet
ssh services-testnet
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL1_ID}@10.10.0.1:10656,${VAL4_ID}@127.0.0.1:10956\"/" ~/.aura-val3/config/config.toml
```

### 4.4 Start Validator 4
```bash
nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val4 > ~/.aura-val4/node.log 2>&1 &
```

### 4.5 FINAL CHECKPOINT: Verify 4-Validator Consensus
```bash
# Wait for sync
sleep 60

# Check all 4 validators active
curl -s http://10.10.0.1:10657/validators | jq '.result.validators | length'
# Should return: 4

# Check consensus participation
curl -s http://10.10.0.1:10657/consensus_state | jq '.result.round_state.votes[0].prevotes_bit_array'
# Should show all 4 validators voting

# Verify blocks advancing
for port in 10657 10757 10857 10957; do
  echo "Port $port: $(curl -s http://10.10.0.1:$port/status 2>/dev/null | jq -r '.result.sync_info.latest_block_height' || curl -s http://10.10.0.4:$port/status | jq -r '.result.sync_info.latest_block_height')"
done

# Target: 95%+ consensus (all 4 validators signing most blocks)
```

## Phase 5: Deploy Supporting Services

After 4-validator consensus is stable:

```bash
# On aura-testnet (primary services)
# Explorer: 10080, Faucet: 10081, WS: 10082, GraphQL: 10400

# On services-testnet (backup/indexer)
# Indexer: 10101, WS Proxy: 10201
```

## Health Check Commands

```bash
# Quick status
curl -s http://10.10.0.1:10657/status | jq '{height: .result.sync_info.latest_block_height, catching_up: .result.sync_info.catching_up}'

# Validator set
curl -s http://10.10.0.1:10657/validators | jq '.result.validators[] | {address: .address, voting_power: .voting_power}'

# Peer count
curl -s http://10.10.0.1:10657/net_info | jq '.result.n_peers'
```

## Rollback Procedure

If consensus fails at any phase:
1. Stop all validators: `pkill -f aurad`
2. Check logs: `tail -100 ~/.aura-valX/node.log`
3. Reset state if needed: `aurad tendermint unsafe-reset-all --home ~/.aura-valX`
4. Restart from last working phase
