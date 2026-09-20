# LESSONS LEARNED — WorkFlow
**Status:** 1 lesson so far.
**Next lesson number:** LL-002

---

Format for each entry (matches the sibling SAL Operations project's convention):

```markdown
### LL-XXX: One-line summary of the lesson
`[Category]`
What happened, concretely — the real symptom, not a hypothetical.
**Why:** the underlying reason, so future-you can judge edge cases.
**How to apply:** the concrete rule to follow going forward.
```

### LL-001: `npm install` Fails Reliably Inside This Project's Google-Drive-Synced Folder
`[Environment / Google Drive]`
Confirmed twice, reproducibly, right at scaffolding time: `npm install` run directly inside `H:\My Drive\Claude Projects\WorkFlow\` fails with `EPERM: operation not permitted, rmdir ...` during npm's own cleanup pass, followed by `EBADF: bad file descriptor`, leaving a near-empty `node_modules` (no `.bin`, nothing usable). The exact same `package.json` installed cleanly (87 packages, clean build) copied to a plain local temp folder outside Drive sync. This is the same class of issue the sibling SAL Operations project has documented and partially worked around (Drive's virtual filesystem adds real per-file I/O overhead and, for npm specifically, breaks its rename/rmdir dance during a large multi-file install like `node_modules`) — but here it's an outright failure, not just slowness.
**Why:** Google Drive's local sync client intercepts file operations on a virtual filesystem layer; npm's install process does rapid create/rename/delete cycles across thousands of small files (`node_modules`), which Drive's sync layer doesn't handle as a plain local disk would.
**How to apply:** Never run `npm install` (or anything that writes a large `node_modules`) directly inside this repo's Drive-synced path. `node_modules` is gitignored anyway, so nothing is lost by keeping it out of Drive entirely — either work from a plain local git clone (recommended; matches what SAL Operations' own unresolved "Someday" item already recommends doing for itself), or, if working directly in the Drive folder is preferred for some other reason, install into a local path and symlink `node_modules` back in. `git` operations (status/add/commit/push) on the source files themselves are unaffected — only npm's own install-time file churn triggers this.
