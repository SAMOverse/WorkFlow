# LESSONS LEARNED — WorkFlow
**Status:** 2 lessons so far.
**Next lesson number:** LL-003

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

### LL-002: A Loose `^` Version Range on `eslint-plugin-react-hooks` Resolved to an Incompatible Config Shape
`[Tooling / ESLint]`
Scaffolded `eslint.config.js` by copying the sibling SAL Operations dashboard's working pattern (`reactHooks.configs.flat.recommended`), but wrote `"eslint-plugin-react-hooks": "^5.0.0"` in `package.json` from memory instead of checking what version the sibling project actually has installed (`^7.1.1`). npm resolved `^5.0.0` to `5.2.0` — a real published version, but one whose `configs` export dropped the `flat` namespace entirely (it exposes `recommended`, `recommended-legacy`, `recommended-latest` instead), so the copied config line crashed with `Cannot read properties of undefined (reading 'recommended')`. Fixed by pinning the same major version range the sibling project actually uses (`^7.1.1`), not by chasing the newer API shape — confirmed the original `flat.recommended` line is correct once the version matches.
**Why:** A config snippet copied from a working sibling project is only actually valid for the *version* of that dependency the sibling project has installed — the same import path (`configs.flat.recommended`) is a real, working API in one major version and a `TypeError` in another. Guessing a version range "from memory" instead of checking the sibling's `package.json` directly is exactly how this mismatch happened.
**How to apply:** When copying a config pattern (ESLint, Babel, bundler config, etc.) from another project in this same account, copy its dependency *versions* too, not just the config file's contents — grep the sibling project's `package.json` for the exact range in use rather than writing a plausible-looking one from memory. If a copied config throws on a method/property that "should" exist, suspect a version mismatch before assuming the copied code is wrong.
