# AURA Public Endpoints

Public API endpoints for connecting to the AURA testnet.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-mvp-1` |
| Version | v1.0.0-mvp |
| Status | Active |
| Native Token | AURA (uaura) |

**Links**: [Website](https://aurablockchain.org) | [Discord](https://discord.gg/RwQ8pma6) | [GitHub](https://github.com/aura-blockchain)

## Public Endpoints

### Primary Endpoints (aura-testnet / sentry1)

| Service | URL |
|---------|-----|
| RPC | `https://testnet-rpc.aurablockchain.org` |
| REST API | `https://testnet-api.aurablockchain.org` |
| gRPC | `testnet-grpc.aurablockchain.org:443` |
| WebSocket | `wss://testnet-ws.aurablockchain.org` |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL |
|---------|-----|
| RPC | `https://testnet-rpc-2.aurablockchain.org` |
| REST API | `https://testnet-api-2.aurablockchain.org` |

## Explorer & Tools

| Service | URL |
|---------|-----|
| Explorer (Ping.pub) | https://explorer.aurablockchain.org/aura |
| Legacy Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |
| API Docs (Swagger) | https://testnet-api.aurablockchain.org/swagger/ |

## Peering

Connect to sentry nodes (NOT validators directly):

### Persistent Peers
```
f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681
35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681
```

### Address Book
```bash
curl -s https://artifacts.aurablockchain.org/addrbook.json > ~/.aura/config/addrbook.json
```

## Quick Commands

```bash
# Check sync status
curl -s https://testnet-rpc.aurablockchain.org/status | jq '.result.sync_info'

# Get latest block height
curl -s https://testnet-rpc.aurablockchain.org/status | jq -r '.result.sync_info.latest_block_height'

# Scrape Prometheus metrics
curl -s https://testnet-rpc.aurablockchain.org:10660/metrics
```
