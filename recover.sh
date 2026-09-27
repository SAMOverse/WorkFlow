#!/usr/bin/env bash
set -e
export PS4='+\t $ '
exec 2>&1
echo "=== WORKFLOW-REVIEW DIR RECOVERY ==="
echo "PWD: $(pwd)"
echo ""
echo "=== Files present in working dir ==="
ls -la
echo ""
echo "=== Re-initialize git for gh-pages branch ==="
# The .git was accidentally removed. Re-init a fresh repo.
# Current working dir has the mockup files at root (index.html, app.js, etc.)
# which is exactly the content we want on gh-pages.
git init
echo ""
echo "=== Set git identity ==="
git config user.name "SAMOverse Bot"
git config user.email "samoverse@users.noreply.github.com"
echo ""
echo "=== Add remote (fork owner) ==="
git remote add origin git@github.com:SAMOverse/WorkFlow.git 2>/dev/null || git remote set-url origin git@github.com:SAMOverse/WorkFlow.git
echo "Remote origin: $(git remote get-url origin 2>/dev/null || echo 'not set')"
echo ""
echo "=== Stage all files ==="
git add -A
echo ""
echo "=== Git status before commit ==="
git status --short
echo ""
echo "=== Commit ==="
git commit -m "init gh-pages: WorkFlow mockup (standalone artifact)

Deployed from mockup/ directory of master branch.
Standalone HTML/CSS/JS Gantt planner — no build step, no server.
See master branch for the full React+Vis-Timeline+Supabase scaffold
which is not yet built.

Co-authored-by: Hermes Agent <hermes@nousresearch.com>"
echo ""
echo "=== Verify commit ==="
git log --oneline -1
echo ""
echo "=== Current branch ==="
git branch --show-current
echo ""
echo "=== All branches (local) ==="
git branch -a 2>/dev/null || echo "(no other branches — fresh repo)"
echo ""
echo "=== DONE: ready to push gh-pages ==="
