# AURA Testnet Setup Guide

**Chain ID**: `aura-mvp-1`
**Validators**: 4 (deployed across 2 servers)
**Sentries**: 2 (public-facing)

## Architecture Overview

```
                    ┌─────────────────────────────────────┐
                    │         aura-testnet                │
                    │        (158.69.119.76)              │
                    │                                     │
                    │  ┌─────────┐     ┌─────────┐       │
                    │  │  val1   │     │  val2   │       │
                    │  │ :26656  │     │ :26756  │       │
                    │  └────┬────┘     └────┬────┘       │
                    │       │               │            │
                    │       └───────┬───────┘            │
                    │               │                    │
                    │         ┌─────┴─────┐              │
   [External] ──────┼────────►│  sentry1  │              │
                    │         │  :26681   │              │
                    │         └───────────┘              │
                    │                                     │
                    │  Services: explorer, faucet,       │
                    │  graphql, ws-proxy, health         │
                    └─────────────────────────────────────┘
                                      │
                                      │ VPN (10.10.0.x)
                                      │
                    ┌─────────────────────────────────────┐
                    │       services-testnet              │
                    │       (139.99.149.160)              │
                    │                                     │
                    │  ┌─────────┐     ┌─────────┐       │
                    │  │  val3   │     │  val4   │       │
                    │  │ :26656  │     │ :26756  │       │
                    │  └────┬────┘     └────┬────┘       │
                    │       │               │            │
                    │       └───────┬───────┘            │
                    │               │                    │
                    │         ┌─────┴─────┐              │
   [External] ──────┼────────►│  sentry2  │              │
                    │         │  :26681   │              │
                    │         └───────────┘              │
                    │                                     │
                    │  Services: indexer                 │
                    └─────────────────────────────────────┘
```

## Server Allocation

| Node | Server | Home Directory | RPC | P2P | gRPC |
|------|--------|----------------|-----|-----|------|
| val1 | aura-testnet | ~/.aura-mvp-val1 | 127.0.0.1:26657 | 0.0.0.0:26656 | localhost:19090 |
| val2 | aura-testnet | ~/.aura-mvp-val2 | 127.0.0.1:26757 | 0.0.0.0:26756 | localhost:19190 |
| sentry1 | aura-testnet | ~/.aura-mvp-sentry1 | 127.0.0.1:26680 | 0.0.0.0:26681 | - |
| val3 | services-testnet | ~/.aura-mvp-val3 | 127.0.0.1:26657 | 0.0.0.0:26656 | - |
| val4 | services-testnet | ~/.aura-mvp-val4 | 127.0.0.1:26757 | 0.0.0.0:26756 | - |
| sentry2 | services-testnet | ~/.aura-mvp-sentry2 | 127.0.0.1:26680 | 0.0.0.0:26681 | - |

## Node IDs

| Node | ID |
|------|----|
| val1 | e07f0f1d927504521957d2a4e025ff2266097f3c |
| val2 | efd4c11d67c1c3b7f75b0e5123487a30959c721a |
| sentry1 | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |
| val3 | e760686c2f86456b8d1b666e4aca209cb573b148 |
| val4 | 5026a4c6b3b89cedb15cefddb9177fe03aea06b9 |
| sentry2 | 35fdadb8b017fc95023a384c7769b946f363294e |

## Systemd Services

### aura-testnet

```bash
# Validator and sentry nodes
sudo systemctl status aurad-mvp-val1
sudo systemctl status aurad-mvp-val2
sudo systemctl status aurad-mvp-sentry1

# Supporting services
sudo systemctl status aura-explorer
sudo systemctl status aura-faucet
sudo systemctl status aura-graphql
sudo systemctl status aura-websocket-proxy
sudo systemctl status aura-health
```

### services-testnet

```bash
sudo systemctl status aurad-mvp-val3
sudo systemctl status aurad-mvp-val4
sudo systemctl status aurad-mvp-sentry2
sudo systemctl status aura-testnet-indexer
```

## Joining as External Validator

### Step 1: Initialize Node

