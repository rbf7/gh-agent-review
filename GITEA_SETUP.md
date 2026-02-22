# 🏠 Gitea Integration Guide

Complete setup for **self-hosted Gitea**.

---

## ✨ Features

✅ Posts reviews as **PR comments**  
✅ Works with **local development**  
✅ Perfect for **self-hosted git**  
✅ Simple REST API  
✅ Auto-updates comments on new commits  
✅ Links to specific code lines  

---

## 🔑 Step 1: Create a Gitea Token

### Access Your Gitea Instance
1. Go to: `https://your-gitea.company.com`
2. Log in with your account
3. Click your profile icon → Settings
4. Left sidebar → Applications
5. Click "Generate New Token"
6. Name: `code-review-automation`
7. Select scopes:
   - ✅ `repo` (repository access)
   - ✅ `write:issue` (write PR comments)
8. Click "Generate Token"
9. **Copy the token** (you won't see it again!)

### Token Format
Gitea tokens are alphanumeric strings without special prefix.

---

## 🔐 Step 2: Set Environment Variables

### Local Development (Bash)
```bash
# Option 1: Export in terminal (temporary)
export GITEA_URL="https://gitea.company.com"
export GITEA_TOKEN="xxx"
./main-review.sh feature/auth develop . --post-to-platform

# Option 2: Create .env file (recommended)
cat > .env << EOF
GITEA_URL=https://gitea.company.com
GITEA_TOKEN=xxx
GITEA_OWNER=your-username
GITEA_REPO=your-repo
EOF

chmod 600 .env
source .env
```

### Local Development (PowerShell - Windows)
```powershell
# Set environment variables
[Environment]::SetEnvironmentVariable("GITEA_URL", "https://gitea.company.com", "User")
[Environment]::SetEnvironmentVariable("GITEA_TOKEN", "xxx", "User")
[Environment]::SetEnvironmentVariable("GITEA_OWNER", "your-username", "User")
[Environment]::SetEnvironmentVariable("GITEA_REPO", "your-repo", "User")

# Or temporary:
$env:GITEA_URL = "https://gitea.company.com"
$env:GITEA_TOKEN = "xxx"
```

---

## 📍 Step 3: Find Your Owner & Repo

### Owner (Organization or Username)
```bash
# Your owner appears in the URL
# https://gitea.company.com/OWNER/repo
# owner = OWNER

# Or query the API
curl -H "Authorization: token $GITEA_TOKEN" \
  $GITEA_URL/api/v1/user
```

### Repository
```bash
# Your repo appears in the URL
# https://gitea.company.com/owner/REPO
# repo = REPO

# Or query the API
curl -H "Authorization: token $GITEA_TOKEN" \
  $GITEA_URL/api/v1/user/repos
```

---

## ✅ Step 4: Test Your Setup

### Test Token
```bash
# Verify your token works
curl -H "Authorization: token $GITEA_TOKEN" \
  $GITEA_URL/api/v1/user
```

### Test Local Analysis
```bash
# Create a feature branch with changes
git checkout -b feature/test-review
echo "# Test" >> README.md
git add README.md
git commit -m "Test change"

# Run analysis (local only, no posting)
./main-review.sh feature/test-review develop . --dry-run

# You should see report.json generated
cat report.json
```

### Test Platform Posting
```bash
# Set variables
export GITEA_URL="https://gitea.company.com"
export GITEA_TOKEN="xxx"

# Run with posting
./main-review.sh feature/test-review develop . --post-to-platform

# Check your PR - comment should appear!
```

---

## 🚀 Usage

### Local Development
```bash
# One-time setup
export GITEA_URL="https://gitea.company.com"
export GITEA_TOKEN="xxx"

# Analyze your branch before pushing
./main-review.sh feature/auth develop ./src

# With posting
./main-review.sh feature/auth develop . --post-to-platform
```

### Manual Workflow
```bash
# Since Gitea is often used without CI/CD
# You'll typically run locally and post manually

export GITEA_URL="https://gitea.company.com"
export GITEA_TOKEN="xxx"

# Develop on feature branch
git checkout -b feature/my-feature
# ... make changes ...
git commit -m "my changes"

# Review before pushing
./main-review.sh feature/my-feature develop ./src

# Push to remote
git push origin feature/my-feature

# Create PR on Gitea web UI

# Run review and post comment
./main-review.sh feature/my-feature develop . --post-to-platform
```

---

## 📊 What Gets Posted

### PR Comment Example
```markdown
## 🔍 Code Review Analysis

**Summary:** 12 issues found (3 HIGH, 5 MEDIUM, 4 LOW)

### 🔒 Security (3 issues)
- ⚠️ Line 42 (src/auth.py): Hardcoded password found
  [View on Gitea](link-to-code)

### 📊 Code Quality (5 issues)
- 🟡 Line 15 (src/api.py): Function complexity too high
  [View on Gitea](link-to-code)

...

**[Full Report](review-report-url)**
```

---

## 🔄 Advanced Usage

### Auto-Update on New Commits
The system automatically updates the review comment when you push new commits to the PR.

### Custom Configuration
```bash
# Edit Gitea-specific settings
nano config/projects.yaml

# Add:
gitea:
  post_as_comment: true
  include_code_links: true
```

### Multiple Gitea Instances
```bash
# Can work with multiple Gitea instances
export GITEA_URL_PRIMARY="https://gitea.company.com"
export GITEA_URL_SECONDARY="https://gitea2.company.com"
export GITEA_TOKEN_PRIMARY="xxx"
export GITEA_TOKEN_SECONDARY="yyy"
```

---

## 🆘 Troubleshooting

### "401 Unauthorized"
```bash
# Token is invalid or expired
# 1. Go to your Gitea instance Settings → Applications
# 2. Verify token exists and not expired
# 3. Export correctly: export GITEA_TOKEN="xxx"
# 4. Test: curl -H "Authorization: token $GITEA_TOKEN" $GITEA_URL/api/v1/user
```

### "404 Not Found"
```bash
# Verify owner and repo are correct
# https://gitea.company.com/OWNER/REPO

# Check with API:
curl -H "Authorization: token $GITEA_TOKEN" \
  $GITEA_URL/api/v1/repos/$GITEA_OWNER/$GITEA_REPO
```

### "Comment Not Posting"
```bash
# 1. Check token has write access
# 2. Check you're in a PR (not issue)
# 3. Check owner/repo names are correct
# 4. Run with --verbose: ./main-review.sh feature/auth develop . --post-to-platform --verbose
```

---

## 📚 Resources

- **Gitea Official Site**: https://gitea.io
- **Gitea API**: https://docs.gitea.io/en-us/api-usage/
- **Gitea Installation**: https://docs.gitea.io/en-us/installation/

---

## ✨ Next Steps

1. ✅ Access your Gitea instance
2. ✅ Create token
3. ✅ Set environment variables
4. ✅ Test locally
5. ✅ Commit code
6. ✅ Create PR on Gitea
7. ✅ Run review and post comment!

---

*Last Updated: 2024*
