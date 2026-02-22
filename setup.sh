#!/bin/bash
# Setup script for code review automation system

set -e

echo "🚀 Setting up Code Review Automation System"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check git
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Please install Git first."
    echo "   macOS: brew install git"
    echo "   Ubuntu: sudo apt-get install git"
    echo "   Windows: Download from git-scm.com"
    exit 1
fi
echo "✓ Git $(git --version | awk '{print $3}')"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.8+ first."
    echo "   macOS: brew install python3"
    echo "   Ubuntu: sudo apt-get install python3"
    echo "   Windows: Download from python.org"
    exit 1
fi
echo "✓ Python $(python3 --version | awk '{print $2}')"

# Check curl (for API posting)
if command -v curl &> /dev/null; then
    echo "✓ curl available (for platform posting)"
else
    echo "⚠  curl not found (optional, needed for platform posting)"
    echo "   macOS: brew install curl"
    echo "   Ubuntu: sudo apt-get install curl"
fi

# Check jq (for JSON processing)
if command -v jq &> /dev/null; then
    echo "✓ jq available (for JSON processing)"
else
    echo "⚠  jq not found (optional, recommended)"
    echo "   macOS: brew install jq"
    echo "   Ubuntu: sudo apt-get install jq"
fi

echo ""

# Make scripts executable
echo "🔐 Making scripts executable..."
chmod +x *.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true
echo "✓ Scripts are executable"

echo ""

# Create directories if needed
echo "📁 Creating directories..."
mkdir -p config 2>/dev/null || true
mkdir -p scripts 2>/dev/null || true
mkdir -p reports 2>/dev/null || true
echo "✓ Directories ready"

echo ""

# Create .env.example if not exists
if [ ! -f .env.example ]; then
    echo "📝 Creating .env.example..."
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

# General Configuration
# SKIP_REVIEW=false
# DRY_RUN=false
EOF
    echo "✓ .env.example created"
fi

echo ""

# Create .gitignore entries if needed
if [ -f .gitignore ]; then
    if ! grep -q "\.env" .gitignore; then
        echo ".env" >> .gitignore
        echo "✓ Added .env to .gitignore"
    fi
else
    echo ".env" > .gitignore
    echo "✓ Created .gitignore with .env"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Choose your platform:"
echo "   • Local only: LOCAL_ONLY_SETUP.md (no auth needed)"
echo "   • GitHub: GitHub_SETUP.md"
echo "   • GitLab: GITLAB_SETUP.md"
echo "   • Bitbucket: BITBUCKET_SETUP.md"
echo "   • Gitea: GITEA_SETUP.md"
echo ""
echo "2. Try it out:"
echo "   ./main-review.sh feature/branch develop ./src"
echo ""
echo "3. Read the docs:"
echo "   • README.md - Overview"
echo "   • QUICK_REFERENCE.md - Common commands"
echo "   • GIT_AGNOSTIC_ARCHITECTURE.md - Design deep-dive"
echo ""
echo "Happy reviewing! 🎉"
