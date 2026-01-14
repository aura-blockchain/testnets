# AURA Testnets Repository

## Repository Separation

**This repo (`testnets/`)** → github:aura-blockchain/testnets (network config)
**Main repo (`aura/`)** → github:aura-blockchain/aura (source code)

### Save HERE (testnets/<chain-id>/)
- genesis.json, chain.json, assetlist.json, versions.json
- peers.txt, seeds.txt
- config/app.toml, config/config.toml (reference configs)
- SNAPSHOTS.md, state_sync.md
- README.md

### Save to MAIN REPO (aura/)
- Go source code, modules, CLI
- Protobuf definitions
- Tests, Makefiles, Dockerfiles
- General documentation

## Active Testnet: aura-mvp-1

### Sentry Architecture

External nodes connect to public sentry nodes, NOT directly to validators.

```
[External Nodes] → [Sentry-1/Sentry-2] → [Validators]
                         ↓
                   [Public Services]
```

### Sentry Nodes (Public P2P - Connect Here)

| Sentry | Server | P2P Address | Node ID |
|--------|--------|-------------|---------|
| sentry-1 | aura-testnet | 158.69.119.76:26681 | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |
| sentry-2 | services-testnet | 139.99.149.160:26681 | 35fdadb8b017fc95023a384c7769b946f363294e |

**Persistent peers string:**
```
f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681
```

### Validators (Private - NO direct access)

| Validator | Server | Home | Node ID |
|-----------|--------|------|---------|
| val1 | aura-testnet | ~/.aura-mvp-val1 | e07f0f1d927504521957d2a4e025ff2266097f3c |
| val2 | aura-testnet | ~/.aura-mvp-val2 | efd4c11d67c1c3b7f75b0e5123487a30959c721a |
| val3 | services-testnet | ~/.aura-mvp-val3 | e760686c2f86456b8d1b666e4aca209cb573b148 |
| val4 | services-testnet | ~/.aura-mvp-val4 | 5026a4c6b3b89cedb15cefddb9177fe03aea06b9 |

### Internal Port Configuration

**aura-testnet (158.69.119.76)**:
| Node | RPC | P2P | gRPC |
|------|-----|-----|------|
| val1 | 127.0.0.1:26657 | 0.0.0.0:26656 | 19090 |
| val2 | 127.0.0.1:26757 | 0.0.0.0:26756 | 19190 |
| sentry1 | 127.0.0.1:26680 | 0.0.0.0:26681 | - |

**services-testnet (139.99.149.160)**:
| Node | RPC | P2P | gRPC |
|------|-----|-----|------|
| val3 | 127.0.0.1:26657 | 0.0.0.0:26656 | - |
| val4 | 127.0.0.1:26757 | 0.0.0.0:26756 | - |
| sentry2 | 127.0.0.1:26680 | 0.0.0.0:26681 | - |

### Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST API | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |
| Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |

### Service Ports (aura-testnet internal)

| Service | Port |
|---------|------|
| Explorer | 10080 |
| GraphQL | 10400 |
| WS Proxy | 10082 |
| Faucet | 8080 |

## Systemd Services

**aura-testnet**:
- `aurad-mvp-val1.service`
- `aurad-mvp-val2.service`
- `aurad-mvp-sentry1.service`
- `aura-explorer.service`
- `aura-faucet.service`
- `aura-graphql.service`
- `aura-websocket-proxy.service`
- `aura-health.service`

**services-testnet**:
- `aurad-mvp-val3.service`
- `aurad-mvp-val4.service`
- `aurad-mvp-sentry2.service`
- `aura-testnet-indexer.service`

## Health Check

```bash
# On aura-testnet
curl -s http://127.0.0.1:26657/status | jq '.result.sync_info'

# Via public endpoint
curl -s https://testnet-rpc.aurablockchain.org/status | jq '.result.sync_info'
```

## Connecting External Node

```bash
PEERS="f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

See `aura-mvp-1/README.md` for full setup instructions.
