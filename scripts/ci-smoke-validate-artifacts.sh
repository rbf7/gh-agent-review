#!/bin/bash

set -euo pipefail

REPORTS_DIR="${1:-reports}"
JSON_FILE="${REPORTS_DIR}/copilot-review.json"
MD_FILE="${REPORTS_DIR}/enhanced-copilot-review.md"

fail() {
  echo "❌ $1" >&2
  exit 1
}

info() {
  echo "ℹ️  $1"
}

[ -d "$REPORTS_DIR" ] || fail "Reports directory not found: $REPORTS_DIR"
[ -f "$JSON_FILE" ] || fail "Missing JSON artifact: $JSON_FILE"
[ -f "$MD_FILE" ] || fail "Missing Markdown artifact: $MD_FILE"
[ -s "$MD_FILE" ] || fail "Markdown artifact is empty: $MD_FILE"

command -v jq >/dev/null 2>&1 || fail "jq is required for schema validation"

jq empty "$JSON_FILE" >/dev/null 2>&1 || fail "Invalid JSON in artifact: $JSON_FILE"

# Top-level contract checks
jq -e '
  (.summary | type == "string") and
  (.recommendation | type == "string") and
  (.recommendation == "APPROVE" or .recommendation == "REQUEST_CHANGES" or .recommendation == "COMMENT") and
  (.score | type == "number") and
  (.score >= 0 and .score <= 10) and
  (.issues | type == "array") and
  (.stats | type == "object") and
  (.stats.total_findings | type == "number") and
  (.stats.critical_count | type == "number") and
  (.stats.high_count | type == "number") and
  (.stats.medium_count | type == "number") and
  (.stats.low_count | type == "number")
' "$JSON_FILE" >/dev/null || fail "JSON top-level schema validation failed"

# Per-issue schema checks (if issues exist)
jq -e '
  [ .issues[]? |
    (
      (.type | type == "string") and
      (.severity | type == "string") and
      ((.severity | ascii_downcase) == "critical" or (.severity | ascii_downcase) == "high" or (.severity | ascii_downcase) == "medium" or (.severity | ascii_downcase) == "low") and
      (.title | type == "string") and
      (.description | type == "string") and
      (.location | type == "string") and
      (.recommendation | type == "string") and
      (.example | type == "string")
    )
  ] | all
' "$JSON_FILE" >/dev/null || fail "JSON issue schema validation failed"

# Findings count consistency check
jq -e '
  (.stats.total_findings == (.issues | length)) and
  (.stats.critical_count == ([.issues[]? | select((.severity|ascii_downcase)=="critical")] | length)) and
  (.stats.high_count == ([.issues[]? | select((.severity|ascii_downcase)=="high")] | length)) and
  (.stats.medium_count == ([.issues[]? | select((.severity|ascii_downcase)=="medium")] | length)) and
  (.stats.low_count == ([.issues[]? | select((.severity|ascii_downcase)=="low")] | length))
' "$JSON_FILE" >/dev/null || fail "JSON stats do not match issues"

# Basic markdown structure checks
if ! grep -Eiq "^# .*Enhanced Copilot Code Review Report" "$MD_FILE"; then
  fail "Markdown header missing or invalid"
fi
if ! grep -q "## Executive Summary" "$MD_FILE"; then
  fail "Markdown Executive Summary section missing"
fi
if ! grep -q "## Findings Breakdown" "$MD_FILE"; then
  fail "Markdown Findings Breakdown section missing"
fi

info "Artifact smoke validation passed"
