#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 3 ]]; then
  printf '%s\n' 'Usage: container/run_docker.sh <image> <data_dir> <output_dir> [Limma arguments]' >&2
  exit 2
fi

image="$1"
data_dir="$2"
output_dir="$3"
shift 3
test -d "${data_dir}" || { printf 'Input directory does not exist: %s\n' "${data_dir}" >&2; exit 2; }
mkdir -p "${output_dir}"
data_dir="$(CDPATH= cd -- "${data_dir}" && pwd -P)"
output_dir="$(CDPATH= cd -- "${output_dir}" && pwd -P)"

exec docker run --rm \
  --platform "${DOCKER_PLATFORM:-linux/amd64}" \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=${data_dir},dst=/data,readonly" \
  --mount "type=bind,src=${output_dir},dst=/output" \
  "${image}" "$@"
