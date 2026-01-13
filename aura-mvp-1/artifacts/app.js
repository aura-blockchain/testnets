// AURA Testnet Artifacts - App.js

const RPC_URL = 'https://testnet-rpc.aurablockchain.org';
const API_URL = 'https://testnet-api.aurablockchain.org';

// Check network status
async function checkNetworkStatus() {
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.querySelector('.status-text');

    try {
        const response = await fetch(`${RPC_URL}/status`);
        const data = await response.json();

        if (data.result) {
            statusDot.classList.remove('offline');
            statusText.textContent = 'Network Online';

            // Update current block
            const blockHeight = data.result.sync_info.latest_block_height;
            document.getElementById('currentBlock').textContent = parseInt(blockHeight).toLocaleString();

            // Update state sync info
            updateStateSyncInfo(data.result.sync_info);
        }
    } catch (error) {
        console.error('Network check failed:', error);
        statusDot.classList.add('offline');
        statusText.textContent = 'Network Offline';
    }
}

// Update state sync configuration
async function updateStateSyncInfo(syncInfo) {
    const currentHeight = parseInt(syncInfo.latest_block_height);
    const trustHeight = currentHeight - 2000; // Go back 2000 blocks for safety

    try {
        const response = await fetch(`${RPC_URL}/block?height=${trustHeight}`);
        const data = await response.json();

        if (data.result) {
            const trustHash = data.result.block_id.hash;

            document.getElementById('statesync-height').textContent = trustHeight.toString();
            document.getElementById('statesync-hash').textContent = trustHash;

            // Update copy buttons
            document.getElementById('copy-height').setAttribute('data-copy', trustHeight.toString());
            document.getElementById('copy-hash').setAttribute('data-copy', trustHash);
        }
    } catch (error) {
        console.error('Failed to fetch trust block:', error);
        document.getElementById('statesync-height').textContent = 'Error loading';
        document.getElementById('statesync-hash').textContent = 'Error loading';
    }
}

// Copy to clipboard functionality
function setupCopyButtons() {
    // Copy buttons
    document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('click', async () => {
            const textToCopy = btn.getAttribute('data-copy') || btn.previousElementSibling.textContent;

            try {
                await navigator.clipboard.writeText(textToCopy);
                const originalText = btn.textContent;
                btn.textContent = 'Copied!';
                btn.classList.add('copied');

                setTimeout(() => {
                    btn.textContent = originalText;
                    btn.classList.remove('copied');
                }, 2000);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });
    });

    // Copy targets (clickable code blocks)
    document.querySelectorAll('.copy-target').forEach(el => {
        el.addEventListener('click', async () => {
            const textToCopy = el.getAttribute('data-copy') || el.textContent;

            try {
                await navigator.clipboard.writeText(textToCopy);
                const originalColor = el.style.color;
                el.style.color = 'var(--success-color)';

                setTimeout(() => {
                    el.style.color = originalColor;
                }, 1000);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });
    });
}

// Load snapshot metadata (if available)
async function loadSnapshotMetadata() {
    try {
        const response = await fetch('snapshots/metadata.json');
        if (response.ok) {
            const data = await response.json();

            if (data.pruned) {
                document.getElementById('snapshot-pruned-size').textContent = data.pruned.size;
                document.getElementById('snapshot-pruned-height').textContent = parseInt(data.pruned.height).toLocaleString();
            }

            if (data.archive) {
                document.getElementById('snapshot-archive-size').textContent = data.archive.size;
                document.getElementById('snapshot-archive-height').textContent = parseInt(data.archive.height).toLocaleString();
            }
        }
    } catch (error) {
        // Metadata not available, keep defaults
        console.log('Snapshot metadata not available');
    }
}

// Load checksum data
async function loadChecksums() {
    try {
        const response = await fetch('SHA256SUMS');
        if (response.ok) {
            const text = await response.text();
            const lines = text.trim().split('\n');

            lines.forEach(line => {
                const [checksum, filename] = line.split(/\s+/);
                if (filename && checksum) {
                    const platform = filename.replace('aurad-', '').replace('binaries/', '');
                    const checksumEl = document.getElementById(`checksum-${platform}`);
                    if (checksumEl) {
                        checksumEl.textContent = checksum.substring(0, 12) + '...';
                        checksumEl.title = checksum;
                    }
                }
            });
        }
    } catch (error) {
        console.log('Checksums not available');
    }
}

// Format bytes to human-readable size
function formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}

// Load binary file sizes from metadata
async function loadBinarySizes() {
    try {
        const response = await fetch('binaries/metadata.json');
        if (response.ok) {
            const data = await response.json();
            for (const [platform, info] of Object.entries(data)) {
                const sizeEl = document.getElementById(`size-${platform}`);
                if (sizeEl && info.size) {
                    sizeEl.textContent = formatBytes(info.size);
                }
            }
        }
    } catch (error) {
        console.log('Binary metadata not available');
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    checkNetworkStatus();
    setupCopyButtons();
    loadSnapshotMetadata();
    loadChecksums();
    loadBinarySizes();

    // Refresh network status every 30 seconds
    setInterval(checkNetworkStatus, 30000);
});
