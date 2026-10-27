# Decision Log

| Decision | Rationale |
| --- | --- |
| Export the primary continuous-matrix CLI only | It is the active canonical interface and can be validated independently. |
| Preserve canonical scientific files byte-for-byte | Scientific behavior remains owned and versioned by OMIX. |
| Require `input_data_type` explicitly | Assay identity is scientific metadata; it must not be inferred from numeric values. |
| Reject raw counts | Limma’s continuous-matrix entrypoint must not silently become a count-normalization workflow. |
| Keep batch-corrected output separate | A corrected matrix supports downstream use but is not an inferential result table. |
| Exclude cell-type collection to L2P Multi | It has a distinct interface and needs its own versioned adapter, fixtures, and parity evidence. |
