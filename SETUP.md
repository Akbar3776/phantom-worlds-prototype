# Phantom Worlds: setup for Claude Code

This file sets up the GitHub repository so Claude Code can build Phantom Worlds. It contains the steps and the exact contents of every rules, settings and prompt file. The project itself is described in `docs/PROJECT-CONTEXT.md`. Every link is in `docs/DATA-LINKS.md`.

The setup is self-contained. Any session, started by anyone, can run it. No step waits on a named person, and nothing depends on an outside party answering. Work that needs a login or a token is skipped, recorded, and the session moves on.

## Contents

1. The three files and where they go
2. What the setup creates
3. Steps
4. Lanes
5. Files to create, with exact contents
6. Secrets and tokens
7. The working loop
8. Troubleshooting

---

## 1. The three files and where they go

| File | Path in the repository | Holds |
|---|---|---|
| `SETUP.md` | repository root | this setup |
| `PROJECT-CONTEXT.md` | `docs/PROJECT-CONTEXT.md` | the product, every decision and its reasons, the language, the test, architecture, methods, machine learning, interface, build plan, proof |
| `DATA-LINKS.md` | `docs/DATA-LINKS.md` | every link, file name, table name and query |

These three replace the earlier planning kit. If an older file from the kit is in the repository, delete it so agents read one source.

---

## 2. What the setup creates

| Path | Purpose |
|---|---|
| `AGENTS.md` | the rules every coding agent follows. Codex reads it directly |
| `CLAUDE.md` | imports `AGENTS.md` and adds Claude Code habits |
| `.claude/settings.json` | pre-approves the archive and documentation sites and routine commands, blocks reading `.env` files |
| `.gitignore` | keeps secrets, data and build output out of git |
| `.env.example` | names of the tokens, no values |
| `docs/decisions.md` | new decisions, open check answers, items that need outside action |
| `docs/ai-log.md` | one line per task, for the AI-use statement |
| `prompts/1-session-start.md` | start any session on any lane |
| `prompts/2-task.md` | one task |
| `prompts/3-review.md` | review another lane's pull request |
| `prompts/4-wording-pass.md` | check every interface string against the language |
| `prompts/5-failed-pass-mark.md` | when a proof test fails |
| `prompts/6-ml-start.md` | start the ML lane: data, labels, first models |
| `.codex/config.toml` | optional, only if Codex is used |

---

## 3. Steps

1. **Clone the repository.**
   ```
   git clone <repository URL> phantom-worlds
   cd phantom-worlds
   ```
2. **Add the three files.** Put `SETUP.md` in the root, and `PROJECT-CONTEXT.md` and `DATA-LINKS.md` in `docs/`.
3. **Start Claude Code in the repository root**, in a terminal on a local machine. The Engine and ML lanes download large files and call archive services. Cloud sessions can restrict outbound network, so check step 5 before relying on one.
4. **Create the rest of the files.** Paste this into Claude Code:
   ```
   Read SETUP.md. Create every file listed in its section 5, at the path in each heading, with exactly the content inside each ~~~ block. Do not change the content. Then run:
   git add -A && git commit -m "Set up agent rules, prompts and docs"
   Report the files created.
   ```
   Then push: `git push`.
5. **Check network access.** Paste:
   ```
   Run: curl -s "https://irsa.ipac.caltech.edu/TAP/sync?QUERY=SELECT+TOP+3+table_name+FROM+TAP_SCHEMA.tables&FORMAT=CSV"
   Show me the output.
   ```
   Three table names mean the archive is reachable. An error means the session's network blocks it (section 8).
6. **Start a lane.** Paste `prompts/1-session-start.md` with the lane filled in. For the ML lane, paste `prompts/6-ml-start.md` after it.
7. **More than one session on one machine.** Give each session its own folder with git worktrees, so two sessions never share a working directory:
   ```
   git worktree add ../pw-engine -b eng/start
   git worktree add ../pw-ml -b ml/start
   git worktree add ../pw-web -b web/start
   ```
   Start one Claude Code session in each folder.

---

## 4. Lanes

Lanes are areas of code. Any session can take any lane. They meet only at `contracts/`.

