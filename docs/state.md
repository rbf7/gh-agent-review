# Project state

**Last updated:** 2026-11-21 (agent files brought to the org standard), by Claude Code.

## Where we are

- A Bash wrapper around the GitHub Copilot CLI that runs a multi-agent code review and writes
  JSON and Markdown reports (`README.md`, `scripts/enhanced-copilot-review-v3.sh`).
- No functional change since 2026-02-23. No tests, no workflows.

## Open items

1. **Maintain or archive** (owner decides first). The README calls the tool production-ready,
   its version notes disagree (v1.0.1 and v3/v3.1), and five root summary files
   (`DELIVERY_SUMMARY.md`, `FILE_INVENTORY.md`, `FILE_INVENTORY_STATUS.md`, `PROJECT_SUMMARY.md`,
   `QUICK_START.md`) repeat the README.
2. The script overwrites `.github/copilot-instructions.md` in the repository it reviews
   (`create_copilot_instructions` in `scripts/enhanced-copilot-review-v3.sh`), this repo
   included by default. It should leave an existing file alone and write its own instructions
   elsewhere. Until then `.gitignore` keeps hiding that file here (see `AGENTS.md`).
3. The script clones the `awesome-copilot` and `antigravity-awesome-skills` repositories at run
   time from their default branch. Pin both to a commit.
4. Owner: confirm a ruleset protects `main` (Settings → Rules → Rulesets).

## Next actions

1. Owner: item 4, then item 1. Items 2 and 3 only if the tool is maintained.
