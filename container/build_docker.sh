#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
vcs_ref="$(git -C "${root}" rev-parse HEAD)"
build_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
docker buildx build --file "${root}/container/Dockerfile" --load --platform linux/amd64 --tag "${1:-limma-analysis:local}" --build-arg "VCS_REF=${vcs_ref}" --build-arg "BUILD_DATE=${build_date}" "${root}"
