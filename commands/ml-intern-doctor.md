---
description: Diagnose the ml-intern plugin — checks uv, Python, venv, tokens, and MCP server health.
---

Run the following diagnostics using the Bash tool, in parallel where possible, and report back in a short table. Do NOT do anything else — this command is only for diagnostics.

1. **uv installed:** `command -v uv && uv --version || echo "uv: NOT FOUND"`
2. **Python version:** `python3 --version`
3. **Plugin root exists:** `ls "${CLAUDE_PLUGIN_ROOT:-$(ls -dt $HOME/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/ 2>/dev/null | head -1)}" | head -5`
4. **Plugin venv:** `ls "${CLAUDE_PLUGIN_ROOT:-$(ls -dt $HOME/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/ 2>/dev/null | head -1)}/.venv/bin/python" 2>&1`
5. **HF_TOKEN set:** `[ -n "$HF_TOKEN" ] && echo "HF_TOKEN: set (${#HF_TOKEN} chars)" || echo "HF_TOKEN: NOT SET"`
6. **GITHUB_TOKEN set:** `[ -n "$GITHUB_TOKEN" ] && echo "GITHUB_TOKEN: set (${#GITHUB_TOKEN} chars)" || echo "GITHUB_TOKEN: NOT SET"`
7. **MCP server importable:** `cd "${CLAUDE_PLUGIN_ROOT:-$(ls -dt $HOME/.claude/plugins/cache/ml-intern-plugin/ml-intern/*/ 2>/dev/null | head -1)}" && uv run --no-sync python -c "from ml_intern_mcp.server import REGISTERED_TOOL_NAMES; print(f'{len(REGISTERED_TOOL_NAMES)} tools registered')" 2>&1`

For each check, mark ✓ (healthy) or ✗ (broken) and give a one-line remediation when broken. Example output:

| Check | Result | Fix |
| --- | --- | --- |
| uv installed | ✓ 0.4.30 | — |
| Python version | ✓ 3.12.8 | — |
| Plugin venv | ✗ missing | Run `/mcp` once — first launch triggers venv creation |
| HF_TOKEN | ✗ not set | Add `export HF_TOKEN="hf_..."` to ~/.zshrc |
| GITHUB_TOKEN | ✓ set (40 chars) | — |
| MCP server | ✓ 10 tools | — |

Finish with a one-line summary: `All green — plugin healthy.` or list the top 1-2 issues to fix.
