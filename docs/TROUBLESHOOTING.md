# 🚨 Troubleshooting Guide

> **v3 Update (2026-02-22):** Troubleshooting steps should target `scripts/enhanced-copilot-review-v3.sh` as the default script.

Common issues and solutions for the Agentic AI Code Reviewer.

---

## Installation Issues

### "gh: command not found"

**Problem:** GitHub CLI not installed

**Solutions:**

```bash
# macOS
brew install gh

# Ubuntu/Debian
curl -fsSLo /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.x.x/gh_2.x.x_linux_amd64.deb
sudo dpkg -i /tmp/gh.deb

# CentOS/RHEL
sudo dnf install 'dnf-command(copr)'
sudo dnf copr enable cli/cli community
sudo dnf install gh

# Or build from source
git clone https://github.com/cli/cli.git
cd cli
make
sudo ./bin/gh completion -s bash | sudo tee /etc/bash_completion.d/gh > /dev/null
```

---

### "Permission denied" on scripts/enhanced-copilot-review-v3.sh

**Problem:** Script not executable

**Solution:**
```bash
chmod +x scripts/enhanced-copilot-review-v3.sh
```

---

### "not authenticated with GitHub"

**Problem:** GitHub CLI not authenticated

**Solution:**
```bash
gh auth login
# Follow interactive prompts:
# - Select GitHub.com
# - Choose SSH or HTTPS
# - Authorize with browser
# - Done!
```

---

## Runtime Issues

### "No changes to review"

**Problem:** No diff found between branches

**Solutions:**

```bash
# Check branch names are correct
git branch -a

# Verify branches exist
git show-ref --verify refs/heads/feature/auth

# Try specific diff
git diff main..feature/auth

# Check if code path is correct
ls -la ./src

# Run with explicit branches
./scripts/enhanced-copilot-review-v3.sh main feature/auth ./src
```

---

### "Download failed" for awesome-copilot files

**Problem:** Network issue or repository down

**Solutions:**

```bash
# Check internet connection
ping github.com

# Test manual download
curl -fL https://raw.githubusercontent.com/github/awesome-copilot/main/instructions/java.instructions.md

# Clear cache and retry
rm -rf .copilot/
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src

# Use cached files if available
ls -la .copilot/instructions/
```

---

### "Copilot extension not found"

**Problem:** GitHub CLI Copilot extension not installed

**Solution:**

```bash
# Script auto-installs, but if it fails manually:
gh extension install github/gh-copilot

# Verify installation
gh extension list | grep copilot

# If still fails, check version
gh version
# Copilot extension requires gh v2.x.x or higher
```

---

### "JSON parse error"

**Problem:** Copilot response isn't valid JSON

**Solution:**

```bash
# Check raw output
cat reports/copilot-review.txt | head -50

# Copilot might return markdown instead of JSON
# Try running again - it's usually first-run issue

# If persistent, check Copilot availability
gh copilot suggest "test" --no-cache

# Report issue with example to GitHub
```

---

### "No such file or directory: .copilot/instructions"

**Problem:** Directory not created yet

**Solution:**

```bash
# Script creates this automatically, but if not:
mkdir -p .copilot/instructions
mkdir -p .copilot/agents

# Run review again
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src
```

---

### "timeout waiting for copilot response"

**Problem:** Copilot API taking too long

**Solutions:**

```bash
# Check GitHub API status
curl https://www.githubstatus.com/api/v2/status.json | jq .

# Try smaller code changes
# Copilot responds faster to smaller diffs

# Retry with increased timeout
# Add to script if needed (around line 250):
COPILOT_TIMEOUT=300 ./scripts/enhanced-copilot-review-v3.sh ...

# Try during off-peak hours
# (less API load = faster response)
```

---

### "too many requests" error

**Problem:** Rate limiting from GitHub API

**Solution:**

```bash
# Wait and retry
sleep 60
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src

# Check rate limit
gh api rate-limit

# Upgrade GitHub account for higher limits
# Free: 60 requests/hour
# Authenticated: 5000 requests/hour
```

---

## Platform-Specific Issues

### "git diff not found"

**Problem:** Git not installed or not in PATH

**Solution:**

```bash
# Install git
# macOS: brew install git
# Ubuntu: sudo apt-get install git
# Others: See https://git-scm.com/downloads

# Add to PATH if needed
export PATH="$PATH:/usr/local/bin"
```