```bash
# Download binary
curl -LO https://artifacts.aurablockchain.org/mvp/v1.0.0-mvp/aurad-linux-amd64
chmod +x aurad-linux-amd64
sudo mv aurad-linux-amd64 /usr/local/bin/aurad

# Initialize
aurad init my-validator --chain-id aura-mvp-1

# Download genesis
curl -o ~/.aura/config/genesis.json https://artifacts.aurablockchain.org/mvp/genesis.json
```

### Step 2: Configure Peers

Connect to sentry nodes only (NOT validators):

```bash
PEERS="f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

### Step 3: Start Node and Sync

```bash
# Start node
aurad start

# Or with systemd
sudo systemctl enable aurad
sudo systemctl start aurad
```

### Step 4: Create Validator (after sync)

```bash
# Check sync status
aurad status | jq '.SyncInfo.catching_up'
# Wait until catching_up is false

# Create validator key
aurad keys add validator

# Get tokens from faucet
curl -X POST https://testnet-faucet.aurablockchain.org/api/v1/faucet/request \
  -H "Content-Type: application/json" \
  -d '{"address": "aura1..."}'

# Create validator
aurad tx staking create-validator \
  --amount=1000000uaura \
  --pubkey=$(aurad tendermint show-validator) \
  --moniker="my-validator" \
  --chain-id=aura-mvp-1 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=validator
```

## Health Check Commands

```bash
# Quick status
curl -s http://127.0.0.1:26657/status | jq '{height: .result.sync_info.latest_block_height, catching_up: .result.sync_info.catching_up}'

# Validator set
curl -s http://127.0.0.1:26657/validators | jq '.result.validators[] | {address: .address, voting_power: .voting_power}'

# Peer count
curl -s http://127.0.0.1:26657/net_info | jq '.result.n_peers'

# Via public endpoint
curl -s https://testnet-rpc.aurablockchain.org/status | jq '.result.sync_info'
```

## Restart Procedures

### Single Node Restart

```bash
ssh aura-testnet
sudo systemctl restart aurad-mvp-val1
sudo journalctl -u aurad-mvp-val1 -f
```

### Rolling Restart (all validators)

```bash
# Val1
ssh aura-testnet "sudo systemctl restart aurad-mvp-val1"
sleep 30

# Val2
ssh aura-testnet "sudo systemctl restart aurad-mvp-val2"
sleep 30

# Val3
ssh services-testnet "sudo systemctl restart aurad-mvp-val3"
sleep 30

# Val4
ssh services-testnet "sudo systemctl restart aurad-mvp-val4"
```

## Binary Updates

```bash
# Build locally
cd ~/blockchain-projects/aura-project/aura
make build

# Deploy to aura-testnet
scp build/aurad aura-testnet:~/.aura-mvp-val1/cosmovisor/genesis/bin/
ssh aura-testnet "sudo systemctl restart aurad-mvp-val1 aurad-mvp-val2 aurad-mvp-sentry1"

# Deploy to services-testnet
scp build/aurad services-testnet:~/.aura-mvp-val3/cosmovisor/genesis/bin/
ssh services-testnet "sudo systemctl restart aurad-mvp-val3 aurad-mvp-val4 aurad-mvp-sentry2"
```

## Rollback Procedure

If consensus fails:

```bash
# Stop all validators
ssh aura-testnet "sudo systemctl stop aurad-mvp-val1 aurad-mvp-val2"
ssh services-testnet "sudo systemctl stop aurad-mvp-val3 aurad-mvp-val4"

# Check logs for errors
ssh aura-testnet "journalctl -u aurad-mvp-val1 -n 100"

# Reset state if needed (DESTRUCTIVE)
ssh aura-testnet "~/.aura-mvp-val1/cosmovisor/genesis/bin/aurad tendermint unsafe-reset-all --home ~/.aura-mvp-val1"

# Restart
ssh aura-testnet "sudo systemctl start aurad-mvp-val1 aurad-mvp-val2"
ssh services-testnet "sudo systemctl start aurad-mvp-val3 aurad-mvp-val4"
```
