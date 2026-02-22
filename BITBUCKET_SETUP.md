# 🪣 Bitbucket Integration Guide

Complete setup for **Bitbucket Cloud** or **Bitbucket Server/Data Center**.

---

## ✨ Features

✅ Posts reviews as **PR comments**  
✅ Works with **Bitbucket Pipelines**  
✅ Works with **local development**  
✅ Works with **Bitbucket Server/Data Center**  
✅ Auto-updates comments on new commits  
✅ Links to specific code lines  

---

## 🔑 Step 1: Create a Bitbucket Token

### For Bitbucket Cloud (Personal Use)
1. Go to: [bitbucket.org/account/settings/personal-access-tokens/](https://bitbucket.org/account/settings/personal-access-tokens/)
2. Click "Create token"
3. Name: `code-review-automation`
4. Scopes:
   - ✅ `repo` (repository access)
   - ✅ `pullrequest` (pull request access)
5. Click "Create"
6. **Copy the token** (you won't see it again!)

### For Bitbucket Server/Data Center
1. Go to your Bitbucket instance user profile
2. Personal settings → Access tokens
3. Create token with scopes: `REPO_READ`, `REPO_WRITE`

### Token Format
Bitbucket tokens are typically long alphanumeric strings.

---

## 🔐 Step 2: Set Environment Variables

### Local Development (Bash)
```bash
# Option 1: Export in terminal (temporary)
export BITBUCKET_TOKEN="xxx"
export BITBUCKET_WORKSPACE="your-workspace"
export BITBUCKET_REPO="your-repo"
./main-review.sh feature/auth develop . --post-to-platform

# Option 2: Create .env file (recommended)
cat > .env << EOF
BITBUCKET_TOKEN=xxx
BITBUCKET_WORKSPACE=your-workspace
BITBUCKET_REPO=your-repo
BITBUCKET_URL=https://bitbucket.org  # For cloud
# BITBUCKET_URL=https://bitbucket.company.com  # For server
EOF

chmod 600 .env
source .env
```

### Local Development (PowerShell - Windows)
```powershell
# Set environment variables
[Environment]::SetEnvironmentVariable("BITBUCKET_TOKEN", "xxx", "User")
[Environment]::SetEnvironmentVariable("BITBUCKET_WORKSPACE", "your-workspace", "User")
[Environment]::SetEnvironmentVariable("BITBUCKET_REPO", "your-repo", "User")

# Or temporary:
$env:BITBUCKET_TOKEN = "xxx"
$env:BITBUCKET_WORKSPACE = "your-workspace"
$env:BITBUCKET_REPO = "your-repo"
```

### Bitbucket Pipelines
```yaml
# bitbucket-pipelines.yml
image: ubuntu:latest

pipelines:
  pull-requests:
    '**':
      - step:
          name: Code Review
          script:
            - ./setup.sh
            - export BITBUCKET_TOKEN=$BITBUCKET_TOKEN
            - export BITBUCKET_WORKSPACE=$BITBUCKET_WORKSPACE
            - export BITBUCKET_REPO=$BITBUCKET_REPO
            - ./main-review.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH . --post-to-platform
```

Then add token in:
1. Workspace Settings → Pipelines → Repository variables
2. Name: `BITBUCKET_TOKEN`
3. Value: Your token
4. Mark as Secret ✅

---

## 📍 Step 3: Find Your Workspace & Repo

### Workspace
```bash
# Your workspace appears in the URL
# https://bitbucket.org/WORKSPACE/repo
# workspace = WORKSPACE

# Or query the API
curl -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  https://api.bitbucket.org/2.0/user
```

### Repository
```bash
# Your repo appears in the URL
# https://bitbucket.org/workspace/REPO
# repo = REPO

# Or query the API
curl -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  https://api.bitbucket.org/2.0/repositories/WORKSPACE
```

---

## ✅ Step 4: Test Your Setup

### Test Token
```bash
# Verify your token works
curl -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  https://api.bitbucket.org/2.0/user

# For Bitbucket Server:
curl -u username:$BITBUCKET_TOKEN \
  $BITBUCKET_URL/rest/api/1.0/user
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
export BITBUCKET_TOKEN="xxx"
export BITBUCKET_WORKSPACE="your-workspace"
export BITBUCKET_REPO="your-repo"

# Run with posting
./main-review.sh feature/test-review develop . --post-to-platform

# Check your PR - comment should appear!
```

---

## 🚀 Usage

### Local Development
```bash
# One-time setup
export BITBUCKET_TOKEN="xxx"
export BITBUCKET_WORKSPACE="your-workspace"
export BITBUCKET_REPO="your-repo"

# Analyze your branch before pushing
./main-review.sh feature/auth develop ./src

# With posting
./main-review.sh feature/auth develop . --post-to-platform
```

### In Bitbucket Pipelines
```bash
# Automatically runs on every PR
# Comment posted automatically
# No extra setup needed!
```

### Bitbucket Server/Data Center
```bash
export BITBUCKET_URL="https://bitbucket.company.com"
export BITBUCKET_TOKEN="xxx"
export BITBUCKET_WORKSPACE="your-workspace"
export BITBUCKET_REPO="your-repo"

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
  [View on Bitbucket](link-to-code)

### 📊 Code Quality (5 issues)
- 🟡 Line 15 (src/api.py): Function complexity too high
  [View on Bitbucket](link-to-code)

...

**[Full Report](review-report-url)**
```

---

## 🔄 Advanced Usage

### Auto-Update on New Commits
The system automatically updates the review comment when you push new commits to the PR.

### Custom Configuration
```bash
# Edit Bitbucket-specific settings
nano config/projects.yaml

# Add:
bitbucket:
  post_as_comment: true
  inline_comments: true
  include_code_links: true
```

### Skipping Review
```bash
# Add to commit message to skip review
git commit -m "feat: skip-review - small change"

# Or use environment variable
export SKIP_REVIEW=true
./main-review.sh feature/auth develop .
```

---

## 🆘 Troubleshooting

### "401 Unauthorized"
```bash
# Token is invalid or expired
# 1. Go to bitbucket.org/account/settings/personal-access-tokens/
# 2. Verify token exists and not expired
# 3. Check scopes: repo, pullrequest
# 4. Export correctly: export BITBUCKET_TOKEN="xxx"
# 5. Test: curl -H "Authorization: Bearer $BITBUCKET_TOKEN" https://api.bitbucket.org/2.0/user
```

### "404 Repository Not Found"
```bash
# Verify workspace and repo names are correct
# https://bitbucket.org/WORKSPACE/REPO

# Check with API:
curl -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO
```

### "Comment Not Posting"
```bash
# 1. Check token has write access
# 2. Check you're in a PR (not issue)
# 3. Check workspace/repo names are correct
# 4. Run with --verbose: ./main-review.sh feature/auth develop . --post-to-platform --verbose
```

### "Rate Limited"
```bash
# Bitbucket Cloud: 60 req/min for authenticated users
# Wait before running again
```

---

## 📚 Resources

- **Bitbucket Personal Access Tokens**: https://bitbucket.org/account/settings/personal-access-tokens/
- **Bitbucket API**: https://developer.atlassian.com/cloud/bitbucket/rest/
- **Bitbucket Pipelines**: https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/
- **Bitbucket Server REST API**: https://developer.atlassian.com/server/bitbucket/reference/rest-api/

---

## ✨ Next Steps

1. ✅ Create token
2. ✅ Find workspace and repo
3. ✅ Set environment variables
4. ✅ Test locally
5. ✅ Commit code
6. ✅ Create PR
7. ✅ Watch review comment appear!

---

*Last Updated: 2024*
