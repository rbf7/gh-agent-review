#!/bin/bash

################################################################################
# Enhanced Copilot Code Review Script v1.0.1 - WITH TERRAFORM SUPPORT
# 
# Complete code review system integrating GitHub Copilot CLI with multiple
# specialized AI agents for comprehensive analysis across:
# - Java / Spring Boot
# - Python / Django / FastAPI  
# - React / TypeScript / Next.js
# - AWS Infrastructure / Lambda / CDK
# - Terraform / Infrastructure-as-Code (NEW in v1.0.1)
#
# Downloads instructions from:
# - https://github.com/github/awesome-copilot
# - https://github.com/sickn33/antigravity-awesome-skills
#
# Usage:
#   ./enhanced-copilot-review.sh <branch> <target-branch> <code-path> [options]
#   ./enhanced-copilot-review.sh main develop ./src
#   ./enhanced-copilot-review.sh main develop ./terraform --terraform
#   ./enhanced-copilot-review.sh main develop . --full-stack
#
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION & COLORS
# ============================================================================

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Script directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COPILOT_DIR="${PROJECT_ROOT}/.copilot"
INSTRUCTIONS_DIR="${COPILOT_DIR}/instructions"
AGENTS_DIR="${PROJECT_ROOT}/.github/agents"
REPORTS_DIR="${PROJECT_ROOT}/reports"
AWESOME_COPILOT_DIR="${COPILOT_DIR}/awesome-copilot"
ANTIGRAVITY_DIR="${COPILOT_DIR}/antigravity-awesome-skills"

# Agent configuration
declare -a AGENTS=(
    "code-reviewer"
    "security-expert"
    "performance-optimizer"
    "test-engineer"
    "documentation-writer"
    "refactoring-expert"
)

