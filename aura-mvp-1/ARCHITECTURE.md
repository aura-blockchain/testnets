# AURA MVP Testnet Architecture

## Overview

The AURA MVP testnet (`aura-mvp-1`) is a 4-validator Cosmos SDK network with sentry node architecture for DDoS protection.

## Network Topology

```
                              INTERNET
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
                 ▼                               ▼
    ┌────────────────────────┐     ┌────────────────────────┐
    │      SENTRY-1          │     │      SENTRY-2          │
    │   158.69.119.76:26681  │     │  139.99.149.160:26681  │
    │                        │     │                        │
    │  Node ID: f5ce5e5c...  │     │  Node ID: 35fdadb8...  │
    └───────────┬────────────┘     └────────────┬───────────┘
                │                               │
                │         WireGuard VPN         │
                │          (10.10.0.x)          │
                │                               │
    ┌───────────┴───────────────────────────────┴───────────┐
    │                    PRIVATE NETWORK                     │
    │                                                        │
    │  ┌─────────────────────────────────────────────────┐  │
    │  │              aura-testnet (10.10.0.1)           │  │
    │  │                                                 │  │
    │  │   ┌─────────────┐       ┌─────────────┐        │  │
    │  │   │    VAL1     │◄─────►│    VAL2     │        │  │
    │  │   │   :26656    │       │   :26756    │        │  │
    │  │   │  25% power  │       │  25% power  │        │  │
    │  │   └─────────────┘       └─────────────┘        │  │
    │  │          │                     │               │  │
    │  │          └──────────┬──────────┘               │  │
    │  │                     │                          │  │
    │  │              ┌──────┴──────┐                   │  │
    │  │              │  SENTRY-1   │                   │  │
    │  │              │   :26681    │                   │  │
    │  │              └─────────────┘                   │  │
    │  │                                                │  │
    │  │   Services: Explorer, Faucet, GraphQL,        │  │
    │  │             WebSocket Proxy, Health           │  │
    │  └─────────────────────────────────────────────────┘  │
    │                         │                              │
    │                    VPN Tunnel                          │
    │                         │                              │
    │  ┌─────────────────────────────────────────────────┐  │
    │  │           services-testnet (10.10.0.4)          │  │
    │  │                                                 │  │
    │  │   ┌─────────────┐       ┌─────────────┐        │  │
    │  │   │    VAL3     │◄─────►│    VAL4     │        │  │
    │  │   │   :26656    │       │   :26756    │        │  │
    │  │   │  25% power  │       │  25% power  │        │  │
    │  │   └─────────────┘       └─────────────┘        │  │
    │  │          │                     │               │  │
    │  │          └──────────┬──────────┘               │  │
    │  │                     │                          │  │
    │  │              ┌──────┴──────┐                   │  │
    │  │              │  SENTRY-2   │                   │  │
    │  │              │   :26681    │                   │  │
    │  │              └─────────────┘                   │  │
    │  │                                                │  │
    │  │   Services: Indexer                           │  │
    │  └─────────────────────────────────────────────────┘  │
    │                                                        │
    └────────────────────────────────────────────────────────┘
```

## Server Details

### aura-testnet (Primary)

| Property | Value |
|----------|-------|
| Public IP | 158.69.119.76 |
| VPN IP | 10.10.0.1 |
| Provider | OVH |
| Location | Canada |
| SSH | `ssh aura-testnet` |

**Nodes:**

| Node | Home Directory | RPC | P2P | gRPC | Node ID |
|------|----------------|-----|-----|------|---------|
| val1 | ~/.aura-mvp-val1 | 127.0.0.1:26657 | 0.0.0.0:26656 | localhost:19090 | e07f0f1d927504521957d2a4e025ff2266097f3c |
| val2 | ~/.aura-mvp-val2 | 127.0.0.1:26757 | 0.0.0.0:26756 | localhost:19190 | efd4c11d67c1c3b7f75b0e5123487a30959c721a |
| sentry1 | ~/.aura-mvp-sentry1 | 127.0.0.1:26680 | 0.0.0.0:26681 | - | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |

**Services:**

| Service | Port | Systemd Unit |
|---------|------|--------------|
| Block Explorer | 10080 | aura-explorer.service |
| Faucet API | 8080 | aura-faucet.service |
| GraphQL Gateway | 10400 | aura-graphql.service |
| WebSocket Proxy | 10082 | aura-websocket-proxy.service |
| Health Check | - | aura-health.service |

### services-testnet (Secondary)

| Property | Value |
|----------|-------|
| Public IP | 139.99.149.160 |
| VPN IP | 10.10.0.4 |
| Provider | OVH |
| Location | Canada |
| SSH | `ssh services-testnet` |

**Nodes:**

| Node | Home Directory | RPC | P2P | Node ID |
|------|----------------|-----|-----|---------|
| val3 | ~/.aura-mvp-val3 | 127.0.0.1:26657 | 0.0.0.0:26656 | e760686c2f86456b8d1b666e4aca209cb573b148 |
| val4 | ~/.aura-mvp-val4 | 127.0.0.1:26757 | 0.0.0.0:26756 | 5026a4c6b3b89cedb15cefddb9177fe03aea06b9 |
| sentry2 | ~/.aura-mvp-sentry2 | 127.0.0.1:26680 | 0.0.0.0:26681 | 35fdadb8b017fc95023a384c7769b946f363294e |

