# ml-intern — Claude Code plugin

[![Version](https://img.shields.io/github/v/tag/toqitahamid/ml-intern-plugin?label=version&color=blue)](https://github.com/toqitahamid/ml-intern-plugin/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#prerequisites)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-orange.svg)](https://docs.claude.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

Autonomous ML research agent for Claude Code. Gives CC the `ml-intern`
workflow: research-first (literature crawl, methodology extraction), data
audit, pre-flight validated training scripts, and HPC-ready submission
patterns.

Based on the standalone [ml-intern agent by Hugging Face](https://github.com/huggingface/ml-intern).

**Platforms:** macOS and Linux. Windows is not yet supported (the MCP
launcher is a POSIX shell script). See [Issues](https://github.com/toqitahamid/ml-intern-plugin/issues)
if you want to help add Windows support.

## Prerequisites

- **Python ≥3.11** — uv will download it if your system Python is older.
- **[uv](https://docs.astral.sh/uv/)** — manages the plugin's Python venv
  and dependencies. Install with:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh    # macOS/Linux
  # or: brew install uv
  ```
- **Claude Code** with plugin support (current stable works).

## Install

Claude Code installs plugins from a marketplace, so installation is two
steps: add the marketplace, then install the plugin.

```
/plugin marketplace add toqitahamid/ml-intern-plugin
/plugin install ml-intern@ml-intern-plugin
/reload-plugins
```

Confirm:

```
/plugin    # should list "ml-intern" with 1 skill, 1 command, 2 MCP servers
/mcp       # should show 10 tools under ml_intern_tools, and hf-mcp-server
```

### First-run note

On your **first** `/mcp` attempt after install, you may see:

```
Failed to reconnect to plugin:ml-intern:ml_intern_tools
```

This is expected. The plugin's MCP server runs under `uv`, and the first
launch needs ~10–30 seconds to create a Python venv and install
dependencies. Claude Code's MCP connection timeout is shorter than that,
so the first attempt may time out. Progress messages are written to
Claude Code's MCP log during the wait.

**Fix:** wait ~30 seconds, then run `/mcp` again (or restart Claude Code).
From then on the server starts in under a second.

To pre-warm manually (optional):

```bash
cd "$(ls -dt ~/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/ | head -1)"
uv sync
```

### Alternative: local install (for development)

```
git clone https://github.com/toqitahamid/ml-intern-plugin
/plugin marketplace add /absolute/path/to/ml-intern-plugin
/plugin install ml-intern@ml-intern-plugin
/reload-plugins
```

## Environment setup

Two tokens are required for the plugin's tools to work without
rate-limiting or auth errors.

### 1. Get the tokens

- **`HF_TOKEN`** — create at https://huggingface.co/settings/tokens
  - Type: **Fine-grained** (recommended) or **Read** token
  - Scopes: `Read access to contents of all public gated repos` is enough
    for most workflows; add `Write` only if you intend to push
    models/datasets
- **`GITHUB_TOKEN`** — create at https://github.com/settings/tokens
  - Type: **Classic PAT** or **Fine-grained**
  - Scopes: only `public_repo` is needed for ML code search

### 2. Set them in your shell profile

Add to `~/.zshrc` (macOS default) or `~/.bashrc`:

```bash
export HF_TOKEN="hf_xxxxxxxxxxxxxxxxxxxx"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
```

Reload your shell:

```bash
source ~/.zshrc   # or: source ~/.bashrc
```

Restart Claude Code after setting the tokens — it reads env at launch.

### Hugging Face MCP first-use

The first time any `hf-mcp-server` tool is called, Claude Code opens an
OAuth browser window for huggingface.co. Sign in and grant access; it's
a one-time flow.

### What happens without tokens

| Missing | Effect |
| --- | --- |
| `HF_TOKEN` | Public HF data works but is rate-limited; private/gated datasets and models fail with 401 |
| `GITHUB_TOKEN` | GitHub search capped at 10 req/min — two literature-search turns will rate-limit you |
| Both | HF MCP server's OAuth dialog still handles HF auth; GitHub tools still fail |

## Usage

- **Auto-triggers** on ML tasks: "train a model", "fine-tune", "find a
  dataset on HF", "plan a DPO recipe", etc.
- **Force-activate** with `/ml-intern <prompt>` for ambiguous prompts.
- **Diagnose** anything broken with `/ml-intern-doctor`.

### Try it

After install + tokens + restart, paste one of these into Claude Code:

```
/ml-intern find a small image-classification dataset on Hugging Face and show me its schema and one sample row
```

```
/ml-intern plan a SFT recipe for a 3B model on a reasoning benchmark. Start from the literature — find the landmark paper, crawl its citations, extract the best dataset and training method
```

```
/ml-intern write a SLURM sbatch script for a 7B SFT run on a100x4 with trackio logging and push_to_hub enabled
```

Expected behavior: the skill auto-activates (look for "ml-intern" in
CC's skill bar), calls the plugin's tools in the order the workflow
prescribes, and produces a concrete result — not a plan for what it
*would* do.

## What's inside

- **Skill** — `ml-intern` persona and workflow, adapted from the
  standalone agent's `system_prompt_v3`.
- **Slash commands** — `/ml-intern` (force-activate), `/ml-intern-doctor`
  (diagnose install/env issues).
- **MCP server** exposing 10 tools (7 HF + 3 GitHub):
  `explore_hf_docs`, `fetch_hf_docs`, `find_hf_api`, `hf_inspect_dataset`,
  `hf_repo_files`, `hf_repo_git`, `hf_papers`, `github_find_examples`,
  `github_list_repos`, `github_read_file`.
- **Hugging Face MCP server** (`huggingface.co/mcp`) wired in
  automatically.

## Design choices

- **No HF Jobs, no remote sandbox.** The skill is written for users
  running compute on their own HPC (SLURM / PBS) via Bash. If you want
  HF Jobs, use the official
  [huggingface-skills](https://github.com/huggingface/huggingface-skills)
  plugin alongside this one.
- **No duplication with Claude Code natives.** The plugin does not ship
  file-read, file-edit, shell, plan, or subagent tools — CC already
  provides those. The skill tells the model to use CC's native `Read`,
  `Edit`, `Write`, `Bash`, `TaskCreate`, and `Agent` for the
  appropriate work.

## Troubleshooting

Run `/ml-intern-doctor` inside Claude Code at any time. It checks `uv`,
Python, the venv, both tokens, and the MCP server, then prints a table
of ✓/✗ with one-line fixes.

**`/mcp` shows `ml_intern_tools` as failed**

1. First-install: the venv is still being created. Wait ~30 seconds and
   run `/mcp` again.
2. `uv` is not installed. The plugin's wrapper script prints install
   instructions to stderr — see CC's MCP log, or run
   `command -v uv && uv --version` in a terminal to confirm.
3. `uv` is installed but not on the PATH Claude Code inherits. The
   wrapper already adds `~/.local/bin`, `~/.cargo/bin`, Homebrew
   locations. If your uv is elsewhere, symlink it into `~/.local/bin`.

**Tools return 401 or rate-limit errors**

Tokens are missing or not inherited by Claude Code. See
[Environment setup](#environment-setup). Remember: CC reads env at
launch — set the vars, then restart Claude Code.

**MCP server was healthy, then broke after a plugin update**

The cached venv may be stale for the new dep set. Fix:

```bash
rm -rf ~/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/.venv
```

Then run `/mcp` — the wrapper will recreate the venv on next launch.

**Plugin stops working after a Claude Code restart**

Check that `uv` is still installed (`command -v uv`) and that the tokens
are still in your shell profile. CC inherits env from your login shell
at launch time.

## Development

```bash
git clone https://github.com/toqitahamid/ml-intern-plugin
cd ml-intern-plugin
uv sync --extra dev
uv run pytest
```

14 tests cover vendored imports, MCP tool registration, and
skill ↔ registry parity.

## Contributing

Issues and PRs welcome at
[github.com/toqitahamid/ml-intern-plugin](https://github.com/toqitahamid/ml-intern-plugin).
Especially valuable:

- Windows support (a `scripts/run-mcp.cmd` equivalent of `run-mcp.sh`)
- Reports of failure modes not covered in [Troubleshooting](#troubleshooting)
- Skill prompt improvements (tuned from real usage)

## Changelog

Release history is maintained in [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE](LICENSE) for the full text.
