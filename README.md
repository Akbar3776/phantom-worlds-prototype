# Phantom Worlds

Phantom Worlds lets anyone search NASA's SPHEREx sky by the light each object gives off in 102 infrared bands, to find moving and unexplained objects that no catalogue lists yet, including in the crowded Milky Way.

Entry for NASA Space Apps Challenge 2026, challenge 12, "Planet X and SPHEREx". The build plan and its progress are in [`docs/PROJECT-CONTEXT.md`](docs/PROJECT-CONTEXT.md) section 12.

## Start here

| You want to | Read |
|---|---|
| Know the rules every coding agent follows | [`AGENTS.md`](AGENTS.md) |
| Set up Claude Code and start a lane | [`SETUP.md`](SETUP.md), then [`prompts/1-session-start.md`](prompts/1-session-start.md) |
| Understand the product, methods and decisions | [`docs/PROJECT-CONTEXT.md`](docs/PROJECT-CONTEXT.md) |
| Find a link, file name, table or query | [`docs/DATA-LINKS.md`](docs/DATA-LINKS.md) |
| See new decisions and what waits on outside action | [`docs/decisions.md`](docs/decisions.md) |

## Repository layout

```
AGENTS.md  CLAUDE.md  SETUP.md  README.md  LICENSE
docs/        PROJECT-CONTEXT.md, DATA-LINKS.md, decisions.md, ai-log.md
prompts/     prompts that start sessions and tasks
contracts/   JSON Schemas for data products, OpenAPI for the API, URL contract
engine/      Python package `phantom`: archive access, cutouts, registration, stacks,
             photometry, spectra, features, detectors, checks, predictions, searched map, CLI
engine/phantom/ml/   model features, inference, calibration, novelty checks
ml/          training scripts, configs, reports, model cards
api/         FastAPI app. Imports `phantom`. No science code of its own
web/         Vite + React + TypeScript single-page app
proof/       one script that produces every number on the Proof panel
data/        local cache and downloads, git-ignored
.github/     CI, labels, pull request and issue templates
.devcontainer/   Codespaces and VS Code dev container
```

## How work flows

Each lane owns a set of folders and a branch prefix. Lanes meet only at `contracts/`. Any session can take any lane.

| Lane | Owns | Branch prefix | Label |
|---|---|---|---|
| Engine | `engine/phantom/` except `ml/`, `api/`, `proof/`, weekly update | `eng/` | `lane: engine` |
| ML | `engine/phantom/ml/`, `ml/` | `ml/` | `lane: ml` |
| Web | `web/`, site deploy | `web/` | `lane: web` |

1. Start a session with [`prompts/1-session-start.md`](prompts/1-session-start.md). The ML lane adds [`prompts/6-ml-start.md`](prompts/6-ml-start.md).
2. One task per branch and per pull request, titled `<task ID> <what it does>`, for example `T12 add visit stacks`.
3. The pull request template carries the definition of done from `AGENTS.md` section 7.
4. A session on another lane reviews with [`prompts/3-review.md`](prompts/3-review.md). Merge on "merge".
5. New decisions go in [`docs/decisions.md`](docs/decisions.md). Each task adds one line to [`docs/ai-log.md`](docs/ai-log.md).

## Checks

| Check | What it does | When it runs |
|---|---|---|
| Repository rules | AGENTS.md under 32 KiB, no secrets or data in git, agent configs parse, a decisions line for any contract change, a reminder for the AI log line | every push and pull request |
| Python (engine, ML, API, proof) | `uv sync --locked`, `ruff check`, `pytest` | once `pyproject.toml` exists |
| Web | `pnpm install`, lint, test, build, and Playwright once configured | once `web/package.json` exists |
| Label by lane | adds the lane, `contracts`, `docs` and `ci` labels | every pull request |

## Development environments

| Where | What you get |
|---|---|
| Claude Code on the web | A cloud environment with the archive hosts listed in `docs/decisions.md`. Its setup script installs from the lockfiles at session start |
| Codespaces or a VS Code dev container | `.devcontainer/` with Python 3.12, uv, Node 22, pnpm 10 and Claude Code |
| A terminal on your machine | Follow [`SETUP.md`](SETUP.md) |

## Licence

Our code is Apache-2.0. See [`LICENSE`](LICENSE).