**Services:**

| Service | Port | Systemd Unit |
|---------|------|--------------|
| Indexer | 4101 | aura-testnet-indexer.service |

## Public Endpoints

All public traffic is routed through Cloudflare:

### Primary Endpoints (aura-testnet / sentry1)

| Service | URL | Backend |
|---------|-----|---------|
| RPC | https://testnet-rpc.aurablockchain.org | Sentry1 RPC :26680 |
| REST API | https://testnet-api.aurablockchain.org | Sentry1 REST :1380 |
| gRPC | testnet-grpc.aurablockchain.org:443 | Val1 gRPC :19090 |
| WebSocket | wss://testnet-ws.aurablockchain.org | WS Proxy :10082 |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL | Backend |
|---------|-----|---------|
| RPC | https://testnet-rpc-2.aurablockchain.org | Sentry2 RPC :26680 |
| REST API | https://testnet-api-2.aurablockchain.org | Sentry2 REST :1380 |

### Services

| Service | URL | Backend |
|---------|-----|---------|
| Explorer (Ping.pub) | https://explorer.aurablockchain.org/aura | Static /var/www/ping-explorer |
| Legacy Explorer | https://testnet-explorer.aurablockchain.org | Explorer :10080 |
| Faucet | https://testnet-faucet.aurablockchain.org | Faucet :8080 |
| Artifacts | https://artifacts.aurablockchain.org | Cloudflare R2 |

## Security Architecture

### Sentry Node Pattern

```
[Internet] ──► [Sentry] ──► [Validator]
                  │
                  ├── pex = true (discovers peers)
                  └── Exposed P2P port

[Validator]
    ├── pex = false (no peer discovery)
    ├── persistent_peers = [sentries only]
    └── private_peer_ids = [other validators]
```

**Why sentries?**
- Validators never exposed to internet directly
- DDoS attacks hit sentries, not validators
- Sentries can be replaced without validator downtime
- Network topology is hidden from attackers

### VPN (WireGuard)

- All validator-to-validator traffic over VPN
- VPN IPs: 10.10.0.1 (aura-testnet), 10.10.0.4 (services-testnet)
- Validator P2P uses VPN IPs, not public IPs

### Firewall Rules

**Sentry nodes (public-facing):**
- Allow inbound: 26681/tcp (P2P)
- Allow inbound: 22/tcp (SSH, restricted)
- Block all other inbound

**Validators (private):**
- Allow inbound from VPN only
- No public inbound ports

## Consensus Configuration

| Parameter | Value |
|-----------|-------|
| Chain ID | aura-mvp-1 |
| Validators | 4 |
| Voting Power | 25% each |
| Block Time | ~5 seconds |
| Consensus | CometBFT (Tendermint) |

**Consensus Requirements:**
- 67% voting power needed for blocks (3 of 4 validators)
- Single validator failure: network continues
- Two validator failures: network halts

## Data Flow

### Transaction Submission

```
1. User submits tx to RPC endpoint
2. Cloudflare routes to nginx on aura-testnet
3. nginx forwards to sentry1 RPC (:26680)
4. Sentry broadcasts to validators via P2P
5. Validators include in block
6. Block propagates back through sentries
```

### Block Explorer

```
1. Explorer queries val1 RPC (:26657)
2. Indexes blocks/txs into local database
3. Serves web UI on :10080
4. Cloudflare serves publicly
```

## Monitoring

### Health Check Daemon

Runs on aura-testnet, checks:
- Block height advancing
- Validator signing status
- Peer connectivity
- Service availability

### Prometheus Metrics

Each node exports metrics on :26660:
- `tendermint_consensus_height`
- `tendermint_consensus_validators`
- `tendermint_p2p_peers`

## Disaster Recovery

### Single Validator Failure

Network continues with 75% voting power. Fix:
1. Check logs: `journalctl -u aurad-mvp-valX -f`
2. Restart: `sudo systemctl restart aurad-mvp-valX`

### Two Validator Failures

Network halts. Recovery:
1. Fix validators (don't reset state)
2. Restart in order: val1, val2, val3, val4
3. Monitor consensus resumption

### Complete Network Reset

Only if necessary (loses all state):
```bash
# On each server
for node in val1 val2 val3 val4 sentry1 sentry2; do
  aurad tendermint unsafe-reset-all --home ~/.aura-mvp-$node
done
# Restart all services
```

## Peer Connection Reference

### For External Nodes

Connect to sentries only:
```
persistent_peers = "f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
```

### For Validators (Internal)

Validators peer with each other over VPN and with local sentry:
```
# val1 peers
persistent_peers = "efd4c11d67c1c3b7f75b0e5123487a30959c721a@127.0.0.1:26756,e760686c2f86456b8d1b666e4aca209cb573b148@10.10.0.4:26656,5026a4c6b3b89cedb15cefddb9177fe03aea06b9@10.10.0.4:26756"
```
