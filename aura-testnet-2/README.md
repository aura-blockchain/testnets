# AURA Testnet 2

Public testnet for the AURA blockchain with `auratest1` address prefix.

## Network Details

| Property | Value |
|----------|-------|
| Chain ID | `aura-testnet-2` |
| Address Prefix | `auratest1` |
| Denom | `uaura` |
| RPC | https://rpc.testnet.aurablockchain.org |
| REST API | https://api.testnet.aurablockchain.org |
| Explorer | https://explorer.testnet.aurablockchain.org |
| Faucet | https://faucet.aurablockchain.org |

## Quick Start

### 1. Download and install the binary

```bash
# Clone the repository
git clone https://github.com/aura-blockchain/aura.git
cd aura/chain

# Build testnet binary (uses auratest1 prefix)
make build-testnet

# Install
cp build/aurad $GOPATH/bin/
```

### 2. Initialize node

```bash
aurad init <your-moniker> --chain-id aura-testnet-2
```

### 3. Download genesis

```bash
curl -o ~/.aura/config/genesis.json https://raw.githubusercontent.com/aura-blockchain/testnets/main/aura-testnet-2/genesis.json
```

### 4. Set peers

```bash
PEERS="d57420cfc4bc8b7d75ce20c581cf04e07089f792@158.69.119.76:10656"
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

### 5. Start node

```bash
aurad start
```

## Faucet

Request testnet tokens at https://faucet.aurablockchain.org

- Amount per request: 200 AURA
- Cooldown: 4 hours
- Wallet address must start with `auratest1`

## Genesis Accounts

| Account | Address | Balance |
|---------|---------|---------|
| Validator | `auratest1w2p7vgvu5nakc83zhlqld846fquhskgul8h0p3` | 1,000,000 AURA |
| Faucet | `auratest1m3dtvvj0r7cavf64nv299dp5kqr8fu0ud89nfs` | 100,000,000 AURA |
