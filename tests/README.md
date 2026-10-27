# Adapter contract tests

`test_adapter_contract.sh` verifies the standalone boundary before the canonical
CLI runs: `input_data_type` must be explicit and supported, a manifest declaring
raw counts is rejected, and matrix/metadata sample identifiers must match exactly.
It also verifies that failed requests do not create `run_manifest.json`.
