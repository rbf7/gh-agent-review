#!/bin/bash

################################################################################
# Enhanced Copilot Code Review Script v3.0.0
#
# v3 merges v1's real GitHub CLI + Copilot review execution with v2's
# orchestration, stack-aware setup, and reporting model.
#
# Usage:
#   ./scripts/enhanced-copilot-review-v3.sh <base-branch> <head-branch> <code-path> [--strict]
#   ./scripts/enhanced-copilot-review-v3.sh main feature/auth ./src
#   ./scripts/enhanced-copilot-review-v3.sh main HEAD . --strict
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COPILOT_DIR="${PROJECT_ROOT}/.copilot"
INSTRUCTIONS_DIR="${COPILOT_DIR}/instructions"
AGENTS_DIR="${PROJECT_ROOT}/.github/agents"
REPORTS_DIR="${PROJECT_ROOT}/reports"
AWESOME_COPILOT_DIR="${COPILOT_DIR}/awesome-copilot"
ANTIGRAVITY_DIR="${COPILOT_DIR}/antigravity-awesome-skills"

DETECTED_STACKS=""
STRICT_MODE=false

# ============================================================================
# LOGGING
# ============================================================================

log_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_info() { echo -e "${CYAN}ℹ️  ${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }
log_action() { echo -e "${MAGENTA}▶  ${1}${NC}"; }

# ============================================================================
# VALIDATION
# ============================================================================

validate_prerequisites() {
    log_header "VALIDATING PREREQUISITES"

    local missing_tools=()
    for tool in git gh jq; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
            log_error "Missing: $tool"
        else
            log_success "Found: $tool"
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: brew install ${missing_tools[*]}"
        return 1
    fi

    if ! git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository: $PROJECT_ROOT"
        return 1
    fi
    log_success "Git repository verified"

    if ! gh auth status >/dev/null 2>&1; then
        log_warning "GitHub CLI is not authenticated. Run: gh auth login"
    else
        log_success "GitHub CLI authenticated"
    fi

    if gh copilot -- --help >/dev/null 2>&1; then
        log_success "GitHub Copilot CLI available"
    else
        log_warning "GitHub Copilot CLI not initialized. Attempting non-interactive setup..."
        printf 'y\n' | gh copilot -- --help >/dev/null 2>&1 || true

        if gh copilot -- --help >/dev/null 2>&1; then
            log_success "GitHub Copilot CLI initialized"
        else
            log_error "Failed to enable GitHub Copilot CLI"
            return 1
        fi
    fi

    return 0
}

setup_directories() {
    log_header "SETTING UP DIRECTORIES"
    mkdir -p "$COPILOT_DIR" "$INSTRUCTIONS_DIR" "$AGENTS_DIR" "$REPORTS_DIR"
    log_success "Directories created/verified"
}

# ============================================================================
# STACK DETECTION
# ============================================================================

detect_stacks() {
    log_header "DETECTING TECHNOLOGY STACKS"

    local code_path="$1"
    local detected=()

    [ -d "$code_path" ] || code_path="$PROJECT_ROOT/$code_path"

    if find "$code_path" -type f \( -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" -o -name "*.java" \) | grep -q .; then
        detected+=("java")
    fi

    if find "$code_path" -type f \( -name "requirements.txt" -o -name "setup.py" -o -name "Pipfile" -o -name "pyproject.toml" -o -name "*.py" \) | grep -q .; then
        detected+=("python")
    fi

    if find "$code_path" -type f \( -name "package.json" -o -name "package-lock.json" -o -name "tsconfig.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" \) | grep -q .; then
        detected+=("typescript")
    fi

    if find "$code_path" -type f \( -name "*.tsx" -o -name "*.jsx" \) | grep -q .; then
        detected+=("react")
    fi

    if find "$code_path" -type f \( -name "*.tf" -o -name "terraform.tfvars" -o -name "*.tfvars" \) | grep -q .; then
        detected+=("terraform")
    fi

    if grep -R -i -E "aws|lambda|cloudformation|cdk|terraform" "$code_path" 2>/dev/null | head -1 | grep -q .; then
        detected+=("aws")
    fi

    if [ ${#detected[@]} -eq 0 ]; then
        detected+=("generic")
        log_warning "No specific stack detected, using generic"
    fi

    DETECTED_STACKS="$(printf '%s\n' "${detected[@]}" | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/ $//')"

    for stack in $DETECTED_STACKS; do
        log_success "Detected: $stack"
    done
    log_info "Final stacks: $DETECTED_STACKS"
}

# ============================================================================
# INSTRUCTIONS
# ============================================================================

download_awesome_copilot() {
    log_header "DOWNLOADING AWESOME COPILOT"

    if [ -d "$AWESOME_COPILOT_DIR/.git" ]; then
        log_info "Updating awesome-copilot repository..."
        git -C "$AWESOME_COPILOT_DIR" pull origin main --quiet 2>/dev/null || true
    else
        log_action "Cloning awesome-copilot repository..."
        git clone --depth 1 --branch main https://github.com/github/awesome-copilot.git "$AWESOME_COPILOT_DIR" 2>/dev/null || {
            log_warning "Could not clone awesome-copilot, continuing with cached version if available"
        }
    fi

    if [ -d "$AWESOME_COPILOT_DIR/instructions" ]; then
        cp "$AWESOME_COPILOT_DIR"/instructions/*.instructions.md "$INSTRUCTIONS_DIR/" 2>/dev/null || true
        log_success "Awesome Copilot instructions synced"
    fi
}

download_antigravity_skills() {
    log_header "DOWNLOADING ANTIGRAVITY SKILLS"

    if [ -d "$ANTIGRAVITY_DIR/.git" ]; then
        log_info "Updating antigravity-awesome-skills repository..."
        git -C "$ANTIGRAVITY_DIR" pull origin main --quiet 2>/dev/null || true
    else
        log_action "Cloning antigravity-awesome-skills repository..."
        git clone --depth 1 --branch main https://github.com/sickn33/antigravity-awesome-skills.git "$ANTIGRAVITY_DIR" 2>/dev/null || {
            log_warning "Could not clone antigravity-awesome-skills, continuing with cached version if available"
        }
    fi

    if [ -d "$ANTIGRAVITY_DIR" ]; then
        local copied=0

        while IFS= read -r file; do
            if [[ "$file" == *"skill"* ]] || [[ "$file" == *"instruction"* ]]; then
                cp "$file" "$INSTRUCTIONS_DIR/" 2>/dev/null || true
                copied=$((copied + 1))
                if [ "$copied" -ge 20 ]; then
                    break
                fi
            fi
        done < <(find "$ANTIGRAVITY_DIR" -name "*.md" -type f 2>/dev/null)

        log_success "Antigravity skills synced"
    fi
}

create_copilot_instructions() {
    log_header "CREATING COPILOT INSTRUCTIONS"

    cat > "$PROJECT_ROOT/.github/copilot-instructions.md" <<EOF
# Copilot Instructions for Agentic AI Code Reviewer (v3)

You are an AI assistant helping with comprehensive code reviews across multiple technology stacks.

## Detected Stacks
${DETECTED_STACKS}

## Review Dimensions
1. Security (OWASP Top 10, secrets, IAM, encryption)
2. Performance (query efficiency, scalability, cost optimization)
3. Code Quality (SOLID, DRY, maintainability)
4. Testing (coverage, edge cases, integration)
5. Documentation (readability, completeness)

## Output Contract
Return STRICT JSON with:
- summary
- issues[] with type, severity, title, description, location, recommendation, example
- score (0-10)
- recommendation (APPROVE|REQUEST_CHANGES|COMMENT)
EOF

    log_success "Created: $PROJECT_ROOT/.github/copilot-instructions.md"
}

build_stack_instruction_block() {
    local block_file="$1"
    : > "$block_file"

    local include_files=(
        "security-best-practices.instructions.md"
        "performance-optimization.instructions.md"
        "testing-best-practices.instructions.md"
    )

    for stack in $DETECTED_STACKS; do
        case "$stack" in
            java)
                include_files+=("java.instructions.md" "springboot.instructions.md")
                ;;
            python)
                include_files+=("python.instructions.md")
                ;;
            react)
                include_files+=("reactjs.instructions.md")
                ;;
            typescript)
                include_files+=("typescript.instructions.md")
                ;;
            aws)
                include_files+=("aws-best-practices.instructions.md" "aws.instructions.md")
                ;;
            terraform)
                include_files+=("terraform.instructions.md")
                ;;
        esac
    done

    printf "## Stack-Specific Instructions\n" >> "$block_file"
    printf "Detected stacks: %s\n\n" "$DETECTED_STACKS" >> "$block_file"

    for file in "${include_files[@]}"; do
        local full="$INSTRUCTIONS_DIR/$file"
        if [ -f "$full" ]; then
            printf "### %s\n" "$file" >> "$block_file"
            sed -n '1,80p' "$full" >> "$block_file"
            printf "\n\n" >> "$block_file"
        fi
    done
}

# ============================================================================
# REVIEW EXECUTION
# ============================================================================

run_ai_review() {
    log_header "RUNNING AI REVIEW (GH COPILOT)"

    local branch1="$1"
    local branch2="$2"
    local code_path="$3"

    local diff_file="$REPORTS_DIR/diff.patch"
    local instructions_block="$REPORTS_DIR/instructions-block.md"
    local prompt_file="$REPORTS_DIR/review-prompt.txt"
    local raw_output="$REPORTS_DIR/copilot-review.txt"

    git -C "$PROJECT_ROOT" diff "$branch1...$branch2" -- "$code_path" > "$diff_file"

    if [ ! -s "$diff_file" ]; then
        log_warning "No changes to review between $branch1...$branch2 for path '$code_path'"
        return 2
    fi

    build_stack_instruction_block "$instructions_block"

    cat > "$prompt_file" <<EOF
You are an expert code reviewer.

Review the following git diff using the stack-specific instructions.
Return ONLY valid JSON (no markdown fences).
Do NOT echo placeholders from the schema (for example: "string", "critical|high|medium|low", "APPROVE|REQUEST_CHANGES|COMMENT").
Use concrete values derived from the diff.
If no real issues are found, return an empty issues array with recommendation "APPROVE" and score between 8 and 10.

Required JSON schema:
{
  "summary": "string",
  "issues": [
    {
      "type": "security|performance|quality|pattern|bug|coverage|suggestion|terraform|aws|documentation|testing",
      "severity": "critical|high|medium|low",
      "title": "string",
      "description": "string",
      "location": "file:line or file",
      "recommendation": "string",
      "example": "string"
    }
  ],
  "score": 0,
  "recommendation": "APPROVE|REQUEST_CHANGES|COMMENT"
}

${DETECTED_STACKS}

$(cat "$instructions_block")

## Git Diff
$(cat "$diff_file")
EOF

    if gh copilot -p "$(cat "$prompt_file")" > "$raw_output" 2>&1; then
        log_success "AI review completed"
    else
        log_error "gh copilot prompt execution failed"
        return 1
    fi

    return 0
}

extract_or_build_json() {
    local raw_output="$REPORTS_DIR/copilot-review.txt"
    local json_output="$REPORTS_DIR/copilot-review.json"
    local normalized_json="$REPORTS_DIR/copilot-review.normalized.json"

    if command -v python3 >/dev/null 2>&1; then
        python3 - "$raw_output" "$json_output" <<'PY'
import json
import sys
from pathlib import Path

raw_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
text = raw_path.read_text(encoding='utf-8', errors='ignore')

def first_json_blob(s: str):
    decoder = json.JSONDecoder()
    for i, ch in enumerate(s):
        if ch in '{[':
            try:
                obj, end = decoder.raw_decode(s[i:])
                return obj
            except Exception:
                continue
    return None

obj = first_json_blob(text)
if obj is None:
    out_path.write_text("", encoding='utf-8')
    sys.exit(0)
out_path.write_text(json.dumps(obj, ensure_ascii=False, indent=2), encoding='utf-8')
PY
    fi

    if [ ! -s "$json_output" ] || ! jq empty "$json_output" >/dev/null 2>&1; then
        log_warning "No valid JSON found in AI output. Generating fallback JSON."
        cat > "$json_output" <<EOF
{
  "summary": "AI output was not valid JSON. Review raw output.",
  "issues": [],
  "score": 0,
  "recommendation": "COMMENT"
}
EOF
    fi

    jq --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       --arg version "3.0.0" \
       --arg system "Enhanced Copilot Code Reviewer" \
       --arg stacks "$DETECTED_STACKS" \
       --arg raw_file "$REPORTS_DIR/copilot-review.txt" '
    . as $root |
    {
      review_metadata: {
        generated_at: $generated_at,
        version: $version,
        system: $system
      },
      detected_stacks: ($stacks | split(" ") | map(select(length > 0))),
      summary: ($root.summary // "No summary provided"),
            recommendation: (
                (($root.recommendation // "COMMENT") | ascii_upcase) as $r
                | if ($r == "APPROVE" or $r == "REQUEST_CHANGES" or $r == "COMMENT") then $r else "COMMENT" end
            ),
            score: (
                ((if (($root.score // 0) | type) == "number" then ($root.score // 0) else 0 end)
                | if . < 0 then 0 elif . > 10 then 10 else . end)
            ),
      issues: ($root.issues // []),
      stats: {
        total_findings: (($root.issues // []) | length),
        critical_count: (($root.issues // []) | map(select((.severity // "") | ascii_downcase == "critical")) | length),
        high_count: (($root.issues // []) | map(select((.severity // "") | ascii_downcase == "high")) | length),
        medium_count: (($root.issues // []) | map(select((.severity // "") | ascii_downcase == "medium")) | length),
        low_count: (($root.issues // []) | map(select((.severity // "") | ascii_downcase == "low")) | length)
      },
      artifacts: {
        raw_output: $raw_file
      }
    }' "$json_output" > "$normalized_json"

    mv "$normalized_json" "$json_output"
    log_success "Structured JSON report generated: $json_output"
}

generate_markdown_report() {
    local branch1="$1"
    local branch2="$2"
    local code_path="$3"
    local report_md="$REPORTS_DIR/enhanced-copilot-review.md"

    local summary recommendation score total critical high medium low
    summary="$(jq -r '.summary' "$REPORTS_DIR/copilot-review.json")"
    recommendation="$(jq -r '.recommendation' "$REPORTS_DIR/copilot-review.json")"
    score="$(jq -r '.score' "$REPORTS_DIR/copilot-review.json")"
    total="$(jq -r '.stats.total_findings' "$REPORTS_DIR/copilot-review.json")"
    critical="$(jq -r '.stats.critical_count' "$REPORTS_DIR/copilot-review.json")"
    high="$(jq -r '.stats.high_count' "$REPORTS_DIR/copilot-review.json")"
    medium="$(jq -r '.stats.medium_count' "$REPORTS_DIR/copilot-review.json")"
    low="$(jq -r '.stats.low_count' "$REPORTS_DIR/copilot-review.json")"

    cat > "$report_md" <<EOF
# 🔍 Enhanced Copilot Code Review Report (v3)

**Generated:** $(date)
**Branches:** ${branch1}...${branch2}
**Code Path:** ${code_path}
**Detected Stacks:** ${DETECTED_STACKS}

## Executive Summary

- **Summary:** ${summary}
- **Recommendation:** ${recommendation}
- **Score:** ${score}/10

## Findings Breakdown

- **Total:** ${total}
- **Critical:** ${critical}
- **High:** ${high}
- **Medium:** ${medium}
- **Low:** ${low}

## Top Issues

EOF

    jq -r '.issues[]? | "### [\((.severity // "unknown") | ascii_upcase)] \(.title // "Untitled")\n- **Type:** \(.type // "unknown")\n- **Location:** \(.location // "unknown")\n- **Description:** \(.description // "")\n- **Recommendation:** \(.recommendation // "")\n"' "$REPORTS_DIR/copilot-review.json" >> "$report_md"

    cat >> "$report_md" <<EOF

---

## Artifacts

- Raw output: \
  ${REPORTS_DIR}/copilot-review.txt
- JSON output: \
  ${REPORTS_DIR}/copilot-review.json
- Prompt used: \
  ${REPORTS_DIR}/review-prompt.txt
- Diff used: \
  ${REPORTS_DIR}/diff.patch

EOF

    log_success "Markdown report generated: $report_md"
}

apply_strict_exit_policy() {
    if [ "$STRICT_MODE" != true ]; then
        return 0
    fi

    local critical high
    critical="$(jq -r '.stats.critical_count' "$REPORTS_DIR/copilot-review.json")"
    high="$(jq -r '.stats.high_count' "$REPORTS_DIR/copilot-review.json")"

    if [ "$critical" -gt 0 ]; then
        log_error "Strict mode failed: critical issues found ($critical)"
        return 2
    fi

    if [ "$high" -gt 0 ]; then
        log_error "Strict mode failed: high issues found ($high)"
        return 3
    fi

    log_success "Strict mode passed: no critical/high issues"
    return 0
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    log_header "ENHANCED COPILOT CODE REVIEW v3.0.0"
    log_info "Real AI review + stack-specific instructions + structured reports"
    echo ""

    if [ $# -lt 3 ]; then
        log_error "Usage: $0 <base-branch> <head-branch> <code-path> [--strict]"
        exit 1
    fi

    local branch1="$1"
    local branch2="$2"
    local code_path="$3"
    shift 3 || true

    while (( "$#" )); do
        case "$1" in
            --strict)
                STRICT_MODE=true
                ;;
            *)
                log_warning "Unknown option ignored: $1"
                ;;
        esac
        shift || true
    done

    validate_prerequisites
    setup_directories
    detect_stacks "$code_path"
    download_awesome_copilot
    download_antigravity_skills
    create_copilot_instructions

    if run_ai_review "$branch1" "$branch2" "$code_path"; then
        extract_or_build_json
        generate_markdown_report "$branch1" "$branch2" "$code_path"
    else
        local rc=$?
        if [ "$rc" -eq 2 ]; then
            cat > "$REPORTS_DIR/copilot-review.json" <<EOF
{
  "review_metadata": {
    "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "version": "3.0.0",
    "system": "Enhanced Copilot Code Reviewer"
  },
  "detected_stacks": ["$(echo "$DETECTED_STACKS" | sed 's/ /", "/g')"],
  "summary": "No changes to review for selected branches/path.",
  "recommendation": "COMMENT",
  "score": 0,
  "issues": [],
  "stats": {
    "total_findings": 0,
    "critical_count": 0,
    "high_count": 0,
    "medium_count": 0,
    "low_count": 0
  }
}
EOF
            generate_markdown_report "$branch1" "$branch2" "$code_path"
            log_warning "Completed with no diff to review"
            return 0
        fi
        log_error "Review execution failed"
        return 1
    fi

    echo ""
    log_header "REVIEW COMPLETE ✅"
    log_info "Reports generated in: $REPORTS_DIR"
    log_info "Markdown report: $REPORTS_DIR/enhanced-copilot-review.md"
    log_info "JSON report: $REPORTS_DIR/copilot-review.json"

    local smoke_script="$SCRIPT_DIR/ci-smoke-validate-artifacts.sh"
    if [ -x "$smoke_script" ]; then
        log_header "RUNNING CI SMOKE VALIDATION"
        "$smoke_script" "$REPORTS_DIR"
    else
        log_warning "CI smoke script not executable or missing: $smoke_script"
        log_warning "Run manually: bash $smoke_script $REPORTS_DIR"
    fi

    apply_strict_exit_policy
}

main "$@"