---

### "branch not found"

**Problem:** Branch name incorrect or doesn't exist

**Solutions:**

```bash
# List all branches
git branch -a

# Create missing branch
git checkout -b feature/test

# Verify remote branches
git fetch origin
git branch -r

# Use correct names
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src
```

---

### GitLab/Bitbucket/Gitea Issues

**Problem:** Platform-specific error

**Solution:**

```bash
# These platforms work with GitHub CLI via REST API
# Most issues are platform authentication

# For GitLab
# Ensure your GitLab token is configured
gh auth login
# Select: GitHub Enterprise Server
# Server address: https://gitlab.com

# For Bitbucket
# Set BITBUCKET_TOKEN environment variable
export BITBUCKET_TOKEN="your_token"

# For Gitea
# Set GITEA_TOKEN and GITEA_URL
export GITEA_TOKEN="your_token"
export GITEA_URL="https://gitea.example.com"
```

---

## Output Issues

### "reports directory empty"

**Problem:** Review completed but no output files

**Solution:**

```bash
# Check if review actually ran
ls -la reports/

# Check script output for errors
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src 2>&1 | tail -20

# Verify copilot response
cat reports/copilot-review.txt

# Check permissions
chmod 755 reports/
```

---

### "CI smoke validation failed"

**Problem:** `scripts/ci-smoke-validate-artifacts.sh` exits non-zero in CI

**Solutions:**

```bash
# Run validator manually
./scripts/ci-smoke-validate-artifacts.sh reports

# Common causes:
# 1) Missing files
ls -la reports/copilot-review.json reports/enhanced-copilot-review.md

# 2) Invalid JSON
jq empty reports/copilot-review.json

# 3) Recommendation enum invalid
jq '.recommendation' reports/copilot-review.json

# 4) stats mismatch with issues
jq '{issues:(.issues|length),stats:.stats}' reports/copilot-review.json
```

---

### "JSON report malformed"

**Problem:** reports/copilot-review.json is not valid JSON

**Solutions:**

```bash
# Validate JSON
jq . reports/copilot-review.json

# Show error
jq . reports/copilot-review.json 2>&1 | head

# Check for special characters
cat reports/copilot-review.json | head -20

# Raw output might contain markdown
# This is normal - Copilot sometimes returns markdown instead of JSON
# Try running again

# Workaround: parse as text
grep -o '"severity".*"critical"' reports/copilot-review.json
```

---

### "Markdown report incomplete"

**Problem:** reports/enhanced-copilot-review.md is truncated

**Solution:**

```bash
# Check file size
wc -l reports/enhanced-copilot-review.md

# Might be expected if very large
# Split into smaller reviews

# Check for errors
tail -20 reports/enhanced-copilot-review.md

# Regenerate
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src
```

---

## Performance Issues

### "Review takes too long"

**Problem:** Exceeding expected execution time

**Solutions:**

```bash
# Break large PRs into smaller changes
# Copilot responds faster to smaller diffs

# Review only specific directory
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src
# instead of
./scripts/enhanced-copilot-review-v3.sh main feature/test .

# Check network speed
ping -c 3 github.com

# Try during off-peak hours
# GitHub API might be under load

# Check system resources
top
# Ensure you have sufficient memory and CPU
```

---

### "Script consumes too much memory"

**Problem:** OOM error or system slowdown

**Solution:**

```bash
# This is rare - script is lightweight
# Issue is likely with Copilot API response

# Monitor memory
watch -n 1 free -h

# If stuck, kill process
pkill -f enhanced-copilot-review-v3.sh

# Try again with smaller code diff
```

---

## Configuration Issues

### ".github/copilot-instructions.md not readable by Copilot"

**Problem:** Instructions not being applied

**Solutions:**

```bash
# Verify file exists and is readable
ls -la .github/copilot-instructions.md
cat .github/copilot-instructions.md | head -20

# Verify file is in correct location
# Must be in .github/ directory at repo root

# Check file format
file .github/copilot-instructions.md
# Should be: ASCII text, with very long lines

# Verify YAML frontmatter
head -3 .github/copilot-instructions.md
# Should show: ---

# For VS Code, restart VS Code
# Copilot loads config on startup
```

---

### "AGENTS.md not being used"

**Problem:** Agents not loaded in IDE

**Solution:**

