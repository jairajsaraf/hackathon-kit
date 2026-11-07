---
name: session-handoff-maintenance
description: How to keep HANDOFF.md, the single file that records a project's current state, accurate across Claude sessions, plus the one-home-per-fact rule. Load at the START of a session to know which document to trust, and at the END of any session that changed code, plans, decisions or open issues. If you changed state and did not update the handoff, the next session inherits a lie.
---

# Session Handoff Maintenance

A new session starts with no memory. Re-deriving the project's state from code costs tokens and invites wrong guesses, so keep one short file, `HANDOFF.md` at the repo root, that says where things stand.

## When NOT to use this skill
The handoff records *state*. Rules and design belong in the README or plan; behaviour belongs in code and tests. If you are about to write a rule or a long explanation into the handoff, put it in its own document and link to it.

## Document hierarchy (who wins when they disagree)

1. **`HANDOFF.md`**: current state: what works, what is broken, open issues, what is next. The most recently dated claim wins on *state*.
2. **README, plan, spec**: goals, design, rules. They win on *intent*.
3. **Code, tests, git history**: the authority on behaviour. A physical file beats any handoff claim about that file; verify with a command before trusting either.

**One home per fact.** Every fact lives in exactly one document; everything else cross-references. Duplicated facts are how two documents come to contradict each other.

## Start-of-session check (30 seconds)

```bash
head -5 HANDOFF.md                     # note the Last updated date
git log -3 --format='%h %ad %s' --date=short
git status --short
```

If the repo has newer commits than the handoff's date, treat the handoff as stale: read the commits, then fix the handoff before doing new work.

## Update procedure (end of any state-changing session)

1. Rewrite the affected section. Do not append a correction below stale text.
2. Update the `Last updated:` line with an absolute date and time.
3. Move resolved items to a "Resolved this session" note for one session, then delete them.
4. Commit `HANDOFF.md` with the work it describes, or tell the user to save it where the next session will read it.

## House style

Tables for state; short prose for context; every claim about a file verifiable by a one-line command; deadlines written as absolute dates and clock times, never "later today"; "Unknown" is a valid and honest status, never infer an outcome.

## What a complete hackathon handoff contains

- **Goal and demo path** in two sentences: what the judges will see.
- **Deadline** and judging time, in bold with date and time.
- **State table**: component / status (works, broken, not started) / how to check.
- **Decisions** with the reason for each, so nobody reopens them.
- **Tooling decisions** from the opt-in-picker skill: item, reason, token cost.
- **Open issues**: file / problem / next step.
- **Next three actions**, in order.

## Provenance
Adapted from the author's own session-handoff skill, generalized for team hackathons. The staleness rules come from real incidents where a handoff described files that had since changed.
