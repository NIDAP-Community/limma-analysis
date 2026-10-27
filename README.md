# Limma Analysis

`limma-analysis` performs differential analysis of a **pre-normalized,
continuous feature-by-sample matrix** with the canonical
[OMIX Limma module](https://github.com/NIDAP-Community/OMIX/tree/68d4811323e2dd997208076dd398cc9d68dae5a1/modules/OMIX-Limma-Analysis).
It is suitable for normalized bulk expression, log2 microarray expression,
pathway scores, cell-fraction estimates, methylation M-values, copy-number
log2 ratios, and other declared continuous matrices. It is research software,
not clinical decision support.

The standalone adapter validates the input boundary, invokes the canonical
Limma CLI unchanged, and produces a portable result bundle. Canonical source
commit and file hashes are recorded in [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md).

## Scope

This release candidate provides only the primary continuous-matrix analysis.
It does **not** provide the canonical cell-type collection entrypoint or the
cell-type collection to L2P Multi workflow; those need a separate, versioned
extension.

## Inputs

Provide two aligned tables:

| Input | Requirement |
| --- | --- |
| Matrix | CSV, TSV, TXT, or RDS feature-by-sample matrix. It must contain a feature identifier column (default `GeneName`) followed only by finite numeric sample columns. |
| Metadata | CSV, TSV, TXT, or RDS sample metadata. It must contain a sample ID column (default `Sample`) matching the matrix sample columns exactly, without duplicates. |
| Input type | An explicit `--input_data_type` selected from [the adapter contract](schemas/adapter_interface.yml). |

Raw integer counts are rejected. This adapter does not determine whether values
look like counts, normalize them, or transform them: the declared data type is
the caller’s scientific contract. Use a count-aware workflow before calling
this adapter when starting from raw counts.

## Validated image

The approved `v1.0.0` Linux/AMD64 image was built from source commit
`8fe2cd7eea6f22cb14eabe78ff6b4f79d2ea5ef0`. Use its immutable digest for
reproducible execution:

```text
ghcr.io/nidap-community/limma-analysis@sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2
```

`v1.0.0` and `latest` are readable tags that resolved to this digest at
publication. A GitHub Release record is still pending account re-authentication.

## Build

The container uses an immutable AMD64 base image digest. Build a local image:

```bash
container/build_docker.sh limma-analysis:local
```

## Run

Place `matrix.tsv` and `metadata.tsv` in an input directory. The provided
helper mounts that directory read-only at `/data` and mounts a new output
directory at `/output`.

```bash
bash container/run_docker.sh limma-analysis:local ./input ./results \
  --matrix /data/matrix.tsv \
  --metadata /data/metadata.tsv \
  --gene_names_column GeneName \
  --sample_names_column Sample \
  --contrast_variable_columns Group \
  --contrasts B-A \
  --input_data_type normalized_bulk_expression \
  --output_dir /output
```

`--contrast_variable_columns` and `--contrasts` define the comparison. The
canonical command also supports covariates, paired designs, batch columns, and
other documented Limma options; view them with:

```bash
docker run --rm --platform linux/amd64 limma-analysis:local --help
```

## Results

The canonical result files remain at the output root for compatibility. Stable
copies make downstream use predictable:

```text
results/
├── tables/
│   ├── Limma_Analysis.csv             # inferential differential-analysis results
│   ├── Sample_Metadata.csv            # modeled sample metadata
│   ├── Variance_Diagnostic.csv
│   └── Batch_Corrected_Expression.csv # optional downstream matrix, not inference
├── figures/
│   └── variance_diagnostic.png
├── logs/
│   ├── run_summary.txt
│   └── sessionInfo.txt
├── RUN_METADATA.md
└── run_manifest.json
```

`run_manifest.json` is written only after the canonical CLI exits successfully.
When batch-corrected values are requested, they are deliberately kept separate
from `Limma_Analysis.csv`, because batch correction is a downstream matrix and
not a replacement for model-based inference.

### Synthetic fixture example

The small redistributable fixture in `test_data/` has three `A` and three `B`
samples. For the declared `B-A` contrast, its first three deliberately shifted
features are returned as follows:

| Feature | B-A log fold change | Adjusted p-value |
| --- | ---: | ---: |
| Gene1 | 1.9 | 3.37e-17 |
| Gene2 | 1.8 | 5.83e-17 |
| Gene3 | 1.7 | 1.44e-16 |

This is a synthetic validation fixture, not a biological finding. Its expected
output and visual inspection notes are recorded in
[docs/README_EXAMPLE_PROVENANCE.md](docs/README_EXAMPLE_PROVENANCE.md).

## Validate locally

```bash
container/smoke_test.sh limma-analysis:local
container/parity_test.sh limma-analysis:local
bash tests/test_adapter_contract.sh limma-analysis:local
```

The smoke test checks the complete result bundle. The parity test compares
canonical and adapter outputs on the same fixture. The contract test confirms
that undeclared types, raw-count manifests, and misaligned samples fail without
creating a success manifest.

## Troubleshooting

- **`--input_data_type is required` or `auto` is rejected:** state the known
  continuous assay type explicitly; the adapter will not guess it.
- **Raw-count manifest is rejected:** normalize counts in a count-aware workflow
  first, then provide the resulting declared continuous matrix.
- **Sample identifiers do not align:** make the metadata sample IDs exactly
  match the matrix sample columns, including spelling and uniqueness.
- **Output directory is not empty:** select a new output directory. This avoids
  confusing an earlier success manifest with the current run.

## HPC use

For Apptainer or Singularity, first build or obtain a local SIF from an
approved image, then use the same input/output layout:

```bash
bash container/run_apptainer.sh limma-analysis.sif ./input ./results primary \
  --matrix /data/matrix.tsv --metadata /data/metadata.tsv \
  --gene_names_column GeneName --sample_names_column Sample \
  --contrast_variable_columns Group --contrasts B-A \
  --input_data_type normalized_bulk_expression --output_dir /output
```

See [docs/container_contract.md](docs/container_contract.md) for the portable
runtime boundary and [docs/architecture.md](docs/architecture.md) for the
canonical/adapter separation.
