# AURA MVP Testnet Transition Plan

**Created**: 2026-01-12
**Status**: DRAFT
**Target Chain ID**: `aura-mvp-1`

## Executive Summary

This document outlines the transition from the current development testnet (`aura-testnet-1`) to the MVP testnet (`aura-mvp-1`). Based on blockchain community best practices, **a fresh genesis is required** because the MVP release removes 16 modules - a consensus-breaking change that cannot be performed via in-place upgrade.

## Transition Strategy

### Why Fresh Genesis (Not Upgrade)?

| Factor | In-Place Upgrade | Fresh Genesis |
|--------|------------------|---------------|
| Module removal (28 → 12) | Not supported | Required |
| State compatibility | Incompatible | Clean slate |
| Cosmos SDK convention | Violates | Follows |
| Genesis validation | Would fail | Passes |
| Validator key reuse | Yes | Yes |
| Historical data | Preserved | Lost |

**Decision**: Fresh genesis with new chain-id `aura-mvp-1`

### Network Topology (Unchanged)

| Validator | Server | VPN IP | Ports |
|-----------|--------|--------|-------|
| val1 | aura-testnet | 10.10.0.1 | RPC:10657, P2P:10656 |
| val2 | aura-testnet | 10.10.0.1 | RPC:10757, P2P:10756 |
| val3 | services-testnet | 10.10.0.4 | RPC:10857, P2P:10856 |
| val4 | services-testnet | 10.10.0.4 | RPC:10957, P2P:10956 |

---

## Pre-Transition Checklist

### Code Readiness
- [ ] MVP binary builds successfully (`make build-mvp`)
- [ ] MVP tests pass (`make test-mvp`)
- [ ] Validation script passes (`./scripts/validate-mvp.sh`)
- [ ] Release binaries built (`./scripts/build-mvp-release.sh v1.0.0-mvp`)
- [ ] Binaries uploaded to R2 artifacts bucket

### Genesis Readiness
- [ ] MVP genesis template validated
- [ ] Genesis generation script tested
- [ ] Validator gentxs prepared
- [ ] Final genesis file generated and validated

### Infrastructure Readiness
- [ ] Backup current testnet state (optional archive)
- [ ] DNS records ready for update (if needed)
- [ ] Explorer configured for new chain-id
- [ ] Faucet configured for new chain-id
- [ ] Monitoring updated for new chain-id

### Communication
- [ ] Transition announcement drafted
- [ ] Validator operators notified (7 days advance notice)
- [ ] Developer community notified
- [ ] Documentation updated

---

## Phase 1: Preparation (T-7 days)

### 1.1 Build MVP Release Binaries

```bash
# On bcpc (local build machine)
cd ~/blockchain-projects/aura-project/aura/chain

# Build MVP binary
make build-mvp

# Verify binary
./build/aurad-mvp version
# Expected: v1.0.0-mvp

# Run validation
./scripts/validate-mvp.sh

# Build release artifacts
./scripts/build-mvp-release.sh v1.0.0-mvp

# Upload to R2
# (Use appropriate R2 upload command)
```

### 1.2 Generate MVP Genesis

```bash
# Generate genesis with 4 validators
cd ~/blockchain-projects/aura-project/aura/chain

# Create temp directories for each validator
for i in 1 2 3 4; do
  ./build/aurad-mvp init val${i} --chain-id aura-mvp-1 --home .mvp-val${i}
done

# Add genesis accounts (1T uaura each)
for i in 1 2 3 4; do
  ./build/aurad-mvp keys add val${i} --keyring-backend test --home .mvp-val${i}
  ./build/aurad-mvp genesis add-genesis-account val${i} 1000000000000uaura \
    --keyring-backend test --home .mvp-val${i}
done

# Create gentxs (250B uaura stake each = 25% voting power)
for i in 1 2 3 4; do
  ./build/aurad-mvp genesis gentx val${i} 250000000000uaura \
    --chain-id aura-mvp-1 \
    --keyring-backend test \
    --home .mvp-val${i}
done

# Collect gentxs
mkdir -p .mvp-val1/config/gentx
cp .mvp-val2/config/gentx/*.json .mvp-val1/config/gentx/
cp .mvp-val3/config/gentx/*.json .mvp-val1/config/gentx/
cp .mvp-val4/config/gentx/*.json .mvp-val1/config/gentx/
./build/aurad-mvp genesis collect-gentxs --home .mvp-val1

# Validate genesis
./build/aurad-mvp genesis validate .mvp-val1/config/genesis.json

# Copy to testnets directory
cp .mvp-val1/config/genesis.json ../testnets/aura-mvp-1/genesis.json
```

