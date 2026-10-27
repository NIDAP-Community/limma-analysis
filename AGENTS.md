# Limma Analysis Contributor Guide

## Scope

This repository is a standalone adapter for the **primary continuous-matrix**
interface of canonical `OMIX-Limma-Analysis`. The cell-type collection entrypoint
and its L2P Multi workflow are deliberately out of scope.

## Source boundary

Do not edit `R/OMIX_Limma_Analysis.R`, `scripts/run_limma_analysis.R`,
`schemas/interface.yml`, or `module.yml` for standalone behavior. They are
byte-preserved canonical files verified in CI. Implement adapter behavior only
in `entrypoint.R`, `schemas/adapter_interface.yml`, container helpers, tests,
and documentation. Update `OMIX_MODULE_SOURCE.md` when synchronizing to a new
canonical OMIX commit.

## Runtime boundary

The container accepts declared files under read-only `/data` and writes only to
`/output`. It must not require database credentials, host paths, network data,
or shell evaluation. It is pinned to the documented AMD64 runtime digest.

## Verification

Run these after changes:

```bash
Rscript --vanilla -e 'parse(file = "entrypoint.R")'
container/build_docker.sh limma-analysis:local
container/smoke_test.sh limma-analysis:local
container/parity_test.sh limma-analysis:local
bash tests/test_adapter_contract.sh limma-analysis:local
```

Do not publish an OCI image, create a GitHub release/tag, or modify OncoChat
without explicit approval.
