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
