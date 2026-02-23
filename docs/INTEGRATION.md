# 🔧 Integration Guide

> **v3 Update (2026-02-22):** CI/CD examples should invoke `scripts/enhanced-copilot-review-v3.sh` for current behavior.

How to integrate the Agentic AI Code Reviewer into your CI/CD pipelines and development workflows.

---

## GitHub Actions Integration

### Basic Setup

Create `.github/workflows/code-review.yml`:

```yaml
name: AI Code Review

on:
  pull_request:
    branches: [main, develop]

jobs:
  copilot-review:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Install Dependencies
        run: |
          brew install gh
          gh auth login --with-token <<< ${{ secrets.GITHUB_TOKEN }}
      
      - name: Run AI Code Review
        run: |
          chmod +x scripts/enhanced-copilot-review-v3.sh
          chmod +x scripts/ci-smoke-validate-artifacts.sh
          ./scripts/enhanced-copilot-review-v3.sh \
            ${{ github.base_ref }} \
            ${{ github.head_ref }} \
            ./

      - name: Validate Artifacts (CI Smoke)
        run: |
          ./scripts/ci-smoke-validate-artifacts.sh reports
      
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: code-review-report
          path: reports/
      
      - name: Comment PR
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('reports/enhanced-copilot-review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

---

## GitLab CI Integration

Create `.gitlab-ci.yml`:

```yaml
stages:
  - review

ai_code_review:
  stage: review
  script:
    - chmod +x scripts/enhanced-copilot-review-v3.sh
    - chmod +x scripts/ci-smoke-validate-artifacts.sh
    - ./scripts/enhanced-copilot-review-v3.sh $CI_MERGE_REQUEST_TARGET_BRANCH_NAME $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME ./
    - ./scripts/ci-smoke-validate-artifacts.sh reports
  artifacts:
    paths:
      - reports/
    reports:
      codequality: reports/copilot-review.json
  only:
    - merge_requests
```

---

## Jenkins Integration

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('AI Code Review') {
            steps {
                script {
                    sh '''
                        chmod +x scripts/enhanced-copilot-review-v3.sh
                chmod +x scripts/ci-smoke-validate-artifacts.sh
                        ./scripts/enhanced-copilot-review-v3.sh main "${GIT_BRANCH}" ./
                ./scripts/ci-smoke-validate-artifacts.sh reports
                    '''
                }
            }
        }
        
        stage('Archive Results') {
            steps {
                archiveArtifacts artifacts: 'reports/**', allowEmptyArchive: true
                publishHTML([
                    reportDir: 'reports',
                    reportFiles: 'enhanced-copilot-review.md',
                    reportName: 'AI Code Review Report'
                ])
            }
        }
    }
}
```

---

## Pre-Commit Hook Integration

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "🔍 Running AI Code Review..."

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)

# Check if code files are staged
if echo "$STAGED_FILES" | grep -E '\.(java|py|jsx|tsx|ts|tf)$' > /dev/null; then
    # Run review on staged changes
    ./scripts/enhanced-copilot-review-v3.sh HEAD ~ .
    
    if [ $? -ne 0 ]; then
        echo "❌ Code review failed"
        exit 1
    fi
    
    echo "✅ Code review passed"
fi

exit 0
```

Then:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Local Development Setup

### Option 1: Alias for Quick Reviews

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias coreview='./scripts/enhanced-copilot-review-v3.sh main develop ./'
alias coreview-java='./scripts/enhanced-copilot-review-v3.sh main develop ./src/main/java'
alias coreview-tf='./scripts/enhanced-copilot-review-v3.sh main develop ./terraform'
```

### Option 2: npm/pip Script

Add to `package.json`:

```json
{
  "scripts": {
    "review": "scripts/enhanced-copilot-review-v3.sh main develop ./",
    "review:app": "scripts/enhanced-copilot-review-v3.sh main develop ./src",
    "review:infra": "scripts/enhanced-copilot-review-v3.sh main develop ./terraform"
  }
}
```

Or `pyproject.toml`:

```toml
[tool.poetry.scripts]
review = "bash scripts/enhanced-copilot-review-v3.sh main develop ./"
```

---

## Docker Integration

Create `Dockerfile`:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.sources > /dev/null && \
    apt-get update && apt-get install -y gh

WORKDIR /app

COPY scripts/ /app/scripts/
COPY docs/ /app/docs/
COPY guides/ /app/guides/

RUN chmod +x /app/scripts/enhanced-copilot-review-v3.sh

