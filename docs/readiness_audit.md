# Primary Continuous-Matrix Adapter Readiness Audit

Audit date: 2026-10-27. This uses the workspace-level Standalone Application
Readiness Checklist and applies only to the primary continuous-matrix adapter.

| Checklist area | Status | Evidence / remaining work |
| --- | --- | --- |
| Canonical source | **Complete** | `OMIX_MODULE_SOURCE.md` records active OMIX module `1.2.0` / interface `3`, commit `68d4811323e2dd997208076dd398cc9d68dae5a1`, hashes, and runtime digest. CI byte-compares all four canonical files. |
| Preflight | **Complete** | Canonical module is `active`. |
| Repository shape | **Complete** | MIT license, README, changelog, source record, entrypoint, schemas, fixture, tests, helpers, architecture/decision/container/adapter/session/release documentation, lockfile, and CI are present. The named `src/` location documents the intentional canonical `R/` and `scripts/` source layout. |
| User experience | **Complete** | README documents purpose, inputs, controls, quick start, results, HPC wrapper, troubleshooting boundaries, a synthetic example, and the immutable application-image digest. |
| CLI and validation | **Complete** | Adapter preflight requires explicit continuous type, exact identifiers, finite numeric values, and a new/empty output directory; it does not infer/transform assays or evaluate shell text. |
| Result bundle | **Complete** | Successful runs write metadata, zero-exit manifest, session/log files, tables, variance figure, and exploratory-use disclaimer. Batch-corrected values are distinct from inference. |
| Container | **Complete** | Local Linux/AMD64 image uses the pinned base digest, runs non-root, has OCI labels, and supports read-only `/data` plus writable `/output`. |
| Local and parity validation | **Complete** | Local build, smoke, canonical parity, help, and adapter-contract tests passed on 2026-10-27. |
| Representative validation | **Partial** | Synthetic fixture output was generated and checked. No redistributable study example has been selected. |
| HPC portability | **Partial** | Apptainer/Singularity wrapper is supplied; target-HPC smoke evidence is not yet retained. |
| Registry and release | **Partial** | Linux/AMD64 `v1.0.0` and `latest` image tags were published at immutable digest `sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2`; source tag `v1.0.0` points to `8fe2cd7`. The versioned GitHub Release object remains pending re-authentication. |
| OncoChat handoff | **Complete** | `docs/oncochat_adapter_contract.md` defines staged artifacts, allowed request boundary, digest requirement, bundle collection, and provenance. |
| OncoChat integration | **Pending external integration** | Deliberately excluded from this task. |

## Scope confirmation

The canonical cell-type collection entrypoint and the collection to L2P Multi
workflow are excluded. A later extension must establish its own schema,
fixtures, parity evidence, container contract, and versioned release decision.
