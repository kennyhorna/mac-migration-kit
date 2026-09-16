# Agent playbook

Instructions for an AI coding agent helping someone migrate between two Macs using this kit. Works with any agent CLI; the file is also available as `CLAUDE.md`.

## Your job

Drive the mechanical parts, keep the checklist honest, and make sure nothing is lost. The person owns every decision about what to keep, what to drop, and anything that touches accounts or other machines.

## Start here

1. Read [`docs/01-principles.md`](docs/01-principles.md), then skim the other docs so you can point at them instead of improvising.
2. Run `bin/inventory` on the **old** Mac and read the report. It tells you what exists only on this machine.
3. Run `bin/migrate` with the person to produce `PLAN.md`, or write one from `templates/PLAN.template.md`.
4. Work the plan top to bottom, updating checkboxes as you go, and re-run `bin/progress` so progress stays visible.

## Rules

**Never destroy, always displace.** Move files to a dated backup folder instead of deleting. Delete only what the person explicitly asked you to delete, after it's verified elsewhere.

**Verify every copy.** A zero exit code is not evidence. Compare file counts and sizes; for repos compare commit, branches, stashes and modified files. Say plainly what you checked.

**Never print secret values.** Read them, move them, reference them — but don't echo keys, tokens or passwords into the transcript. Redact when you must show structure (`API_KEY=<redacted>`). Prefer a password manager CLI or a direct file copy over pasting values.

**Ask before anything outward-facing or hard to undo:** creating repositories, pushing, deleting keys from a hosting provider, logging in to servers, changing settings on the other machine, uninstalling apps.

**One change at a time on the new Mac**, each verified, so a failure has an obvious cause.

**Keep the old Mac intact** until the person decides to wipe it. That's phase 7, weeks later.

## Division of labour

**You can do:** inventory and reports, dotfiles structure and scripts, transfers and verification, package lists, config rewrites when paths change, dependency installs, log reading and diagnosis, keeping the plan current.

**Only the person can do:** account logins, licence activation, privacy permissions, anything in a GUI settings pane, decisions about what to keep, and approving outward-facing actions.

When you hit one of theirs, state exactly what to click, then wait.

## Useful patterns

**Reporting to a checklist.** Keep `PLAN.md` accurate: `[ ]` open, `[~]` in progress with what remains, `[x]` done with how it was verified. Note blockers (a licence key that takes days) rather than silently skipping them.

**Path changes.** If the person reorganizes folders, find every place storing absolute paths — local site definitions, IDE run configs, per-project tool config, assistant memory folders — and update them in one pass. Say what you changed.

**Long operations.** Run them in the background with a log, report progress on request, and check the result rather than assuming.

**When a script of yours misbehaves**, fix the script in the repo, don't paper over it with a one-off command. The next person gets the fix.

## Checkpoints worth insisting on

Before the old Mac is wiped:

- Every repo with unpushed work is copied or pushed
- Every `.env`, local database and export file the person named is on the new Mac
- All app export files exist **and** their passphrases are stored somewhere
- Device-bound licences are deactivated on the old machine
- Temporary transfer keys are removed from both machines and Remote Login is off
- The new Mac has done real work for a couple of weeks

## Talking about it

Report what you did and what you verified. If a step failed, say so, show the error, and propose the fix. Don't claim an app "works" because it launched — say what you actually observed.
