# Architecture

```text
declared continuous matrix + aligned metadata
                │
                ▼
      entrypoint.R (adapter-only validation)
                │
                ▼
scripts/run_limma_analysis.R (byte-preserved canonical CLI)
                │
                ▼
R/OMIX_Limma_Analysis.R (byte-preserved canonical science)
                │
                ▼
canonical artifacts + stable tables/, figures/, logs/, metadata, manifest
```

`scripts/run_limma_analysis.R`, `R/OMIX_Limma_Analysis.R`,
`schemas/interface.yml`, and `module.yml` are byte-preserved from the recorded
OMIX commit. `entrypoint.R` is the application boundary only: it validates the
declared type and exact sample alignment, invokes the canonical CLI unchanged,
then writes stable copies and provenance after success. It never transforms the
matrix, infers assay type, or changes model settings.

The adapter-specific contract is in `schemas/adapter_interface.yml`. The
immutable AMD64 base image and canonical file hashes are recorded in
`OMIX_MODULE_SOURCE.md`. Inputs are mounted read-only at `/data`; results are
written only to `/output`.

The canonical collection entrypoint and L2P Multi workflow are intentionally
outside this architecture and require a separate adapter release.
