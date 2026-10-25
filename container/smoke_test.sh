#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp -d "${TMPDIR:-/tmp}/limma-smoke.XXXXXX")"
docker run --rm --platform linux/amd64 --user "$(id -u):$(id -g)" --mount "type=bind,src=${root}/test_data,dst=/data,readonly" --mount "type=bind,src=${out},dst=/output" "${1:-limma-analysis:local}" --matrix /data/matrix.tsv --metadata /data/metadata.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts B-A --input_data_type normalized_bulk_expression --output_dir /output
for file in Limma_Analysis.csv Sample_Metadata.csv Variance_Diagnostic.csv variance_diagnostic.png run_summary.txt; do test -s "${out}/${file}" || exit 1; done
printf 'Limma container smoke test passed: %s\n' "${out}"
