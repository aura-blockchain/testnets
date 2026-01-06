# AURA Testnets Repository

## Repository Separation

**This repo (`aura-testnets/`)** → github:aura-blockchain/testnets (network config)
**Main repo (`aura/`)** → github:aura-blockchain/aura (source code)

### Save HERE (aura-testnets/<chain-id>/)
- genesis.json - network genesis file
- chain.json - chain registry metadata
- assetlist.json - token metadata
- versions.json - upgrade history
- peers.txt, seeds.txt - node addresses
- config/app.toml, config/config.toml - reference configs
- SNAPSHOTS.md, state_sync.md - sync guides
- README.md - network-specific docs
- bin/SHA256SUMS - binary checksums

### Save to MAIN REPO (aura/)
- Go source code, modules, CLI
- Protobuf definitions
- Tests, Makefiles, Dockerfiles
- General documentation

## Health Check
Run `~/blockchain-projects/scripts/testnet-health-check.sh` for all testnets.

## Port Configuration (AURA Testnet - Port Range 10000-10999)

**4-Validator Setup** with staged deployment (2→3→4 validators)

### Validator Ports (aura-testnet / 10.10.0.1)
| Validator | RPC | P2P | gRPC | REST | Prometheus |
|-----------|-----|-----|------|------|------------|
| Val 1 | 10657 | 10656 | 10090 | 10317 | 10660 |
| Val 2 | 10757 | 10756 | 10190 | 10417 | 10760 |

### Validator Ports (services-testnet / 10.10.0.4)
| Validator | RPC | P2P | gRPC | REST | Prometheus |
|-----------|-----|-----|------|------|------------|
| Val 3 | 10857 | 10856 | 10290 | 10517 | 10860 |
| Val 4 | 10957 | 10956 | 10390 | 10617 | 10960 |

### Public Endpoints
| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST API | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |
| Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |

### Service Ports
| Service | Port |
|---------|------|
| Explorer API | 10080 |
| Faucet API | 10081 |
| WS Proxy | 10082 |
| GraphQL | 10400 |
| cosmos-exporter | 10300 |

See `aura-testnet-1/TESTNET_SETUP.md` for full deployment checklist.
