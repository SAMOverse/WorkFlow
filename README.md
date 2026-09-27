# WorkFlow mockup — source snapshot

This folder mirrors the live, interactive Claude Artifact mockup — a multi-file vanilla JS/HTML/CSS app, not built with Vite/React. It is checked in here for external review (not published via the Artifact's own sharing, which requires a claude.ai account or an unlisted public link).

Live version: v35 — https://claude.ai/artifact/VG8GFdUXphmBCDqUa9sSgv (private; not accessible from this snapshot)

- `index.html` — page shell and all modal/drawer markup
- `data.js` — seed data, date helpers, phase list
- `app.js` — Gantt/Resources/Network/Guide rendering, drag interactions, WBS grouping
- `import.js` — import wizard (WorkFlow JSON, Excel/CSV, PDF/WBS-table parser, AI-interpret fallback)
- `style.css` — all styling, light/dark theme tokens

This is a **snapshot**, not a build artifact — it will drift from the live mockup unless re-synced after future sessions. See `docs/LIVING_PROJECT_STATE.md` for current status and `docs/LESSONS_LEARNED.md` for known gotchas before touching drag/CSS-positioning code or template-literal string content in `app.js`.