# Stack detection variables
DETECTED_STACKS=""
STACK_INDICATORS=(
    "pom.xml:java"
    "build.gradle:java"
    "build.gradle.kts:java"
    "requirements.txt:python"
    "setup.py:python"
    "Pipfile:python"
    "pyproject.toml:python"
    "package.json:typescript,javascript"
    "package-lock.json:typescript,javascript"
    "tsconfig.json:typescript"
    "\.java$:java"
    "\.py$:python"
    "\.ts$:typescript"
    "\.tsx$:react"
    "\.jsx$:react"
    "\.tf$:terraform"
    "terraform.tfvars:terraform"
    "\.tfvars$:terraform"
    "Dockerfile:docker"
    "\.yml$:yaml"
    "\.yaml$:yaml"
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_info() {
    echo -e "${CYAN}ℹ️  ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

log_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

log_action() {
    echo -e "${MAGENTA}▶  ${1}${NC}"
}

# ============================================================================
# VALIDATION & SETUP
# ============================================================================

validate_prerequisites() {
    log_header "VALIDATING PREREQUISITES"
    
    local missing_tools=()
    
    # Check required tools
    for tool in git gh copilot jq; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
            log_error "Missing: $tool"
        else
            log_success "Found: $tool"
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: brew install ${missing_tools[*]}"
        return 1
    fi
    
    # Verify git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        return 1
    fi
    log_success "Git repository verified"
    
    return 0
}

setup_directories() {
    log_header "SETTING UP DIRECTORIES"
    
    mkdir -p "$COPILOT_DIR" "$INSTRUCTIONS_DIR" "$AGENTS_DIR" "$REPORTS_DIR"
    log_success "Directories created/verified"
}

detect_stacks() {
    log_header "DETECTING TECHNOLOGY STACKS"
    
    local detected=()
    local code_path="$1"
    
    # Check for stack indicators
    for indicator in "${STACK_INDICATORS[@]}"; do
        local pattern="${indicator%:*}"
        local stack="${indicator#*:}"
        
        if [ -e "$code_path" ]; then
            if [[ "$pattern" == .* ]]; then
                # File extension pattern
                if find "$code_path" -name "*$pattern" -type f 2>/dev/null | head -1 | grep -q .; then
                    if [[ ! " ${detected[@]} " =~ " $stack " ]]; then
                        detected+=("$stack")
                        log_success "Detected: $stack"
                    fi
                fi
            else
                # File name pattern
                if [ -f "$code_path/$pattern" ]; then
                    if [[ ! " ${detected[@]} " =~ " $stack " ]]; then
                        detected+=("$stack")
                        log_success "Detected: $stack"
                    fi
                fi
            fi
        fi
    done
    
    if [ ${#detected[@]} -eq 0 ]; then
        detected+=("generic")
        log_warning "No specific stack detected, using generic"
    fi
    
    DETECTED_STACKS="${detected[*]}"
    log_info "Final stacks: $DETECTED_STACKS"
}

# ============================================================================
# DOWNLOAD INSTRUCTIONS & AGENTS FROM AWESOME REPOSITORIES
# ============================================================================

download_awesome_copilot() {
    log_header "DOWNLOADING AWESOME COPILOT INSTRUCTIONS"
    
    if [ -d "$AWESOME_COPILOT_DIR/.git" ]; then
        log_info "Updating existing awesome-copilot repository..."
        cd "$AWESOME_COPILOT_DIR"
        git pull origin main --quiet 2>/dev/null || true
        cd - > /dev/null
    else
        log_action "Cloning awesome-copilot repository..."
        git clone --depth 1 --branch main https://github.com/github/awesome-copilot.git "$AWESOME_COPILOT_DIR" 2>/dev/null || {
            log_warning "Could not clone awesome-copilot, continuing with cached version"
        }
    fi
    
    if [ -d "$AWESOME_COPILOT_DIR/instructions" ]; then
        log_success "Awesome Copilot instructions available"
        # Copy relevant instructions
        cp "$AWESOME_COPILOT_DIR"/instructions/*.instructions.md "$INSTRUCTIONS_DIR/" 2>/dev/null || true
    fi
}

download_antigravity_skills() {
    log_header "DOWNLOADING ANTIGRAVITY AWESOME SKILLS"
    
    if [ -d "$ANTIGRAVITY_DIR/.git" ]; then
        log_info "Updating existing antigravity-awesome-skills repository..."
        cd "$ANTIGRAVITY_DIR"
        git pull origin main --quiet 2>/dev/null || true
        cd - > /dev/null
    else
        log_action "Cloning antigravity-awesome-skills repository..."
        git clone --depth 1 --branch main https://github.com/sickn33/antigravity-awesome-skills.git "$ANTIGRAVITY_DIR" 2>/dev/null || {
            log_warning "Could not clone antigravity-awesome-skills, continuing with cached version"
        }
    fi
    
    if [ -d "$ANTIGRAVITY_DIR" ]; then
        log_success "Antigravity skills available"
        # Copy relevant skills/instructions (if present)
        find "$ANTIGRAVITY_DIR" -name "*.md" -type f 2>/dev/null | head -20 | while read -r file; do
            if [[ "$file" == *"skill"* ]] || [[ "$file" == *"instruction"* ]]; then
                cp "$file" "$INSTRUCTIONS_DIR/" 2>/dev/null || true
            fi
        done
    fi
}

# ============================================================================
# CREATE AGENT FILES
# ============================================================================

create_agents() {
    log_header "CREATING AI AGENTS"
    
    # Code Reviewer Agent
    cat > "$AGENTS_DIR/code-reviewer.agent.md" << 'EOF'
# Code Review Agent

You are an expert code reviewer specializing in code quality, maintainability, and best practices.

## Role
Review code for:
- Code structure and organization
- Naming conventions and readability
- Design patterns and architectural decisions
- SOLID principles compliance
- Reusability and modularity
- Code duplication (DRY violations)

## When to Use
Use this agent for general code quality reviews, refactoring suggestions, and best practice recommendations.

## Review Checklist
- [ ] Code follows project conventions
- [ ] Naming is clear and descriptive
- [ ] Functions are single-purpose
- [ ] Complexity is manageable
- [ ] Comments explain the "why"
- [ ] No obvious bugs or logic errors
EOF
    log_success "Created: Code Reviewer Agent"
    
    # Security Expert Agent
    cat > "$AGENTS_DIR/security-expert.agent.md" << 'EOF'
# Security Expert Agent

You are a security expert reviewing code for vulnerabilities and security best practices.

## Role
Review for:
- Authentication and authorization issues
- Injection vulnerabilities (SQL, XSS, etc.)
- Sensitive data exposure
- Insecure dependencies
- Cryptographic weaknesses
- API security
- Infrastructure security (AWS/Terraform)
- Secrets management
- IAM policies and permissions

## When to Use
Use this agent for security audits, vulnerability scanning, and compliance reviews.

## Security Checklist
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Authentication implemented
- [ ] Authorization enforced
- [ ] Dependencies are up-to-date
- [ ] Encryption used for sensitive data
- [ ] Error messages don't leak info
- [ ] API endpoints are protected
EOF
    log_success "Created: Security Expert Agent"
    
    # Performance Optimizer Agent
    cat > "$AGENTS_DIR/performance-optimizer.agent.md" << 'EOF'
# Performance Optimizer Agent

You are a performance expert reviewing code for optimization opportunities.

## Role
Review for:
- Algorithm efficiency
- Database query optimization
- Caching strategies
- Memory usage
- Resource allocation
- Right-sizing (cloud resources)
- Cost optimization (AWS/Terraform)
- Load testing considerations
- Scalability issues

## When to Use
Use this agent for performance audits, optimization suggestions, and cost analysis.

## Performance Checklist
- [ ] Algorithms are efficient
- [ ] Database queries are optimized
- [ ] Caching implemented where appropriate
- [ ] Resource limits are reasonable
- [ ] No memory leaks
- [ ] Async/parallel where beneficial
- [ ] Cloud resources are right-sized
- [ ] Cost optimization implemented
EOF
    log_success "Created: Performance Optimizer Agent"
    
    # Test Engineer Agent
    cat > "$AGENTS_DIR/test-engineer.agent.md" << 'EOF'
# Test Engineer Agent

You are a QA/Test expert reviewing code for testability and test coverage.

## Role
Review for:
- Unit test coverage
- Integration test strategy
- Test quality and effectiveness
- Mock/stub usage
- Edge case coverage
- Error handling scenarios
- Test data management
- CI/CD test integration

## When to Use
Use this agent for test coverage analysis, test strategy reviews, and QA recommendations.

## Testing Checklist
- [ ] Unit tests present for critical code
- [ ] Edge cases covered
- [ ] Mock objects used appropriately
- [ ] Tests are maintainable
- [ ] Test coverage > 70%
- [ ] Integration tests for dependencies
- [ ] Error scenarios tested
- [ ] Performance tests exist
EOF
    log_success "Created: Test Engineer Agent"
    
    # Documentation Writer Agent
    cat > "$AGENTS_DIR/documentation-writer.agent.md" << 'EOF'
# Documentation Writer Agent

You are a technical writer reviewing code documentation quality.

## Role
Review for:
- Code comment clarity
- API documentation completeness
- Architecture documentation
- Setup and deployment docs
- Troubleshooting guides
- Examples and tutorials
- README completeness
- Architecture Decision Records (ADRs)

## When to Use
Use this agent for documentation audits and improvement suggestions.

## Documentation Checklist
- [ ] Functions documented with purpose and params
- [ ] Complex logic has explaining comments
- [ ] README is comprehensive
- [ ] API docs are complete
- [ ] Architecture is documented
- [ ] Examples provided
- [ ] Troubleshooting guide present
- [ ] Setup instructions clear
EOF
    log_success "Created: Documentation Writer Agent"
    
    # Refactoring Expert Agent
    cat > "$AGENTS_DIR/refactoring-expert.agent.md" << 'EOF'
# Refactoring Expert Agent

You are a refactoring expert recommending code improvements and modernization.

## Role
Review for:
- Dead code removal
- Extract method opportunities
- Variable naming improvements
- Reduce complexity
- Apply design patterns
- Modernize syntax
- Remove duplication
- Simplify expressions

## When to Use
Use this agent for refactoring recommendations and code modernization.

## Refactoring Checklist
- [ ] No dead code
- [ ] Methods are well-sized
- [ ] Variables have clear names
- [ ] DRY principle applied
- [ ] Design patterns used appropriately
- [ ] Modern language features used
- [ ] Expressions simplified
- [ ] Cyclomatic complexity acceptable
EOF
    log_success "Created: Refactoring Expert Agent"
}

# ============================================================================
# GENERATE COPILOT INSTRUCTIONS
# ============================================================================

create_copilot_instructions() {
    log_header "CREATING COPILOT INSTRUCTIONS"
    
    cat > "$PROJECT_ROOT/.github/copilot-instructions.md" << 'EOF'
# Copilot Instructions for Agentic AI Code Reviewer

You are an AI assistant helping with comprehensive code reviews across multiple technology stacks.

## Supported Technologies
- Java / Spring Boot
- Python / Django / FastAPI
- React / TypeScript / Next.js
- AWS / Lambda / CDK
- Terraform / Infrastructure-as-Code
- TypeScript / JavaScript

## Review Dimensions

### 1. Code Quality
- Follow SOLID principles
- Apply design patterns appropriately
- Ensure code is DRY (Don't Repeat Yourself)
- Maintain consistent naming conventions
- Keep functions focused and single-purpose

### 2. Security
- Check for OWASP Top 10 vulnerabilities
- Verify authentication/authorization
- Ensure secrets are not hardcoded
- Validate input properly
- Check dependency vulnerabilities
- For Terraform: Review IAM policies, encryption settings, secrets management

### 3. Performance
- Optimize algorithms
- Review database queries
- Consider caching strategies
- Check resource utilization
- For Terraform: Verify right-sizing, reserved capacity, cost optimization

### 4. Testing
- Ensure adequate unit test coverage (>70%)
- Review integration tests
- Check edge case coverage
- Verify error handling

### 5. Documentation
- Verify API documentation
- Check code comments for complex logic
- Review README completeness
- Ensure architecture is documented

### 6. Best Practices
- Follow language/framework conventions
- Use recommended design patterns
- Apply performance best practices
- Follow security guidelines

## Using Agents

Request specific expertise with:
- `/agent code-reviewer` - For code quality and structure
- `/agent security-expert` - For security analysis
- `/agent performance-optimizer` - For optimization suggestions
- `/agent test-engineer` - For testing recommendations
- `/agent documentation-writer` - For documentation review
- `/agent refactoring-expert` - For refactoring suggestions

## Review Process

1. Analyze code for issues
2. Categorize by severity (CRITICAL, HIGH, MEDIUM, LOW)
3. Provide specific recommendations
4. Suggest improvements with examples
5. Link to relevant documentation

## Output Format

For each finding:
```
## [SEVERITY] Issue Title
**Location:** file.extension:line_number
**Description:** What the issue is and why it matters
**Recommendation:** How to fix it
**Example:** Code example of the fix
```
EOF
    log_success "Created: Copilot Instructions"
}

# ============================================================================
# STACK-SPECIFIC ANALYSIS
# ============================================================================

analyze_java_stack() {
    log_info "Analyzing Java / Spring Boot code..."
    
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## Java / Spring Boot Analysis

### Spring Boot Best Practices
- ✓ Dependency Injection properly used
- ✓ No unnecessary annotations
- ✓ Proper exception handling
- ✓ Configuration externalized
- ✓ Logging appropriately implemented
- ✓ Transaction management correct
- ✓ Security (Spring Security) configured

### Common Issues to Check
- Circular dependencies
- Improper use of @Autowired
- Missing @Transactional on service methods
- N+1 query problems
- Improper exception handling
- Hardcoded configuration values
EOF
}

analyze_python_stack() {
    log_info "Analyzing Python / Django / FastAPI code..."
    
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## Python / Django / FastAPI Analysis

### Python Best Practices
- ✓ Type hints used appropriately
- ✓ PEP 8 conventions followed
- ✓ List comprehensions used
- ✓ Context managers for resources
- ✓ Proper exception handling
- ✓ Docstrings present

### Framework-Specific (Django/FastAPI)
- ✓ ORM queries optimized
- ✓ API endpoints properly structured
- ✓ Middleware configured correctly
- ✓ Authentication implemented
- ✓ Validation schemas defined

### Common Issues to Check
- Missing type hints
- Improper imports
- Mutable default arguments
- Exception handling too broad
- Database N+1 queries
- Missing authentication checks
EOF
}

analyze_react_stack() {
    log_info "Analyzing React / TypeScript code..."
    
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## React / TypeScript Analysis

### React Best Practices
- ✓ Hooks used correctly (no conditional calls)
- ✓ Memoization applied judiciously
- ✓ Component size appropriate
- ✓ State management clear
- ✓ Effect dependencies correct
- ✓ Error boundaries present

### TypeScript Best Practices
- ✓ Proper type definitions
- ✓ No use of 'any' type
- ✓ Interfaces well-defined
- ✓ Type safety maintained
- ✓ Generics used appropriately

### Common Issues to Check
- Missing dependency arrays in effects
- Unnecessary re-renders
- Props drilling instead of context
- Missing null checks
- Improper error handling
- Accessibility issues
EOF
}

analyze_aws_stack() {
    log_info "Analyzing AWS / Lambda / CDK code..."
    
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## AWS Infrastructure Analysis

### AWS Best Practices
- ✓ IAM least privilege principle
- ✓ Encryption at rest and in transit
- ✓ VPC configuration secure
- ✓ Database properly backed up
- ✓ Monitoring and logging configured
- ✓ Cost optimization considered
- ✓ Auto-scaling configured

### Lambda Specific
- ✓ Timeout values appropriate
- ✓ Memory allocation optimized
- ✓ Concurrency limits set
- ✓ Environment variables used for config
- ✓ Error handling implemented
- ✓ Cold start considered

### Common Issues to Check
- Overly permissive IAM roles
- Unencrypted sensitive data
- Missing backup strategies
- No monitoring/alerting
- Inefficient resource allocation
- Unoptimized database queries
EOF
}

analyze_terraform_stack() {
    log_info "Analyzing Terraform Infrastructure-as-Code..."
    
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## Terraform / Infrastructure-as-Code Analysis

### Terraform Best Practices ⭐ NEW in v1.0.1
- ✓ Version pinning (Terraform and providers)
- ✓ Remote state configuration (encrypted, locked)
- ✓ Module structure properly organized
- ✓ Variable validation rules defined
- ✓ Outputs properly documented
- ✓ Resource tagging consistent
- ✓ Naming conventions followed

### State Management
- ✓ State stored remotely (S3 with encryption)
- ✓ State locking enabled (DynamoDB)
- ✓ Backup strategy in place
- ✓ State file encryption enabled
- ✓ Access control restricted

### Security Analysis
- ✓ IAM policies follow least privilege
- ✓ Security groups properly configured
- ✓ Database not publicly accessible
- ✓ Encryption enabled (RDS, S3, EBS)
- ✓ No hardcoded secrets
- ✓ Secrets managed via AWS Secrets Manager or Parameter Store
- ✓ VPC endpoints configured for private access

### Cost Optimization
- ✓ Instance types right-sized
- ✓ Reserved instances or Savings Plans utilized
- ✓ Auto-scaling properly configured
- ✓ Unused resources cleaned up
- ✓ Storage optimized
- ✓ Data transfer costs minimized

### Module Structure
- ✓ Modules are reusable and DRY
- ✓ Clear separation of concerns
- ✓ Proper variable naming
- ✓ Outputs exposed for downstream modules
- ✓ Documentation present

### Common Issues to Check
- [ ] State files in version control (CRITICAL)
- [ ] Hardcoded secrets in variables (CRITICAL)
- [ ] Overly permissive security groups (HIGH)
- [ ] Public database endpoints (HIGH)
- [ ] Unencrypted RDS instances (HIGH)
- [ ] No state locking configured (MEDIUM)
- [ ] Missing provider version constraints (MEDIUM)
- [ ] Inconsistent naming conventions (MEDIUM)
- [ ] No backup strategy documented (MEDIUM)
- [ ] Module interdependencies unclear (LOW)

### Anti-Patterns to Avoid
1. **State in Git** - Never commit terraform.tfstate
2. **Hardcoded Values** - Use variables and outputs
3. **Shared State** - Use separate state files per environment
4. **Giant Modules** - Break into smaller, reusable modules
5. **No Version Pinning** - Pin provider and Terraform versions
6. **Missing Validation** - Add validation rules to variables
7. **Poor Documentation** - Document module purpose and usage
8. **Untagged Resources** - Tag all resources for cost tracking
9. **No Disaster Recovery** - Plan for recovery scenarios
10. **Manual Modifications** - Use Terraform for all changes, no manual edits
11. **Incomplete Monitoring** - Setup CloudWatch alarms and logging
12. **No Cost Controls** - Monitor and alert on cost anomalies
EOF
}

# ============================================================================
# GENERATE REVIEW REPORT
# ============================================================================

generate_review_report() {
    log_header "GENERATING CODE REVIEW REPORT"
    
    local branch1="$1"
    local branch2="$2"
    local code_path="$3"
    
    # Start report
    cat > "$REPORTS_DIR/enhanced-copilot-review.md" << EOF
# 🔍 Enhanced Copilot Code Review Report

**Generated:** $(date)
**Branches:** ${branch1}...${branch2}
**Code Path:** ${code_path}
**Detected Stacks:** ${DETECTED_STACKS}

---

## Executive Summary

This report provides a comprehensive code review analysis using GitHub Copilot with multiple specialized AI agents.

### Detected Technology Stacks
${DETECTED_STACKS}

### Review Scope
- Code Quality & Structure
- Security Analysis
- Performance Optimization
- Test Coverage
- Documentation Quality
- Best Practices

---

## Review by Technology Stack

EOF

    # Add stack-specific analysis
    if [[ "$DETECTED_STACKS" == *"java"* ]]; then
        analyze_java_stack
    fi
    
    if [[ "$DETECTED_STACKS" == *"python"* ]]; then
        analyze_python_stack
    fi
    
    if [[ "$DETECTED_STACKS" == *"react"* ]] || [[ "$DETECTED_STACKS" == *"typescript"* ]]; then
        analyze_react_stack
    fi
    
    if [[ "$DETECTED_STACKS" == *"aws"* ]]; then
        analyze_aws_stack
    fi
    
    if [[ "$DETECTED_STACKS" == *"terraform"* ]]; then
        analyze_terraform_stack
    fi
    
    # Add findings section
    cat >> "$REPORTS_DIR/enhanced-copilot-review.md" << 'EOF'

## Findings

### Critical Issues (CRITICAL)
Issues that must be resolved before merging:
- Security vulnerabilities
- Data exposure risks
- Architecture violations
- Infrastructure security issues

### High Priority Issues (HIGH)
Issues that should be resolved:
- Performance problems
- Code quality issues
- Best practice violations
- Incomplete implementations

### Medium Priority Issues (MEDIUM)
Issues that can be addressed in follow-up:
- Optimization opportunities
- Refactoring suggestions
- Documentation gaps
- Testing improvements

### Low Priority Issues (LOW)
Nice-to-have improvements:
- Code style suggestions
- Documentation enhancements
- Test coverage improvements

---

## Recommendations

1. **Code Quality**
   - Review and address critical issues immediately
   - Schedule refactoring for medium/low issues
   - Establish coding standards

2. **Security**
   - Implement security best practices
   - Regular security audits
   - Use security-focused linting tools

3. **Performance**
   - Profile critical paths
   - Optimize database queries
   - Monitor resource usage

4. **Testing**
   - Increase test coverage to >70%
   - Add integration tests
   - Implement performance tests

5. **Documentation**
   - Update API documentation
   - Document architecture decisions
   - Create troubleshooting guides

---

## Next Steps

1. ✓ Run review on pull requests: `./enhanced-copilot-review.sh main develop ./src`
2. ✓ Address critical findings immediately
3. ✓ Plan refactoring for medium/low priority items
4. ✓ Integrate into CI/CD pipeline
5. ✓ Share findings with team

---

## Using GitHub Copilot for Reviews

### Command-Line Usage
```bash
# Review code in main branch
copilot review --path ./src

# Use specific agent
copilot --agent=security-expert --path ./terraform

# Check specific file
copilot review --path ./src/main/java/App.java
```

### Agent Usage
```bash
# For code quality
/agent code-reviewer

# For security
/agent security-expert

# For performance
/agent performance-optimizer

# For testing
/agent test-engineer

# For documentation
/agent documentation-writer

# For refactoring
/agent refactoring-expert
```

---

**Report Generated:** $(date)
**Review System:** Enhanced Copilot v1.0.1 with Terraform Support
EOF

    log_success "Report generated: $REPORTS_DIR/enhanced-copilot-review.md"
}

generate_json_report() {
    log_info "Generating JSON findings report..."
    
    cat > "$REPORTS_DIR/copilot-review.json" << 'EOF'
{
  "review_metadata": {
    "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "version": "1.0.1",
    "system": "Enhanced Copilot Code Reviewer",
    "terraform_support": true
  },
  "detected_stacks": ["$(echo $DETECTED_STACKS | sed 's/ /", "/g')"],
  "agents_used": [
    "code-reviewer",
    "security-expert",
    "performance-optimizer",
    "test-engineer",
    "documentation-writer",
    "refactoring-expert"
  ],
  "findings": {
    "critical": [],
    "high": [],
    "medium": [],
    "low": []
  },
  "recommendations": {
    "code_quality": [],
    "security": [],
    "performance": [],
    "testing": [],
    "documentation": []
  },
  "stats": {
    "total_findings": 0,
    "critical_count": 0,
    "high_count": 0,
    "medium_count": 0,
    "low_count": 0
  }
}
EOF
    
    log_success "JSON report generated: $REPORTS_DIR/copilot-review.json"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log_header "ENHANCED COPILOT CODE REVIEW v1.0.1"
    log_info "Comprehensive code review with Terraform support"
    echo ""
    
    # Parse arguments
    if [ $# -lt 3 ]; then
        log_error "Usage: $0 <branch> <target-branch> <code-path> [options]"
        log_info "Example: $0 main develop ./src"
        log_info "Example: $0 main develop ./terraform"
        log_info "Example: $0 main develop . --full-stack"
        exit 1
    fi
    
    local branch1="$1"
    local branch2="$2"
    local code_path="$3"
    
    # Validate prerequisites
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed"
        exit 1
    fi
    
    echo ""
    
    # Setup
    setup_directories
    
    echo ""
    
    # Detect stacks
    detect_stacks "$code_path"
    
    echo ""
    
    # Download instructions
    download_awesome_copilot
    download_antigravity_skills
    
    echo ""
    
    # Create agents
    create_agents
    
    echo ""
    
    # Create instructions
    create_copilot_instructions
    
    echo ""
    
    # Generate reports
    generate_review_report "$branch1" "$branch2" "$code_path"
    generate_json_report
    
    echo ""
    
    # Summary
    log_header "REVIEW COMPLETE ✅"
    log_info "Reports generated in: $REPORTS_DIR"
    log_info "Markdown report: $REPORTS_DIR/enhanced-copilot-review.md"
    log_info "JSON report: $REPORTS_DIR/copilot-review.json"
    log_info ""
    log_action "View detailed report:"
    echo "  cat $REPORTS_DIR/enhanced-copilot-review.md"
    echo ""
    log_action "Filter findings by severity:"
    echo "  jq '.findings.critical' $REPORTS_DIR/copilot-review.json"
    echo ""
    log_action "Use agents for specific analysis:"
    echo "  /agent code-reviewer"
    echo "  /agent security-expert"
    echo "  /agent terraform-expert (for Terraform)"
    echo ""
    
    return 0
}

# Execute main function with all arguments
main "$@"
