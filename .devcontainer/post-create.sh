#!/bin/bash
# Runs once when the dev container is created (Codespaces or VS Code).
# Same steps as the cloud environment setup: each waits for the files it needs.
set -u

command -v uv >/dev/null || pipx install uv
command -v claude >/dev/null || npm install --global @anthropic-ai/claude-code

if [ -f uv.lock ]; then
  uv sync --frozen --all-packages --all-extras --all-groups
fi
if [ -f web/pnpm-lock.yaml ]; then
  pnpm -C web install --frozen-lockfile
fi
mkdir -p data/logs

echo "Ready. Start with SETUP.md, then prompts/1-session-start.md."
