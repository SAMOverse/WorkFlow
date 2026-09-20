# WORKFLOW - LIVING PROJECT STATE
**Version:** 0.1
**Last Updated:** 2026-09-20
**Auto-Update:** Every session close

---

## Current Status

**Overall Progress:** 0% — spec + scaffolding only, no app code written yet.

Repo scaffolded 2026-09-20: `docs/PROJECT_SPEC.md` (full vision/scope/architecture), `CLAUDE.md`, a bare Vite + React starter, a placeholder Netlify function, a draft Supabase schema (not yet applied to a real Supabase project — no Supabase project exists yet). GitHub repo created and pushed. Nothing has been built against the MVP scope in `PROJECT_SPEC.md` §3 yet.

---

## Session Start Protocol

**As of 2026-09-20:** Fresh scaffold, first session. Next session should read `docs/PROJECT_SPEC.md` in full (short enough that this is cheap right now — revisit once it isn't), then start on MVP scope item 1 from spec §3: **Projects** — probably the actual first build step is standing up a real Supabase project and applying the draft schema (spec §5), since nothing else can be built against real data until that exists.

---

## Completed Work

- **2026-09-20:** Project spun off from SAL Operations' Rotation Forecast module. Spec written, repo scaffolded (Vite + React starter, placeholder Netlify function, draft schema), GitHub repo created (private) and pushed.

---

## Next Steps

1. Create a real Supabase project, apply the draft schema from `PROJECT_SPEC.md` §5 (expect to refine it once real data flows through it).
2. Wire the frontend to Supabase (auth + a basic Projects list) — the smallest possible "hello world" that proves the stack end-to-end before building the Gantt view itself.
3. Build the Gantt/timeline view (MVP scope, spec §3) — reuse `vis-timeline` integration knowledge from the sibling SAL Operations project (see this repo's `CLAUDE.md` "Critical Rules").
