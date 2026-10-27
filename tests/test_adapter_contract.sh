#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
image="${1:-limma-analysis:local}"
work="$(mktemp -d "${TMPDIR:-/tmp}/limma-adapter-contract.XXXXXX")"
input="${work}/input"
mkdir -p "${input}"
cp "${root}/test_data/matrix.tsv" "${input}/matrix.tsv"
cp "${root}/test_data/metadata.tsv" "${input}/metadata.tsv"

expect_failure_without_manifest() {
  local name="$1"
  shift
  local output="${work}/${name}"
  if bash "${root}/container/run_docker.sh" "${image}" "${input}" "${output}" "$@"; then
    printf 'Expected %s to fail, but it succeeded.\n' "${name}" >&2
    exit 1
  fi
  test ! -e "${output}/run_manifest.json" || {
    printf 'Failed request %s created run_manifest.json.\n' "${name}" >&2
    exit 1
  }
}

base=(--matrix /data/matrix.tsv --metadata /data/metadata.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts B-A --output_dir /output)
expect_failure_without_manifest missing_type "${base[@]}"
expect_failure_without_manifest auto_type "${base[@]}" --input_data_type auto

printf 'matrix_type: raw_integer_counts\n' > "${input}/Pseudobulk_Manifest.dcf"
expect_failure_without_manifest raw_manifest "${base[@]}" --input_data_type normalized_bulk_expression --pseudobulk_manifest /data/Pseudobulk_Manifest.dcf

sed 's/^B3/NotInMatrix/' "${root}/test_data/metadata.tsv" > "${input}/metadata_misaligned.tsv"
expect_failure_without_manifest misaligned --matrix /data/matrix.tsv --metadata /data/metadata_misaligned.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts B-A --input_data_type normalized_bulk_expression --output_dir /output

# This passes preflight but fails inside the canonical CLI. A success manifest
# must still not exist when canonical Limma returns nonzero.
expect_failure_without_manifest canonical_failure --matrix /data/matrix.tsv --metadata /data/metadata.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts C-A --input_data_type normalized_bulk_expression --output_dir /output

# Batch-corrected values are retained as a distinct downstream matrix rather
# than being substituted for inferential Limma results.
awk 'BEGIN { FS=OFS="\t" } NR == 1 { print $0, "Batch"; next } { print $0, (NR % 2 == 0 ? "Batch1" : "Batch2") }' "${root}/test_data/metadata.tsv" > "${input}/metadata_batch.tsv"
batch_output="${work}/batch_output"
bash "${root}/container/run_docker.sh" "${image}" "${input}" "${batch_output}" --matrix /data/matrix.tsv --metadata /data/metadata_batch.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts B-A --batch_effect_columns Batch --return_batch_corrected_values true --input_data_type normalized_bulk_expression --output_dir /output
test -s "${batch_output}/tables/Limma_Analysis.csv"
test -s "${batch_output}/tables/Batch_Corrected_Expression.csv"
grep -q 'not inferential Limma results' "${batch_output}/run_manifest.json"

printf 'Limma adapter contract tests passed: %s\n' "${work}"
