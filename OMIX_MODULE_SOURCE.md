# Canonical OMIX Source Record

This repository exports the primary continuous-matrix Limma interface from
[`OMIX-Limma-Analysis`](https://github.com/NIDAP-Community/OMIX/tree/68d4811323e2dd997208076dd398cc9d68dae5a1/modules/OMIX-Limma-Analysis).
The adapter invokes the canonical primary CLI without changing its scientific
implementation.

| Field | Recorded value |
| --- | --- |
| Canonical OMIX commit | `68d4811323e2dd997208076dd398cc9d68dae5a1` |
| Module version / interface | `1.2.0` / `3` |
| Module state | `active` |
| Canonical primary CLI | `scripts/run_limma_analysis.R` |
| Pinned AMD64 runtime | `ghcr.io/nidap-community/omix-r-statistics@sha256:1325722877fec5167d171aa766ddf7bbfd056e4999bf40fd8c1eabee495da667` |

## Byte-preserved canonical files

| File | SHA-256 |
| --- | --- |
| `R/OMIX_Limma_Analysis.R` | `c7afa223d1d0cf4ba7a73ed06d8d1c60e191a137a4c01a71671fe585fec8c69a` |
| `scripts/run_limma_analysis.R` | `954587f5e3b30f18370f4340e5f63bf8e2833902a5de2cf2b0b68396502a22d6` |
| `schemas/interface.yml` | `bebaf35ecc35fb257f9eff098c3d45d1879dcd6cea992c07dc80106d12e7d5ee` |
| `module.yml` | `b0d994117f1b57dffe6ccf1ef68c6817d41d235e243c9c4818f5bde51cd59dd9` |

The adapter-specific validation boundary is declared separately in
[`schemas/adapter_interface.yml`](schemas/adapter_interface.yml). It requires
an explicit supported continuous `input_data_type`, exact matrix-to-metadata
sample alignment, and never infers assay type from values or transforms the
matrix.

## Intentional scope boundary

This export supports **only** the primary continuous-matrix Limma entrypoint.
The canonical cell-type collection entrypoint (`run_limma_cell_type_collection.R`)
and the cell-type collection to L2P Multi workflow are neither exported nor
runnable here. They require a separate, versioned extension with its own
interface, fixtures, parity evidence, and release decision.

No standalone OCI image has been published and no GitHub release or tag has
been created for this repository. Those are separate approval-gated steps.
