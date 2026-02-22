# 🚀 Quick Reference - Common Commands

All commands work on **macOS**, **Linux**, and **Windows (PowerShell)**.

---

## 📋 Most Common Commands

### Local Analysis (No Authentication)
```bash
# Analyze feature branch against develop
./main-review.sh feature/your-branch develop ./src

# Analyze against main branch
./main-review.sh feature/your-branch main .

# Dry run (see output without posting)
./main-review.sh feature/your-branch develop ./src --dry-run
```

### With Platform Posting

#### GitHub
```bash
export GITHUB_TOKEN="ghp_xxx"
./main-review.sh feature/auth main . --post-to-platform
```

#### GitLab
```bash
export GITLAB_TOKEN="glpat-xxx"
./main-review.sh feature/auth develop . --post-to-platform
```

#### Bitbucket
```bash
export BITBUCKET_TOKEN="xxx"
./main-review.sh feature/auth develop . --post-to-platform
```

#### Gitea
```bash
export GITEA_TOKEN="xxx"
./main-review.sh feature/auth develop . --post-to-platform
```

### CI/CD Integration

#### GitHub Actions
```bash
./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} . --post-to-platform
```

#### GitLab CI/CD
```bash
./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME . --post-to-platform
```

#### Bitbucket Pipelines
```bash
./main-review.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH . --post-to-platform
```

---

## 🔧 Configuration

### Edit Analysis Rules
```bash
nano config/rules.yaml
```

### Edit Project Settings
```bash
nano config/projects.yaml
```

### Set Environment Variables
```bash
# Create .env file
cp .env.example .env
nano .env

# Load environment
source .env
```

---

## 🆘 Quick Troubleshooting

### "Command not found"
```bash
# Make scripts executable
chmod +x *.sh scripts/*.sh
```

### "Permission denied"
```bash
# Fix permissions
chmod +x main-review.sh
chmod +x scripts/*.sh
```

### "Git not found"
```bash
# Install Git
# macOS: brew install git
# Ubuntu: sudo apt-get install git
# Windows: Download from git-scm.com
```

### "Python not found"
```bash
# Install Python 3.8+
# macOS: brew install python3
# Ubuntu: sudo apt-get install python3
# Windows: Download from python.org
```

### "Token authentication failed"
```bash
# Verify token is set
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN
echo $BITBUCKET_TOKEN
echo $GITEA_TOKEN

# GitHub token needs: repo, read:repo_hook
# GitLab token needs: api, read_repository
# Bitbucket token needs: repo, pr:read
# Gitea token needs: repo
```

### "Branch not found"
```bash
# Update local branches
git fetch origin

# Check available branches
git branch -a
```

### "Not a git repository"
```bash
# Make sure you're in repo directory
pwd
cd /path/to/your/repo
git status
```

---

## 📊 Understanding Output

### Report.json Structure
```json
{
  "review_date": "2024-01-15T10:30:00Z",
  "source_branch": "feature/auth",
  "target_branch": "main",
  "files_changed": 5,
  "total_issues": 12,
  "security_issues": [...],
  "quality_issues": [...],
  "coverage_gaps": [...],
  "performance_issues": [...]
}
```

### Severity Levels
- 🔴 **HIGH** - Critical security/functionality issues
- 🟠 **MEDIUM** - Important improvements needed
- 🟡 **LOW** - Nice-to-have optimizations
- ✅ **INFO** - Informational findings

---

## 🌍 Find Your Project ID

### GitHub
```bash
# Repository owner/repo
# Example: torvalds/linux
# ID = owner/repo

# Or use GitHub API
curl https://api.github.com/repos/OWNER/REPO | jq '.id'
```

### GitLab
```bash
# Project ID in Settings → General
# Or use GitLab API
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.com/api/v4/projects/search/PROJECTNAME
```

### Bitbucket
```bash
# Workspace/Repository
# Example: atlassian/python-bitbucket
# ID = workspace/repo

# Or use Bitbucket API
curl -u username:password \
  https://api.bitbucket.org/2.0/repositories/WORKSPACE/REPO
```

