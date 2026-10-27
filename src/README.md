# Source Layout

The scientific implementation intentionally remains in the canonical-style
`R/` and `scripts/` directories so its path and bytes match OMIX exactly.
There is no repository-local scientific `src/` fork. Standalone adapter logic
lives in the root `entrypoint.R`; its boundary is described in
`schemas/adapter_interface.yml` and `docs/architecture.md`.
