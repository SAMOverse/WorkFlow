# WorkFlow — Project Spec

**Status:** Pre-alpha / spec stage. Nothing built yet beyond scaffolding.
**Version:** 0.1
**Last Updated:** 2026-09-20

---

## 1. Origin

This project spins off a real, validated idea from SAL Operations' **Rotation Forecast** module — a crew-scheduling Gantt/timeline view built and live-tested there. At its core, crew rotation scheduling is just resource-constrained project scheduling: people (resources) assigned to time blocks (tasks), with dependencies (a relief crew can't start before the outgoing crew signs off), conflicts (double-booking), and a timeline view as the primary interface.

That module proved out three real design decisions worth carrying forward rather than re-deriving:

1. **Click-to-edit, not drag-to-resize.** Direct manipulation on a Gantt bar (dragging an edge to change a date) requires inferring *what kind* of change the user meant — genuinely ambiguous, and a real risk of silently making the wrong change. Click a block → open a detail panel pre-filled with context → the user confirms the actual change explicitly. Same interaction cost, none of the ambiguity risk.
2. **Event-sourced changes, not direct overwrites.** A schedule is a *projection* computed from a base plan plus a log of logged deviations/events, not a directly-editable grid of cells. This gives a free audit trail and makes "why does the schedule say this" always answerable.
3. **Soft conflict warnings, never hard blocks.** Overallocation, double-booking, and similar conflicts get a visible badge, never a blocking validation. Real-world scheduling constantly has legitimate exceptions; a tool that blocks on every conflict trains its users to route around it.

## 2. Vision

A **web-based, intuitive project/resource scheduling tool** — the planning power of Microsoft Project or Primavera P6, without the complexity, the desktop-bound licensing, or the multi-day training curve. Aimed at a small team or single planner who wants a real Gantt chart with dependencies and resource assignments, and wants to be productive in minutes, not days.

This is explicitly **not** trying to match Primavera's enterprise feature depth (multi-project portfolios, earned-value analysis, resource cost rollups across a whole organization) on day one. It's trying to match the **20% of features that cover 80% of real use** — task scheduling, dependencies, resource assignment, a clear timeline view — with software that doesn't fight the user.

### Who it's for

- A small team lead or solo planner running one or a handful of concurrent projects.
- Someone who has tried MS Project and found it overwhelming, or tried a simple to-do app and found it too shallow (no dependencies, no resource view).
- Not (initially) targeting large enterprise portfolio management — that's Primavera's real turf, and matching it isn't the goal.

### What "more user-friendly" concretely means

| Primavera / MS Project | WorkFlow |
|---|---|
| Desktop install (Project) or heavyweight enterprise deployment (Primavera) | Runs in a browser, any device |
| Dense toolbar-and-grid-first UI, steep learning curve | Timeline-first, click-to-edit, minimal chrome |
| Every field configurable — power, but overwhelming for a first-time user | Sensible defaults, progressive disclosure (advanced fields hidden until needed) |
| Complex dependency types (SS/FF/FS/SF with lag, in all combinations) | Start with Finish-to-Start (the 90% case); add other types only once FS is solid |
| Conflicts often block or require explicit override dialogs | Soft badges, never blocking (see Origin, above) |

## 3. MVP scope (v1 — build this first)

The smallest version that proves the core loop end-to-end:

- **Projects** — a project has a name, a date range, and belongs to the current user.
- **Tasks** — name, start date, end date/duration, % complete, belongs to a project, optional parent task (simple one-level grouping, not deep WBS nesting yet).
- **Resources** — people (or equipment) that can be assigned to tasks. A resource has a name and a simple daily capacity (e.g. 1.0 = fully available).
- **Assignments** — a task can have zero or more resources assigned.
- **Dependencies** — Finish-to-Start only for v1. Task B cannot start before Task A finishes (displayed, not rigidly enforced — a soft warning if violated, per the "never blocks" principle).
- **Timeline / Gantt view** — the primary screen. One row per task OR per resource (toggle), colored bars for duration, a today-line, zoom presets (matches the pattern already proven in Rotation Forecast).
- **Click-to-edit** — clicking a bar opens a detail panel (dates, % complete, assigned resources, notes). No drag-to-resize in v1.
- **Overallocation warning** — a resource assigned to overlapping tasks beyond its capacity gets a soft visual flag on the timeline. Never blocks assignment.
- **Milestones** — a zero-duration task variant, rendered as a diamond marker.

### Explicitly out of scope for v1

Critical path calculation, baselines (planned vs. actual tracking), cost/budget tracking, multi-project resource pooling, calendars/holidays, MS Project/Primavera file import-export, real-time multi-user collaboration, mobile-native app, task templates, non-FS dependency types, deep WBS nesting. All real, all candidates for v2+ — see §6.

