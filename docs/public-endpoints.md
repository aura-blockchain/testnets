# AURA Public Endpoints

Public API endpoints for connecting to the AURA testnet.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-mvp-1` |
| Version | v0.1.0 |
| Status | Active |
| Native Token | AURA (uaura) |

**Links**: [Website](https://aurablockchain.org) | [Discord](https://discord.gg/RwQ8pma6) | [GitHub](https://github.com/aura-blockchain)

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | `https://testnet-rpc.aurablockchain.org` |
| REST API | `https://testnet-api.aurablockchain.org` |
| gRPC | `testnet-grpc.aurablockchain.org:443` |
| WebSocket | `wss://testnet-ws.aurablockchain.org` |
| Prometheus Metrics | `http://testnet-rpc.aurablockchain.org:10660/metrics` |

## Explorer & Tools

| Service | URL |
|---------|-----|
| Block Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |
| Status Page | https://status.aurablockchain.org |
| API Docs (Swagger) | https://testnet-api.aurablockchain.org/swagger/ |

## Peering

### Persistent Peers
```
02b1374b69dc8ff1dd75d92acf56bec76a29d5c9@testnet-rpc.aurablockchain.org:10656
d8ec2ae6a61262fe36f129f0931c49039b087e9e@testnet-rpc.aurablockchain.org:10756
8ebe092686b892b71a49aa2b96a7dcbd36bb5495@139.99.149.160:10856
4230ebcf5a7db85bb30d65b632495f8651469bcc@139.99.149.160:10956
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