| Lane | Owns | Branch prefix |
|---|---|---|
| Engine | `engine/phantom/` except `ml/`, `api/`, `proof/`, `.github/workflows/weekly.yml` | `eng/` |
| ML | `engine/phantom/ml/`, `ml/` (training scripts, configs, reports, model cards) | `ml/` |
| Web | `web/`, `.github/workflows/deploy-web.yml` | `web/` |

Each lane's tasks are in `docs/PROJECT-CONTEXT.md` section 12. Pull requests from one lane are reviewed by a session on another lane with `prompts/3-review.md`.

---

## 5. Files to create, with exact contents

### 5.1 `AGENTS.md`

~~~markdown
# Phantom Worlds: rules for every coding agent

This file is the shared rulebook. Claude Code reads it through `CLAUDE.md`. Codex reads it directly. Keep it under 32 KiB. The project is described in `docs/PROJECT-CONTEXT.md`. Every link is in `docs/DATA-LINKS.md`.

## 1. What this project is

Phantom Worlds is an entry for NASA Space Apps 2026, challenge 12, "Planet X and SPHEREx". It is a public web tool that shows NASA SPHEREx images of any patch of sky as a time series, so anyone can see what moves or changes. On top of that viewer it lets people search sources by the light they give off in 102 bands, removes every known star to expose what is left, reads molecule features, estimates the most likely object type with an honest confidence, and checks each leftover by machine before people review it.

The build window closes Sun 15 Nov 2026 23:59 WIB (16:59 UTC). Judges read the project page and open the live site.

The project is self-contained. No step waits on a named person, and nothing depends on an outside party answering.

## 2. Hard rules

1. **Time.** Run `date -u` at the start of every session. After the freeze review (`docs/PROJECT-CONTEXT.md` section 12.9) only fixes go in.
2. **Never invent a fact.** Archive column names, file paths, URL layouts, band edges, catalogue values and library behaviour are looked up or measured. If a doc marks something `[TO CHECK]` or `[check]`, check it first. If you cannot check it, record that and take the next task.
3. **Never invent a number shown to users.** Every value on screen comes from data or from a cited source. No sample data, no placeholder rows, no lorem ipsum, no fake accounts.
4. **Nothing shown that does not work.** A control is live or absent. No disabled buttons that hint at future features. Planned features appear only on the Proof panel under "Next".
5. **Follow the language.** Every label, message and identifier that reaches the interface uses the terms, verbs and formats in `docs/PROJECT-CONTEXT.md` section 5. Do not coin synonyms.
6. **Contracts are fixed.** Files under `contracts/` change only with a line in `docs/decisions.md` and a matching change on both sides in the same pull request.
7. **Tier order is the default, not a wall.** Work in the order of `docs/PROJECT-CONTEXT.md` section 12. The five test targets and the objective come first. If a later item is cheap and makes the objective stronger, or a resource offers a better route, log it in `docs/decisions.md` and do it.
8. **Licences.** Allowed: BSD, MIT, Apache-2.0, LGPL as a separate library (Aladin Lite v3). Do not use The Tractor (GPL-2) or tractorjax-spherex (GPL-3). Check every new library's licence before adding it. Our code is Apache-2.0.
9. **Secrets.** Never create accounts. Never read, print, log or commit a token. Tokens live in GitHub secrets and in local `.env` files that are git-ignored. Never ask anyone to paste a token into a chat.
10. **No outside contact.** Do not email, post, or open issues on other projects. Do not submit anything to registries or science teams.
11. **Honest wording.** "Confirmed", "discovered" and "verified" are reserved words. Model output is always an "estimate". Molecule readings are feature strengths. The only composition percentage shown is an ice molecule as a percentage of water ice.
12. **AI log.** After each task append one line to `docs/ai-log.md`: date, agent, lane, task ID, files touched.
13. **Data.** Downloads go to `data/`, which git ignores. Record name, size, checksum and source URL in `data/manifest.csv`. Download with code (`curl`, `wget`, Python). Some archive folders block web-page readers.
14. **Independence.** Do not wait on people. If a step needs a login, a token or an outside answer, skip it, add it to "Needs outside action" in `docs/decisions.md` with what it would unblock, and continue with the next task.

## 3. Read before you work

