# Container Use

The approved Linux/AMD64 application image is:

```text
ghcr.io/nidap-community/limma-analysis@sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2
```

Use the immutable digest for execution. `v1.0.0` and `latest` are convenience
tags that resolved to this digest at publication.

```bash
bash container/run_docker.sh \
  ghcr.io/nidap-community/limma-analysis@sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2 \
  ./input ./results \
  --matrix /data/matrix.tsv --metadata /data/metadata.tsv \
  --gene_names_column GeneName --sample_names_column Sample \
  --contrast_variable_columns Group --contrasts B-A \
  --input_data_type normalized_bulk_expression --output_dir /output
```
