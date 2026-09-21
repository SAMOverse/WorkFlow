# WORKFLOW - LIVING PROJECT STATE
**Version:** 0.3
**Last Updated:** 2026-09-22
**Auto-Update:** Every session close

---

## Session Start Protocol

**Read this file first.** Then, only if you need deeper context:
- `docs/PROJECT_SPEC.md` §3 (MVP scope) — the mockup below covers it, plus more (Network/CPM, POB, transfers, shifts weren't in the original spec draft — see "Scope Grown Beyond Spec" below).
- `docs/LESSONS_LEARNED.md` — skim headers; LL-003 through LL-005 are all from this session and are load-bearing for anyone touching the mockup's CSS or import code.

**The interactive mockup is live and is the current source of truth for UX decisions**, not this doc's prose:
**https://claude.ai/artifact/VG8GFdUXphmBCDqUa9sSgv** (currently version 14).

Immediate next actions, in order:
1. **Verify the two fixes from the end of today's session actually work** — neither was confirmed by the user before close:
   - Excel/CSV import: switched from `readAsBinaryString` to `readAsArrayBuffer` (see LL-005). Test with a real `.xlsx` file.
   - PDF import: the user is skeptical the "paste text → ask Claude to structure it" approach will work for their real source documents (likely scanned/image PDFs with no selectable text, or layouts messy enough that even selectable text pastes unusably). This needs a product conversation, not just a code fix — see "Open Decision: PDF Import" below.
2. Once import is solid, ask the user whether the mockup's scope is sufficient to start the real build, or whether more mockup iteration is wanted.
3. **Resolve the open distribution/architecture decision** (below) before starting real Supabase/Netlify work — it changes the backend entirely.

---

## Current Status

**Overall Progress:** Still 0% real app code (no Vite/React/Supabase work started) — but the interactive mockup is now extremely deep, far beyond a static prototype. It has its own working persistence, import/export, and full CRUD, built entirely on the Claude Artifacts platform (no external backend). Treat it as a high-fidelity, clickable spec, not throwaway.

**What the mockup actually does today** (multi-file Artifact: `index.html`, `style.css`, `data.js`, `app.js`, `import.js`):
- **Gantt tab** — phase-grouped tasks/milestones, drag to reschedule, drag edge to resize, drag bar-edge-to-bar to link dependencies (cycle-safe), a Personnel Transfers lane (heli/boat, multiple per day, full manifest editor), a toggleable POB (persons-on-board) lane with per-day headcount numbers, Day/Week/Month zoom.
- **Resources tab** — full roster (add/edit/delete), shift patterns (Day/Night presets + custom, editable hours), per-resource utilization heatmap, POB total row with an editable cap.
- **Network tab** — auto-generated critical-path (CPM) diagram: float per task, critical path highlighted, a flag where a task's resource assignment overlaps a capacity conflict.
- **Guide tab** — in-app onboarding flow (flowchart-style, not prose).
- **Projects** — create/rename/change-status/delete, not fixed to the three seeded examples (Galoc FPSO Decommissioning / Nido Platform Refit / Tanjung Riser Replacement — all just sample reference data now, freely editable/deletable like anything else).
- **Persistence** — the artifact's own bundled `db` capability (a small JSON doc store tied to the artifact itself). Survives reloads, republishes, works standalone with no Supabase project. This is a real, working demonstration of the "bundled small db, most projects aren't massive" direction discussed mid-session — see the open decision below.
- **Import** — WorkFlow JSON backup (full restore, previews the overwrite before committing), Excel/CSV (auto-matches columns, reviewable/editable staged rows before import), paste-text (asks Claude via the `sample` capability to structure pasted text — e.g. from a PDF — into the same reviewable row list).
- **Export** — full workspace as `.json` (round-trips with Import), current project's tasks as `.csv`.
- **Print** — native browser print dialog + a dedicated `@media print` stylesheet; scaling/page-range use the browser's own print controls, not custom UI.

**Critical rule reversed this session**: `CLAUDE.md`'s original "click-to-edit, not drag-to-resize" rule (carried forward from SAL Operations without the user ever actually deciding it for WorkFlow) is gone. Direct manipulation (drag to move/resize/link) is now the intended interaction model; every drag still writes a dated history entry rather than silently overwriting. See LL-003.

---

## Open Decision: Distribution & Backend Architecture

**Not yet committed.** This has come up twice now and needs a real decision before real build work starts, because it changes the backend entirely:

| | Hosted (original spec: Netlify + Supabase/Postgres) | Standalone (Electron + bundled local db) |
|---|---|---|
| Install | none, share a link | real installer, packaging/signing becomes ongoing work |
| Data | Postgres, multi-device/multi-user sync | SQLite or similar, single-device unless sync is built separately |
| Offline | no | yes |
| Fits "most projects aren't massive"? | over-provisioned for a small crew schedule | closer fit |

The user's own language this session ("bundled small db," "standalone exe") leans toward the right column, but nothing's been formally decided. **Ask directly at the start of next session** rather than assuming — if standalone is confirmed, update `PROJECT_SPEC.md` §4's architecture section (it currently documents the Supabase choice as deliberate) and this file's tech stack assumptions before writing any real code.

## Open Decision: PDF Import

The mockup's PDF path is "paste selectable text → Claude structures it into a task list." The user flagged before session close that this likely won't work for their real documents. Don't assume the fix is technical (better prompting, etc.) without first asking: are their real PDFs scanned/image-based (no extractable text at all — paste-text can never work for these, only OCR would, which is a much bigger addition), or is the text extractable but messy? The answer changes what's worth building next.

---

## Scope Grown Beyond Original Spec

These came from user feedback during mockup iteration, not from `PROJECT_SPEC.md`'s original MVP list — worth folding into the spec once the mockup phase closes, since they're now expected behavior, not extras: the Network/critical-path view, personnel transfer logistics (heli/boat), POB (persons-on-board) capacity tracking, shift patterns, and the import/export/print tooling.

---

## Completed Work

- **2026-09-20:** Project spun off from SAL Operations' Rotation Forecast module. Spec written, repo scaffolded (Vite + React starter, placeholder Netlify function, draft schema), GitHub repo created (private) and pushed.
- **2026-09-21:** Design discussion session — confirmed mockup-first approach and its scope. No code written.
- **2026-09-22:** Long mockup-build session. Built the full interactive Artifact described above across ~14 published versions: initial Gantt/Resources mockup with realistic offshore decommissioning sample data → full CRUD, drag-based direct manipulation, Network/CPM tab, POB tracking, personnel transfers, shift patterns, Guide tab → bundled-db persistence (standalone, no backend) → three real scroll/layout bugs found and fixed (see LL-003–LL-005) → import/export/print (JSON, Excel/CSV, paste+AI, native print) → full project lifecycle (create/rename/close/delete, no longer fixed to the seed data).

---

## Next Steps

1. Verify the Excel-import and PDF-import situations with the user (see Session Start Protocol above) before touching anything else.
2. Get a real answer on the hosted-vs-standalone architecture decision; update `PROJECT_SPEC.md` §4 accordingly once decided.
3. Ask whether the mockup's scope is now sufficient to start the real build, or whether more iteration is wanted first.
4. Once scope is confirmed: fold the "grown beyond spec" items into `PROJECT_SPEC.md`, then start the real build — Supabase project (or SQLite, per the architecture decision) applying the schema, frontend auth + basic CRUD, then the real Gantt view (reusing `vis-timeline` integration knowledge from SAL Operations per this repo's `CLAUDE.md` "Critical Rules" — note direct-manipulation drag is now in scope for the real build too, not just the mockup).
