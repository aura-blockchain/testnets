# Artifacts Automation Pipeline

## Overview

This document describes the planned automation for the AURA testnet artifacts page. Implementation is scheduled for after the 4-validator testnet reconfiguration.

## Current State (Manual)

| Artifact | Update Method | Location |
|----------|---------------|----------|
| Binaries | Manual cross-compile + wrangler upload | R2: `binaries/` |
| SHA256SUMS | Manual generation | R2: `SHA256SUMS` |
| genesis.json | Manual copy from testnet repo | R2: root |
| peers.txt / seeds.txt | Manual update | R2: root |
| Snapshots | Not yet implemented | R2: `snapshots/` |
| State sync info | Live fetch from RPC (app.js) | Dynamic |
| Block height | Live fetch from RPC (app.js) | Dynamic |

## Planned Automation

### 1. Binary Releases (GitHub Actions)

**Trigger:** Tag push (e.g., `v0.1.1`) to `aura-blockchain/aura` repo

**Workflow:** `.github/workflows/release.yml`

```yaml
name: Release Binaries

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - goos: linux
            goarch: amd64
          - goos: linux
            goarch: arm64
          - goos: darwin
            goarch: amd64
          - goos: darwin
            goarch: arm64

    steps:
      - uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.22'

      - name: Build
        env:
          GOOS: ${{ matrix.goos }}
          GOARCH: ${{ matrix.goarch }}
          CGO_ENABLED: 1
        run: |
          # Use appropriate cross-compiler for each target
          make build-testnet
          mv build/aurad build/aurad-${{ matrix.goos }}-${{ matrix.goarch }}

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: aurad-${{ matrix.goos }}-${{ matrix.goarch }}
          path: build/aurad-${{ matrix.goos }}-${{ matrix.goarch }}

  upload-r2:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4

      - name: Generate checksums
        run: |
          cd artifacts
          sha256sum aurad-* > SHA256SUMS
          # Generate metadata.json with file sizes
          echo '{' > binaries/metadata.json
          for f in aurad-*; do
            platform=$(echo $f | sed 's/aurad-//')
            size=$(stat -c%s "$f")
            echo "  \"$platform\": { \"size\": $size }," >> binaries/metadata.json
          done
          sed -i '$ s/,$//' binaries/metadata.json
          echo '}' >> binaries/metadata.json

      - name: Upload to R2
        env:
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CF_ACCOUNT_ID }}
          CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
        run: |
          npm install -g wrangler
          for f in aurad-*; do
            wrangler r2 object put "aura-testnet-artifacts/binaries/$f" \
              --file "$f" \
              --content-type "application/octet-stream" \
              --content-disposition "attachment; filename=\"$f\"" \
              --remote
          done
          wrangler r2 object put "aura-testnet-artifacts/SHA256SUMS" \
            --file "SHA256SUMS" --remote
          wrangler r2 object put "aura-testnet-artifacts/binaries/metadata.json" \
            --file "binaries/metadata.json" --remote
```

**Required Secrets:**
- `CF_ACCOUNT_ID`: Cloudflare account ID (069b2e071fe1c5bea116a29786f2074c)
- `CF_API_TOKEN`: Cloudflare API token with R2 write access

### 2. Snapshot Automation (Cron on Testnet Server)

**Location:** `aura-testnet:/home/ubuntu/scripts/snapshot.sh`

**Schedule:** Daily at 00:00 UTC via cron

```bash
#!/bin/bash
# Snapshot automation script

CHAIN_ID="aura-testnet-1"
SNAP_DIR="/tmp/snapshots"
R2_BUCKET="aura-testnet-artifacts"
HOME_DIR="$HOME/.aura"

# Stop node briefly for consistent snapshot
sudo systemctl stop aurad

# Get current height
HEIGHT=$(curl -s http://127.0.0.1:10657/status | jq -r '.result.sync_info.latest_block_height')

# Create snapshot
mkdir -p $SNAP_DIR
cd $HOME_DIR
tar -cf - data/ | lz4 -z - > "$SNAP_DIR/${CHAIN_ID}_pruned_${HEIGHT}.tar.lz4"

# Restart node
sudo systemctl start aurad

# Upload to R2
wrangler r2 object put "$R2_BUCKET/snapshots/${CHAIN_ID}_pruned_latest.tar.lz4" \
  --file "$SNAP_DIR/${CHAIN_ID}_pruned_${HEIGHT}.tar.lz4" \
  --content-disposition "attachment" \
  --remote

# Update metadata
SIZE=$(stat -c%s "$SNAP_DIR/${CHAIN_ID}_pruned_${HEIGHT}.tar.lz4")
SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $SIZE)
cat > /tmp/snapshot_metadata.json << EOF
{
  "pruned": {
    "height": "$HEIGHT",
    "size": "$SIZE_HUMAN",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF

wrangler r2 object put "$R2_BUCKET/snapshots/metadata.json" \
  --file "/tmp/snapshot_metadata.json" \
  --remote

# Cleanup
rm -rf $SNAP_DIR
```

