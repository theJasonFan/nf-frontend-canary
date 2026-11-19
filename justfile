set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Publish a GitHub release of the pushed HEAD, named <nextflow version>_<YYYYMMDD>_<short hash>.
release:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "The working tree has changes. Commit or stash them first." >&2
        exit 1
    fi
    git fetch --quiet origin
    commit=$(git rev-parse HEAD)
    if [[ "$(git rev-parse '@{upstream}')" != "${commit}" ]]; then
        echo "HEAD is not on the remote branch. Push it first." >&2
        exit 1
    fi
    nextflow_version=$(sed -nE "s/^ *nextflowVersion *= *'>=([0-9.]+)'.*/\1/p" nextflow.config)
    if [[ -z "${nextflow_version}" ]]; then
        echo "nextflow.config needs nextflowVersion = '>=<version>'." >&2
        exit 1
    fi
    name="${nextflow_version}_$(date -u +%Y%m%d)_$(git rev-parse --short=7 HEAD)"
    gh release create "${name}" --target "${commit}" --title "${name}" \
        --notes "Requires Nextflow ${nextflow_version} or later."
