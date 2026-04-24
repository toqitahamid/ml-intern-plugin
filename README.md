# ml-intern — Claude Code plugin

Autonomous ML research agent for Claude Code. Gives CC the `ml-intern`
workflow: research-first (literature crawl, methodology extraction), data
audit, pre-flight validated training scripts, and HPC-ready submission
patterns.

Based on the standalone [ml-intern agent](https://github.com/toqitahamid/ml-intern).

## Install

```
/plugin install github:toqitahamid/ml-intern-plugin
/reload-plugins
```

Then confirm:

```
/plugin    # should list "ml-intern" with 1 skill, 1 command, 2 MCP servers
/mcp       # should show 10 tools under ml_intern_tools
```

### Prerequisites

- **Python ≥3.11** and **`uv`** — the plugin's MCP server runs via
  `uv run`. Install `uv` from https://docs.astral.sh/uv/.
- **Claude Code** with plugin support (latest version recommended).

### Alternative: local install (for development)

```
git clone https://github.com/toqitahamid/ml-intern-plugin
/plugin install /absolute/path/to/ml-intern-plugin
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

### What happens without them

| Missing | Effect |
| --- | --- |
| `HF_TOKEN` | Public HF data works but is rate-limited; private/gated datasets and models fail with 401 |
| `GITHUB_TOKEN` | GitHub search capped at 10 req/min — two literature-search turns will rate-limit you |
| Both | HF MCP server's first call triggers an OAuth dialog in CC for HF auth; GitHub tools still fail |

## Usage

- **Auto-triggers** on ML tasks: "train a model", "fine-tune", "find a
  dataset on HF", "plan a DPO recipe", etc.
- **Force-activate** with `/ml-intern <prompt>` for ambiguous prompts.

## What's inside

- **Skill** with the `ml-intern` persona and workflow (adapted from the
  standalone agent's `system_prompt_v3`).
- **MCP server** exposing 10 HF and GitHub tools:
  `explore_hf_docs`, `fetch_hf_docs`, `find_hf_api`, `hf_inspect_dataset`,
  `hf_repo_files`, `hf_repo_git`, `hf_papers`, `github_find_examples`,
  `github_list_repos`, `github_read_file`.
- **Hugging Face MCP server** (`huggingface.co/mcp`) wired in automatically.

## Design choices

- **No HF Jobs, no remote sandbox.** The skill is written for users running
  compute on their own HPC (SLURM / PBS) via Bash. If you want HF Jobs, use
  the official [huggingface-skills](https://github.com/huggingface/huggingface-skills)
  plugin alongside this one.
- **No duplication with Claude Code natives.** The plugin does not ship
  file-read, file-edit, shell, plan, or subagent tools — CC already provides
  those. The skill tells the model to use CC's native `Read`, `Edit`,
  `Write`, `Bash`, `TaskCreate`, and `Agent` for the appropriate work.

## Development

```bash
git clone https://github.com/toqitahamid/ml-intern-plugin
cd ml-intern-plugin
uv sync --extra dev
uv run pytest
```

14 tests cover vendored imports, MCP tool registration, and
skill ↔ registry parity.

## License

Matches the upstream ml-intern project license.