## 4. Tech stack

Reusing what's proven to work well from SAL Operations, and deliberately **not** repeating its one real architectural regret:

| Layer | Choice | Why |
|---|---|---|
| Frontend | React + Vite | Familiar, fast dev loop, already proven across 3 of this user's projects |
| Gantt/timeline | `vis-timeline` to start | Free, proven — SAL Ops already found and fixed its two real integration bugs (React StrictMode double-mount, HTML-sanitized group labels), so this project inherits that knowledge instead of re-discovering it. Revisit only if its limits are actually hit (e.g. `frappe-gantt`, `dhtmlx-gantt` as later alternatives) |
| Backend data store | **A real relational database (Postgres via Supabase), not Google Sheets** | This is the one deliberate change from the SAL Operations pattern. Sheets-as-database worked at ~5-crew scale but has no real relational integrity — no foreign keys, no transactions, awkward for tasks/dependencies/assignments which are inherently relational. SAL Ops's own "Someday" list already flags this as a regret worth fixing eventually; WorkFlow starts correctly instead of migrating later |
| API layer | Netlify Functions (Node, ESM) | Same proxy-function pattern already proven reliable across this user's projects; Supabase's client can also be called directly from the browser with row-level security, so functions are only needed where server-side logic (not just CRUD) is required — decide per-endpoint, don't force everything through a function unnecessarily |
| Hosting | Netlify | Minimizes new-tool learning curve for a side project meant to be low-friction |
| Auth | Supabase Auth (email/password to start) | Single-user or small-team scope initially; defer any multi-tenant complexity |

## 5. Architecture (initial)

```
Browser (React + vis-timeline, Netlify)
  ↓ (direct, for simple CRUD, via Supabase client + row-level security)
  ↓ (or /.netlify/functions/... for anything needing server-side logic)
Netlify Functions (Node.js ESM) ← only where real logic is needed, not a blanket proxy layer
  ↓
Supabase (Postgres + Auth + Row-Level Security)
```

Unlike SAL Operations, there's no Google Apps Script layer here — that existed only because SAL's data already lived in Google Sheets/Workspace. WorkFlow has no such legacy constraint, so the architecture is one layer flatter from day one.

### Draft schema (starting point, not final — refine once real use starts surfacing gaps)

```sql
create table projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users not null,
  name text not null,
  start_date date,
  end_date date,
  created_at timestamptz default now()
);

create table resources (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects not null,
  name text not null,
  capacity numeric default 1.0,  -- 1.0 = fully available per day
  created_at timestamptz default now()
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects not null,
  parent_task_id uuid references tasks,  -- simple one-level grouping
  name text not null,
  start_date date not null,
  end_date date not null,
  percent_complete numeric default 0,
  is_milestone boolean default false,
  notes text,
  created_at timestamptz default now()
);

create table task_assignments (
  task_id uuid references tasks not null,
  resource_id uuid references resources not null,
  primary key (task_id, resource_id)
);

create table task_dependencies (
  predecessor_task_id uuid references tasks not null,
  successor_task_id uuid references tasks not null,
  -- v1: finish-to-start only, so no dependency_type column yet -- add
  -- it later (SS/FF/SF) rather than modeling unused flexibility now
  primary key (predecessor_task_id, successor_task_id)
);
```

## 6. Roadmap beyond v1 (not building yet, captured so nothing's lost)

Roughly in likely priority order, but not committed — revisit once v1 is actually in use:

1. **Critical path calculation** — highlight the chain of tasks that directly determines project end date.
2. **Baseline tracking** — save a snapshot of the plan, compare planned vs. actual over time.
3. **More dependency types** — SS/FF/SF, with lag/lead time.
4. **Calendars** — working days, holidays, per-resource availability exceptions.
5. **Cost/budget tracking** — per-task or per-resource cost, rollup to project budget.
6. **Multi-project resource pooling** — see a resource's commitments across every project at once (this is close to Rotation Forecast's original crew-view — natural fit).
7. **Import/export interop** — MS Project XML or CSV import, for migrating an existing plan in.
8. **Real-time collaboration** — multiple people editing the same project live.
9. **Task templates** — reusable task-list skeletons for recurring project types.
10. **Deeper WBS nesting** — beyond the one-level parent/child grouping in v1.

## 7. Open questions (decide when they actually come up, not now)

- Multi-project view: is there ever a "see everything across all my projects" screen, or is each project always viewed in isolation? (Relates to roadmap item 6.)
- Should resource capacity vary by day (e.g. part-time on Fridays), or is a flat per-resource capacity enough for v1? Current draft schema assumes flat.
- Timeline row granularity: day-level to start, or does hour-level ever matter for this user's real use cases?
