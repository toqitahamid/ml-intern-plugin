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

# Detect missing uv and tell the user exactly how to install it,
# before it becomes a silent "failed to connect" in Claude Code.
if ! command -v uv >/dev/null 2>&1; then
  cat >&2 <<'EOF'
[ml-intern] `uv` is not installed or not on PATH.

Install it with one of:

  curl -LsSf https://astral.sh/uv/install.sh | sh     # macOS/Linux
  brew install uv                                      # Homebrew
  pipx install uv                                      # via pipx

See https://docs.astral.sh/uv/ for other options.

After installing, reload the plugin in Claude Code (/plugin reload or
restart the app).
EOF
  exit 127
fi

# First-run sync: create the venv and install deps if missing.
# Subsequent runs skip sync entirely (fast).
if [ ! -d ".venv" ]; then
  echo "[ml-intern] first-run: installing Python deps via uv sync (10-30s)..." >&2
  uv sync --quiet >&2 || {
    echo "[ml-intern] uv sync failed. Check your network and retry /mcp." >&2
    exit 1
  }
fi

# --no-sync: don't re-check lockfile on every start (saves ~500ms).
exec uv run --no-sync python -m ml_intern_mcp.server
