# ⚠️ Legacy Document (Archived)

This file references deprecated `main-review.sh` commands and legacy posting flows.
Use the current v3 workflow in `README.md`, `QUICK_START.md`, and `scripts/enhanced-copilot-review-v3.sh`.

# 🐙 GitHub Integration Guide

Complete setup for running code reviews with **GitHub.com** or **GitHub Enterprise**.

---

## ✨ Features

✅ Posts reviews as **PR comments**  
✅ Works with **GitHub Actions**  
✅ Works with **local development**  
✅ Works with **GitHub Enterprise**  
✅ Auto-updates comments on new commits  
✅ Links to specific code lines  

---

## 🔑 Step 1: Create a GitHub Token

### For Personal Use (Development)
1. Go to: [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click "Generate new token"
3. Name it: `code-review-automation`
4. Select scopes:
   - ✅ `repo` (full repository access)
   - ✅ `read:repo_hook` (read repository hooks)
5. Click "Generate token"
6. **Copy the token** (you won't see it again!)

### For GitHub Actions
```yaml
# Your repo already has GITHUB_TOKEN available
# Use it in workflows (no setup needed)
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### For GitHub Enterprise
```bash
# Set your enterprise URL
export GITHUB_ENTERPRISE_URL="https://github.company.com"
export GITHUB_TOKEN="ghp_xxx"
```

---

## 🔐 Step 2: Secure Your Token

### Local Development (Bash)
```bash
# Option 1: Export in terminal (temporary)
export GITHUB_TOKEN="ghp_xxx"
./main-review.sh feature/auth main . --post-to-platform

# Option 2: Create .env file (recommended)
cat > .env << EOF
GITHUB_TOKEN=ghp_xxx
GITHUB_ENTERPRISE_URL=https://github.company.com  # Optional
EOF

chmod 600 .env
source .env

# Option 3: Add to ~/.bashrc (permanent)
echo 'export GITHUB_TOKEN="ghp_xxx"' >> ~/.bashrc
source ~/.bashrc
```

### Local Development (PowerShell - Windows)
```powershell
# Set environment variable
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_xxx", "User")

# Or temporary:
$env:GITHUB_TOKEN = "ghp_xxx"

# Verify:
Write-Output $env:GITHUB_TOKEN
```

### GitHub Actions
```yaml
# .github/workflows/review.yml
name: Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Run Code Review
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ./setup.sh
          ./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} . --post-to-platform
```

### GitHub Enterprise
```yaml
# .github/workflows/review.yml
name: Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Run Code Review
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_ENTERPRISE_URL: https://github.company.com
        run: |
          ./setup.sh
          ./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} . --post-to-platform
```

---

## ✅ Step 3: Test Your Setup

### Test Token
```bash
# Verify your token works
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# For GitHub Enterprise:
curl -H "Authorization: token $GITHUB_TOKEN" \
  $GITHUB_ENTERPRISE_URL/api/v3/user
```

### Test Local Analysis
```bash
# Create a feature branch with changes
git checkout -b feature/test-review
echo "# Test" >> README.md
git add README.md
git commit -m "Test change"

# Run analysis (local only, no posting)
./main-review.sh feature/test-review main . --dry-run

# You should see report.json generated
cat report.json
```

### Test Platform Posting
```bash
# Set token
export GITHUB_TOKEN="ghp_xxx"

# Run with posting
./main-review.sh feature/test-review main . --post-to-platform

# Check your PR - comment should appear!
```

---

## 🚀 Usage

### Local Development
```bash
# One-time setup
export GITHUB_TOKEN="ghp_xxx"

# Analyze your branch before pushing
./main-review.sh feature/auth main ./src

# With posting
./main-review.sh feature/auth main . --post-to-platform
```

### In GitHub Actions
```bash
# Automatically runs on every PR
# Comment posted automatically
# No extra setup needed!
```

### Multiple Branches
```bash
# Analyze feature against different targets
./main-review.sh feature/auth main . --post-to-platform
./main-review.sh feature/auth develop . --post-to-platform
```

---

## 📊 What Gets Posted

### PR Comment Example
```markdown
## 🔍 Code Review Analysis

**Summary:** 12 issues found (3 HIGH, 5 MEDIUM, 4 LOW)

### 🔒 Security (3 issues)
- ⚠️ Line 42 (src/auth.py): Hardcoded password found
  [View on GitHub](#)

### 📊 Code Quality (5 issues)
- 🟡 Line 15 (src/api.py): Function complexity too high
  [View on GitHub](#)

...

**[Full Report](review-report-url)**
```

---

## 🔄 Advanced Usage

### Auto-Update on New Commits
The system automatically updates the review comment when you push new commits to the PR.

### Custom Configuration
```bash
# Edit GitHub-specific settings
nano config/projects.yaml

# Add:
github:
  post_as_review_comment: true
  thread_conversations: true
  include_line_links: true
```

### Skipping Review
```bash
# Add to commit message to skip review
git commit -m "feat: skip-review - small change"

# Or use environment variable
export SKIP_REVIEW=true
./main-review.sh feature/auth main .
```

### Different Review Rules for Branches
```yaml
# config/rules.yaml
branch_rules:
  main:
    - security: strict
    - performance: strict
  
  develop:
    - security: normal
    - performance: normal
  
  feature/*:
    - security: normal
    - performance: relaxed
```

---

## 🆘 Troubleshooting

### "401 Unauthorized"
```bash
# Token is invalid or expired
# 1. Generate new token
# 2. Verify scopes: repo, read:repo_hook
# 3. Export correctly: export GITHUB_TOKEN="ghp_xxx"
# 4. Test: curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

### "404 Repository Not Found"
```bash
# For GitHub Enterprise, must set URL
export GITHUB_ENTERPRISE_URL="https://github.company.com"

# And ensure token has access to private repos
```

### "Comment Not Posting"
```bash
# 1. Check token has write access
# 2. Check you're in a PR (not issue)
# 3. Check branch names are correct
# 4. Run with --verbose: ./main-review.sh feature/auth main . --post-to-platform --verbose
```

### "Rate Limited"
```bash
# GitHub has rate limits: 60 req/hour (unauthenticated), 5000/hour (authenticated)
# Wait before running again, or use different token
```

---

## 📚 Resources

- **GitHub Token Docs**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
- **GitHub API**: https://docs.github.com/en/rest
- **GitHub Actions**: https://docs.github.com/en/actions
- **GitHub Enterprise Docs**: https://docs.github.com/en/enterprise-server@latest

---

## ✨ Next Steps

1. ✅ Create token
2. ✅ Set environment variable
3. ✅ Test locally
4. ✅ Commit code
5. ✅ Create PR
6. ✅ Watch review comment appear!

---

*Last Updated: 2024*
