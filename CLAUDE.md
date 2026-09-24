# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What This Repository Is

**WorkFlow** is a user-friendly, web-based project/resource scheduling tool — a Gantt-based planner aimed at being an intuitive alternative to Microsoft Project / Primavera P6, not a clone of their full feature depth. Spun off from a real, validated idea in a different project (SAL Operations' crew-rotation Gantt timeline).

**Read `docs/PROJECT_SPEC.md` in full before building anything** — it has the vision, MVP scope, tech stack rationale, and a draft schema. This is a side project worked on in free time; there is no urgency, but there is a real spec to follow so early decisions stay consistent across sessions.

---

## Session Start Protocol

This project is new — there's no long history to catch up on yet. Until `docs/LIVING_PROJECT_STATE.md` has real content:

1. `git pull` first.
2. Read `docs/PROJECT_SPEC.md` (the vision/scope/architecture) and `docs/LIVING_PROJECT_STATE.md` (current build status).
3. Check `docs/LESSONS_LEARNED.md` for anything relevant to what you're about to touch.

Once this project has real session history, adopt the same discipline SAL Operations uses (see its own CLAUDE.md for the pattern this will likely converge on): a short "SESSION START PROTOCOL" summary block in `LIVING_PROJECT_STATE.md`, updated at every session close, so a new session doesn't need to re-read everything. **Carry over the size-check gate too, not just the format** — SAL Operations' `LIVING_PROJECT_STATE.md` grew to ~90K characters despite a written "keep it short" instruction (twice, in two different sections), because a prose aspiration alone doesn't hold. Whatever session-close routine gets adopted here should include a `wc -c` check against a real ceiling (SAL Operations uses ~75,000 chars) as a mandatory step from day one, not bolted on after it's already grown.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Frontend | React + Vite |
| Gantt/timeline | `vis-timeline` |
| Database | Postgres via Supabase (not Google Sheets — see spec §4 for why this is a deliberate departure from the SAL Operations pattern) |
| API layer | Netlify Functions (Node.js ESM), only where real server-side logic is needed — simple CRUD can go through Supabase's client + row-level security directly |
| Hosting | Netlify |
| Auth | Supabase Auth |

Full rationale in `docs/PROJECT_SPEC.md` §4.

---

## Development Commands

```bash
npm install         # run from a local (non-Drive) clone -- see LESSONS_LEARNED.md LL-001
npm run dev          # Vite dev server
npm run build        # production build
npm run lint         # ESLint
netlify dev          # local Netlify Functions + frontend together, once functions exist
```

---

## Architecture

```
Browser (React + vis-timeline, Netlify)
  ↓ direct (simple CRUD, via Supabase client + row-level security)
  ↓ or /.netlify/functions/... (only where server-side logic is needed)
Netlify Functions (Node.js ESM)
  ↓
Supabase (Postgres + Auth + Row-Level Security)
```

No Apps Script / Google Workspace layer — that was specific to SAL Operations' legacy data location, not a pattern to repeat here.

---

## Critical Rules (carried forward from SAL Operations, apply from day one)

These are real lessons from a sibling project, worth applying preemptively rather than re-discovering:

- **Netlify Functions must use ESM** (`export const handler = ...`, never `exports.handler`) — a CommonJS export crashes silently with an HTTP 500 in under 10ms and no useful log output.
- **Direct-manipulation editing is allowed** — drag a bar's edges to resize/reschedule it, and drag from a bar's edge to another bar to create a dependency link; click still opens the detail panel for everything else (status, %, notes, resources, delete). This reverses an earlier version of this rule that blanket-banned drag interaction (carried forward from SAL Operations without re-checking it against WorkFlow's own requirements — see LL-003). Every drag still writes a dated history entry on the task (event-sourced, not a silent overwrite) so the original rationale — no untracked silent edits — is preserved without needing a confirm click on every drag.
- **Event-sourced changes, not direct grid overwrites**, for anything that should have an audit trail (see spec §1).
- **Soft conflict warnings, never hard blocks** (see spec §1) — a tool that blocks on every scheduling conflict trains users to route around it instead of trusting it.
- **`vis-timeline` + React StrictMode**: mount/destroy logic must live in one `useEffect`, not split across two differently-scoped effects — StrictMode's dev-only double-invoke will destroy an instance and then try to build a second one into the same now-unusable container, silently doing nothing. (Found and fixed the hard way in the sibling project; see its `LESSONS_LEARNED_MASTER.md` LL-249's neighbor if this needs the full writeup someday.)
- **`vis-timeline` 8.x sanitizes HTML-string group content** — build real DOM elements for custom group labels, not HTML strings, or they render as literal escaped text instead of interactive elements.
- Always verify a deploy against the real live site directly — never trust a CLI's own "deploy complete" message as proof.

---

## Documentation Index

| File | Purpose |
|---|---|
| `docs/PROJECT_SPEC.md` | Vision, MVP scope, tech stack, architecture, draft schema, roadmap |
| `docs/LIVING_PROJECT_STATE.md` | Current build status — seed this in as real work happens |
| `docs/LESSONS_LEARNED.md` | Append-only log of real bugs/gotchas found while building, same format as SAL Operations' own |
