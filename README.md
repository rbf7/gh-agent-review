# 📚 Code Review Automation System

> **Platform-Agnostic • Git Native • Zero Vendor Lock-in**

A powerful, automated code review system that works with **GitHub**, **GitLab**, **Bitbucket**, **Gitea**, or **local-only** analysis.

## ✨ Key Features

✅ **Platform Agnostic** - Works with any Git platform  
✅ **Git Native** - Uses standard `git diff` (no special CLI tools)  
✅ **Local First** - Analyze offline, post to platform optionally  
✅ **Zero Dependencies** - Just Git + Python (nothing else needed)  
✅ **Security Analysis** - Identifies vulnerabilities, secrets, anti-patterns  
✅ **Code Quality** - Coverage gaps, complexity issues, style problems  
✅ **Performance Review** - Detects inefficiencies, N+1 queries, memory leaks  
✅ **Automated Posting** - Converts analysis to PR/MR comments (optional)  

---

## 🚀 Quick Start (2 Minutes)

### Local Analysis (No Authentication Needed)
```bash
# Clone
git clone <url>/code-review-automation.git
cd code-review-automation

# Setup
./setup.sh

# Run analysis
./main-review.sh feature/auth develop ./src

# Output: report.json in current directory
```

### With Platform Posting (Optional)
```bash
# Set your platform token (choose one):
export GITHUB_TOKEN="ghp_xxx"           # GitHub
# OR
export GITLAB_TOKEN="glpat-xxx"         # GitLab
# OR
export BITBUCKET_TOKEN="xxx"            # Bitbucket
# OR
export GITEA_TOKEN="xxx"                # Gitea

# Run with posting
./main-review.sh feature/auth main . --post-to-platform

# Comment automatically posted to PR/MR!
```

---

## 📋 How It Works

### Step 1: Get Changes (Native Git)
```bash
git diff $TARGET_BRANCH...$SOURCE_BRANCH
```

### Step 2: Analyze Locally
- Security scanning
- Code quality checks
- Coverage analysis
- Performance detection

### Step 3: Generate Report
- JSON format (platform-agnostic)
- Markdown format (human-readable)
- Ready to post or save

### Step 4: Optional Platform Posting
- Auto-detects platform from env var
- Posts as PR/MR comment
- Links back to code lines

---

## 🎯 Supported Platforms

| Platform | Support | Integration |
|----------|---------|-------------|
| **GitHub** | ✅ Full | GitHub Actions, local, CI/CD |
| **GitLab** | ✅ Full | GitLab CI/CD, local, Jenkins |
| **Bitbucket** | ✅ Full | Bitbucket Pipelines, local, CI/CD |
| **Gitea** | ✅ Full | Local only (no CI), self-hosted |
| **Local Only** | ✅ Full | Offline analysis, no auth needed |
| **Enterprise** | ✅ Full | Self-hosted, custom integrations |

---

## 📦 What's Included

### Scripts
- `main-review.sh` - Main entry point
- `scripts/get-diff.sh` - Get changes using git diff
- `scripts/analyze-security.sh` - Security analysis
- `scripts/analyze-quality.sh` - Code quality checks
- `scripts/analyze-coverage.sh` - Coverage analysis
- `scripts/analyze-performance.sh` - Performance detection
- `scripts/generate-report.sh` - Report generation
- `scripts/post-to-platform.sh` - Post to GitHub/GitLab/Bitbucket
- `setup.sh` - One-time setup

### Configuration
- `config/rules.yaml` - Customizable analysis rules
- `config/projects.yaml` - Project-specific settings
- `.env.example` - Environment variables template

### Documentation
- `GIT_AGNOSTIC_ARCHITECTURE.md` - Design deep-dive
- `QUICK_REFERENCE.md` - Common commands
- `GitHub_SETUP.md` - GitHub integration
- `GITLAB_SETUP.md` - GitLab integration
- `BITBUCKET_SETUP.md` - Bitbucket integration
- `GITEA_SETUP.md` - Gitea integration
- `LOCAL_ONLY_SETUP.md` - Local-only guide

---

## 🔧 Installation

