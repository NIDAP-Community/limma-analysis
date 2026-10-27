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

## Validated application image

The approved Linux/AMD64 `v1.0.0` image was built from source commit
`8fe2cd7eea6f22cb14eabe78ff6b4f79d2ea5ef0`:

`ghcr.io/nidap-community/limma-analysis@sha256:83d73524eac2d346b329e20f4de5e7bb330c1be96a31a8afe331883280a193a2`

Use the digest for execution. The readable `v1.0.0` and `latest` tags are
convenience references only. The matching GitHub Release is published as `v1.0.0`.