| When | Read in `docs/PROJECT-CONTEXT.md` |
|---|---|
| Every session | this file, sections 1, 4 and 12 |
| Any task that puts words or numbers on screen | sections 5 and 10 |
| Any task in `engine/`, `api/`, `proof/` | sections 7 and 8 |
| Any task that touches a test target | section 6 |
| Any model, classification, molecule reading or training data work | section 9, plus `docs/DATA-LINKS.md` sections 6, 7, 11, 12 |
| Any validation or report card work | section 13 |
| Any archive access, file layout or flag | section 14, plus `docs/DATA-LINKS.md` |
| Accounts, review, reputation, games | section 11 |
| Why something is the way it is | sections 3 and 15 |

## 4. Repository layout

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
.github/workflows/   CI, deploy, weekly update
```

## 5. Lanes

| Lane | Owns | Branch prefix |
|---|---|---|
| Engine | `engine/phantom/` except `ml/`, `api/`, `proof/`, `.github/workflows/weekly.yml` | `eng/` |
| ML | `engine/phantom/ml/`, `ml/` | `ml/` |
| Web | `web/`, `.github/workflows/deploy-web.yml` | `web/` |

Any session can take any lane. Lanes meet only at `contracts/`. Each session works in its own branch, and in its own git worktree when sessions share a machine. A session on another lane reviews each pull request with `prompts/3-review.md` before merge.

## 6. Tooling and commands

Python 3.12 with `uv`. Lint with `ruff`. Tests with `pytest`. Node LTS with `pnpm`. TypeScript strict. Tests with `vitest`, end-to-end with Playwright.

Commands, created in tasks T01 and kept with these names:

```
uv run ruff check . && uv run pytest            # engine, ml, api, proof
uv run phantom --help                           # pipeline CLI
uv run python ml/train.py --help                # model training
uv run python proof/run.py                      # writes proof/report.json and proof/report.md
pnpm -C web lint && pnpm -C web test            # web
pnpm -C web build                               # must stay under the size budget
pnpm -C web e2e                                 # Playwright on the five targets
```

## 7. Definition of done for any task

1. The acceptance check in the build plan passes, and its output is pasted in the pull request.
2. Lint and tests pass in the lane.
3. Every string added to the interface matches the language. Every number has a unit and an origin label.
4. Loading, empty, partial and error states exist for anything that fetches.
5. No new dependency without a one-line reason and its licence in the pull request.
6. The build plan checkbox is ticked and the AI log has its line.

## 8. Engineering rules

- One code path. The API, the pipeline and model inference call the same `phantom` functions, so live results and precomputed results match.
- The site works with the API switched off. Showcase targets and fields load from static data products.
- Every data product carries `data_as_of`, `pipeline_version` and its source file list. Every model output carries `model_version`.
- Network calls from the API go only to an allowlist of hosts. Inputs are validated. Responses are cached by request.
- Read only the bytes you need from archive files (HTTP range). Never use the IRSA cutout service on the live path.
- Like with like. Never blink, subtract or compare two images whose band ranges differ.
- Positions of catalogued sources are moved to each frame's date with proper motion and parallax before any match or overlay.
- Pixels with IRSA's rejected flag bits get zero weight in every fit and stack. Bit 21 marks a pixel on a known source and is never masked.
- Science wavelengths come from `CWAVE` and `CBAND`, never from hardcoded band edges.
- Models: test split by sky tile, gold labels only in the test set, scores per brightness bin, release gate in `docs/PROJECT-CONTEXT.md` section 9.9. A model that fails the gate is not published.
- Small pull requests. One task per pull request. Commit messages in the imperative, task ID first: `T12 add visit stacks`.
- When a pass mark fails, report the measured value. Do not tune a threshold to make it pass.

## 9. When you are stuck

Stop after two failed attempts at the same step. Write in the pull request or in `docs/decisions.md` what you tried, what you saw, and the smallest question that would unblock it. Then move to the next unblocked task. Do not guess around an unknown archive detail, and do not swap in fake data to keep going.

## 10. The plan serves the project

The docs are a starting point and wrong somewhere. When the data, a tutorial or a test shows a better way, take it.

- Propose improvements freely: a faster data route, a clearer control, a stronger check, a new idea that uses SPHEREx's bands. State the gain and the cost in two lines.
- Small improvements inside your task: do them and note them in the pull request.
- Changes to scope, contracts or wording rules: write them in `docs/decisions.md`, update `docs/PROJECT-CONTEXT.md`, then build.
- Open the resource pages yourself. Do not rely only on the summaries.
- What stays fixed: never invent facts or numbers, nothing shown that does not work, licences, secrets, no outside contact, honest wording.

## 11. Links to open first

Full list: `docs/DATA-LINKS.md`.

- Challenge: https://www.spaceappschallenge.org/2026/challenges/planet-x-and-spherex/
- IRSA SPHEREx pages: https://irsa.ipac.caltech.edu/Missions/spherex.html
- Tutorials: https://caltech-ipac.github.io/irsa-tutorials/spherex/
- Data access paths: https://caltech-ipac.github.io/spherex-archive-documentation/spherex-data-access
- Explanatory Supplement v2.1: https://irsa.ipac.caltech.edu/data/SPHEREx/docs/SPHEREx_Expsupp.pdf
- TAP: https://irsa.ipac.caltech.edu/TAP/sync
- SIA: https://irsa.ipac.caltech.edu/SIA
- Files: https://irsa.ipac.caltech.edu/ibe/data/spherex/
- Moving Object Search Tool API: https://irsa.ipac.caltech.edu/applications/MOST/MOSTProgramInterface.html
- WiseView: http://byw.tools/wiseview
~~~

### 5.2 `CLAUDE.md`

~~~markdown
@AGENTS.md

## Claude Code specifics

- The lane is given in the first message of the session. Use its branch prefix: `eng/`, `ml/` or `web/`.
- Before any change to `contracts/`, the photometry solver, the prediction check or a model release, write the plan in the pull request description and the line in `docs/decisions.md` first.
- For a task with a `[TO CHECK]` or `[check]` dependency, do the check first and record the answer in `docs/decisions.md` with the command or URL used.
- Download and query archives with Bash (`curl`, `wget`, `uv run python`). Web-page readers are blocked on some IRSA and DESI folders.
- For TAP from code, use POST with `QUERY`, `LANG=ADQL`, `FORMAT=csv`. List real columns from `TAP_SCHEMA.columns` before writing a query.
- Long jobs (cutouts, joint fits, training) run in the background with their log in `data/logs/`. Report the command and the log path, then keep working on the next task.
- When reviewing another lane's pull request, use `prompts/3-review.md` and report findings ordered by severity. Do not rewrite that code unless the review says to.
- Keep replies short: what changed, the acceptance check output, the next task.
~~~

### 5.3 `.claude/settings.json`

~~~json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "WebSearch",
      "WebFetch(domain:www.spaceappschallenge.org)",
      "WebFetch(domain:irsa.ipac.caltech.edu)",
      "WebFetch(domain:caltech-ipac.github.io)",
      "WebFetch(domain:spherex.caltech.edu)",
      "WebFetch(domain:euclid.caltech.edu)",
      "WebFetch(domain:nasa-irsa-spherex.s3.us-east-1.amazonaws.com)",
      "WebFetch(domain:byw.tools)",
      "WebFetch(domain:archive.stsci.edu)",
      "WebFetch(domain:gea.esac.esa.int)",
      "WebFetch(domain:esdcdoi.esac.esa.int)",
      "WebFetch(domain:www.cosmos.esa.int)",
      "WebFetch(domain:gaia.aip.de)",
      "WebFetch(domain:cds.unistra.fr)",
      "WebFetch(domain:simbad.cds.unistra.fr)",
      "WebFetch(domain:vizier.cds.unistra.fr)",
      "WebFetch(domain:tapvizier.cds.unistra.fr)",
      "WebFetch(domain:aladin.cds.unistra.fr)",
      "WebFetch(domain:ssp.imcce.fr)",
      "WebFetch(domain:www.aavso.org)",
      "WebFetch(domain:data.desi.lbl.gov)",
      "WebFetch(domain:datalab.noirlab.edu)",
      "WebFetch(domain:www.asc-csa.gc.ca)",
      "WebFetch(domain:data.asc-csa.gc.ca)",
      "WebFetch(domain:www.cadc-ccda.hia-iha.nrc-cnrc.gc.ca)",
      "WebFetch(domain:ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca)",
      "WebFetch(domain:zenodo.org)",
      "WebFetch(domain:doi.org)",
      "WebFetch(domain:mocadb.ca)",
      "WebFetch(domain:arxiv.org)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:raw.githubusercontent.com)",
      "WebFetch(domain:pypi.org)",
      "WebFetch(domain:docs.astropy.org)",
      "WebFetch(domain:astroquery.readthedocs.io)",
      "WebFetch(domain:photutils.readthedocs.io)",
      "WebFetch(domain:scikit-learn.org)",
      "WebFetch(domain:xgboost.readthedocs.io)",
      "WebFetch(domain:lightgbm.readthedocs.io)",
      "WebFetch(domain:catboost.ai)",
      "WebFetch(domain:optuna.readthedocs.io)",
      "WebFetch(domain:shap.readthedocs.io)",
      "WebFetch(domain:mapie.readthedocs.io)",
      "WebFetch(domain:pytorch.org)",
      "WebFetch(domain:docs.astral.sh)",
      "WebFetch(domain:huggingface.co)",
      "WebFetch(domain:developers.cloudflare.com)",
      "WebFetch(domain:docs.github.com)",
      "Bash(date -u)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git switch *)",
      "Bash(git worktree *)",
      "Bash(uv *)",
      "Bash(pnpm *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(sha256sum *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/.env)",
      "Read(./**/.env.*)",
      "Bash(rm -rf *)"
    ]
  }
}
~~~

### 5.4 `.gitignore`

~~~
# secrets
.env
.env.*
!.env.example

# personal agent files
CLAUDE.local.md
.claude/settings.local.json
AGENTS.override.md

# data cache, downloads, logs
data/
*.fits
*.fits.gz
*.zip

# build output
node_modules/
web/dist/
.venv/
__pycache__/
.pytest_cache/
.ruff_cache/
~~~

### 5.5 `.env.example`

~~~
# Names only. Values live in GitHub secrets and in a local .env that git ignores.
HF_TOKEN=
HF_DATASET_REPO=
HF_SPACE=
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ACCOUNT_ID=
# Tier C only
SUPABASE_URL=
SUPABASE_ANON_KEY=
~~~

### 5.6 `docs/decisions.md`

~~~markdown
# Decisions log

New decisions, answers to open checks, and items that need outside action. The full history to 14 Nov is in `docs/PROJECT-CONTEXT.md` section 15. One line per entry: date, what, why, the command or URL used.

## Needs outside action

Steps that need a login, a token or an outside answer. Nothing waits on them. Each line says what it would unblock.

- Deploy tokens in GitHub secrets (names in `.env.example`). Unblocks: deploy jobs. Until then the deploy job reports the missing name and stops.
- Spectrophotometry Tool spectra (browser login, 20 positions a job). Unblocks: an extra calibration comparison in the ML lane. Optional.

## Open check answers

(add answers here)

## Decisions

(add decisions here)
~~~

### 5.7 `docs/ai-log.md`

~~~markdown
# AI use log

One line per task. Used for the AI-use statement on the project page.

| Date (WIB) | Agent | Lane | Task | Files touched |
|---|---|---|---|---|
| 13 Nov 2026 | Claude (chat) | planning | Planning docs, agent rules, ML research | docs/PROJECT-CONTEXT.md, docs/DATA-LINKS.md, SETUP.md |
~~~

### 5.8 `prompts/1-session-start.md`

~~~markdown
# Prompt 1: start a session on any lane

Paste into a new session in the repository root or in the lane's worktree. Fill in the lane.

Your lane is <Engine | ML | Web>.

1. Run `date -u` and state the time.
2. Read AGENTS.md. Then read docs/PROJECT-CONTEXT.md sections 1, 4 and 12, and the sections AGENTS.md section 3 lists for your lane. Do not skim.
3. Answer each in one or two sentences, with the section you found it in:
   a. What is the one required objective of the challenge?
   b. Why can two raw SPHEREx frames of the same position not be blinked against each other?
   c. Why does WISE 0855 need per-detector visit stacks?
   d. Where is WISE 0855 now relative to the challenge's coordinates, and how do we handle it?
   e. What are the three values of source status?
   f. What are the four origin labels on a reading?
   g. When does a prediction count as held?
   h. Which words are reserved, and when is each allowed?
   i. What does the site do when the API is off?
   j. Which licences are forbidden and which tools does that rule out?
   k. Why do we not show a full molecule composition, and what do we show?
   l. What is the main type model, and what makes its percentages honest?
4. Check the tools your lane needs and print versions. Engine and ML: git, uv, python 3.12. Web: git, node, pnpm. Install what is missing with uv or pnpm.
5. List the open checks (docs/PROJECT-CONTEXT.md section 16 and section 9.12) that block your lane's first tasks. Do them. Record each answer in docs/decisions.md with the command or URL used.
6. Take the first unticked task in your lane in docs/PROJECT-CONTEXT.md section 12 and work the plan in order.

For every task:
- State the task ID and its acceptance check before you start.
- Write the test first where a test is possible.
- Keep the change to that one task. Open a pull request named "<ID> <what it does>".
- Paste the acceptance check output in the pull request.
- Tick the box in docs/PROJECT-CONTEXT.md section 12 and add your line to docs/ai-log.md.
- Report in three lines: what changed, the check output, the next task ID. Then continue with the next task.

If a fact is marked [TO CHECK] or [check], or is missing from the docs, check it. If it cannot be checked, record it and take the next task. Never guess and never use made-up data. If a step needs a login or a token, add it to "Needs outside action" in docs/decisions.md and continue.
~~~

### 5.9 `prompts/2-task.md`

~~~markdown
# Prompt 2: one task

Do task <ID> from docs/PROJECT-CONTEXT.md section 12.

Before coding, write:
1. The acceptance check, quoted.
2. The sections you will read for it.
3. Your plan in five lines or fewer.
4. Anything you would otherwise have to guess, and how you will check it.

If the task touches contracts/, write the decisions.md line and the plan in the pull request description before changing code.

When done, report: files changed, the acceptance check output, lint and test output, the next task ID.
~~~

### 5.10 `prompts/3-review.md`

~~~markdown
# Prompt 3: review another lane's pull request

Review pull request <number or branch>. This session did not write it. Do not edit its files.

Check, in this order:
1. Does it do the task in docs/PROJECT-CONTEXT.md section 12 and nothing more? Is the acceptance check output present and believable?
2. Correctness. Engine: units, coordinate epochs, pixel versus arcsecond, pixel quality (rejected bits at zero weight, bit 21 never masked), the like-with-like rule, errors propagated, CWAVE and CBAND used. ML: test split by sky tile, gold labels only in the test set, no leakage between splits, scores per brightness bin, calibration and conformal coverage reported, the 50% cap applied. Web: URL state round-trips, all four states exist, no invented data, numbers read from data products.
3. Contracts. Does anything read or write a field that is not in contracts/?
4. Language. Does every new string follow docs/PROJECT-CONTEXT.md section 5? Any reserved word misused? Any number without unit and origin?
5. Rules in AGENTS.md section 2. Any invented fact, dead control, forbidden licence, secret, or outside call beyond the allowlist?
6. Tests. Would the test fail if the code were wrong?

Report findings ordered by severity: blocker, should fix, note. For each: file and line, what is wrong, a concrete failing example, the fix in one sentence. If a level has no findings, say so. End with "merge" or "do not merge".
~~~

### 5.11 `prompts/4-wording-pass.md`

~~~markdown
# Prompt 4: wording pass

List every user-facing string in web/ with its file and line. For each, say whether it follows docs/PROJECT-CONTEXT.md section 5: terms, verbs, reserved words, reading format, confidence words, state pattern, label rules. Give the corrected string where it does not. Then apply the corrections in one pull request named "Wording pass".
~~~

### 5.12 `prompts/5-failed-pass-mark.md`

~~~markdown
# Prompt 5: when a pass mark fails

Test <ID> in proof/report.json failed. Do not change the pass mark and do not tune thresholds to it. Find the cause. Report: the measured value, the three most likely causes in order, the evidence for each, and the smallest change that would test the first cause. Then make that change in its own pull request and re-run the test. If the cause is real and cannot be fixed, publish the failure with its measured value and a one-line reason.
~~~

### 5.13 `prompts/6-ml-start.md`

~~~markdown
# Prompt 6: start the ML lane

Your lane is ML. Read docs/PROJECT-CONTEXT.md section 9 in full, and docs/DATA-LINKS.md sections 6, 7, 11 and 12.

Work in this order, one pull request per task:

1. T01-M. Scaffold engine/phantom/ml/ and ml/. Download by script, into data/, everything in docs/DATA-LINKS.md section 12 rows 1 to 4. Record each file in data/manifest.csv with size, checksum and source URL. Resolve K18 (read the SPIFF README and tables, record the CSV columns) and K20 (SPLICES class values from the release notes).
2. Pick the cube tiles. Count SPLICES rows per order-5 tile to choose the star-forming field. Run the DESI tile count query after checking K29. Record the chosen tiles in docs/decisions.md.
3. T43a. Build the label table: one row per source with type, label source and grade. Gold for testing, silver at half weight. Report counts per type and grade.
4. T43b. Training spectra. Ingest SPIFF. Extract cube spectra for labelled sources. Run the two checks in section 9.4: cube against our own single-frame spectra for 20 bright isolated stars (K22), and QR2 against DR1 for sources in both.
5. T42 and T43c. Features and molecule readings with resampled errors and refusal reasons.
6. T43d to T43g. Template match, XGBoost spectrum trees and the other experts, stacking, calibration, conformal sets, both stored results, deciding bands, novelty checks.
7. T45-M1. Real-or-artefact model from injections and flagged artefacts.
8. Write a model card per model in ml/ and publish only models that pass section 9.9.

Choose models by section 9.11: first picks, then the alternatives in its test list, scored on the calibrate split, test split run once at the end. Report every score per brightness bin.
~~~

### 5.14 `.codex/config.toml` (optional, only if Codex is used)

~~~toml
# Codex reads AGENTS.md automatically. This turns on network inside its workspace sandbox.
# If a setting seems ignored, pass it on the command line:
#   codex -c 'sandbox_workspace_write.network_access=true'
sandbox_mode = "workspace-write"
approval_policy = "on-request"
project_doc_max_bytes = 65536

[sandbox_workspace_write]
network_access = true
~~~

---

## 6. Secrets and tokens

Agents never create accounts and never see token values. Values go into GitHub secrets (repository Settings, Secrets and variables, Actions) and, for local runs, into a `.env` file that git ignores.

| Name | Used by |
|---|---|
| `HF_TOKEN` | pushing data products and models to the Hugging Face Dataset repo, deploying the API Space |
| `HF_DATASET_REPO`, `HF_SPACE` | names of the Dataset repo and the Space |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | deploying the site to Cloudflare Pages |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | accounts and reviews, Tier C only |

If a token is absent, its job reports the missing name and stops. Everything else keeps working.

---

## 7. The working loop

1. Start a session with `prompts/1-session-start.md` (and `prompts/6-ml-start.md` for the ML lane).
2. The session works its lane's tasks in order, one pull request each, and reports three lines after each.
3. A session on another lane reviews each pull request with `prompts/3-review.md`. Merge on "merge".
4. The Tier A gate in `docs/PROJECT-CONTEXT.md` section 12.5 decides when Tier B starts.
5. The freeze review in section 12.9 runs before the project page is written. After it, only fixes.
6. `prompts/4-wording-pass.md` runs before the freeze review. `prompts/5-failed-pass-mark.md` runs on any failed proof test.
7. New decisions go in `docs/decisions.md`. When a decision changes the plan, update `docs/PROJECT-CONTEXT.md` in the same pull request.

---

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| The network check in step 5 fails | The session's network blocks the archive. Run Claude Code in a terminal on a local machine. In Codex, use `.codex/config.toml` or `codex -c 'sandbox_workspace_write.network_access=true'`. Some macOS setups still block it. Then `codex --sandbox danger-full-access` inside the worktree only |
| A web-page reader is refused on IRSA or DESI folders | Those folders block robots. Use `curl`, `wget` or Python |
| TAP answers "QUERY must be set" | The URL encoding broke the query. Encode spaces as `+`, quotes as `%27`, `%` as `%25`, or use POST from code |
| TAP answers that the URL is too long | Use POST |
| A sync TAP query times out | The limit is 5 minutes. Use `/TAP/async` or a smaller region |
| The IRSA cutout service is slow or answers 503 | Expected under load. Use byte-range reads of the full file (section 8, stage 2 of the context) |
| Object name lookup fails | IRSA's lookup was partly down on 13 Nov. Use CDS Sesame, then SIMBAD TAP, then the built-in table of named targets |
| A file in the docs is marked `[check]` and the check fails | Record the result in `docs/decisions.md`, update `docs/PROJECT-CONTEXT.md` or `docs/DATA-LINKS.md`, and continue |
