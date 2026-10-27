# Container Contract

The Limma adapter accepts scientific inputs only through read-only `/data` and
writes results only through writable `/output`.

| Property | Contract |
| --- | --- |
| Runtime | AMD64 `omix-r-statistics` pinned by digest in `container/Dockerfile` |
| Scientific inputs | Explicit files mounted at `/data` |
| Results | A new or empty `/output` directory |
| Network | No network-dependent scientific inputs at execution time |
| Credentials | No database, cloud, or OncoChat credentials accepted or embedded |
| Command surface | Declared Limma CLI arguments only; no arbitrary shell execution |

The image is not yet published. A later approved publication must record an
immutable application image digest before it is invoked by any deployment.
