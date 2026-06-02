#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /private/artifact-bucket-key.json ]]; then
    echo "Could not find /private/artifact-bucket-key.json required file"
    exit 1
fi

# Initialize
if [[ ! -f /data/initialized ]]; then
    # Create needed folders
    mkdir -p /data/snapshot /data/node/logs

    # Login to gcloud
    gcloud auth activate-service-account --key-file=/private/artifact-bucket-key.json

    gcloud storage cp gs://megaeth-public-node-packages/v2.0.18/megaeth-rpc-v2.0.18.tar.gz /data/snapshot
    tar xf /data/snapshot/megaeth-rpc-v2.0.18.tar.gz -C /data/snapshot

    chmod +x /data/snapshot/megaeth-rpc-v2.0.18/rpc-node-v2.0.18
fi

# Setup env file
cp "/data/snapshot/megaeth-rpc-v2.0.18/${NETWORK}/environment.sh" /private/environment.sh

grep -q '^MEGARETH_MAX_LOAD=' /private/environment.sh \
  && sed -i "s/^MEGARETH_MAX_LOAD=.*/MEGARETH_MAX_LOAD=$MEGARETH_BOOTSTRAP_POLICY/" /private/environment.sh \
  || echo "MEGARETH_MAX_LOAD=$MEGARETH_BOOTSTRAP_POLICY" >> /private/environment.sh

grep -q '^MEGARETH_ROLLUP_SEQUENCER=' /private/environment.sh \
  && sed -i "s/^MEGARETH_ROLLUP_SEQUENCER=.*/MEGARETH_ROLLUP_SEQUENCER=$MEGARETH_ROLLUP_SEQUENCER/" /private/environment.sh \
  || echo "MEGARETH_ROLLUP_SEQUENCER=$MEGARETH_ROLLUP_SEQUENCER" >> /private/environment.sh

# Download snapshot itself
gcloud storage cp gs://megaeth-public-mainnet-snapshots/archive-snapshot-7141079.tar .