```bash
# Verify file exists
ls -la AGENTS.md
cat AGENTS.md | head -20

# In VS Code:
# 1. Close editor
# 2. Close folder
# 3. Reopen folder
# 4. Give Copilot 10 seconds to load

# Check VS Code Copilot extension version
# May need latest version for agent support

# Check settings.json
# codium ~/.vscode/settings.json | grep -i copilot
```

---

### "Stack not detected correctly"

**Problem:** Wrong technology detected

**Solution:**

```bash
# Check what was detected
grep "TECH_STACK" reports/enhanced-copilot-review.md

# Verify files are in correct locations
find ./src -name "*.java" | head
find ./src -name "*.py" | head

# If files are in non-standard locations:
# Either move them or run against specific path
./scripts/enhanced-copilot-review-v3.sh main feature/test ./backend

# Check detection logic in script
grep -A 20 "detect_stack()" scripts/enhanced-copilot-review-v3.sh

# Manually specify stack (if you customize script)
# Add export TECH_STACK="java=true python=true react=true"
```

---

## Integration Issues

### "Not working with GitHub Actions"

**Problem:** Script fails in CI/CD environment

**Solution:**

```yaml
# Ensure these steps are present:
- uses: actions/checkout@v3
  with:
    fetch-depth: 0  # Full history for git diff

- name: Install GitHub CLI
  run: |
    curl -fsSLo gh.deb https://github.com/cli/cli/releases/download/v2.x.x/gh_2.x.x_linux_amd64.deb
    sudo dpkg -i gh.deb

- name: Authenticate
  run: |
    echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token

- name: Run Review
  run: |
    chmod +x scripts/enhanced-copilot-review-v3.sh
    ./scripts/enhanced-copilot-review-v3.sh ${{ github.base_ref }} ${{ github.head_ref }} .
```

---

### "GitLab CI not working"

**Problem:** Script fails in GitLab CI/CD

**Solution:**

```yaml
code_review:
  image: ubuntu:latest
  script:
    # Install dependencies
    - apt-get update && apt-get install -y git curl
    - curl -fsSLo gh.deb https://github.com/cli/cli/releases/download/v2.x.x/gh_2.x.x_linux_amd64.deb
    - dpkg -i gh.deb
    
    # Setup authentication
    - mkdir -p ~/.config/gh
    - echo "$CI_JOB_TOKEN" | gh auth login --with-token
    
    # Configure git
    - git config --global user.email "ci@gitlab.com"
    - git config --global user.name "GitLab CI"
    
    # Run review
    - chmod +x scripts/enhanced-copilot-review-v3.sh
    - ./scripts/enhanced-copilot-review-v3.sh $CI_MERGE_REQUEST_TARGET_BRANCH_NAME $CI_COMMIT_REF_NAME .
  artifacts:
    paths:
      - reports/
    expire_in: 1 week
```

---

## Common Errors Reference

| Error | Cause | Fix |
|-------|-------|-----|
| `command not found: gh` | GitHub CLI not installed | `brew install gh` |
| `Permission denied` | Script not executable | `chmod +x script.sh` |
| `not authenticated` | Not logged into GitHub | `gh auth login` |
| `No changes found` | Empty diff | Check branch names |
| `JSON parse error` | Invalid response | Retry, check API status |
| `timeout` | Slow network | Retry, use smaller diffs |
| `rate limited` | Too many API calls | Wait, check limits |
| `file not found` | Wrong path | Verify git location |
| `permission denied (publickey)` | SSH key issue | Check ssh-agent, keys |
| `CRLF/LF mismatch` | Line ending issue | `git config core.autocrlf false` |

---

## Getting Help

### Check These First

1. **Script output** - Run with full output:
   ```bash
  bash -x scripts/enhanced-copilot-review-v3.sh main feature/test . 2>&1 | tail -50
   ```

2. **Raw Copilot response**:
   ```bash
   cat reports/copilot-review.txt
   ```

3. **System info**:
   ```bash
   gh --version
   git --version
   uname -a
   ```

### Resources

- **GitHub CLI Docs:** https://cli.github.com/
- **awesome-copilot Repo:** https://github.com/github/awesome-copilot
- **GitHub Status:** https://www.githubstatus.com/
- **Stack Overflow:** Tag: `github-copilot`
- **GitHub Discussions:** github/copilot-sdk

---

**Last Updated:** February 2024
