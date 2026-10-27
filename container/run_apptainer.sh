#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 4 ]]; then
  printf '%s\n' 'Usage: container/run_apptainer.sh <image.sif> <data_dir> <output_dir> <workflow> [Limma arguments]' >&2
  exit 2
fi

image="$1"
data_dir="$2"
output_dir="$3"
workflow="$4"
shift 4
test -f "${image}" || { printf 'Image file does not exist: %s\n' "${image}" >&2; exit 2; }
test -d "${data_dir}" || { printf 'Input directory does not exist: %s\n' "${data_dir}" >&2; exit 2; }
case "${workflow}" in
  primary) ;;
  *) printf '%s\n' 'Only the primary continuous-matrix workflow is supported by this adapter.' >&2; exit 2 ;;
esac
if command -v apptainer >/dev/null 2>&1; then runtime="apptainer"
elif command -v singularity >/dev/null 2>&1; then runtime="singularity"
else printf '%s\n' 'Neither apptainer nor singularity is available on PATH.' >&2; exit 127
fi
mkdir -p "${output_dir}"
data_dir="$(CDPATH= cd -- "${data_dir}" && pwd -P)"
output_dir="$(CDPATH= cd -- "${output_dir}" && pwd -P)"
exec "${runtime}" exec --cleanenv \
  --bind "${data_dir}:/data:ro,${output_dir}:/output" \
  "${image}" "$@"