### Gitea
```bash
# Repository page shows path
# Example: gitea.company.com/user/repo
# ID = user/repo
```

---

## 📝 Common Workflows

### Workflow 1: Pre-Commit Check
```bash
#!/bin/bash
# Run before committing
./main-review.sh $(git rev-parse --abbrev-ref HEAD) develop ./src --dry-run
```

### Workflow 2: Pull Request Review
```bash
#!/bin/bash
# Run in CI/CD on PR
export GITHUB_TOKEN="$GH_TOKEN"
./main-review.sh $SOURCE_BRANCH $TARGET_BRANCH . --post-to-platform
```

### Workflow 3: Local Testing
```bash
#!/bin/bash
# Test multiple branches
for branch in feature/auth feature/api feature/db; do
  ./main-review.sh $branch develop ./src --dry-run
done
```

### Workflow 4: Batch Analysis
```bash
#!/bin/bash
# Analyze multiple projects
for project in project1 project2 project3; do
  cd $project
  ./main-review.sh develop main . --dry-run
  cd ..
done
```

---

## 🔐 Security Best Practices

### Never Commit Tokens
```bash
# ✅ Use environment variables
export GITHUB_TOKEN="xxx"

# ❌ Don't do this
echo "GITHUB_TOKEN=xxx" > .env
git add .env  # DON'T!

# ✅ Do this instead
echo ".env" >> .gitignore
git add .gitignore
```

### Use GitHub Secrets (GitHub Actions)
```yaml
- run: |
    export GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}
    ./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} .
```

### Use GitLab Variables (GitLab CI)
```yaml
code_review:
  script:
    - export GITLAB_TOKEN=$CI_JOB_TOKEN
    - ./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME .
```

### Use Bitbucket Variables (Bitbucket Pipelines)
```yaml
- step:
    script:
      - export BITBUCKET_TOKEN=$BITBUCKET_TOKEN
      - ./main-review.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH .
```

---

## 📋 Checklist: First Time Setup

- [ ] Clone repository
- [ ] Run `./setup.sh`
- [ ] Test locally: `./main-review.sh feature/test develop ./src`
- [ ] Check output: `cat report.json`
- [ ] Choose platform
- [ ] Get/create token for your platform
- [ ] Export token: `export PLATFORM_TOKEN="xxx"`
- [ ] Test with posting: `./main-review.sh feature/test develop . --post-to-platform`
- [ ] Check PR/MR comment
- [ ] Bookmark this page!

---

## 🆘 Getting Help

### Check Documentation
- Architecture: `GIT_AGNOSTIC_ARCHITECTURE.md`
- Your platform: `GitHub_SETUP.md` | `GITLAB_SETUP.md` | `BITBUCKET_SETUP.md` | `GITEA_SETUP.md`
- Local only: `LOCAL_ONLY_SETUP.md`

### Debug Mode
```bash
# See detailed output
./main-review.sh feature/test develop ./src --verbose
```

### Check Logs
```bash
# See what happened
tail -f review.log
```

### Test Connection
```bash
# Test GitHub token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Test GitLab token
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" https://gitlab.com/api/v4/user

# Test Bitbucket token
curl -u :$BITBUCKET_TOKEN https://api.bitbucket.org/2.0/user

# Test Gitea token
curl -H "Authorization: token $GITEA_TOKEN" $GITEA_URL/api/v1/user
```

---

## 💡 Pro Tips

### Alias for Faster Usage
```bash
# Add to ~/.bashrc or ~/.zshrc
alias review="./main-review.sh"

# Then use:
review feature/auth develop ./src
```

### Function for Multiple Branches
```bash
# Add to ~/.bashrc or ~/.zshrc
review_all() {
  for branch in $(git branch | grep 'feature'); do
    ./main-review.sh ${branch#* } develop ./src
  done
}

# Then use:
review_all
```

### Pipe to Less for Long Output
```bash
./main-review.sh feature/test develop ./src --verbose | less
```

### Filter Results
```bash
# View only high severity issues
cat report.json | jq '.[] | select(.severity=="HIGH")'
```

---

*Last Updated: 2024*
