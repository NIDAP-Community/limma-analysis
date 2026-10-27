#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp -d "${TMPDIR:-/tmp}/limma-smoke.XXXXXX")"
bash "${root}/container/run_docker.sh" "${1:-limma-analysis:local}" "${root}/test_data" "${out}" --matrix /data/matrix.tsv --metadata /data/metadata.tsv --gene_names_column GeneName --sample_names_column Sample --contrast_variable_columns Group --contrasts B-A --input_data_type normalized_bulk_expression --output_dir /output
for file in Limma_Analysis.csv Sample_Metadata.csv Variance_Diagnostic.csv variance_diagnostic.png run_summary.txt; do test -s "${out}/${file}" || exit 1; done
for file in tables/Limma_Analysis.csv tables/Sample_Metadata.csv tables/Variance_Diagnostic.csv figures/variance_diagnostic.png logs/run_summary.txt logs/sessionInfo.txt RUN_METADATA.md run_manifest.json; do test -s "${out}/${file}" || exit 1; done
grep -q '"status": "completed"' "${out}/run_manifest.json"
grep -q '"exit_status": 0' "${out}/run_manifest.json"
printf 'Limma container smoke test passed: %s\n' "${out}"
