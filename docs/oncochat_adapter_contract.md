# OncoChat Adapter Contract

Validate request fields against `schemas/interface.yml`, materialize only the
selected continuous-matrix and metadata artifacts under `/data`, and invoke a
released image by digest. Do not pass database credentials, host paths, or
arbitrary shell arguments into the container.

Use `run_manifest.json` only after a zero exit status. Application code should
use the adapter-owned `tables/`, `figures/`, and `logs/` paths. The database
mapping and release remain separate gates.
