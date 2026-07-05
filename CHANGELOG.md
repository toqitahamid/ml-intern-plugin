# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] — 2026-07-05

### Changed

- **Flash-attention guidance synced with upstream** (huggingface/ml-intern
  #204/#331). The skill previously told the agent to install `flash-attn`;
  it now instructs the opposite: never compile `flash-attn` or use
  `attn_implementation="flash_attention_2"` — load prebuilt Hub kernels
  via the HF `kernels` library (e.g.
  `attn_implementation="kernels-community/flash-attn2"`), Ampere-or-newer
  GPUs only.
- **New skill pitfall: stale preinstalled packages.** Explicitly install
  or upgrade the core stack (`torch`, `transformers`, `trl`, `accelerate`,
  `datasets`, `trackio`, `kernels~=0.12.0`) and print versions before
  model loading.
- **Fail-fast requirements for training scripts** in the pre-flight
  check: version prints, dataset-column asserts, placeholder asserts,
  `push_to_hub`/`hub_model_id` asserts.
- **Exact-source submission rule.** Submit the exact validated script —
  never reconstruct a similar script from memory after testing.
- **`explore_hf_docs` kernels description** synced with upstream: loads
  prebuilt compute kernels from the Hub via `attn_implementation`.

## [0.1.1] — 2026-04-24

### Fixed

- **Hugging Face MCP server now appears in `/mcp`.** The `.mcp.json`
  entry used `"transport": "http"` but Claude Code expects `"type": "http"`;
  the server was silently dropped during schema validation. Corrected.
- **Plugin manifest validation.** `plugin.json` previously declared
  `"author"` as a string; CC's schema requires an object. Converted to
  `{"name": "toqitahamid"}` and added `homepage`, `repository`, `license`.
- **MCP server PATH resolution on macOS GUI launches.** Replaced
  `"command": "uv"` with `"command": "sh"` + a wrapper script at
  `scripts/run-mcp.sh` that augments PATH with `~/.local/bin`,
  `~/.cargo/bin`, and common Homebrew locations. GUI-launched Claude
  Code could not find `uv` otherwise.

### Added

- **`/ml-intern-doctor` slash command.** Runs seven diagnostics (`uv`,
  Python, venv, both tokens, MCP server) and prints a ✓/✗ table with
  one-line fixes per failure.
- **First-run progress logging.** The wrapper script now writes a
  `[ml-intern] first-run: installing Python deps...` line to stderr
  while creating the venv, so users see progress instead of a silent
  timeout.
- **Missing-`uv` error message.** The wrapper detects `uv` absence and
  prints installation instructions (curl, Homebrew, pipx) to stderr
  before exiting.
- **`uv.lock` committed.** Deterministic and faster first installs.
- **Troubleshooting section** in the README covering the four most
  common failure modes, each with a one-line fix.
- **LICENSE file.** MIT. Previously the repo declared MIT in
  `plugin.json` but had no LICENSE file.
- **Usage examples.** Three concrete starter prompts in the README.

### Changed

- **README restructured for production readiness.** Prerequisites now
  precede the install block; platform support (macOS / Linux) stated
  up front; Windows flagged as not yet supported; contributing section
  added.
- **`/ml-intern-doctor` uses a version-agnostic glob** for the plugin
  cache path, so no edit is needed on future version bumps.

## [0.1.0] — 2026-04-24

### Added

- Initial public release.
- `ml-intern` skill (adapted from the standalone agent's
  `system_prompt_v3`) with HPC-oriented workflow (SLURM/PBS replaces
  HF Jobs; no remote sandbox).
- `/ml-intern` slash command to force-activate the skill.
- Stdio MCP server `ml_intern_tools` exposing 10 vendored tools:
  `explore_hf_docs`, `fetch_hf_docs`, `find_hf_api`, `hf_inspect_dataset`,
  `hf_repo_files`, `hf_repo_git`, `hf_papers`, `github_find_examples`,
  `github_list_repos`, `github_read_file`.
- Hugging Face MCP server (`huggingface.co/mcp`) declared in the
  plugin's MCP config for automatic wiring.
- 14-test suite covering vendored-module imports, MCP tool
  registration, and skill ↔ registry name parity.
- Marketplace manifest (`.claude-plugin/marketplace.json`) so the
  plugin is installable via `/plugin marketplace add` +
  `/plugin install`.

[Unreleased]: https://github.com/toqitahamid/ml-intern-plugin/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/toqitahamid/ml-intern-plugin/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/toqitahamid/ml-intern-plugin/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/toqitahamid/ml-intern-plugin/releases/tag/v0.1.0
