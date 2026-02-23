# 📋 FILE INVENTORY & STATUS

> **v3 Status (2026-02-22):** Preferred runner is `scripts/enhanced-copilot-review-v3.sh`. Legacy scripts remain for compatibility.
> **v3.1 Update (2026-02-23):** Runner now supports `--repo-root <path>` and `--model <id>` (default `gpt-5-mini`), and `<code-path>` may be `.` when no `src` folder exists.

**Last Updated:** February 22, 2026  
**Status:** ✅ Current and v3-compliant

---

## ✅ Parameter Semantics (Mirrored)

`./scripts/enhanced-copilot-review-v3.sh <base-branch> <head-branch> <code-path> [--repo-root <path>] [--model <id>]`

- `<base-branch>`: baseline ref used for comparison
- `<head-branch>`: branch/ref being reviewed
- `<code-path>`: scoped folder/file (use `.` for full repo)
- `--repo-root`: optional target repository root when reviewing an external project directory

Example (generic):

```bash
./scripts/enhanced-copilot-review-v3.sh origin/develop feature/auth src --repo-root /path/to/external-repo --model gpt-5-mini
```

## ✅ Antigravity Ignore List (Mirrored)

- Default blocked path: `skills/windows-privilege-escalation/SKILL.md`
- Extra entries per run: `ANTIGRAVITY_IGNORE_PATHS_EXTRA` (colon-separated)

```bash
ANTIGRAVITY_IGNORE_PATHS_EXTRA="skills/path1/SKILL.md:skills/path2/SKILL.md" \
./scripts/enhanced-copilot-review-v3.sh main feature/auth .
```

---

## ✅ Current Structure Snapshot

- Root docs present: `README.md`, `QUICK_START.md`, `PROJECT_SUMMARY.md`, `FILE_INVENTORY.md`, `DELIVERY_SUMMARY.md`
- Docs present: `docs/ARCHITECTURE.md`, `docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md`, `docs/INTEGRATION.md`, `docs/EXAMPLES.md`, `docs/TROUBLESHOOTING.md`
- Guides present: Java, Python, React, AWS, Terraform guides in `guides/`
- Scripts present in `scripts/`:
  - `enhanced-copilot-review-v3.sh` (preferred)
  - `enhanced-copilot-review-v2.sh` (legacy)
  - `enhanced-copilot-review.sh` (legacy)

---

## ✅ v3 Compliance Checks

- Operational examples now use `scripts/enhanced-copilot-review-v3.sh`
- CI/CD snippets reference v3 command path
- Troubleshooting and architecture docs reference v3 runtime
- Legacy script mentions are only for backward compatibility context

---

## ✅ Recommended Verification Commands

```bash
# Script syntax check
bash -n scripts/enhanced-copilot-review-v3.sh

# Basic usage check
./scripts/enhanced-copilot-review-v3.sh || true

# Run a review on a real diff (example)
./scripts/enhanced-copilot-review-v3.sh <base-branch> <head-branch> .
```

---

## Notes

- v3 requires GitHub CLI (`gh`) and Copilot extension/auth for full AI execution.
- If unauthenticated, complete `gh auth login` before running end-to-end AI review.