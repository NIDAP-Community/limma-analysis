# Limma Analysis

Portable continuous-matrix Limma component derived from canonical OMIX Limma
Analysis. Raw counts are not accepted; supply an explicitly declared normalized
or score-matrix artifact with aligned metadata.

## Status

Local candidate only. It has passed a synthetic continuous-expression container
smoke test but is not published or OncoChat-enabled.

## Input and output

Stage a declared continuous matrix and aligned metadata read-only under `/data`.

```bash
docker run --rm --platform linux/amd64 \
  -v "$PWD/input:/data:ro" -v "$PWD/results:/output" \
  limma-analysis:local \
  --matrix /data/matrix.tsv --metadata /data/metadata.tsv \
  --gene_names_column GeneName --sample_names_column Sample \
  --contrast_variable_columns Group --contrasts B-A \
  --input_data_type normalized_bulk_expression --output_dir /output
```

The root output retains `Limma_Analysis.csv`, `Sample_Metadata.csv`, variance
diagnostics, and `run_summary.txt`. The adapter additionally provides stable
copies under `tables/`, `figures/`, and `logs/`, with `RUN_METADATA.md` and
`run_manifest.json` for orchestration.