### Prerequisites
```bash
# Required (already installed on most systems)
git --version           # 2.0+
python3 --version       # 3.8+

# Optional (for CI/CD)
curl --version         # For API posting
jq --version           # For JSON processing
```

### Setup (One Time)
```bash
git clone <url>/code-review-automation.git
cd code-review-automation
chmod +x *.sh scripts/*.sh
./setup.sh
```

---

## 📖 Usage Examples

### Local Analysis
```bash
# Analyze feature branch against develop
./main-review.sh feature/auth develop ./src

# Output: report.json
```

### With Platform Posting
```bash
# GitHub
export GITHUB_TOKEN="ghp_xxx"
./main-review.sh feature/auth main . --post-to-platform

# GitLab
export GITLAB_TOKEN="glpat-xxx"
./main-review.sh feature/auth develop . --post-to-platform

# Bitbucket
export BITBUCKET_TOKEN="xxx"
./main-review.sh feature/auth develop . --post-to-platform
```

### Dry Run (See what would happen)
```bash
./main-review.sh feature/auth develop ./src --dry-run
```

### Custom Configuration
```bash
# Edit rules for your project
nano config/rules.yaml

# Use custom config
./main-review.sh feature/auth develop ./src --config ./config/custom.yaml
```

---

## 🏛️ Architecture

### Platform-Agnostic Design
```
┌─────────────────────────────────────┐
│  User runs: ./main-review.sh        │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  Get diff using native git          │
│  git diff $TARGET...$SOURCE         │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  Run analysis (100% offline)        │
│  ✓ Security scanning                │
│  ✓ Code quality                     │
│  ✓ Coverage gaps                    │
│  ✓ Performance issues               │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  Generate JSON report               │
│  (platform-agnostic format)         │
└─────────────────────────────────────┘
              │
              ├─► Save as report.json
              │
              └─► OPTIONAL: Post to platform
                  ├─ GitHub (if GITHUB_TOKEN set)
                  ├─ GitLab (if GITLAB_TOKEN set)
                  ├─ Bitbucket (if BITBUCKET_TOKEN set)
                  └─ Gitea (if GITEA_TOKEN set)
```

### Zero Vendor Lock-In
- No GitLab CLI required
- No GitHub CLI required
- No special tools needed
- Just Git + standard REST APIs
- Works everywhere

---

## 🔒 Security & Privacy

### Local Analysis
- ✅ Runs 100% locally
- ✅ No data sent to external services (unless you choose to post)
- ✅ Perfect for enterprise/sensitive code
- ✅ No authentication needed for local analysis

### Optional Platform Posting
- ✅ Only posts if you set environment variable
- ✅ Uses official platform APIs
- ✅ Standard OAuth tokens
- ✅ Posts only what's in your `report.json`

---

## 📊 Output Example

### JSON Report (report.json)
```json
{
  "review_date": "2024-01-15T10:30:00Z",
  "source_branch": "feature/auth",
  "target_branch": "main",
  "files_changed": 5,
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
  "quality_issues": [...],
  "coverage_gaps": [...],
  "performance_issues": [...]
}
```

### Markdown Comment (Posted to PR/MR)
```markdown
## 🔍 Code Review Analysis

**Summary:** 12 issues found (3 HIGH, 5 MEDIUM, 4 LOW)

### 🔒 Security (3 issues)
- ⚠️ Line 42: Hardcoded password found
- ...

### 📊 Code Quality (5 issues)
- 🟡 Line 15: Function too complex (cyclomatic: 8)
- ...

### 📈 Coverage (2 issues)
- 🔴 Line 89: Uncovered branch
- ...

### ⚡ Performance (2 issues)
- 🐌 Line 120: N+1 query detected
- ...
```

---

## 🛠️ Configuration

### Edit Rules
```bash
# Edit what the system looks for
nano config/rules.yaml
```

### Example: Adding a Rule
```yaml
security_checks:
  - id: "HARDCODED_SECRETS"
    pattern: "(password|secret|key|token)\\s*=\\s*['\"].*['\"]"
    severity: "HIGH"
    message: "Hardcoded secret detected"
```

### Project-Specific Settings
```bash
# Configure for your project
nano config/projects.yaml
```

