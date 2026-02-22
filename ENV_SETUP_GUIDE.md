# ⚠️ Legacy Document (Archived)

This guide contains deprecated `main-review.sh` instructions.
Use `QUICK_START.md` and `scripts/enhanced-copilot-review-v3.sh` for current setup.

# 📋 Environment Variables Guide

## Overview

The `.env.example` file is a **template** for environment variables needed by the code review system. It shows all available configuration options and how to use them.

---

## ✅ Files Explained

### `.env.example` (Template)
- **What it is**: A template showing ALL available environment variables
- **What you do**: Copy it to `.env` and fill in YOUR values
- **Never commit**: Already in `.gitignore`
- **Format**: Each variable commented out (starts with `#`)

### `.env` (Your Actual Config - NOT Committed)
- **What it is**: Your personal copy with YOUR tokens and settings
- **What you do**: Copy from `.env.example`, uncomment, and fill in values
- **Never commit**: It's in `.gitignore` (safe!)
- **Contains**: Your actual tokens, URLs, workspace names

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Copy Template to `.env`
```bash
cp .env.example .env
```

### Step 2: Edit `.env` and Uncomment Your Platform
```bash
# Edit the file
nano .env  # or vim, code, etc.

# Uncomment the lines for your platform
# Example for GitHub:
GITHUB_TOKEN="ghp_xxx"

# Example for GitLab:
GITLAB_TOKEN="glpat-xxx"
GITLAB_URL="https://gitlab.com"
```

### Step 3: Load and Use
```bash
source .env
./main-review.sh feature/auth main . --post-to-platform
```

---

## 📋 Configuration Reference

### GitHub

**Template:**
```bash
GITHUB_TOKEN=ghp_xxx
GITHUB_ENTERPRISE_URL=https://github.company.com  # Optional
```

