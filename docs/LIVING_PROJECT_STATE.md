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
**https://claude.ai/artifact/VG8GFdUXphmBCDqUa9sSgv** (currently version 21).

Immediate next actions, in order:
1. **User-test Round 4** (below) — bidirectional link knobs, robust drop-target hit-testing, pinned Transfers+POB, predecessor typeahead, fixed inline-column bug.
2. **Open design question from Round 4**: should bar fill color be driven by phase (one consistent color per phase group) instead of status? See "Round 4" below — not yet decided, don't build further on the current status-color scheme without an answer.
2. Once import + editing UX is solid, ask the user whether the mockup's scope is sufficient to start the real build, or whether more mockup iteration is wanted.
3. **Resolve the open distribution/architecture decision** (below) before starting real Supabase/Netlify work — it changes the backend entirely.

## Session 2026-09-22 (second session), Round 2: Gantt/drawer/import UX pass

After the PDF-import work below, the user live-tested the mockup and gave five pieces of feedback in one batch. Diagnosed and built all five directly in the mockup (no separate design/mockup phase — this artifact already is that):

1. **Import modal "mystery box" bug**: the box beside each review row's checkbox that looked broken was actually the task-name text field — its CSS (`min-width:0`) let it collapse to ~0px while sibling columns had no min-width and refused to shrink, so it alone absorbed the squeeze on a narrower viewport. Root-caused, not guessed (see LL-004's spirit). Fixed: modal widened 600→760px, every review column given a real min-width so none can collapse, column headers added, horizontal scroll added as a fallback at narrow widths.
2. **Click-to-open only worked on the Gantt bar itself**, not the task's name label in the left column — the label had no click handler at all. Added.
3. **Gantt didn't auto-scroll to a clicked task** if its dates were outside the visible viewport. Added `scrollGanttToTask()`: pans/scrolls only whichever axis (horizontal date-range / vertical row position) is actually out of view, and auto-expands the task's phase group first if it was collapsed (otherwise the row doesn't exist to scroll to).
4. **Inline optional columns beside each task** (user's original ask) got redirected during scoping to a different, more specific ask: **import-time optional field capture + Start/End/Duration consistency validation**, generalized across import paths (not hardcoded to WBS specifically, per the user's explicit correction). Built:
   - A generic "extra fields" mechanism: any import path can expose source fields beyond the mandatory Name/Start/End as opt-in checkboxes ("Also found in the source — include in each task's Notes?"), appended to Notes only if checked. For the WBS-table PDF parser: WBS code + the source's raw duration text. For Excel/CSV: any spreadsheet column left over after the existing header-matching (previously silently dropped).
   - Soft-flag (never hard-block, matching this project's own rule) data-quality issues discovered during parsing: Finish-before-Start in the source (auto-swapped back, flagged), the day/month order having to be auto-guessed, and a coarse (3×/⅓ tolerance, deliberately loose) mismatch between the source's stated Duration and the actual Start–Finish span — loose specifically because "days" in these MS Project exports usually means *working* days, not calendar days, so a strict check would false-flag most ordinary rows spanning a weekend. Flagged rows get a ⚠ with a tooltip in the review table; verified via the Node harness that real clean data produces zero false positives and synthetic bad data reliably triggers both checks.
5. **Start/End/Duration anchor system** (user's #5): drawer's Days field is now editable (was read-only display); a 📌 pin next to each of Start/End/Days marks which one stays fixed while the other two are edited — editing the pinned field itself moves the whole span duration-preserving (matches existing bar-drag-body behavior). Persisted per-task (`task.anchor`), defaults to `'start'` for tasks that predate the field. Visually flagged via a highlighted field-group background, not just the pin icon alone.

**Not yet verified in a live browser** (items 4 and 5 above — items 1–3 were simple enough to be confident in, and 4's parsing-side flag logic was regression-tested via the Node harness): the anchor recompute math and the extra-fields checkbox UI have not been clicked through in an actual browser session. Next session should start there.

## Round 3 (same session): six more findings from live testing

User live-tested Round 2 and reported six issues in one batch:
1. **Dependency-link drag "only shows up at the end of the bar"** — real UX cause, not a functional break as far as the code shows: the link knob was `opacity:0` until hover and only an 11px hit target positioned half off the bar's edge, genuinely hard to discover/grab. Enlarged the hit target (via an oversized invisible `::before`, dot itself stays small) and gave it a low base opacity so it's discoverable without already knowing to hover there. **Caveat**: couldn't rule out a genuine functional break in the drop-target detection since it can't be exercised outside a real browser — if dragging still fails to create a link after this, that points to the actual bug being elsewhere (say so and it'll get properly diagnosed, not guessed at again).
2. **"All the bars are uncolored"** — traced to a real but different cause: this session's PDF importer defaults every imported task to `status:'upcoming'` (the source PDF has no status column), and "Upcoming" bars are deliberately styled minimally (dashed outline, no fill) in the existing design — so bulk-importing ~300 tasks and looking at the result reads as "nothing has any color." Gave Upcoming bars a light phase-color wash (via `color-mix()`) instead of flat white, so a fresh import still reads as organized-by-phase at a glance while keeping the dashed-border "not started" language. Flagged as a hypothesis, not a confirmed diagnosis — ask the user to confirm this was about freshly-imported data specifically, not the original seeded Galoc project (which already has varied statuses set).
3. **Selected task now visually accentuated**: the whole row (label + timeline) tints, and the bar/milestone itself gets a colored ring — chosen over a border-only treatment because bar status colors already vary hugely (near-blank Upcoming vs. solid-filled Done), so a consistent-contrast highlight needed to work independent of the bar's own color.
4. **Inline optional columns beside each task**, actually built this time (Round 2 misread this as an import-time-only ask): a "Columns" picker in the Gantt toolbar toggles Start/End/Days/%/Status/WBS as small editable fields rendered beside the task name; the row-label column's width is now a CSS custom property (`--label-w`) driven by how many columns are on, scoped specifically to `#panel-gantt` so it doesn't leak into the Resources tab's own (differently-stywatched) row-label usage. WBS only shows real data for tasks imported via the WBS-table PDF path (now stored as `task.wbsRef`, not just optionally in Notes).
5. **Predecessor dropdown now auto-scrolls** to the chosen predecessor (reuses `scrollGanttToTask` from Round 2).
6. **POB row is now sticky** below the date axis (`position:sticky; top:44px`) so it stays visible while scrolling through a long task list, independent of the Personnel Transfers row above it (which still scrolls normally — only POB was asked for).

**Verification**: syntax-checked (`node --check`) and CSS brace-balance checked before publishing (v20) — real safety nets given the volume of changes, but none of this has been exercised in an actual browser session yet.

## Round 4 (same session): live-testing found a real bug + real design question

1. **Link-knob still not working, and user asked for knobs on both ends**: added a left-edge knob mirroring the existing right-edge one (drag left-to-target now pulls that target in as *this* task's predecessor — the reverse direction from the right knob). More importantly, replaced the drop-target detection: it was a single `document.elementFromPoint()` sample at the exact release pixel, which fails outright on short imported tasks rendered as a few-pixel sliver at Week/Month zoom (this dataset has plenty — "ICON Project Kick Off" etc.). Now scans every bar/milestone's bounding rect with a 6px tolerance. Also fixed a self-inflicted conflict: the enlarged link-knob hit-area from Round 3 overlapped the existing 7px resize-handle at the same edge; changed it to extend mostly outward (away from the bar) instead of symmetrically.
2. **"Grouped activities should be a single colour" + "is there a grouping option?"** — asked the user directly rather than guess. **Decided: no** — keep the current status-driven bar fill (done/upcoming/hold/critical/progress); phase stays a swatch dot + light tint on Upcoming bars, not the bar's main color. No code change needed; settled, don't revisit without new user input.
3. **Personnel Transfers pinned too**, not just POB (user's Round-3 answer was interpreted too literally — they'd said "only asked about POB" was noted, but this round clarified they want both). Transfers sticks at `top:44px` (right below the date axis), POB now sticks at `top:78px` (below Transfers), stacked correctly.
4. **Predecessor dropdown replaced with a real typeahead**: the user's Round-3 report that "autoscroll doesn't work" turned out to be a misdiagnosis on my part — the actual complaint was that a native `<select>` with 300+ options always opens scrolled to the top with no filtering, which no amount of auto-scrolling the *Gantt chart* behind it would fix. Replaced `<select id="dAddPred">` with a filterable text-input + results-list combobox (up to 30 matches, filtered as you type). Kept the Gantt-scroll-to-task behavior on selection since it's still useful, just wasn't the actual fix.
5. **Confirmed, concrete bug found**: `sourceDuration` (the raw duration text captured during WBS-table import, e.g. "8 ewks") was added as a toggleable inline column in Round 3 but `buildInlineCols()` had no rendering branch for its key — toggling it on silently added an empty, invisible cell. This is very likely the actual reason "I still do not see the adhoc fields" — real bug, not a discoverability issue. Fixed, and verified via a Node script that every `INLINE_COLS` key now has a matching branch (all 7: start/end/days/pct/status/wbs/srcDur) so this class of bug can't silently recur. Also fixed a minor under-sizing in the dynamic label-width math (`--label-w` wasn't accounting for the row-label's own `gap:8px` between flex children, off by 2px per enabled column — unlikely to fully explain the missing-column report on its own, but a real latent bug regardless).

**Still unverified in a live browser** — same caveat as every round this session; only regression-checkable via Node (syntax + a static "every declared column key has a handler" check), not real pointer/DOM interaction.

## Round 5 (same session): user live-tested Round 4

1. **Link-drag still reported as not working, root cause still unconfirmed.** Static review of the logic found no further bug, but did find a real gap: several failure paths (`findDropTarget` returns nothing, `fromTask`/`toTask` fails to resolve, the dependency already exists) produced **zero toast/feedback** — silent no-ops that are indistinguishable from "the feature is broken." Every branch now ends in an explicit toast (success names both tasks; failure says why: no target under the drop point, already linked, or would cycle). This won't fix a genuine remaining logic bug if one exists, but it turns any future failure into something diagnosable instead of a black box — next report should include which toast (if any) appeared.
2. **Predecessor typeahead default list reordered**: previously showed unfiltered results in raw import order (task #1 first, regardless of where the open task sits in a 300+ row schedule) — user's real complaint (misread in Round 4 as an autoscroll issue). Now sorted by proximity of each candidate's own end-date to the open task's start-date, with that date shown next to each name, so the most plausible predecessors surface without typing anything.
3. **Build/version indicator added**: `BUILD_INFO` constant in `app.js`, shown in the sidebar footer. Manually bumped by hand each publish (the artifact platform's own version id isn't readable from page JS) — inherently lags by one publish sometimes, since updating the string is itself a publish that gets a newer number. Not worth chasing further; good enough as an approximate build marker for bug reports.
4. **Asked about Predecessor-column import** (user's question, not a bug): confirmed their current real document has no such column, but it's common in this document family generally. **Deferred, not built** — matches this session's own LL-006 lesson (build a parser against a real sample, not an assumed format like Primavera's `12FS+2d` syntax). Revisit when a real document with this column is available.

## Round 6 (same session): link-drag still reported broken after two fix attempts

User tested again — link-drag drop still not registering (drawer-based predecessor selection works fine, isolating the bug specifically to the drag-knob code path, not the underlying preds/persistence system). Two rounds of static-code fixes (robust bounding-box hit-testing, then full toast coverage on every branch) haven't resolved it or even produced a toast the user mentioned seeing. Real possibility raised but not yet confirmed: **the user may be testing against a stale cached page** — Claude Artifacts don't auto-reload in an already-open tab when a new version publishes; every fix this session could be invisible without a manual refresh. Asked the user to confirm directly next.

Also this round: rewired the ghost line during a link-drag to snap onto the target's actual finish-to-start anchor point (and highlight the hovered target) instead of just following the raw cursor — addresses the user's separate "it should connect end-of-A to start-of-B, not end-to-end" report, which was likely a drag-preview clarity issue (the persisted arrow-drawing code was already end→start correct, confirmed by re-reading it). Removed an undocumented cap (30 results) on the predecessor typeahead's result list per explicit request to see the full list, not a truncated one.

**New feature request, not yet scoped or built**: user wants to press-and-hold-drag a task's row label to manually reorder tasks within a phase — currently impossible, since task order is always date-derived (`buildVisibleRows` sorts by `start`, no persisted manual-order field exists on tasks at all). Asked the user how this should interact with dates: **answered — visual only, snaps back to date order on next render/date edit.** Not yet built (deferred behind the link-knob bug below, which was the priority).

## Round 7 (same session): found the real link-knob bug

Confirmed with the user first: they *are* hard-reloading between every test (ruled out stale-cache as the explanation for the fix not landing). That meant two rounds of fixes to the drop-detection/toast logic genuinely hadn't worked — time to look harder rather than guess a fourth time.

**Root cause found**: `.bar` has `overflow:hidden` (needed to clip the progress-fill/track to the bar's rounded corners — legitimate, not itself a bug). The link knobs were rendered as *children* of `.bar`, deliberately positioned partway outside its box (`left:-6px`/`right:-6px`) so they'd sit right at the bar's edges. `overflow:hidden` was silently clipping away roughly half of each knob's visible/clickable area — and clipping away **the entire enlarged hit-area** (`::before` pseudo-element) added in Round 3, making that entire fix a complete no-op the whole time. The drop-detection and toast-feedback work from Rounds 4–6 was real improvement but was never the actual blocker.

**Fix**: knobs are now separate elements appended directly to `.row-timeline` (siblings of `.bar`, not children), positioned via inline `left`/`top` computed independently from the same `left`/`width` values the bar itself uses. `.row-timeline` has no `overflow` set, so nothing clips them or their hit-areas anymore. Lost the `.bar:hover` → full-opacity cascade in the process (that only worked while the knob was a descendant of the bar) — compensated with a higher base opacity (.5, was .35) since hover-gating no longer applies structurally.

**Not yet verified live** — same caveat as every round, but this is the first fix this session backed by an actual located root cause (a real DOM/CSS structural issue, confirmed by re-reading `.bar`'s own CSS) rather than a plausible-sounding guess. If this doesn't fix it, the bug is somewhere I haven't looked yet and static code review alone isn't going to find it — would need actual DevTools inspection (computed styles / hit-test at the failure point) next, not another guess.

## Round 8 (same session): overflow-fix didn't resolve it either; added real diagnostics

User confirmed hard-reloading between every test (ruled out staleness for real this time) and reported drag-linking *still* fails even after the overflow:hidden structural fix, while drawer-based predecessor selection keeps working fine — same isolation as before, pointing at the drag-specific code path, not the underlying preds/persistence system. Four rounds of static-code fixes across three different hypotheses (drop-detection robustness, missing toast feedback, DOM/CSS clipping) have not resolved it. Time to stop guessing.

**Added real diagnostics instead of a fifth guess**: `console.log` at every step of the drag (`pointerdown` firing, `pointerup` firing, `findDropTarget` result, resolved from/to tasks, which branch it exits through, final success state), plus a `try/catch` around the whole `onUp` body so any silently-thrown exception surfaces as both a console error and a toast telling the user to check DevTools. This turns the black box into something with actual evidence — next test should be done with the browser console (F12) open, and whatever it prints should come back verbatim rather than just "still doesn't work." One real (if unconfirmed) suspicion going into this: if a `pointercancel` fires instead of a normal `pointerup` for any reason, none of this project's own code would be responsible (searched for periodic re-renders / interval timers that could interrupt an in-progress drag — found none), so if diagnostics show *nothing at all* logs, that points outside this codebase's own logic.

**Also fixed**: the pinned Transfers/POB rows were sticky-vertically (top) but not staying sticky-horizontally (left) — the label text scrolled away instead of staying pinned like every other row's label does. Root cause: the ROW itself was `position:sticky` (vertical) with its CHILD `.row-label` ALSO independently `position:sticky` (horizontal) — nested sticky-in-sticky, a known source of browsers failing to stick the descendant correctly. Restructured so sticky is applied directly to the label and timeline elements (each independently, both axes where needed) with no sticky ancestor between them and the scroll container, instead of splitting the two axes across a sticky parent and a sticky child.

## Round 9 (same session): the diagnostics worked — real root cause found and fixed

User tested with DevTools console open and pasted back real evidence: a stack trace showing `TypeError: Cannot add property 1, object is not extensible`, thrown from `Array.unshift` inside `pushHistory`, called from the link-drag's `onUp`. Confirmed root cause:

`deserializeTasks(tasks)` (called every time a project loads from the db capability) does `{...t, start:D(t.start), end:D(t.end)}` — a shallow spread. That creates a fresh top-level task object, but nested arrays (`history`, `preds`, `resources`) are copied **by reference**, not cloned. The `db` capability's own `snap.data()` appears to return a non-extensible (frozen) snapshot — likely a deliberate platform safeguard against callers mutating a cached read instead of calling `.set()`/`.update()`. So every task loaded from a real (non-seed) project had a `history` array that stayed frozen forever, buried inside an otherwise-normal-looking mutable object. `pushHistory`'s `.unshift()` mutated that array in place → crash, every time, for every task loaded from the database (not just imported ones — this affects the original seed data too, once it's been through one persist/reload cycle).

This explains the whole shape of the bug across every round: drawer-based predecessor edits worked because `it.preds = state.pendingPreds.slice()` **replaces** the array (never touches the frozen one) — pure luck of which code path happened to reassign vs. mutate. Drag-based linking always hit `pushHistory`'s in-place `.unshift()` and crashed, every single time, regardless of the drop-detection/hit-area fixes from Rounds 3–8 — none of those were ever the actual problem. It also explains the "phantom predecessor persisted after deletion" report: `toTask.preds.push(...)` (also an in-place mutation, also on a frozen array in some cases) executed before the crash, so the in-memory object *looked* linked, but the crash happened before `persistProject()` ever ran — nothing was actually saved. A page reload clears it, since the phantom state never reached the database.

**Fixed at three points**: `deserializeTasks` now explicitly re-clones `preds`/`resources`/`history` on every load (the actual fix — every task from here on has genuinely fresh, mutable nested arrays). `pushHistory` and the link-drag's `preds` update were also changed from in-place mutation (`.unshift()`/`.push()`) to reassignment (spread into a new array) as belt-and-suspenders, so this class of bug can't recur even if some other code path ever hands either function an un-cloned array.

**This is the first fix in this whole saga backed by a real stack trace rather than a plausible-sounding guess** — high confidence this is actually it, not another round of static-analysis speculation.

## Round 10 (same session): click a dependency arrow to delete it

User's ask: delete a dependency by clicking its arrow, instead of opening the task's drawer and removing it from the predecessor chip list. Built: the visible SVG line is only ~1.4px (too thin to click reliably), so each dependency arrow now has a separate, invisible, wide (14px) hit-path sibling with `pointer-events:stroke` (the parent `<svg>` has `pointer-events:none` overall, so this opts back in individually) carrying the click handler and a hover tooltip; hovering it highlights the real line red via the adjacent-sibling CSS selector, so it's clear what's about to be removed. Click commits immediately (removes the pred, writes a history entry, persists, shows a toast) — no separate confirm step, matching how every other direct-manipulation action in this app already works (drag-to-resize, drag-to-link all commit on release). Scoped to the Gantt tab's dependency arrows only, not the Network tab's (a different, more read-only view).

**Currently at v29.**

**Also this turn**: user asked for (not yet started) a UAT framework proposal (KPIs/criteria/scoring/token-cost estimate, explicitly no execution) and a standalone-executable (Electron) conversion effort estimate — both advisory, answered in chat, not built. Git pushed with the accumulated doc updates from this whole session.

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

## PDF Import: Resolved This Session (2026-09-22, second session)

The open question from the previous session — are the user's real PDFs scanned/image-based, or extractable-but-messy? — is answered: the user shared a real source document (`GDP Master Project Schedule_20260710.pdf`, a Matahio Energy / Galoc decommissioning MS Project export) and confirmed **this is the typical case** for their real imports. It has fully selectable, well-structured tabular text (ID/WBS/Task Name/Duration/Start/Finish columns) — not scanned — but is "messy" in a different way than assumed: duplicate text (Gantt bar labels repeat every task name, plus month/quarter headers and company/page footers repeat once per PDF page), large (405 rows across 7 pages), hierarchical (WBS parent/rollup rows summarize their own children's date spans — importing them flat would double-count dates), non-standard duration units (`edays`/`ewks`/`ehrs` vs. plain `days`), and `DD/MM/YY` dates (day-first, not the `MM/DD` a naive parse would assume — genuinely ambiguous for day-values ≤12).

**Notable:** this real document is the actual source behind the mockup's seeded "Galoc FPSO Decommissioning" sample project — task names match exactly (P&A Galoc-5/6B/3ST1/4, riser/umbilical cutting, chain cutting, tow, etc.), confirming the mockup's data model already fits the real domain.

**Built:** `import.js`'s paste pane now detects this WBS-table shape (header line containing WBS/Duration/Start/Finish) and, when matched, parses it **deterministically — no AI call, no size limit** — instead of routing through the old `sample.json()` "ask Claude" path (which silently truncated at `text.slice(0,6000)`, roughly page 1.5 of a document like this). The parser:
- Correctly reads `DD/MM/YY` dates, with an auto-correct swap if a value is only valid as `MM/DD`.
- Keeps only leaf WBS rows (a row is skipped if any other row's WBS is a dotted child of it), so parent/rollup summary rows don't get imported as duplicate-spanning tasks. Verified against a real 59-row excerpt: 50 leaves, 9 rollups correctly skipped, zero bad rows.
- Groups each leaf under the **nearest ancestor whose name contains "Phase"** (e.g. WBS 3.5's "PHASE C2: Mooring Disconnection…"), falling back to the bare top-level WBS ancestor if none — verified this produces much better phase-guess groupings than naively using the top-level ancestor alone (which collapsed 50 unrelated tasks under one generic "PROJECT ENGINEERING" label in this document).
- Falls back to the existing AI-interpret path for genuinely unstructured paste text (that path's prompt also now carries an explicit day-first/month-first disambiguation hint).

**Real remaining limitation, not yet addressed:** phase-guessing still maps into the mockup's fixed 6-item `PHASES` array (hardcoded in `data.js`, no "add phase" capability exists). A real schedule like this one has ~20+ of its own phase groupings — the importer's guesses will mostly miss and fall back to `PHASES[0]`, relying on the existing per-row phase dropdown for manual correction. Whether WorkFlow needs per-project, user-defined phases (not a fixed global list) is a real product question worth raising before the real build, not just a mockup polish item.

**Follow-up same session:** the user tried Import expecting a direct PDF file picker (like Excel/CSV has) and there wasn't one — paste-only wasn't the expected UX. Added a real "Upload a PDF" file input to the paste pane, using `pdf.js` (loaded via a dynamic `import()` of the ESM build on cdnjs — v6.3.289 only ships `.mjs`, no legacy UMD build) for client-side text extraction, feeding the same deterministic parser. Text lines are reconstructed from `pdf.js`'s own `item.hasEOL` heuristic per page. The WBS-row regexes were loosened to drop their trailing `$` anchor so a stray interleaved Gantt-bar-label fragment appended to the same extracted line (a real risk of `pdf.js`'s left-to-right/top-to-bottom text-extraction order not perfectly matching this document's two-region layout — data table + overlaid Gantt chart) doesn't break the match; re-verified via the Node harness with a synthetic trailing-garbage case, no regressions (still 50/59 leaves, 0 bad rows).

**Not yet done / genuinely unverified:** none of this has been tested in a real browser — Node can't exercise `pdf.js`'s DOM/Worker-dependent PDF-parsing path, only the regex/date logic downstream of it. The line-reconstruction quality for a real two-column (table + Gantt chart) PDF page is a real unknown until tried live. Have the user try Import → Paste tab → "Upload a PDF" with a real file before treating this as closed.

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