---

## 🚀 CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/review.yml
name: Code Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: ./setup.sh
      - run: export GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }} && ./main-review.sh ${{ github.head_ref }} ${{ github.base_ref }} . --post-to-platform
```

### GitLab CI/CD
```yaml
# .gitlab-ci.yml
code_review:
  script:
    - ./setup.sh
    - export GITLAB_TOKEN=$CI_JOB_TOKEN
    - ./main-review.sh $CI_COMMIT_REF_NAME $CI_MERGE_REQUEST_TARGET_BRANCH_NAME . --post-to-platform
  only:
    - merge_requests
```

### Bitbucket Pipelines
```yaml
# bitbucket-pipelines.yml
image: ubuntu:latest
pipelines:
  pull-requests:
    '**':
      - step:
          script:
            - ./setup.sh
            - export BITBUCKET_TOKEN=$BITBUCKET_TOKEN
            - ./main-review.sh $BITBUCKET_BRANCH $BITBUCKET_PR_DESTINATION_BRANCH . --post-to-platform
```

### Jenkins
```groovy
// Jenkinsfile
pipeline {
    post {
        always {
            script {
                sh './setup.sh'
                sh 'export GITHUB_TOKEN=$GITHUB_TOKEN && ./main-review.sh feature develop . --post-to-platform'
            }
        }
    }
}
```

---

## 🆘 Troubleshooting

### "Command not found: ./main-review.sh"
```bash
chmod +x main-review.sh scripts/*.sh
```

### "Git command failed"
```bash
# Make sure you're in a git repository
git status

# Make sure branches exist
git branch -a
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
# Check your token is exported
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN

# Make sure token has correct permissions
# GitHub: repo, read:repo_hook
# GitLab: api, read_repository
# Bitbucket: repo, pr:read
```

---

## 📚 Documentation

- **[GIT_AGNOSTIC_ARCHITECTURE.md](GIT_AGNOSTIC_ARCHITECTURE.md)** - Design deep-dive
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Common commands
- **[GitHub_SETUP.md](GitHub_SETUP.md)** - GitHub integration
- **[GITLAB_SETUP.md](GITLAB_SETUP.md)** - GitLab integration
- **[BITBUCKET_SETUP.md](BITBUCKET_SETUP.md)** - Bitbucket integration
- **[GITEA_SETUP.md](GITEA_SETUP.md)** - Gitea integration
- **[LOCAL_ONLY_SETUP.md](LOCAL_ONLY_SETUP.md)** - Local-only guide

---

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `./main-review.sh` on your changes
5. Submit a pull request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🎯 Key Principles

1. **Git Native** - Use git, not vendor CLIs
2. **Platform Agnostic** - Work with any platform
3. **Local First** - Analyze offline by default
4. **Minimal Dependencies** - Just what's needed
5. **Simple Setup** - One `setup.sh` script
6. **Zero Lock-in** - Switch platforms anytime
7. **Open Standard** - JSON output format
8. **Enterprise Ready** - Works in any environment

---

## ❓ FAQ

**Q: Do I need to authenticate to run local analysis?**  
A: No! Local analysis is 100% offline. Authentication is only needed if you want to post results to a platform.

**Q: What if I use multiple platforms?**  
A: Just set different environment variables. The system auto-detects based on what's set.

**Q: Can I run this in CI/CD?**  
A: Yes! Works with GitHub Actions, GitLab CI, Bitbucket Pipelines, Jenkins, and any CI system that can run shell scripts.

**Q: What about self-hosted platforms?**  
A: Full support for self-hosted GitLab, Gitea, and Bitbucket Server. Just set the URL environment variable.

**Q: Is it secure?**  
A: Yes. Local analysis never sends data anywhere. Tokens are never logged. Only you decide what to post.

---

**Ready to get started?**

1. **[Quick Start](QUICK_REFERENCE.md)** (2 minutes)
2. **[Architecture](GIT_AGNOSTIC_ARCHITECTURE.md)** (10 minutes)
3. **[Setup Guide](LOCAL_ONLY_SETUP.md)** (15 minutes)

*Last Updated: 2024*
