# ml-intern — Claude Code plugin

[![Version](https://img.shields.io/github/v/tag/toqitahamid/ml-intern-plugin?label=version&color=blue)](https://github.com/toqitahamid/ml-intern-plugin/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#prerequisites)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

Autonomous ML research agent for Claude Code. Adds a skill that crawls
ML literature, audits HF datasets, writes pre-flight-validated training
scripts, and submits to your HPC. Based on the
[ml-intern agent by Hugging Face](https://github.com/huggingface/ml-intern).

## Prerequisites

- macOS or Linux (Windows PR welcome)
- Python ≥3.11
- [`uv`](https://docs.astral.sh/uv/): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Claude Code with plugin support

## Install

```
/plugin marketplace add toqitahamid/ml-intern-plugin
/plugin install ml-intern@ml-intern-plugin
/reload-plugins
```

The first `/mcp` check may time out while `uv` creates the Python venv
(~10–30s). Run `/mcp` again and it will connect.

## Set up tokens

Add to `~/.zshrc` or `~/.bashrc`, then restart Claude Code:

```bash
export HF_TOKEN="hf_..."         # https://huggingface.co/settings/tokens
export GITHUB_TOKEN="ghp_..."    # https://github.com/settings/tokens (public_repo)
```

Without tokens, HF tools rate-limit on public data and fail on gated
content; GitHub tools rate-limit after a handful of calls.

## Try it

Dataset inspection:

```
/ml-intern find a small image-classification dataset on Hugging Face and show me its schema
```

Research workflow:

```
/ml-intern plan a SFT recipe for a 3B model on a reasoning benchmark — start from the literature
```

HPC script generation:

```
/ml-intern write a SLURM sbatch script for a 7B SFT run on 4x A100 with Trackio logging
```

The skill auto-triggers on plain ML prompts too; the slash command is
the explicit escape hatch.

## What's inside

- **`ml-intern` skill** — research-first workflow, tuned for HPC
  submission via SLURM or PBS. No HF Jobs, no remote sandbox.
- **10 MCP tools** (7 HF, 3 GitHub): `explore_hf_docs`, `fetch_hf_docs`,
  `find_hf_api`, `hf_inspect_dataset`, `hf_repo_files`, `hf_repo_git`,
  `hf_papers`, `github_find_examples`, `github_list_repos`,
  `github_read_file`.
- **Hugging Face MCP server** — included; authenticates via OAuth on
  first use.
- **`/ml-intern`** — force-activates the skill for a turn.
- **`/ml-intern-doctor`** — diagnoses install and env issues.

## Troubleshooting

Run `/ml-intern-doctor` — it prints a ✓/✗ table for uv, Python, venv,
tokens, and MCP server health.

<details>
<summary>Common fixes</summary>

**`/mcp` shows `ml_intern_tools` failed.** On first install, wait 30
seconds and retry. If it still fails, `uv` is either missing (run
`command -v uv`) or not on Claude Code's PATH — symlink it into
`~/.local/bin`.

**401 / rate-limit errors.** Tokens missing. Set them in your shell
profile and restart Claude Code.

**Broke after a plugin update.** Stale venv:
`rm -rf ~/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/.venv`,
then `/mcp`.

</details>

## Development

```bash
git clone https://github.com/toqitahamid/ml-intern-plugin
cd ml-intern-plugin
uv sync --extra dev
uv run pytest
```

## Contributing

Issues and PRs welcome at
[github.com/toqitahamid/ml-intern-plugin](https://github.com/toqitahamid/ml-intern-plugin).
Highest-value contributions: Windows support (a `scripts/run-mcp.cmd`
sibling of the POSIX launcher), bug reports, and skill-prompt
refinements.

## Changelog & license

- Release history: [CHANGELOG.md](CHANGELOG.md)
- License: MIT — see [LICENSE](LICENSE)