### 1.3 Notify Stakeholders

**Announcement Template**:
```
Subject: AURA Testnet Transition to MVP (aura-mvp-1)

The AURA testnet will transition from aura-testnet-1 to aura-mvp-1 on [DATE].

What's changing:
- New chain-id: aura-mvp-1
- Reduced module set (28 → 12 modules)
- Fresh genesis (no state migration)

Action required:
- Validators: Update binary to aurad-mvp v1.0.0-mvp
- Developers: Update chain-id in configurations
- Users: Testnet tokens will be reset (use faucet)

Timeline:
- T-7: Announcement (today)
- T-1: Final genesis distribution
- T-0: Coordinated chain start at [TIME UTC]

Resources:
- Binary: https://artifacts.aurablockchain.org/mvp/v1.0.0-mvp/
- Genesis: https://artifacts.aurablockchain.org/mvp/genesis-mvp.json
- Docs: https://docs.aurablockchain.org/mvp
```

---

## Phase 2: Shutdown Current Testnet (T-0, Step 1)

### 2.1 Archive Current State (Optional)

```bash
# On aura-testnet server
ssh aura-testnet

# Export current state for archival
~/.aura/cosmovisor/genesis/bin/aurad export --home ~/.aura-val1 > ~/aura-testnet-1-final-export.json

# Compress and archive
gzip ~/aura-testnet-1-final-export.json
# Upload to R2 archive bucket if needed
```

### 2.2 Stop All Validators

**Execute in order across both servers:**

```bash
# Terminal 1: aura-testnet (val1, val2)
ssh aura-testnet

# Graceful shutdown
pkill -SIGTERM -f "aurad.*aura-val1"
pkill -SIGTERM -f "aurad.*aura-val2"

# Wait for clean shutdown
sleep 10

# Verify stopped
pgrep -f aurad
# Should return nothing

# Terminal 2: services-testnet (val3, val4)
ssh services-testnet

pkill -SIGTERM -f "aurad.*aura-val3"
pkill -SIGTERM -f "aurad.*aura-val4"

sleep 10
pgrep -f aurad
```

### 2.3 Backup Validator Keys

```bash
# On aura-testnet
ssh aura-testnet
mkdir -p ~/validator-keys-backup/testnet-1
cp ~/.aura-val1/config/priv_validator_key.json ~/validator-keys-backup/testnet-1/val1.json
cp ~/.aura-val2/config/priv_validator_key.json ~/validator-keys-backup/testnet-1/val2.json

# On services-testnet
ssh services-testnet
mkdir -p ~/validator-keys-backup/testnet-1
cp ~/.aura-val3/config/priv_validator_key.json ~/validator-keys-backup/testnet-1/val3.json
cp ~/.aura-val4/config/priv_validator_key.json ~/validator-keys-backup/testnet-1/val4.json
```

### 2.4 Clean Old Data

```bash
# On aura-testnet
ssh aura-testnet
rm -rf ~/.aura-val1/data
rm -rf ~/.aura-val2/data

# On services-testnet
ssh services-testnet
rm -rf ~/.aura-val3/data
rm -rf ~/.aura-val4/data
```

---

## Phase 3: Deploy MVP Testnet (T-0, Step 2)

### 3.1 Deploy MVP Binary

```bash
# From bcpc to aura-testnet
scp ~/blockchain-projects/aura-project/aura/chain/build/aurad-mvp \
  aura-testnet:~/.aura/cosmovisor/genesis/bin/aurad

# From bcpc to services-testnet
scp ~/blockchain-projects/aura-project/aura/chain/build/aurad-mvp \
  services-testnet:~/.aura/cosmovisor/genesis/bin/aurad
```

### 3.2 Initialize MVP Validators