ENTRYPOINT ["/app/scripts/enhanced-copilot-review-v3.sh"]
```

Usage:

```bash
docker build -t ai-code-reviewer .
docker run -v $(pwd):/workspace ai-code-reviewer main develop /workspace
```

---

## Environment Configuration

### Authentication

Set environment variables:

```bash
# GitHub Token (required)
export GITHUB_TOKEN="your_token_here"

# Optional: Copilot endpoint
export COPILOT_API_ENDPOINT="https://api.github.com"

# Optional: Cache directory
export COPILOT_CACHE_DIR="./.copilot"
```

### In CI/CD Systems

**GitHub Actions:**
```yaml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  COPILOT_CACHE_DIR: /tmp/copilot-cache
```

**GitLab CI:**
```yaml
variables:
  GITHUB_TOKEN: $CI_JOB_TOKEN
  COPILOT_CACHE_DIR: /tmp/copilot-cache
```

**Jenkins:**
```groovy
withEnv(['GITHUB_TOKEN=credentials("github-token")',
         'COPILOT_CACHE_DIR=/tmp/copilot-cache']) {
    sh './scripts/enhanced-copilot-review-v3.sh ...'
}
```

---

## Quality Gates

### Fail on Critical Issues

Add to your CI/CD:

```bash
# After running review
if grep -q "CRITICAL" reports/enhanced-copilot-review.md; then
    echo "❌ Critical issues found"
    exit 1
fi
```

### Conditional Passes

```bash
#!/bin/bash

# Parse report
CRITICAL=$(jq '.issues[] | select(.severity=="critical") | length' reports/copilot-review.json)
HIGH=$(jq '.issues[] | select(.severity=="high") | length' reports/copilot-review.json)

# Allow high but not critical
if [ "$CRITICAL" -gt 0 ]; then
    exit 1
fi

# Warn on high
if [ "$HIGH" -gt 5 ]; then
    echo "⚠️  Warning: $HIGH high severity issues"
fi

exit 0
```

---

## Monitoring & Alerts

### Slack Integration

```bash
#!/bin/bash

REPORT=$(cat reports/enhanced-copilot-review.md)
CRITICAL=$(jq '.issues[] | select(.severity=="critical") | length' reports/copilot-review.json)

if [ "$CRITICAL" -gt 0 ]; then
    curl -X POST $SLACK_WEBHOOK \
        -H 'Content-Type: application/json' \
        -d "{
            \"text\": \"🚨 Critical issues in code review\",
            \"blocks\": [
                {
                    \"type\": \"section\",
                    \"text\": {
                        \"type\": \"mrkdwn\",
                        \"text\": \"$REPORT\"
                    }
                }
            ]
        }"
fi
```

### Email Notifications

```bash
#!/bin/bash

if [ -f reports/enhanced-copilot-review.md ]; then
    mail -s "AI Code Review Report" team@company.com < reports/enhanced-copilot-review.md
fi
```

---

## Performance Tuning

### Caching Instructions

```bash
# Enable caching to skip downloads
export COPILOT_CACHE_DIR="/persistent/cache"

# First run: downloads (1-2 minutes)
./scripts/enhanced-copilot-review-v3.sh main develop ./

# Subsequent runs: cached (30-60 seconds)
./scripts/enhanced-copilot-review-v3.sh main develop ./
```

### Parallel Execution

For monorepos:

```bash
#!/bin/bash

# Review multiple services in parallel
(./scripts/enhanced-copilot-review-v3.sh main develop ./services/auth &)
(./scripts/enhanced-copilot-review-v3.sh main develop ./services/api &)
(./scripts/enhanced-copilot-review-v3.sh main develop ./services/frontend &)

wait

# Combine reports
jq -s 'add' reports/*/copilot-review.json > reports/combined.json
```

---

## Troubleshooting Integration

### Debug Mode

```bash
# Enable debug output
export DEBUG=1
./scripts/enhanced-copilot-review-v3.sh main develop ./
```

### Log Collection

```bash
# Capture full logs
./scripts/enhanced-copilot-review-v3.sh main develop ./ 2>&1 | tee review.log

# View just errors
grep -i "error\|fail\|critical" review.log
```

---

## Best Practices

1. **Run reviews on PRs, not every commit**
   - Reduces noise
   - Provides focused feedback

2. **Cache instructions between runs**
   - First run: 1-2 minutes
   - Cached runs: 30-60 seconds

3. **Comment on PRs with findings**
   - Automatic feedback
   - Team visibility

4. **Archive reports**
   - Track quality over time
   - Historical analysis

5. **Set quality gates**
   - Prevent critical issues
   - Allow education on high issues

6. **Integrate with existing tools**
   - Slack, email, dashboards
   - Team workflows

---

**Integration Guide v1.0.1 - February 2026**