**Get Token:**
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a name (e.g., "Code Review Automation")
4. Select scopes:
   - ✅ `repo` (full repository access)
   - ✅ `read:repo_hook` (read webhooks)
   - ❌ NOT `write:repo_hook` (don't need to create webhooks)
5. Generate and copy token
6. Paste into `GITHUB_TOKEN="ghp_xxx"`

**Enterprise GitHub:**
```bash
GITHUB_TOKEN="ghp_xxx"
GITHUB_ENTERPRISE_URL="https://github.company.com"
```

---

### GitLab

**Template:**
```bash
GITLAB_TOKEN=glpat-xxx
GITLAB_URL=https://gitlab.com
```

**Get Token (Cloud):**
1. Go to https://gitlab.com/-/profile/personal_access_tokens
2. Create new personal access token
3. Give it a name (e.g., "Code Review Automation")
4. Select scopes:
   - ✅ `api` (general API access)
   - ✅ `read_repository` (read code)
   - ❌ NOT `write_repository` (don't need to write code)
5. Generate and copy token
6. Paste into `GITLAB_TOKEN="glpat-xxx"`

**Self-Hosted GitLab:**
```bash
GITLAB_TOKEN="glpat-xxx"
GITLAB_URL="https://gitlab.company.com"  # Your self-hosted URL
```

**Get Token (Self-Hosted):**
1. Go to `https://your-gitlab-url/-/profile/personal_access_tokens`
2. Follow same steps as cloud GitLab

---

### Bitbucket

**Template:**
```bash
BITBUCKET_TOKEN=xxx
BITBUCKET_WORKSPACE=your-workspace
BITBUCKET_REPO=your-repo
```

**Get Token:**
1. Go to https://bitbucket.org/account/settings/app-passwords/
2. Create new app password
3. Give it a name (e.g., "Code Review Automation")
4. Select permissions:
   - ✅ `repositories` (read repositories)
   - ✅ `pullrequest` (read/write PR comments)
5. Generate and copy password
6. Paste into `BITBUCKET_TOKEN="xxx"`

**Find Workspace/Repo:**
```bash
# From your repository URL: https://bitbucket.org/YOUR-WORKSPACE/YOUR-REPO
BITBUCKET_WORKSPACE="YOUR-WORKSPACE"
BITBUCKET_REPO="YOUR-REPO"
```

---

### Gitea

**Template:**
```bash
GITEA_TOKEN=xxx
GITEA_URL=https://gitea.company.com
GITEA_OWNER=your-username
GITEA_REPO=your-repo
```

**Get Token:**
1. Go to your Gitea instance: `https://your-gitea-url/user/settings/applications`
2. Create new access token
3. Give it a name (e.g., "Code Review Automation")
4. Select scopes:
   - ✅ `repo` (repository access)
   - ✅ `write:issue` (post comments)
5. Generate and copy token
6. Paste into `GITEA_TOKEN="xxx"`

**Find Owner/Repo:**
```bash
# From your repository URL: https://your-gitea-url/OWNER/REPO
GITEA_OWNER="OWNER"
GITEA_REPO="REPO"
```

---

### General Configuration

```bash
# Skip review and only generate report
SKIP_REVIEW=false

# Dry run - show what would happen without doing it
DRY_RUN=false

# Verbose output
VERBOSE=false
```

---

## 💡 Usage Examples

### Example 1: GitHub User

**Setup (.env):**
```bash
GITHUB_TOKEN="ghp_xxx_your_token_here"
```

**Usage:**
```bash
source .env
./main-review.sh feature/auth main . --post-to-platform
```

### Example 2: GitLab Cloud

**Setup (.env):**
```bash
GITLAB_TOKEN="glpat-xxx_your_token_here"
GITLAB_URL="https://gitlab.com"
```

**Usage:**
```bash
source .env
./main-review.sh feature/auth develop . --post-to-platform
```

### Example 3: Self-Hosted GitLab

**Setup (.env):**
```bash
GITLAB_TOKEN="glpat-xxx_your_token_here"
GITLAB_URL="https://gitlab.company.com"
```

**Usage:**
```bash
source .env
./main-review.sh feature/auth develop . --post-to-platform
```

### Example 4: Bitbucket

**Setup (.env):**
```bash
BITBUCKET_TOKEN="xxx_your_token_here"
BITBUCKET_WORKSPACE="my-workspace"
BITBUCKET_REPO="my-repo"
```

**Usage:**
```bash
source .env
./main-review.sh feature/auth develop . --post-to-platform
```

### Example 5: Gitea Self-Hosted

**Setup (.env):**
```bash
GITEA_TOKEN="xxx_your_token_here"
GITEA_URL="https://gitea.company.com"
GITEA_OWNER="john"
GITEA_REPO="my-project"
```

**Usage:**
```bash
source .env
./main-review.sh feature/auth develop . --post-to-platform
```

---

## 🔒 Security Best Practices

### ✅ DO This

```bash
# Good: Token in .env (not committed)
export GITHUB_TOKEN="ghp_xxx"

# Good: Load from file
source .env

# Good: Use in script
./main-review.sh ... --post-to-platform

# Good: Token only in environment
echo $GITHUB_TOKEN  # Shows token, but not in logs/code
```

### ❌ DON'T Do This

```bash
# Bad: Token in command (could be logged)
./main-review.sh ... --token "ghp_xxx"

# Bad: Token in script (ends up in git history)
GITHUB_TOKEN="ghp_xxx"  # In script file
./main-review.sh ...

# Bad: Token in credentials file (committed)
# Never add .env to git!

# Bad: Commit .env.example with real tokens
# Keep .env.example as template only!
```

---

## 📝 Troubleshooting

### Issue: "Token not found"

**Problem**: Environment variable not set

**Solution**:
```bash
# Make sure you sourced .env
source .env

# Verify token is loaded
echo $GITHUB_TOKEN  # Should show your token

# If empty, check .env file
cat .env | grep GITHUB_TOKEN
```

### Issue: "Authentication failed"

**Problem**: Token is expired, revoked, or invalid

**Solution**:
```bash
# Generate a new token from your platform
# GitHub: https://github.com/settings/tokens
# GitLab: https://gitlab.com/-/profile/personal_access_tokens
# Etc.

# Update .env with new token
nano .env

# Reload
source .env

# Test
./main-review.sh feature/test develop . --post-to-platform
```

### Issue: "Permission denied"

**Problem**: Token doesn't have required permissions

**Solution**:
```bash
# Check token permissions on your platform
# GitHub: https://github.com/settings/tokens (view token details)
# GitLab: https://gitlab.com/-/profile/personal_access_tokens

# Regenerate with correct scopes:
# GitHub: repo, read:repo_hook
# GitLab: api, read_repository
# Bitbucket: repositories, pullrequest
# Gitea: repo

# Update .env and reload
```

### Issue: "URL not found" (self-hosted)

**Problem**: GITLAB_URL, GITEA_URL, or similar is wrong

**Solution**:
```bash
# Verify your platform URL
# For self-hosted GitLab:
echo $GITLAB_URL  # Should be https://gitlab.company.com (no trailing slash)

# For self-hosted Gitea:
echo $GITEA_URL   # Should be https://gitea.company.com (no trailing slash)

# Update .env
GITLAB_URL="https://gitlab.company.com"  # Correct format

# Reload
source .env
```

---

## 🔄 Multiple Environments

### Switch Between Platforms

```bash
# Save current settings
cp .env .env.github
source .env.github
./main-review.sh ...

# Switch to GitLab
cp .env .env.gitlab
# Edit .env.gitlab with GitLab credentials
source .env.gitlab
./main-review.sh ...

# Switch back to GitHub
source .env.github
./main-review.sh ...
```

### CI/CD Integration

**GitHub Actions:**
```yaml
- name: Code Review
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: ./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} .
```

**GitLab CI:**
```yaml
code_review:
  env:
    GITLAB_TOKEN: $CI_JOB_TOKEN
    GITLAB_URL: $CI_SERVER_URL
  script:
    - ./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME .
```

**Bitbucket Pipelines:**
```yaml
step:
  - &build
    script:
      - export BITBUCKET_TOKEN=$BB_AUTH_TOKEN
      - ./main-review.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH .
```

---

## ✅ Setup Checklist

- [ ] Copy `.env.example` to `.env`
- [ ] Choose your platform (GitHub, GitLab, Bitbucket, Gitea)
- [ ] Get your API token from your platform
- [ ] Uncomment and fill in the token in `.env`
- [ ] If self-hosted, set the URL (GITLAB_URL, GITEA_URL, etc)
- [ ] Save `.env`
- [ ] Load with `source .env`
- [ ] Test with `./main-review.sh ... --post-to-platform`
- [ ] Verify `.env` is in `.gitignore` (don't commit it!)

---

## 📞 Quick Reference

| Platform | Token Name | URL Setting | Token URL |
|----------|-----------|-------------|-----------|
| **GitHub** | `GITHUB_TOKEN` | Optional: `GITHUB_ENTERPRISE_URL` | https://github.com/settings/tokens |
| **GitLab Cloud** | `GITLAB_TOKEN` | `GITLAB_URL=https://gitlab.com` | https://gitlab.com/-/profile/personal_access_tokens |
| **GitLab Self** | `GITLAB_TOKEN` | `GITLAB_URL=https://your-url` | `https://your-url/-/profile/personal_access_tokens` |
| **Bitbucket** | `BITBUCKET_TOKEN` | + `BITBUCKET_WORKSPACE` + `BITBUCKET_REPO` | https://bitbucket.org/account/settings/app-passwords |
| **Gitea** | `GITEA_TOKEN` | `GITEA_URL=https://your-url` | `https://your-url/user/settings/applications` |

---

**✅ Now you have the `.env.example` file with complete setup instructions!**

*Last Updated: 2024*
