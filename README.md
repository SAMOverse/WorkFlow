# WorkFlow

A user-friendly, web-based project/resource scheduling tool — a Gantt-based planner aimed at being an intuitive alternative to Microsoft Project / Primavera P6.

Spun off from a validated idea in a sibling project's crew-rotation timeline: click-to-edit over drag-to-resize, event-sourced schedule changes, and soft (never-blocking) conflict warnings.

**Status:** Pre-alpha — spec and scaffolding only. See [`docs/PROJECT_SPEC.md`](docs/PROJECT_SPEC.md) for the full vision, MVP scope, and tech stack, and `CLAUDE.md` for AI-assistant working conventions on this repo.

## Stack

React + Vite · `vis-timeline` · Supabase (Postgres + Auth) · Netlify Functions · Netlify hosting.

## Getting started

```bash
npm install
npm run dev
```

Netlify Functions require the Netlify CLI once real functions exist:

```bash
netlify dev
```
