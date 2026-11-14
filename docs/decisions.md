# Decisions log

New decisions, answers to open checks, and items that need outside action. The full history to 14 Nov is in `docs/PROJECT-CONTEXT.md` section 15. One line per entry: date, what, why, the command or URL used.

## Needs outside action

Steps that need a login, a token or an outside answer. Nothing waits on them. Each line says what it would unblock.

- Deploy tokens in GitHub secrets (names in `.env.example`). Unblocks: deploy jobs. Until then the deploy job reports the missing name and stops.
- Spectrophotometry Tool spectra (browser login, 20 positions a job). Unblocks: an extra calibration comparison in the ML lane. Optional.
- `docs/DATA-LINKS.md` is missing from the repository. It was not in the 14 Nov upload. Unblocks: every link, file name, table name and query the other docs point to, including `prompts/6-ml-start.md` step 1. Add it at `docs/DATA-LINKS.md`.
- Branch ruleset for `main` (repository Settings, Rules, Rulesets, New branch ruleset, target the default branch): require a pull request before merging with 0 required approvals, require the status checks `Repository rules`, `Python (engine, ML, API, proof)` and `Web`, block force pushes. Sessions share one GitHub account, so a required approval would block every merge. Unblocks: CI gates every merge.
- Secret scanning with push protection (repository Settings, security section), at the latest when the repository goes public. Unblocks: GitHub refuses a push that contains a token.
- Hugging Face upload hosts on the cloud environment `el-repo`, measured at the first push from a cloud session. The download host `us.aws.cdn.hf.co` is already allowed. Unblocks: publishing to the Dataset repo from the cloud (T12).
- `HF_TOKEN` as a network secret on the cloud environment `el-repo`, only if publishing runs from a cloud session. The proxy adds it to requests, so no agent sees the value. Unblocks: T12 and T13 from the cloud.

## Open check answers

- 14 Nov 2026, K2 (partial): the bucket `nasa-irsa-spherex` lists anonymously. Its root holds `dr1/`, `qr2/`, `qr3/` and `index.html`. The key layout under each prefix is still to list. Command: `curl "https://nasa-irsa-spherex.s3.us-east-1.amazonaws.com/?list-type=2&delimiter=/&max-keys=10"`
- 14 Nov 2026, K5 (partial): `www.aavso.org` answers scripted requests with a Cloudflare challenge (HTTP 403, `cf-mitigated: challenge`), so VSX cannot be read there by script. Route to try once CDS answers: VSX on VizieR (`B/vsx`) `[TO CHECK]`. Command: `curl -sI https://www.aavso.org/vsx/`

## Decisions

- 14 Nov 2026, cloud environment `el-repo` for Claude Code on the web. Limited network: package registries plus `irsa.ipac.caltech.edu`, `caltech-ipac.github.io`, `cds.unistra.fr`, `simbad.cds.unistra.fr`, `vizier.cds.unistra.fr`, `tapvizier.cds.unistra.fr`, `alasky.cds.unistra.fr`, `aladin.cds.unistra.fr`, `vizier.idia.ac.za`, `ssp.imcce.fr`, `ws.cadc-ccda.hia-iha.nrc-cnrc.gc.ca`, `gea.esac.esa.int`, `datalab.noirlab.edu`, `data.desi.lbl.gov`, `zenodo.org`, `huggingface.co`, `us.aws.cdn.hf.co`, `download.pytorch.org`, `www.spaceappschallenge.org`, `arxiv.org`, `www.aavso.org`. The SPHEREx S3 bucket was reachable without an entry. Setup script: `uv sync --frozen` when `uv.lock` exists, `pnpm -C web install --frozen-lockfile` when `web/pnpm-lock.yaml` exists, `mkdir -p data/logs`. Why: SETUP.md step 5 failed on the default environment (IRSA refused by network policy). Check: SETUP.md step 5 now returns three table names.
- 14 Nov 2026, GitHub setup. `main` is the default branch. `.github/workflows/ci.yml` runs the repository rules on every push and pull request, plus the Python and Web jobs once `pyproject.toml` and `web/package.json` exist. T01-E and T01-W extend this workflow and do not add another. Labels come from `.github/workflows/labels.yml`, lane labels on pull requests from `.github/labeler.yml`. The pull request template carries AGENTS.md section 7. Dev container in `.devcontainer/` (Python 3.12, uv, Node 22, pnpm 10, Claude Code). Actions use their current major tag, `v7`. Why: one place for checks and a readable review trail. Check: actionlint and ShellCheck report nothing, issue forms and the dev container validate against their schemas, the rules job fails on a planted `.env` and a planted token.
- 14 Nov 2026 03:45 UTC, CDS seen from the cloud: SIMBAD TAP and VizieR `asu-tsv` answered CDS's "This page is currently unavailable" page, TAPVizieR reset the connection, and Sesame redirected to the mirror `vizier.idia.ac.za`, which answers. Why it matters: T08 name lookup and SIMBAD `otype` labels depend on CDS. Retry before relying on it. Command: `curl -sL "https://cds.unistra.fr/cgi-bin/nph-sesame/-oI/A?Barnard%27s%20Star"`
- 14 Nov 2026, `www.spaceappschallenge.org` fails TLS verification from scripts. The server sends a chain that ends at Comodo "AAA Certificate Services", which the container's CA bundle does not trust. The challenge text is in `docs/PROJECT-CONTEXT.md` section 2. Command: `openssl s_client -connect www.spaceappschallenge.org:443 -showcerts`