**Cron entry:**
```
0 0 * * * /home/ubuntu/scripts/snapshot.sh >> /var/log/snapshot.log 2>&1
```

### 3. Network Config Updates (GitHub Actions)

**Trigger:** Push to `aura-blockchain/testnets` repo affecting `aura-testnet-1/`

**Workflow:** `.github/workflows/sync-artifacts.yml`

```yaml
name: Sync Network Config to R2

on:
  push:
    branches: [main]
    paths:
      - 'aura-testnet-1/genesis.json'
      - 'aura-testnet-1/peers.txt'
      - 'aura-testnet-1/seeds.txt'
      - 'aura-testnet-1/chain.json'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Upload changed files to R2
        env:
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CF_ACCOUNT_ID }}
          CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
        run: |
          npm install -g wrangler
          cd aura-testnet-1

          for file in genesis.json peers.txt seeds.txt chain.json addrbook.json; do
            if [ -f "$file" ]; then
              wrangler r2 object put "aura-testnet-artifacts/$file" \
                --file "$file" \
                --content-disposition "attachment; filename=\"$file\"" \
                --remote
            fi
          done
```

### 4. Dynamic Data (Already Implemented)

The following data is fetched live by `app.js` on page load - no automation needed:

| Data | Source | Update Frequency |
|------|--------|------------------|
| Block height | RPC `/status` | Every 30 seconds |
| State sync trust height | RPC `/block` | On page load |
| State sync trust hash | RPC `/block` | On page load |
| Network status | RPC `/status` | Every 30 seconds |

## R2 Bucket Structure

```
aura-testnet-artifacts/
├── index.html
├── styles.css
├── app.js
├── genesis.json
├── chain.json
├── peers.txt
├── seeds.txt
├── addrbook.json
├── state_sync.md
├── install.sh
├── SHA256SUMS
├── binaries/
│   ├── aurad-linux-amd64
│   ├── aurad-linux-arm64
│   ├── aurad-darwin-amd64
│   ├── aurad-darwin-arm64
│   └── metadata.json
└── snapshots/
    ├── aura-testnet-1_pruned_latest.tar.lz4
    ├── aura-testnet-1_archive_latest.tar.lz4
    └── metadata.json
```

## Implementation Checklist

After 4-validator testnet reconfiguration:

- [ ] Create GitHub Actions workflow for binary releases in `aura` repo
- [ ] Add Cloudflare secrets to GitHub repos
- [ ] Create GitHub Actions workflow for network config sync in `testnets` repo
- [ ] Deploy snapshot script to testnet server
- [ ] Configure cron job for daily snapshots
- [ ] Test full pipeline with a test release
- [ ] Update `app.js` to load snapshot metadata
- [ ] Document manual override procedures

## Manual Override

For emergency updates or debugging, manual uploads remain available:

```bash
# From local machine with wrangler configured
source ~/.nvm/nvm.sh && nvm use 22

# Upload a file
wrangler r2 object put "aura-testnet-artifacts/<path>" \
  --file "<local-file>" \
  --content-disposition "attachment; filename=\"<filename>\"" \
  --remote

# List bucket contents
wrangler r2 object list aura-testnet-artifacts --remote
```

## References

- [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) - Standard chain.json format
- [Polkachu Snapshots](https://www.polkachu.com/testnets/cosmos) - Snapshot service example
- [kjnodes Services](https://services.kjnodes.com/testnet/cosmoshub/) - Testnet services example
- [Cloudflare R2 Wrangler Docs](https://developers.cloudflare.com/r2/api/workers/workers-api-usage/)
