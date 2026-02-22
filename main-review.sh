#!/bin/bash
# Main code review automation script
# Git-agnostic, works with any platform

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SOURCE_BRANCH=""
TARGET_BRANCH=""
ANALYSIS_DIR="."
DRY_RUN=false
POST_TO_PLATFORM=false
VERBOSE=false

# Usage information
usage() {
    cat << EOF
Usage: ./main-review.sh <source-branch> <target-branch> <analysis-dir> [OPTIONS]

Arguments:
  <source-branch>      Feature branch to analyze
  <target-branch>      Target branch to compare against (main, develop, etc)
  <analysis-dir>       Directory to analyze (default: .)

Options:
  --post-to-platform   Post results to GitHub/GitLab/Bitbucket/Gitea (optional)
  --dry-run            Show what would happen without posting
  --verbose            Show detailed output
  --help               Show this help message

Examples:
  # Local analysis only (no authentication needed)
  ./main-review.sh feature/auth develop ./src

  # With platform posting (requires token)
  ./main-review.sh feature/auth main . --post-to-platform

  # Dry run
  ./main-review.sh feature/auth develop . --dry-run

EOF
    exit 1
}

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Parse arguments
if [ $# -lt 3 ]; then
    usage
fi

SOURCE_BRANCH="$1"
TARGET_BRANCH="$2"
ANALYSIS_DIR="$3"
shift 3

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --post-to-platform)
            POST_TO_PLATFORM=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate inputs
if [ -z "$SOURCE_BRANCH" ] || [ -z "$TARGET_BRANCH" ]; then
    print_error "Source and target branches are required"
    usage
fi

if [ ! -d "$ANALYSIS_DIR" ]; then
    print_error "Analysis directory not found: $ANALYSIS_DIR"
    exit 1
fi

print_info "Code Review Automation (Git-Agnostic)"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

print_info "Repository: $(git rev-parse --show-toplevel | xargs basename)"
print_info "Source branch: $SOURCE_BRANCH"
print_info "Target branch: $TARGET_BRANCH"
print_info "Analysis directory: $ANALYSIS_DIR"
echo ""

# Fetch latest branches
print_info "Fetching latest branches..."
git fetch origin --quiet 2>/dev/null || true

# Get diff using native git (no platform CLI needed)
print_info "Getting changes using native git..."
if ! git diff "$TARGET_BRANCH...$SOURCE_BRANCH" > /tmp/review.diff 2>/dev/null; then
    print_error "Failed to get diff. Branches may not exist."
    print_error "Available branches:"
    git branch -a | head -10
    exit 1
fi

DIFF_SIZE=$(wc -l < /tmp/review.diff)
if [ "$DIFF_SIZE" -eq 0 ]; then
    print_warning "No differences found between $SOURCE_BRANCH and $TARGET_BRANCH"
    exit 0
fi

print_success "Got $(grep '^@@' /tmp/review.diff | wc -l) changed sections"

# Run analysis scripts
print_info "Running analysis..."
echo ""

# Create temporary output directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Run security analysis
print_info "Security analysis..."
if [ -f "$SCRIPT_DIR/scripts/analyze-security.sh" ]; then
    bash "$SCRIPT_DIR/scripts/analyze-security.sh" "$ANALYSIS_DIR" > "$TEMP_DIR/security.json" 2>/dev/null || true
    SECURITY_COUNT=$(jq 'length' "$TEMP_DIR/security.json" 2>/dev/null || echo 0)
    print_success "Found $SECURITY_COUNT security issues"
else
    echo "[]" > "$TEMP_DIR/security.json"
fi

# Run quality analysis
print_info "Code quality analysis..."
if [ -f "$SCRIPT_DIR/scripts/analyze-quality.sh" ]; then
    bash "$SCRIPT_DIR/scripts/analyze-quality.sh" "$ANALYSIS_DIR" > "$TEMP_DIR/quality.json" 2>/dev/null || true
    QUALITY_COUNT=$(jq 'length' "$TEMP_DIR/quality.json" 2>/dev/null || echo 0)
    print_success "Found $QUALITY_COUNT quality issues"
else
    echo "[]" > "$TEMP_DIR/quality.json"
fi

# Run coverage analysis
print_info "Coverage analysis..."
if [ -f "$SCRIPT_DIR/scripts/analyze-coverage.sh" ]; then
    bash "$SCRIPT_DIR/scripts/analyze-coverage.sh" "$ANALYSIS_DIR" > "$TEMP_DIR/coverage.json" 2>/dev/null || true
    COVERAGE_COUNT=$(jq 'length' "$TEMP_DIR/coverage.json" 2>/dev/null || echo 0)
    print_success "Found $COVERAGE_COUNT coverage gaps"
else
    echo "[]" > "$TEMP_DIR/coverage.json"
fi

# Run performance analysis
print_info "Performance analysis..."
if [ -f "$SCRIPT_DIR/scripts/analyze-performance.sh" ]; then
    bash "$SCRIPT_DIR/scripts/analyze-performance.sh" "$ANALYSIS_DIR" > "$TEMP_DIR/performance.json" 2>/dev/null || true
    PERF_COUNT=$(jq 'length' "$TEMP_DIR/performance.json" 2>/dev/null || echo 0)
    print_success "Found $PERF_COUNT performance issues"
else
    echo "[]" > "$TEMP_DIR/performance.json"
fi

echo ""

# Generate report
print_info "Generating report..."
if [ -f "$SCRIPT_DIR/scripts/generate-report.sh" ]; then
    bash "$SCRIPT_DIR/scripts/generate-report.sh" \
        "$SOURCE_BRANCH" "$TARGET_BRANCH" \
        "$TEMP_DIR/security.json" \
        "$TEMP_DIR/quality.json" \
        "$TEMP_DIR/coverage.json" \
        "$TEMP_DIR/performance.json" > report.json
    print_success "Report generated: report.json"
else
    print_error "generate-report.sh not found"
    exit 1
fi

# Display summary
TOTAL_ISSUES=$(jq 'length' report.json 2>/dev/null || echo 0)
print_success "Total issues found: $TOTAL_ISSUES"

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN - no changes will be posted"
fi

# Post to platform if requested and not dry run
if [ "$POST_TO_PLATFORM" = true ] && [ "$DRY_RUN" = false ]; then
    echo ""
    print_info "Posting to platform..."
    
    if [ -f "$SCRIPT_DIR/scripts/post-to-platform.sh" ]; then
        if bash "$SCRIPT_DIR/scripts/post-to-platform.sh" \
            "$SOURCE_BRANCH" "$TARGET_BRANCH" report.json; then
            print_success "Results posted to platform"
        else
            print_warning "Failed to post to platform (platform token may not be set)"
        fi
    else
        print_error "post-to-platform.sh not found"
    fi
fi

echo ""
print_success "Review complete!"
print_info "Full report: report.json"

if [ "$VERBOSE" = true ]; then
    echo ""
    echo "Report preview:"
    jq '.' report.json | head -50
fi

exit 0
