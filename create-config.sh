# Configuration files for code review automation

## config/rules.yaml - Analysis Rules

cat > config/rules.yaml << 'EOF'
# Code Review Analysis Rules
# Customize these rules for your project

security_checks:
  hardcoded_secrets:
    enabled: true
    patterns:
      - '(password|secret|key|token)\s*=\s*["\'].*["\']'
      - 'api_key\s*=\s*["\'].*["\']'
      - 'aws_secret\s*=\s*["\'].*["\']'
    severity: HIGH
    message: "Hardcoded secret detected"
  
  sql_injection:
    enabled: true
    patterns:
      - '\$\w+\s+.*SELECT'
      - '\$\w+\s+.*INSERT'
      - '\$\w+\s+.*UPDATE'
    severity: HIGH
    message: "Potential SQL injection vulnerability"
  
  command_injection:
    enabled: true
    patterns:
      - 'exec.*\+.*\w+'
      - 'eval.*\$'
      - 'os\.system\(.*\$'
    severity: HIGH
    message: "Potential command injection"

quality_checks:
  complexity:
    enabled: true
    max_lines: 100
    max_params: 5
    severity: MEDIUM
    message: "Function might be too complex"
  
  todo_fixme:
    enabled: true
    patterns:
      - 'TODO'
      - 'FIXME'
      - 'HACK'
    severity: LOW
    message: "TODO/FIXME/HACK comment found"
  
  commented_code:
    enabled: true
    min_consecutive_lines: 3
    severity: LOW
    message: "Commented-out code detected"

coverage_checks:
  no_tests:
    enabled: true
    severity: MEDIUM
    message: "No test files found"
  
  no_coverage_report:
    enabled: true
    severity: LOW
    message: "No coverage report found"

performance_checks:
  n_plus_one:
    enabled: true
    severity: MEDIUM
    message: "Potential N+1 query detected"
  
  nested_loops:
    enabled: true
    max_depth: 3
    severity: LOW
    message: "Deep nesting detected"
EOF

## config/projects.yaml - Project Configuration

cat > config/projects.yaml << 'EOF'
# Project-specific configuration

default:
  # Which checks to run
  enabled_checks:
    - security
    - quality
    - coverage
    - performance
  
  # Ignore paths
  ignore_paths:
    - ".git"
    - "node_modules"
    - ".venv"
    - "dist"
    - "build"
  
  # File patterns to analyze
  include_patterns:
    - "*.py"
    - "*.js"
    - "*.java"
    - "*.go"
    - "*.rb"
  
  # Platform-specific settings
  github:
    post_as_review_comment: true
    thread_conversations: true
    include_line_links: true
  
  gitlab:
    post_as_discussion: true
    thread_comments: true
    include_code_lines: true
  
  bitbucket:
    post_as_comment: true
    inline_comments: true
    include_code_links: true
  
  gitea:
    post_as_comment: true
    include_code_links: true

# Project-specific overrides
projects:
  my-api:
    enabled_checks:
      - security
      - quality
      - performance
    # stricter rules
    security:
      severity_threshold: HIGH
    performance:
      max_latency_ms: 100
  
  my-web:
    enabled_checks:
      - security
      - quality
      - coverage
    # frontend specific
    coverage:
      min_percentage: 80
EOF

## .env.example - Environment Variables Template

cat > .env.example << 'EOF'
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

# Example .env content (copy to .env and fill in your values)
# GITHUB_TOKEN=ghp_xxx
# 
# Then: source .env
# Then: ./main-review.sh feature/auth main . --post-to-platform
EOF

## .gitignore entries

cat >> .gitignore << 'EOF'
# Environment variables
.env
.env.local
.env.*.local

# Reports
report.json
report.md
*.report

# Temporary files
/tmp
/temp
*.tmp

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Python
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.coverage

# Node
node_modules/
npm-debug.log

# Logs
*.log
logs/

# Reports directory
reports/
EOF

echo "✓ Configuration files created"
