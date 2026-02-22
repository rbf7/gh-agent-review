# 🤖 Agentic AI Code Reviewer

> **Production-Grade Code Review System** using GitHub Copilot + awesome-copilot Instructions + 6 Specialized AI Agents

> **v3 Update (2026-02-22):** Preferred script is `scripts/enhanced-copilot-review-v3.sh`. Legacy scripts `scripts/enhanced-copilot-review.sh` and `scripts/enhanced-copilot-review-v2.sh` are kept for backward compatibility.

![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.1-blue)
![Stack](https://img.shields.io/badge/stack-Java%20%7C%20Python%20%7C%20React%20%7C%20AWS%20%7C%20Terraform%20%7C%20TypeScript-orange)
![Platforms](https://img.shields.io/badge/platforms-GitHub%20%7C%20GitLab%20%7C%20Bitbucket%20%7C%20Gitea-blueviolet)

---

## ✨ What This Does

Automatically reviews your code with **6 specialized AI agents** and **10 instruction sets** from awesome-copilot, providing comprehensive analysis across:

- ✅ **Security** - OWASP vulnerabilities, injection attacks, auth/encryption
- ✅ **Performance** - Bottlenecks, optimization, scalability, N+1 queries
- ✅ **Code Quality** - Design patterns, maintainability, refactoring
- ✅ **Testing** - Coverage analysis, test quality, edge cases
- ✅ **Documentation** - Accuracy, completeness, examples
- ✅ **Infrastructure as Code** - Terraform best practices, state management, security
- ✅ **Stack-Specific** - Java/Spring, Python, React, AWS, Terraform, TypeScript patterns

**For your stack:** Java + Python + React + AWS + Terraform + TypeScript

---

## 🚀 Quick Start (30 Seconds)

```bash
# 1. Make executable
chmod +x scripts/enhanced-copilot-review-v3.sh

# 2. Run review
./scripts/enhanced-copilot-review-v3.sh main feature/auth ./src

# 3. View results
cat reports/enhanced-copilot-review.md
cat reports/copilot-review.json
```

**That's it!** The script handles everything else automatically.

👉 **[Full Quick Start Guide](QUICK_START.md)**

---

## 📋 Documentation

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[QUICK_START.md](QUICK_START.md)** | 30-second setup and common commands | 2 min |
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | System design, components, data flow | 10 min |
| **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** | Common issues and solutions | 5 min |
| **[docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md](docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md)** | Complete integration guide | 15 min |
| **[docs/INTEGRATION.md](docs/INTEGRATION.md)** | CI/CD integration patterns | 10 min |
| **[docs/EXAMPLES.md](docs/EXAMPLES.md)** | Real usage examples | 10 min |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Files to keep/delete, final cleanup | 5 min |

### Team-Specific Guides

| Guide | For | Contents |
|-------|-----|----------|
| **[guides/FOR_JAVA_DEVELOPERS.md](guides/FOR_JAVA_DEVELOPERS.md)** | Java/Spring teams | Spring patterns, enterprise best practices |
| **[guides/FOR_PYTHON_DEVELOPERS.md](guides/FOR_PYTHON_DEVELOPERS.md)** | Python teams | Pythonic patterns, async/await, pytest |
| **[guides/FOR_REACT_DEVELOPERS.md](guides/FOR_REACT_DEVELOPERS.md)** | React teams | Components, hooks, performance, state |
| **[guides/FOR_AWS_DEVELOPERS.md](guides/FOR_AWS_DEVELOPERS.md)** | AWS/Lambda teams | Serverless patterns, CDK, optimization |
| **[guides/FOR_TERRAFORM_DEVELOPERS.md](guides/FOR_TERRAFORM_DEVELOPERS.md)** | Infrastructure teams | Terraform best practices, state management, security |

---

## 🎯 Core Features

### ✅ Automatic Stack Detection

Scans your codebase and detects:
- Java, Spring Boot
- Python, Django, FastAPI
- React, Next.js
- AWS Lambda, CDK
- Terraform, CloudFormation
- TypeScript
- Custom frameworks

```bash
./scripts/enhanced-copilot-review-v3.sh main feature/test ./src
# ✅ Detected: Java, Spring Boot, AWS Lambda, Terraform
# ✅ Downloading: 10 instruction files
# ✅ Loading: 6 specialized agents
# ✅ Running review...
```

### ✅ awesome-copilot Integration

Automatically downloads and applies:

```
Instructions (10 files):
✓ java.instructions.md
✓ springboot.instructions.md
✓ python.instructions.md
✓ reactjs.instructions.md
✓ typescript.instructions.md
✓ aws.instructions.md
✓ terraform.instructions.md
✓ security-best-practices.md
✓ performance-optimization.md
✓ testing-best-practices.md

Agents (6 specialized):
✓ Code Reviewer - Comprehensive analysis
✓ Security Expert - Vulnerability detection
✓ Performance Optimizer - Speed & scalability
✓ Test Engineer - Coverage & quality
✓ Documentation Writer - Docs validation
✓ Refactoring Expert - Design improvements
```

### ✅ 6 Specialized AI Agents

All agents run simultaneously on your code and infrastructure code:

```
┌─────────────────────────────────────┐
│   Code Reviewer Agent               │
├─────────────────────────────────────┤
│ • Comprehensive analysis             │
│ • Pattern detection                 │
│ • Multi-domain review               │
│ • Terraform configuration review    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Security Expert Agent             │
├─────────────────────────────────────┤
│ • OWASP Top 10 detection            │
│ • SQL injection prevention          │
│ • Terraform security review         │
│ • IAM policy analysis               │
│ • Encryption validation             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Performance Optimizer Agent       │
├─────────────────────────────────────┤
│ • N+1 query detection               │
│ • Bottleneck identification         │
│ • Resource right-sizing             │
│ • Cost optimization                 │
└─────────────────────────────────────┘

Plus 3 more...
```

### ✅ Terraform-Specific Review Capabilities

Comprehensive analysis of infrastructure code:

```
✓ State Management
  - Remote state configuration
  - State locking setup
  - Encryption validation
  - Backup strategy

✓ Security Review
  - IAM policy analysis
  - Security group rules
  - Database accessibility
  - Encryption settings

✓ Code Quality
  - Variable validation
  - Module structure
  - Naming conventions
  - Documentation

✓ Cost Optimization
  - Instance right-sizing
  - Reserved capacity usage
  - Auto-scaling config
  - Unused resources

✓ Best Practices
  - Provider versioning
  - Dependency management
  - Tag standardization
  - Testing coverage
```

### ✅ Comprehensive Reporting

Generates multiple report formats:

**JSON Report** (for CI/CD automation):
```json
{
  "summary": "15 issues found: 2 critical, 5 high, 8 medium",
  "score": 6.8,
  "recommendation": "REQUEST_CHANGES",
  "issues": [
    {
      "type": "security",
      "severity": "critical",
      "title": "Terraform State File Unencrypted",
      "location": "terraform/main.tf:12",
      "fix": "Enable S3 encryption in backend configuration"
    }
  ]
}
```

**Markdown Report** (for human review):
```markdown
# Code Review Summary

**Detected Stack:** Java, Spring Boot, AWS Lambda, Terraform
**Review Date:** 2026-02-22
**Overall Score:** 6.8/10
**Recommendation:** REQUEST_CHANGES

## Critical Issues (2)
- SQL Injection in auth.py:45
- Terraform State File Not Encrypted

## High Priority (5)
- N+1 query pattern detected
- Terraform state locking not configured
...
```

### ✅ Git-Agnostic

Works with any git platform:

```
✓ GitHub (native support)
✓ GitLab (via REST API)
✓ Bitbucket (via REST API)
✓ Gitea (via REST API)
✓ Local git repositories
✓ Self-hosted installations
```

---

## 📦 What's Included

```
agentic-ai-code-reviewer/
│
├── 🚀 scripts/enhanced-copilot-review-v3.sh      ← Main executable
│   ├─ Stack detection engine (with Terraform)
│   ├─ awesome-copilot downloader
│   ├─ Configuration generator
│   ├─ GitHub CLI integration
│   └─ Report generator
│
├── 📚 Documentation/
│   ├── QUICK_START.md                 ← Start here (30 sec)
│   ├── docs/ARCHITECTURE.md           ← System design
│   ├── docs/TROUBLESHOOTING.md        ← Common issues
│   ├── docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md
│   ├── docs/INTEGRATION.md            ← CI/CD setup
│   └── docs/EXAMPLES.md               ← Real examples
│
├── 👥 Team Guides/
│   ├── guides/FOR_JAVA_DEVELOPERS.md
│   ├── guides/FOR_PYTHON_DEVELOPERS.md
│   ├── guides/FOR_REACT_DEVELOPERS.md
│   ├── guides/FOR_AWS_DEVELOPERS.md
│   └── guides/FOR_TERRAFORM_DEVELOPERS.md  ← NEW!
│
├── 📄 .gitignore                       ← Exclude generated files
└── 📊 PROJECT_SUMMARY.md              ← Cleanup guide
```

---

## 💻 Usage Examples

### Example 1: Review Application Code

```bash
# Review changes from main to feature/auth, scanning ./src
./scripts/enhanced-copilot-review-v3.sh main feature/auth ./src
```

### Example 2: Review Infrastructure Code

```bash
# Review Terraform changes
./scripts/enhanced-copilot-review-v3.sh main feature/infrastructure ./terraform

# Review specific environment
./scripts/enhanced-copilot-review-v3.sh main develop ./terraform/environments/dev
```

### Example 3: Review Complete Stack

```bash
# Review entire repository (app + infrastructure)
./scripts/enhanced-copilot-review-v3.sh main feature/full-stack .
```

### Example 4: Check Results

```bash
# View human-readable summary
cat reports/enhanced-copilot-review.md

# View structured JSON for parsing
cat reports/copilot-review.json | jq '.issues[] | select(.severity=="critical")'

# Count issues by type
cat reports/copilot-review.json | jq '.issues | group_by(.type) | map({type: .[0].type, count: length})'
```

---

## 🔧 System Requirements

### Required

```
✓ Git (any recent version)
✓ GitHub CLI (gh) - v2.x or higher
✓ bash 4.x or higher
✓ Internet connection (for awesome-copilot download)
```

### Optional

```
✓ jq (for JSON parsing - makes reports prettier)
✓ terraform (for local Terraform validation)
✓ GitHub Copilot subscription (for enhanced reviews)
✓ GitHub account (for CLI authentication)
```

### Installation

```bash
# GitHub CLI installation
# macOS
brew install gh

# Ubuntu/Debian
curl -fsSLo /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.x.x/gh_2.x.x_linux_amd64.deb
sudo dpkg -i /tmp/gh.deb

# All platforms
brew install jq      # (optional, for pretty JSON output)
brew install terraform  # (optional, for local validation)

# Authenticate
gh auth login
```

👉 **[Full Installation Guide](docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md#installation)**

---

## 🎯 Configuration

### Automatic Configuration

The script automatically creates:

**`.github/copilot-instructions.md`** - Copilot reads this automatically
```markdown
# Copilot Configuration

## Role
You are an expert code reviewer specializing in multiple technologies.

## Stack
- Java & Spring Boot
- Python
- React & TypeScript
- AWS & Serverless
- Terraform & Infrastructure as Code
- Security & Performance

## Focus Areas
1. Security vulnerabilities (OWASP)
2. Infrastructure security (IAM, encryption)
3. Terraform best practices
4. Performance optimization
5. Code quality and patterns
6. Test coverage
7. Design improvements
```

---

## 📊 Performance

| Scenario | Time |
|----------|------|
| First run (download) | 40-60 seconds |
| Subsequent runs (cached) | 30-45 seconds |
| Small PR (<100 lines) | 30-45 seconds |
| Medium PR (100-500 lines) | 45-90 seconds |
| Large PR (500-1000 lines) | 90-120 seconds |
| Large Terraform configs | 60-120 seconds |

The script caches awesome-copilot instructions, so first run is slowest.

---

## 🔐 Security

### Data Privacy

```
✓ No credentials stored
✓ No API keys transmitted
✓ Code diffs stay local (only diff sent to Copilot)
✓ Generated files are local only
✓ Terraform state analysis is local
✓ Uses existing gh authentication
```

### What Gets Sent to Copilot

```
✓ Code diff (the changes between branches)
✓ Terraform configuration diffs
✓ awesome-copilot instructions (public, from GitHub)
✓ Agent definitions (local)

✗ Secrets/passwords
✗ Database credentials
✗ Private keys
✗ Environment variables
✗ AWS credentials
```

---

## 📈 Common Results

### Example Output

```
# Code Review Summary
**Detected Stack:** Java + Spring Boot + React + Python + AWS + Terraform
**Review Date:** February 22, 2026
**Overall Score:** 6.8/10
**Recommendation:** REQUEST_CHANGES

## Critical Issues (4)
1. **SQL Injection in UserRepository.java:45**
   - Raw user input in SQL query
   - Use parameterized queries
   - Impact: HIGH

2. **Terraform State File Not Encrypted**
   - S3 backend missing encryption configuration
   - Enable server-side encryption
   - Impact: CRITICAL

3. **Unencrypted Password Storage**
   - Passwords stored as plain text
   - Use bcrypt or Argon2
   - Impact: CRITICAL

4. **Overly Permissive IAM Policy**
   - Resource: "*" with Action: "*"
   - Use least privilege principle
   - Impact: HIGH

## High Priority (7)
- N+1 query pattern in fetchUserPermissions()
- React component re-rendering unnecessarily
- Terraform state locking not configured
- Missing error handling in Lambda function
- Insufficient test coverage (22%)
- Performance: Lambda cold start not optimized
- Terraform module documentation missing

## Medium Priority (12)
- Code style inconsistencies
- Missing documentation
- Potential null pointer exceptions
- Unused imports
- And more...
```

---

## 🚀 Next Steps

### For New Users

1. **[Quick Start (2 min)](QUICK_START.md)** - Get it running
2. **[ARCHITECTURE.md (10 min)](docs/ARCHITECTURE.md)** - Understand how it works
3. **Run your first review** - See it in action

### For Infrastructure Teams

1. **[Terraform Guide (10 min)](guides/FOR_TERRAFORM_DEVELOPERS.md)** - Terraform-specific review
2. **[docs/INTEGRATION.md (10 min)](docs/INTEGRATION.md)** - Add to CI/CD pipeline
3. **Review Terraform changes** - Start with infrastructure code

### For Integration

1. **[INTEGRATION.md (10 min)](docs/INTEGRATION.md)** - Add to CI/CD
2. **[Examples (10 min)](docs/EXAMPLES.md)** - Real usage scenarios
3. **Set up automation** - Runs on every PR/MR

### For Support

1. **[TROUBLESHOOTING.md (5 min)](docs/TROUBLESHOOTING.md)** - Common issues
2. **[FAQ](#faq)** - Frequently asked questions
3. **[GitHub Issues](#support)** - Report bugs

---

## ❓ FAQ

### Q: Do I need GitHub Copilot subscription?
**A:** Recommended but not required. GitHub CLI works with free accounts; Copilot features require subscription.

### Q: Will this work with GitLab/Bitbucket?
**A:** Yes! Uses standard git commands and GitHub CLI's REST API support.

### Q: Can I review Terraform and application code together?
**A:** Yes! Run the script on the entire repository. It detects both and reviews both.

### Q: How do I ensure Terraform security?
**A:** Check the [Terraform Developer Guide](guides/FOR_TERRAFORM_DEVELOPERS.md) and see security checklist.

### Q: What about private repositories?
**A:** Works the same way. Authentication is via `gh auth`.

### Q: How much does this cost?
**A:** Script is free. Uses existing GitHub/Copilot infrastructure.

👉 **[Full FAQ](docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md#faq)**

---

## 🤝 Contributing

Want to improve this? We welcome:

- Bug reports and fixes
- Documentation improvements
- Agent customizations
- Platform support
- Integration examples
- Terraform patterns

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for details.

---

## 📜 License

MIT License - See LICENSE file

---

## 🙏 Credits

Built with:
- [GitHub Copilot](https://github.com/features/copilot)
- [awesome-copilot](https://github.com/github/awesome-copilot)
- [GitHub CLI](https://cli.github.com/)
- [Terraform](https://www.terraform.io/)

---

## 📞 Support

### Documentation

- **Quick Start:** [QUICK_START.md](QUICK_START.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Full Guide:** [docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md](docs/AWESOME_COPILOT_GITHUB_CLI_GUIDE.md)
- **Terraform Guide:** [guides/FOR_TERRAFORM_DEVELOPERS.md](guides/FOR_TERRAFORM_DEVELOPERS.md)

### Getting Help

1. Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) first
2. Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
3. Run with debug: `bash -x scripts/enhanced-copilot-review-v3.sh ... 2>&1`

### Report Issues

- [GitHub Issues](https://github.com/yourusername/agentic-ai-code-reviewer/issues)
- Include: OS, error message, script output

---

## 📊 Project Status

- ✅ **Core Functionality:** Production Ready
- ✅ **Documentation:** Complete (13+ files)
- ✅ **Stack Support:** Java, Python, React, AWS, Terraform, TypeScript
- ✅ **Platform Support:** GitHub, GitLab, Bitbucket, Gitea, Local
- ✅ **CI/CD Integration:** Ready
- ✅ **Infrastructure Review:** Ready
- ✅ **Testing:** Verified with multiple stacks
- 🚀 **Version:** 1.0.1

---

## 🎉 Ready to Use!

```bash
# Get started now
chmod +x scripts/enhanced-copilot-review-v3.sh
./scripts/enhanced-copilot-review-v3.sh main develop ./src

# Or follow the quick start
cat QUICK_START.md

# For infrastructure teams
cat guides/FOR_TERRAFORM_DEVELOPERS.md
```

**Questions?** Check the [documentation](#-documentation) or [troubleshooting guide](docs/TROUBLESHOOTING.md).

---

**Last Updated:** February 22, 2026  
**Version:** 1.0.1  
**Status:** ✅ Production Ready  
**New in 1.0.1:** Terraform support
