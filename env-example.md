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

# ============================================
# USAGE INSTRUCTIONS
# ============================================
# 
# 1. Copy this file to .env
#    cp .env.example .env
#
# 2. Fill in your credentials:
#    For GitHub:
#      export GITHUB_TOKEN="ghp_xxx"
#
#    For GitLab:
#      export GITLAB_TOKEN="glpat-xxx"
#      export GITLAB_URL="https://gitlab.com"
#
#    For Bitbucket:
#      export BITBUCKET_TOKEN="xxx"
#      export BITBUCKET_WORKSPACE="your-workspace"
#      export BITBUCKET_REPO="your-repo"
#
#    For Gitea:
#      export GITEA_TOKEN="xxx"
#      export GITEA_URL="https://gitea.company.com"
#
# 3. Load environment variables:
#    source .env
#
# 4. Run the review:
#    ./main-review.sh feature/auth main . --post-to-platform
#
# ============================================
# NEVER COMMIT THIS FILE!
# ============================================
# 
# The .gitignore already excludes .env files.
# Keep your tokens safe - never add them to git!
#
# ============================================
# GETTING TOKENS
# ============================================
#
# GITHUB:
#   1. Go to https://github.com/settings/tokens
#   2. Click "Generate new token (classic)"
#   3. Select scopes: repo, read:repo_hook
#   4. Copy and paste into GITHUB_TOKEN
#
# GITLAB:
#   1. Go to https://gitlab.com/-/profile/personal_access_tokens
#   2. Create new token with scopes: api, read_repository
#   3. Copy and paste into GITLAB_TOKEN
#   4. If self-hosted: Set GITLAB_URL to your instance URL
#
# BITBUCKET:
#   1. Go to https://bitbucket.org/account/settings/app-passwords/
#   2. Create new app password
#   3. Select permissions: repo, pullrequest
#   4. Copy and paste into BITBUCKET_TOKEN
#   5. Also set BITBUCKET_WORKSPACE and BITBUCKET_REPO
#
# GITEA:
#   1. Go to your Gitea instance /user/settings/applications
#   2. Create new access token
#   3. Select scopes: repo
#   4. Copy and paste into GITEA_TOKEN
#   5. Set GITEA_URL to your Gitea instance
#
# ============================================
