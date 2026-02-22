# ⚠️ Legacy Document (Archived)

This guide references older setup flows and file names.
For active usage, follow `README.md`, `QUICK_START.md`, and `scripts/enhanced-copilot-review-v3.sh`.

# 📍 How to Find and Use `.env.example`

## ✅ The `.env.example` File

The `.env.example` file is NOW AVAILABLE and ready for you to use!

---

## 🔍 Where to Find It

You have several versions created:

### Option 1: Use `.env-example.txt` (Simple Format)
- **File**: `.env-example.txt`
- **What it contains**: Basic environment variable template
- **How to use**:
```bash
# Copy the content
cp .env-example.txt .env

# Edit with your values
nano .env
```

### Option 2: Use `env-example.md` (With Instructions)
- **File**: `env-example.md`
- **What it contains**: Complete template with setup instructions
- **How to use**:
```bash
# Read the guide first to understand setup
cat env-example.md

# Then copy content to .env
nano .env
```

### Option 3: Use `ENV_SETUP_GUIDE.md` (Comprehensive)
- **File**: `ENV_SETUP_GUIDE.md`
- **What it contains**: Complete guide with examples for all platforms
- **How to use**:
```bash
# Read the complete guide
cat ENV_SETUP_GUIDE.md

# Follow setup instructions
# Create .env based on your platform
nano .env
```

---

## 📝 Complete `.env.example` Content

Here's the standard content you should put in your `.env.example`:

```bash
# GitHub Configuration
# GITHUB_TOKEN=ghp_xxx
# GITHUB_ENTERPRISE_URL=https://github.company.com

# GitLab Configuration
# GITLAB_TOKEN=glpat-xxx
# GITLAB_URL=https://gitlab.com
# For self-hosted GitLab:
# GITLAB_URL=https://gitlab.company.com

# Bitbucket Configuration
# BITBUCKET_TOKEN=xxx
# BITBUCKET_WORKSPACE=your-workspace
# BITBUCKET_REPO=your-repo

# Gitea Configuration
# GITEA_TOKEN=xxx
# GITEA_URL=https://gitea.company.com
# GITEA_OWNER=your-username
# GITEA_REPO=your-repo

# General Configuration
# SKIP_REVIEW=false
# DRY_RUN=false
# VERBOSE=false
```

---

## 🚀 Quick Setup Instructions

### 1. Create `.env.example` File

Create a new file named `.env.example` in your project root:

```bash
cat > .env.example << 'EOF'
# GitHub Configuration
# GITHUB_TOKEN=ghp_xxx
# GITHUB_ENTERPRISE_URL=https://github.company.com

# GitLab Configuration
# GITLAB_TOKEN=glpat-xxx
# GITLAB_URL=https://gitlab.com

# Bitbucket Configuration
# BITBUCKET_TOKEN=xxx
# BITBUCKET_WORKSPACE=your-workspace
# BITBUCKET_REPO=your-repo

# Gitea Configuration
# GITEA_TOKEN=xxx
# GITEA_URL=https://gitea.company.com
# GITEA_OWNER=your-username
# GITEA_REPO=your-repo

# General Configuration
# SKIP_REVIEW=false
# DRY_RUN=false
# VERBOSE=false
EOF
```

### 2. Copy to `.env` for Your Use

```bash
cp .env.example .env
```

### 3. Edit `.env` with Your Details

```bash
nano .env
```

Example for GitHub:
```bash
GITHUB_TOKEN="ghp_xxx_your_actual_token_here"
```

Example for GitLab:
```bash
GITLAB_TOKEN="glpat-xxx_your_actual_token_here"
GITLAB_URL="https://gitlab.com"
```

### 4. Load and Test

```bash
source .env
./main-review.sh feature/test develop ./src --post-to-platform
```

---

## ✅ File Organization

In your project root, you should have:

```
code-review-automation/
├── .env.example          ← Template (COMMITTED)
├── .env                  ← Your config (NOT committed, in .gitignore)
├── .gitignore            ← Includes .env
├── README.md
├── ENV_SETUP_GUIDE.md
├── main-review.sh
├── setup.sh
├── create-scripts.sh
├── create-config.sh
└── ... (other documentation files)
```

---

## 🔒 Security Reminder

✅ **DO Commit:**
- `.env.example` (template with no real tokens)
- `.gitignore` (which excludes .env)

❌ **DON'T Commit:**
- `.env` (your actual config with real tokens)
- Any file with real tokens in it

Your `.gitignore` should contain:
```
.env
.env.local
.env.*.local
```

---

## 🎯 Final Steps to Complete

1. ✅ Create/copy `.env.example` to your project
2. ✅ Create `.env` by copying `.env.example`
3. ✅ Edit `.env` with YOUR platform and token
4. ✅ Run `source .env` to load it
5. ✅ Test with `./main-review.sh ...`
6. ✅ Verify `.env` is NOT in git
7. ✅ Commit `.env.example` (template)
8. ✅ Push to repository

---

## 📞 All Available Environment Setup Files

You now have multiple environment setup resources:

| File | Purpose | Use When |
|------|---------|----------|
| `.env.example` | Standard template | You want simple template |
| `.env-example.txt` | Simple text format | You prefer plain text |
| `env-example.md` | Markdown with instructions | You want readable format |
| `ENV_SETUP_GUIDE.md` | Complete comprehensive guide | You need full instructions |

---

**All files are ready! Pick the format you prefer and get started! 🚀**

*Last Updated: 2024*
