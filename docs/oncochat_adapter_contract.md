# Deployment Adapter Contract

This document describes the boundary a later orchestration layer must honor; it
does not modify or configure OncoChat.

## Accepted request

- Validate against `schemas/adapter_interface.yml` before staging files.
- Materialize one approved, pre-normalized continuous matrix and aligned sample
  metadata under read-only `/data`.
- Pass an explicit allowed `input_data_type`; never pass `auto` or raw counts.
- Supply only declared Limma arguments and a new `/output` directory.

## Execution boundary

- Invoke the approved standalone image by immutable digest:
  `ghcr.io/nidap-community/limma-analysis@sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2`.
- Do not expose database credentials, cloud credentials, host paths, or arbitrary
  shell arguments to the container.
- Do not provide network-dependent scientific inputs during execution.

## Completion boundary

- Treat a run as successful only when the process exits zero and
  `/output/run_manifest.json` reports `status: completed` and `exit_status: 0`.
- Consume adapter-owned paths under `tables/`, `figures/`, and `logs/`.
- Keep `tables/Batch_Corrected_Expression.csv`, when requested, separate from
  inferential `tables/Limma_Analysis.csv`.

The cell-type collection to L2P Multi workflow is explicitly out of scope for
this adapter version. Database mapping and deployment remain separate approval
gates.
