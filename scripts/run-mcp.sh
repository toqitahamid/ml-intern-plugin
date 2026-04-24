#!/usr/bin/env bash
# Launches the ml-intern MCP server.
# Handles:
# - Claude Code's GUI launch PATH missing common tool locations (uv, python)
# - First-run venv creation via `uv sync` (transparent to CC)
# - Subsequent fast starts via `uv run --no-sync`

set -e

# Claude Code substitutes ${CLAUDE_PLUGIN_ROOT} with the installed plugin dir.
# If it isn't set (running manually), fall back to the script's grandparent.
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Augment PATH so uv / python are findable even when CC launches from a
# minimal environment (macOS GUI apps don't inherit the user's shell PATH).
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

cd "$PLUGIN_ROOT"

# First-run sync: create the venv and install deps if missing.
# Subsequent runs skip sync entirely (fast).
if [ ! -d ".venv" ]; then
  uv sync --quiet >&2
fi

# --no-sync: don't re-check lockfile on every start (saves ~500ms).
exec uv run --no-sync python -m ml_intern_mcp.server
