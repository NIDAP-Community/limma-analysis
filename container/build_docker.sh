#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
docker buildx build --file "${root}/container/Dockerfile" --load --platform linux/amd64 --tag "${1:-limma-analysis:local}" "${root}"