```bash
# On aura-testnet
ssh aura-testnet

# Initialize val1
~/.aura/cosmovisor/genesis/bin/aurad init val1-mvp --chain-id aura-mvp-1 --home ~/.aura-val1

# Initialize val2
~/.aura/cosmovisor/genesis/bin/aurad init val2-mvp --chain-id aura-mvp-1 --home ~/.aura-val2

# On services-testnet
ssh services-testnet

# Initialize val3
~/.aura/cosmovisor/genesis/bin/aurad init val3-mvp --chain-id aura-mvp-1 --home ~/.aura-val3

# Initialize val4
~/.aura/cosmovisor/genesis/bin/aurad init val4-mvp --chain-id aura-mvp-1 --home ~/.aura-val4
```

### 3.3 Distribute Genesis and Keys

```bash
# From bcpc - distribute genesis to all validators
GENESIS=~/blockchain-projects/aura-project/testnets/aura-mvp-1/genesis.json

scp $GENESIS aura-testnet:~/.aura-val1/config/genesis.json
scp $GENESIS aura-testnet:~/.aura-val2/config/genesis.json
scp $GENESIS services-testnet:~/.aura-val3/config/genesis.json
scp $GENESIS services-testnet:~/.aura-val4/config/genesis.json

# Distribute validator keys (generated in Phase 1)
scp .mvp-val1/config/priv_validator_key.json aura-testnet:~/.aura-val1/config/
scp .mvp-val2/config/priv_validator_key.json aura-testnet:~/.aura-val2/config/
scp .mvp-val3/config/priv_validator_key.json services-testnet:~/.aura-val3/config/
scp .mvp-val4/config/priv_validator_key.json services-testnet:~/.aura-val4/config/
```

### 3.4 Configure Ports (Same as Before)

Ports remain unchanged from `aura-testnet-1` - use existing `TESTNET_SETUP.md` configuration.

### 3.5 Configure Peers

```bash
# On aura-testnet
ssh aura-testnet

# Get node IDs
VAL1_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val1)
VAL2_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val2)

echo "VAL1_ID=$VAL1_ID"
echo "VAL2_ID=$VAL2_ID"

# On services-testnet
ssh services-testnet

VAL3_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val3)
VAL4_ID=$(~/.aura/cosmovisor/genesis/bin/aurad tendermint show-node-id --home ~/.aura-val4)

echo "VAL3_ID=$VAL3_ID"
echo "VAL4_ID=$VAL4_ID"

# Configure persistent_peers for all validators
# (Use values from TESTNET_SETUP.md with new node IDs)
```

---

## Phase 4: Coordinated Launch (T-0, Step 3)

### 4.1 Set Genesis Time

Update genesis.json with coordinated start time:

```bash
# Set genesis_time to 15 minutes in the future
GENESIS_TIME=$(date -u -d "+15 minutes" +"%Y-%m-%dT%H:%M:%SZ")
echo "Genesis time: $GENESIS_TIME"

# Update genesis on all nodes (or regenerate with correct time)
```

### 4.2 Start Validators (Coordinated)

**Start order**: val1 → val2 → val3 → val4 (30 second intervals)

```bash
# T+0:00 - Start val1
ssh aura-testnet "nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val1 > ~/.aura-val1/node.log 2>&1 &"

# T+0:30 - Start val2
ssh aura-testnet "nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val2 > ~/.aura-val2/node.log 2>&1 &"

# T+1:00 - Start val3
ssh services-testnet "nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val3 > ~/.aura-val3/node.log 2>&1 &"

# T+1:30 - Start val4
ssh services-testnet "nohup ~/.aura/cosmovisor/genesis/bin/aurad start --home ~/.aura-val4 > ~/.aura-val4/node.log 2>&1 &"
```

### 4.3 Verify Launch

```bash
# Wait for genesis time to pass, then verify

# Check block production
curl -s http://10.10.0.1:10657/status | jq '{
  chain_id: .result.node_info.network,
  height: .result.sync_info.latest_block_height,
  catching_up: .result.sync_info.catching_up
}'

# Expected:
# {
#   "chain_id": "aura-mvp-1",
#   "height": "1",
#   "catching_up": false
# }

# Check validator count
curl -s http://10.10.0.1:10657/validators | jq '.result.validators | length'
# Expected: 4

# Check all validators are signing
curl -s http://10.10.0.1:10657/consensus_state | jq '.result.round_state.votes[0].prevotes_bit_array'
# Expected: "BA{4:xxxx}" (all x's should be filled)
```

