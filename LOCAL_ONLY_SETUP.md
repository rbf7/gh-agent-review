# ⚠️ Legacy Document (Archived)

This file documents the deprecated `main-review.sh` flow and is retained for historical reference only.
For the current implementation, use:

- `QUICK_START.md`
- `README.md`
- `docs/INTEGRATION.md`
- `scripts/enhanced-copilot-review-v3.sh`

# 📱 Local-Only Setup Guide

Perfect for **offline analysis**, **private repositories**, or **no platform needed**.

---

## ✨ Features

✅ **Zero authentication** needed  
✅ **100% offline** analysis  
✅ **No platform** required  
✅ **Fast local** execution  
✅ **JSON output** for further processing  
✅ **Perfect for** pre-commit checks  

---

## 🚀 Step 1: Installation

### Requirements
```bash
# Just need these (probably already installed)
git --version        # 2.0+
python3 --version    # 3.8+
```

### Setup
```bash
# Clone
git clone <url>/code-review-automation.git
cd code-review-automation

# Setup
chmod +x *.sh scripts/*.sh
./setup.sh

# Done! No tokens, no configuration needed.
```

---

## 📋 Step 2: Basic Usage

### Single Branch Analysis
```bash
# Analyze feature branch against develop
./main-review.sh feature/auth develop ./src

# Output: report.json in current directory
cat report.json
```

### Analyze Entire Repository
```bash
# Analyze feature branch, all files
./main-review.sh feature/auth develop .

# Output: report.json
```

### Different Target Branches
```bash
# Against main
./main-review.sh feature/auth main .

# Against release
./main-review.sh feature/auth release .

# Against specific commit
./main-review.sh feature/auth abc1234 .
```

---

## 🔍 Step 3: Understanding Output

### Report.json Structure
```json
{
  "review_date": "2024-01-15T10:30:00Z",
  "source_branch": "feature/auth",
  "target_branch": "develop",
  "files_changed": 5,
  "lines_added": 150,
  "lines_deleted": 30,
  "total_issues": 12,
  "security_issues": [
    {
      "file": "src/auth.py",
      "line": 42,
      "severity": "HIGH",
      "message": "Hardcoded password found",
      "code": "SECRET_HARDCODED"
    }
  ],
  "quality_issues": [
    {
      "file": "src/api.py",
      "line": 15,
      "severity": "MEDIUM",
      "message": "Function too complex",
      "complexity": 8,
      "code": "COMPLEXITY_HIGH"
    }
  ],
  "coverage_gaps": [
    {
      "file": "src/utils.py",
      "line": 89,
      "severity": "MEDIUM",
      "message": "Branch not covered",
      "code": "COVERAGE_GAP"
    }
  ],
  "performance_issues": [
    {
      "file": "src/db.py",
      "line": 120,
      "severity": "LOW",
      "message": "N+1 query detected",
      "code": "N_PLUS_ONE"
    }
  ]
}
```

### Severity Levels
- 🔴 **HIGH** - Critical security/functionality issues
- 🟠 **MEDIUM** - Important improvements
- 🟡 **LOW** - Nice-to-have optimizations
- ✅ **INFO** - Informational findings

---

## 🛠️ Workflow Examples

### Pre-Commit Check
```bash
#!/bin/bash
# Save as: .git/hooks/pre-commit
# Then: chmod +x .git/hooks/pre-commit

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH="develop"

./main-review.sh $CURRENT_BRANCH $TARGET_BRANCH . --dry-run

if [ $? -ne 0 ]; then
  echo "Review failed. Commit anyway? (y/n)"
  read -r choice
  if [ "$choice" != "y" ]; then
    exit 1
  fi
fi
```

### Pre-Push Check
```bash
#!/bin/bash
# Save as: .git/hooks/pre-push
# Then: chmod +x .git/hooks/pre-push

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH="develop"

echo "Running code review before push..."
./main-review.sh $CURRENT_BRANCH $TARGET_BRANCH . --dry-run

if [ $? -ne 0 ]; then
  echo "Issues found. Push anyway? (y/n)"
  read -r choice
  if [ "$choice" != "y" ]; then
    exit 1
  fi
fi
```

### Batch Analysis
```bash
#!/bin/bash
# Analyze all feature branches

for branch in $(git branch | grep 'feature'); do
  echo "Analyzing $branch..."
  ./main-review.sh ${branch#* } develop . --dry-run
  echo "---"
done
```

### Daily Report
```bash
#!/bin/bash
# Generate daily report for team

REPORT_DIR="./reports/$(date +%Y-%m-%d)"
mkdir -p $REPORT_DIR

for branch in $(git branch -r | grep 'origin/feature'); do
  LOCAL_BRANCH=${branch#origin/}
  REPORT_FILE="$REPORT_DIR/$LOCAL_BRANCH.json"
  
  echo "Analyzing $LOCAL_BRANCH..."
  ./main-review.sh $LOCAL_BRANCH develop . > $REPORT_FILE
done

echo "Reports generated in $REPORT_DIR"
```

---

## 📊 Processing Results

