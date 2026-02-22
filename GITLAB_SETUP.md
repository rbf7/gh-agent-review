# 🦊 GitLab Integration Guide

Complete setup for **GitLab.com**, **GitLab Self-Hosted**, or **GitLab Enterprise**.

---

## ✨ Features

✅ Posts reviews as **MR comments**  
✅ Works with **GitLab CI/CD**  
✅ Works with **local development**  
✅ Works with **self-hosted GitLab**  
✅ Auto-updates comments on new commits  
✅ Links to specific code lines  

---

## 🔑 Step 1: Create a GitLab Token

### For Personal Use (Development)
1. Go to: `https://gitlab.com/-/profile/personal_access_tokens` (or your self-hosted URL)
2. Click "Add new token"
3. Name: `code-review-automation`
4. Scopes:
   - ✅ `api` (API access)
   - ✅ `read_repository` (read code)
5. Expiration: Your preference
6. Click "Create personal access token"
7. **Copy the token** (you won't see it again!)

### Token Format
GitLab tokens start with `glpat-` and look like:
```
glpat-abcdef1234567890_xy
```

### For Self-Hosted GitLab
```bash
# Set your GitLab instance URL
export GITLAB_URL="https://gitlab.company.com"
export GITLAB_TOKEN="glpat-xxx"
```

---

## 🔐 Step 2: Secure Your Token

### Local Development (Bash)
```bash
# Option 1: Export in terminal (temporary)
export GITLAB_TOKEN="glpat-xxx"
./main-review.sh feature/auth develop . --post-to-platform

# Option 2: Create .env file (recommended)
cat > .env << EOF
GITLAB_URL=https://gitlab.com
GITLAB_TOKEN=glpat-xxx
EOF

chmod 600 .env
source .env

# Option 3: Self-hosted
cat > .env << EOF
GITLAB_URL=https://gitlab.company.com
GITLAB_TOKEN=glpat-xxx
EOF
```

### Local Development (PowerShell - Windows)
```powershell
# Set environment variable
[Environment]::SetEnvironmentVariable("GITLAB_TOKEN", "glpat-xxx", "User")
[Environment]::SetEnvironmentVariable("GITLAB_URL", "https://gitlab.com", "User")

# Or temporary:
$env:GITLAB_TOKEN = "glpat-xxx"
$env:GITLAB_URL = "https://gitlab.com"
```

### GitLab CI/CD
```yaml
# .gitlab-ci.yml
code_review:
  image: ubuntu:latest
  script:
    - ./setup.sh
    - export GITLAB_TOKEN=$CI_JOB_TOKEN
    - export GITLAB_URL=$CI_SERVER_URL
    - ./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME . --post-to-platform
  only:
    - merge_requests
```

### GitLab CI/CD (Alternative - Personal Token)
```yaml
# .gitlab-ci.yml
code_review:
  image: ubuntu:latest
  script:
    - ./setup.sh
    - export GITLAB_TOKEN=$GITLAB_AUTOMATION_TOKEN
    - export GITLAB_URL=$CI_SERVER_URL
    - ./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME . --post-to-platform
  only:
    - merge_requests
```

Then add the token in:
1. Project Settings → CI/CD → Variables
2. Name: `GITLAB_AUTOMATION_TOKEN`
3. Value: Your token
4. Protected & Masked ✅

---

## ✅ Step 3: Test Your Setup

### Test Token
```bash
# Verify your token works (GitLab.com)
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.com/api/v4/user

# For self-hosted:
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  $GITLAB_URL/api/v4/user
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
# Set token
export GITLAB_TOKEN="glpat-xxx"

# Run with posting
./main-review.sh feature/test-review develop . --post-to-platform

# Check your MR - comment should appear!
```

---

## 🚀 Usage

### Local Development
```bash
# One-time setup
export GITLAB_TOKEN="glpat-xxx"

# Analyze your branch before pushing
./main-review.sh feature/auth develop ./src

# With posting
./main-review.sh feature/auth develop . --post-to-platform
```

### In GitLab CI/CD
```bash
# Automatically runs on every MR
# Comment posted automatically
# No extra setup needed!
```

### Self-Hosted GitLab
```bash
export GITLAB_URL="https://gitlab.company.com"
export GITLAB_TOKEN="glpat-xxx"

./main-review.sh feature/auth develop . --post-to-platform
```

---

## 📊 What Gets Posted

### MR Comment Example
```markdown
## 🔍 Code Review Analysis

**Summary:** 12 issues found (3 HIGH, 5 MEDIUM, 4 LOW)

### 🔒 Security (3 issues)
- ⚠️ Line 42 (src/auth.py): Hardcoded password found
  [View on GitLab](link-to-code)

### 📊 Code Quality (5 issues)
- 🟡 Line 15 (src/api.py): Function complexity too high
  [View on GitLab](link-to-code)

...

**[Full Report](review-report-url)**
```

---

## 🔄 Advanced Usage

### Auto-Update on New Commits
The system automatically updates the review comment when you push new commits to the MR.

### Custom Configuration
```bash
# Edit GitLab-specific settings
nano config/projects.yaml

# Add:
gitlab:
  post_as_discussion: true
  thread_comments: true
  include_code_lines: true
```

### Skipping Review
```bash
# Add to commit message to skip review
git commit -m "feat: skip-review - small change"

# Or use environment variable
export SKIP_REVIEW=true
./main-review.sh feature/auth develop .
```

### Multiple GitLab Instances
```bash
# Can work with multiple GitLab instances
export GITLAB_URL_PRIMARY="https://gitlab.com"
export GITLAB_URL_SECONDARY="https://gitlab.company.com"
export GITLAB_TOKEN_PRIMARY="glpat-xxx"
export GITLAB_TOKEN_SECONDARY="glpat-yyy"
```

---

## 🆘 Troubleshooting

### "401 Unauthorized"
```bash
# Token is invalid or expired
# 1. Go to https://gitlab.com/-/profile/personal_access_tokens
# 2. Verify token exists and not expired
# 3. Check scopes: api, read_repository
# 4. Export correctly: export GITLAB_TOKEN="glpat-xxx"
# 5. Test: curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" https://gitlab.com/api/v4/user
```

### "404 Not Found"
```bash
# For self-hosted, must set URL
export GITLAB_URL="https://gitlab.company.com"

# Verify project exists:
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  $GITLAB_URL/api/v4/projects/search/project-name
```

### "Comment Not Posting"
```bash
# 1. Check token has write access
# 2. Check you're in an MR (not issue)
# 3. Check branch names are correct
# 4. Run with --verbose: ./main-review.sh feature/auth develop . --post-to-platform --verbose
```

### "Rate Limited"
```bash
# GitLab has rate limits depending on your plan
# Free: 10 req/sec
# Wait before running again
```

---

## 📚 Resources

- **GitLab Personal Tokens**: https://gitlab.com/-/profile/personal_access_tokens
- **GitLab API**: https://docs.gitlab.com/ee/api/
- **GitLab CI/CD**: https://docs.gitlab.com/ee/ci/
- **GitLab Self-Hosted**: https://about.gitlab.com/install/

---

## ✨ Next Steps

1. ✅ Create token
2. ✅ Set GITLAB_TOKEN and GITLAB_URL
3. ✅ Test locally
4. ✅ Commit code
5. ✅ Create MR
6. ✅ Watch review comment appear!

---

*Last Updated: 2024*