---

## Phase 5: Post-Launch Verification

### 5.1 Health Checks

```bash
# Run on all validator ports
for port in 10657 10757; do
  echo "=== Validator on port $port ==="
  curl -s http://10.10.0.1:$port/status | jq '{height: .result.sync_info.latest_block_height}'
done

for port in 10857 10957; do
  echo "=== Validator on port $port ==="
  curl -s http://10.10.0.4:$port/status | jq '{height: .result.sync_info.latest_block_height}'
done
```

### 5.2 Test Transactions

```bash
# Request tokens from faucet
curl -X POST https://testnet-faucet.aurablockchain.org/request \
  -H "Content-Type: application/json" \
  -d '{"address": "aura1..."}'

# Send test transaction
~/.aura/cosmovisor/genesis/bin/aurad tx bank send \
  val1 aura1... 1000000uaura \
  --chain-id aura-mvp-1 \
  --keyring-backend test \
  --home ~/.aura-val1 \
  --yes
```

### 5.3 Update Infrastructure

- [ ] Update explorer to point to `aura-mvp-1`
- [ ] Update faucet chain-id configuration
- [ ] Update public RPC/REST/gRPC endpoints
- [ ] Update documentation links
- [ ] Update chain registry files

---

## Rollback Procedure

If the MVP launch fails, rollback to `aura-testnet-1`:

### Immediate Rollback (Within 1 Hour)

```bash
# 1. Stop all MVP validators
ssh aura-testnet "pkill -f aurad"
ssh services-testnet "pkill -f aurad"

# 2. Restore old binary
scp ~/blockchain-projects/aura-project/aura/chain/build/aurad \
  aura-testnet:~/.aura/cosmovisor/genesis/bin/aurad
scp ~/blockchain-projects/aura-project/aura/chain/build/aurad \
  services-testnet:~/.aura/cosmovisor/genesis/bin/aurad

# 3. Restore old genesis and keys
# (From backup taken in Phase 2.3)

# 4. Restore data directories
# (From backup if available, or reset and resync)

# 5. Restart old testnet
```

### Decision Criteria for Rollback

| Issue | Action |
|-------|--------|
| Validators won't start | Check logs, fix config, retry |
| No blocks produced after 10 min | Rollback |
| Consensus failure | Check peer connectivity, retry |
| < 67% voting power online | Wait, or rollback if > 30 min |
| Transaction failures | Debug, may not require rollback |

---

## Timeline Summary

| Time | Action |
|------|--------|
| T-7 days | Announce transition, build binaries |
| T-3 days | Final genesis generation, testing |
| T-1 day | Final stakeholder notification |
| T-0:00 | Stop current testnet |
| T-0:15 | Deploy MVP binary and genesis |
| T-0:30 | Configure and start validators |
| T-0:45 | Verify launch, run health checks |
| T-1:00 | Update infrastructure (explorer, faucet) |
| T-2:00 | Public announcement of successful launch |

---

## Contacts

| Role | Responsibility |
|------|----------------|
| Tech Lead | Transition coordination, binary builds |
| Validator Ops | Server management, node operations |
| DevOps | Infrastructure updates, monitoring |
| Communications | Stakeholder notifications |

---

## Appendix A: File Locations

| File | Location |
|------|----------|
| MVP Binary | `aura/chain/build/aurad-mvp` |
| MVP Genesis Template | `testnets/aura-testnet-1/genesis-mvp-template.json` |
| MVP Chain Registry | `testnets/aura-testnet-1/chain-mvp.json` |
| Final Genesis | `testnets/aura-mvp-1/genesis.json` |
| Build Script | `aura/chain/scripts/build-mvp-release.sh` |
| Validation Script | `aura/chain/scripts/validate-mvp.sh` |

## Appendix B: Module Changes

### MVP Modules (12)
- auth, bank, staking, slashing, distribution, consensus
- upgrade, params, genutil, wasm
- identity, vcregistry, dataregistry, compliance, governance, prevalidation

### Deferred Modules (16)
- security, walletsecurity, validatorsecurity, networksecurity
- cryptography, economicsecurity, dex, bridge
- confidencescore, inclusionroutines, incidentresponse, monitoring
- aiassistant, contractregistry, identitychange, privacy, economics, aurabindings