### Filter Issues by Severity
```bash
# HIGH severity only
cat report.json | jq '.security_issues[] | select(.severity=="HIGH")'

# MEDIUM or higher
cat report.json | jq '.[] | select(.severity=="HIGH" or .severity=="MEDIUM")'
```

### Count Issues by Type
```bash
# Count security issues
cat report.json | jq '.security_issues | length'

# Count quality issues
cat report.json | jq '.quality_issues | length'

# Count coverage gaps
cat report.json | jq '.coverage_gaps | length'

# Total issues
cat report.json | jq '[.security_issues, .quality_issues, .coverage_gaps, .performance_issues] | flatten | length'
```

### Generate Summary Report
```bash
# Extract key metrics
cat report.json | jq '{
  date: .review_date,
  source: .source_branch,
  target: .target_branch,
  files_changed: .files_changed,
  total_issues: .total_issues,
  by_severity: {
    high: (.security_issues | map(select(.severity=="HIGH")) | length),
    medium: (.security_issues | map(select(.severity=="MEDIUM")) | length),
    low: (.security_issues | map(select(.severity=="LOW")) | length)
  }
}'
```

### Export to CSV
```bash
# Convert issues to CSV
cat report.json | jq -r '.security_issues[] | [.file, .line, .severity, .message] | @csv'
```

---

## 🔧 Customization

### Edit Analysis Rules
```bash
# View current rules
cat config/rules.yaml

# Edit rules
nano config/rules.yaml

# Example: Add new rule
# security_checks:
#   - id: "MY_CHECK"
#     pattern: "my_pattern"
#     severity: "HIGH"
#     message: "Found my pattern"
```

### Run Specific Checks
```bash
# Run only security checks
./main-review.sh feature/auth develop ./src --checks security

# Run only quality checks
./main-review.sh feature/auth develop ./src --checks quality

# Run multiple checks
./main-review.sh feature/auth develop ./src --checks security,quality
```

### Dry Run Mode
```bash
# See what would happen without saving report
./main-review.sh feature/auth develop ./src --dry-run
```

---

## 💾 File Organization

### Organizing Reports
```bash
# Save reports with timestamps
mkdir -p reports/2024-01-15
./main-review.sh feature/auth develop . > reports/2024-01-15/review.json

# Archive old reports
tar -czf reports/2024-01-15.tar.gz reports/2024-01-15/
```

### Version Control
```bash
# Add reports to gitignore
echo "*.json" >> .gitignore
echo "reports/" >> .gitignore

# Or track selected reports
git add reports/latest.json
```

---

## 📈 Metrics Tracking

### Track Over Time
```bash
#!/bin/bash
# Track metrics across branches

for branch in $(git branch); do
  COUNT=$(./main-review.sh $branch develop . | jq '.total_issues' 2>/dev/null || echo "error")
  echo "$branch: $COUNT issues"
done
```

### Trend Analysis
```bash
# Save daily counts
echo "$(date +%Y-%m-%d): $(./main-review.sh feature/auth develop . | jq '.total_issues')" >> metrics.txt

# View trend
cat metrics.txt
```

---

## 🆘 Troubleshooting

### "Branch not found"
```bash
# Update local branches
git fetch origin

# Check branches
git branch -a
```

### "No changes found"
```bash
# Make sure branches are different
git log feature/auth..develop --oneline

# If no output, branches have no differences
```

### "Permission denied"
```bash
# Make scripts executable
chmod +x *.sh scripts/*.sh
```

### "Python not found"
```bash
# Install Python
# macOS: brew install python3
# Ubuntu: sudo apt-get install python3
```

---

## ✨ Pro Tips

### Create Alias
```bash
# Add to ~/.bashrc or ~/.zshrc
alias review="./main-review.sh"

# Then use:
review feature/auth develop ./src
```

### Function for Common Tasks
```bash
# Add to ~/.bashrc or ~/.zshrc
review_feature() {
  ./main-review.sh $1 develop . --dry-run
}

# Then use:
review_feature my-feature
```

### Integrate with Editor
```bash
# VS Code - Edit .vscode/settings.json
{
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
  // Add custom task
}
```

### GitHub Desktop Integration
```bash
# Run from GitHub Desktop
# Terminal → ./main-review.sh feature/branch develop .
```

---

## 🎯 Workflow Summary

### Typical Development Workflow
```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
# ... edit files ...

# 3. Commit
git add .
git commit -m "my changes"

# 4. Run local review
./main-review.sh feature/my-feature develop ./src

# 5. Check results
cat report.json

# 6. Fix issues if needed
# ... make more changes ...

# 7. Push
git push origin feature/my-feature

# 8. Create PR on platform (if needed)
```

---

## 📚 Next Steps

1. ✅ Run `./setup.sh`
2. ✅ Create feature branch: `git checkout -b feature/test`
3. ✅ Make a change: `echo "test" >> file.txt`
4. ✅ Commit: `git add . && git commit -m "test"`
5. ✅ Run review: `./main-review.sh feature/test develop .`
6. ✅ Check report: `cat report.json`

**That's it! No authentication, no configuration needed! 🚀**

---

*Last Updated: 2024*
