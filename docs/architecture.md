# Architecture

`scripts/run_limma_analysis.R` and `R/OMIX_Limma_Analysis.R` are byte-preserved
canonical OMIX science. `entrypoint.R` is the application boundary: it invokes
the CLI unchanged and copies completed artifacts into a stable result bundle.
It does not transform the expression matrix or alter model settings.

The immutable base image is recorded in `OMIX_MODULE_SOURCE.md`. An adapter
must stage a declared continuous matrix and aligned metadata under `/data`; the
container writes only to `/output`.
