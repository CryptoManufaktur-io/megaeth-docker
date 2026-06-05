#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /private/artifact-bucket-key.json ]]; then
    echo "Could not find /private/artifact-bucket-key.json required file"
    exit 1
fi

# Login to gcloud
gcloud auth activate-service-account --key-file=/private/artifact-bucket-key.json

# Create needed folders
mkdir -p /data/snapshot /data/node/logs

if [[ ! -f "/data/snapshot/megaeth-rpc-${CHAIN_VERSION_TAG}/${NETWORK}/environment.sh" ]]; then
    # Remove old versions
    rm -rf /data/snapshot/megaeth-rpc-v*

    echo "Downloading and extracting megaeth-rpc-${CHAIN_VERSION_TAG}.tar.gz ..."
    gcloud storage cp gs://megaeth-public-node-packages/${CHAIN_VERSION_TAG}/megaeth-rpc-${CHAIN_VERSION_TAG}.tar.gz /data/snapshot
    tar xf /data/snapshot/megaeth-rpc-${CHAIN_VERSION_TAG}.tar.gz -C /data/snapshot
    chmod +x /data/snapshot/megaeth-rpc-${CHAIN_VERSION_TAG}/rpc-node-${CHAIN_VERSION_TAG}
    rm /data/snapshot/megaeth-rpc-${CHAIN_VERSION_TAG}.tar.gz
else
    echo "No need to download megaeth-rpc-${CHAIN_VERSION_TAG}.tar.gz"
fi


# Initialize
if [[ ! -f /data/.initialized ]]; then
    echo "Initializing ..."

    # Download snapshot itself
    if [[ ! -f /data/.download_complete ]]; then
        echo "Downloading snapshot ..."
        gsutil -o GSUtil:resumable_tracker_dir=/data/.gsutil-tracker \
            cp gs://megaeth-public-mainnet-snapshots/archive-snapshot-7141079.tar /data/snapshot 2>&1 | tr '\r' '\n'
        echo "Downloading snapshot complete ..."
        touch /data/.download_complete
    else
        echo "No need to download snapshot"
    fi

    # Extract and remove snapshot file
    rm -rf /data/node/db
    tar -xvf /data/snapshot/archive-snapshot-7141079.tar -C /data/node
    echo "Done extraction"
    rm /data/snapshot/archive-snapshot-7141079.tar


    # Mark done initialized
    touch /data/.initialized
else
    echo "Already Initialized"
fi

# Setup env file
cp "/data/snapshot/megaeth-rpc-${CHAIN_VERSION_TAG}/${NETWORK}/environment.sh" /data/environment.sh

grep -q '^MEGARETH_BOOTSTRAP_POLICY=' /data/environment.sh \
  && sed -i "s|^MEGARETH_BOOTSTRAP_POLICY=.*|MEGARETH_BOOTSTRAP_POLICY=$MEGARETH_BOOTSTRAP_POLICY|" /data/environment.sh \
  || echo "MEGARETH_BOOTSTRAP_POLICY=$MEGARETH_BOOTSTRAP_POLICY" >> /data/environment.sh

grep -q '^MEGARETH_ROLLUP_SEQUENCER=' /data/environment.sh \
  && sed -i "s|^MEGARETH_ROLLUP_SEQUENCER=.*|MEGARETH_ROLLUP_SEQUENCER=$MEGARETH_ROLLUP_SEQUENCER|" /data/environment.sh \
  || echo "MEGARETH_ROLLUP_SEQUENCER=$MEGARETH_ROLLUP_SEQUENCER" >> /data/environment.sh
