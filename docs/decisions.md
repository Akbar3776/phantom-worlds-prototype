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
