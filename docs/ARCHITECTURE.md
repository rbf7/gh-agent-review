# 🏗️ System Architecture (Updated v1.0.1)

> **v3 Update (2026-02-22):** Runtime implementation now prefers `scripts/enhanced-copilot-review-v3.sh` for actual GitHub CLI Copilot execution and normalized JSON reporting.

Complete technical overview of the Agentic AI Code Reviewer system with Terraform support.

---

## System Overview

```
┌─────────────────────────────────────────────────────────┐
│           User: scripts/enhanced-copilot-review-v3.sh   │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
        ▼                           ▼
    ┌─────────┐              ┌──────────┐
    │Detect   │              │Download  │
    │Stack    │              │awesome-  │
    │(Git     │              │copilot   │
    │scan)    │              │(10 files)│ ← +Terraform
    └────┬────┘              └────┬─────┘
         │                        │
         │    ┌──────────────────┤
         │    │                  │
         ▼    ▼                  ▼
    ┌─────────────────────────────────────┐
    │     Create Enhanced Configuration   │
    │ • .github/copilot-instructions.md  │
    │ • AGENTS.md                         │
    │ • Combined with awesome-copilot     │
    │ • Includes Terraform guidance       │ ← NEW
    └────────────────┬────────────────────┘
                     │
                     ▼
    ┌─────────────────────────────────────┐
    │   GitHub CLI + Copilot Agents       │
    │ • Code Reviewer                     │
    │ • Security Expert                   │
    │ • Performance Optimizer             │
    │ • Test Engineer                     │
    │ • Documentation Writer              │
    │ • Refactoring Expert                │
    └────────────────┬────────────────────┘
                     │
                     ▼
    ┌─────────────────────────────────────┐
    │    Comprehensive Code Review        │
    │ • Security scan (OWASP)             │
    │ • Performance analysis              │
    │ • Code quality check                │
    │ • Test coverage                     │
    │ • Design patterns                   │
    │ • Infrastructure analysis ← NEW     │
    │ • Stack-specific guidance           │
    └────────────────┬────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
    ┌──────────┐           ┌──────────┐
    │JSON      │           │Markdown  │
    │Report    │           │Report    │
    │(Machines)│           │(Humans)  │
    └──────────┘           └──────────┘
```

---

## Updated Stack Detection (v1.0.1)

**Location:** Stack detection in `scripts/enhanced-copilot-review-v3.sh`

**Function:** `detect_stack()`

**How it works:**
```bash
# Scans codebase for file types and patterns
├─ Java: .java files, pom.xml, build.gradle
├─ Python: .py files, requirements.txt, setup.py
├─ React: .jsx, .tsx files, package.json with "react"
├─ AWS: boto3, CDK references, AWS SDK imports
├─ TypeScript: .ts, .tsx files, tsconfig.json
├─ Terraform: .tf files, *.tfvars, terraform.lock.hcl ← NEW
│            └─ Detects: main.tf, variables.tf, outputs.tf
└─ Detects framework: Spring Boot, Django, FastAPI, Next.js, etc.
```

**Output:** `TECH_STACK` environment variable with detected technologies

---

## Updated awesome-copilot Downloader (v1.0.1)

**Location:** Instruction sync in `scripts/enhanced-copilot-review-v3.sh`

**What Gets Downloaded:**

```
From: https://raw.githubusercontent.com/github/awesome-copilot/main/

Instructions/ (10 files based on stack detection):
├─ java.instructions.md              (if Java detected)
├─ springboot.instructions.md        (if Spring detected)
├─ python.instructions.md            (if Python detected)
├─ reactjs.instructions.md           (if React detected)
├─ typescript.instructions.md        (if TypeScript detected)
├─ aws.instructions.md               (if AWS detected)
├─ terraform.instructions.md         (if Terraform detected) ← NEW
├─ security-best-practices.md        (always)
├─ performance-optimization.md       (always)
└─ testing-best-practices.md         (always)

Agents/ (6 specialized agents - always):
├─ code-reviewer.agent.md
├─ security-expert.agent.md
├─ performance-optimizer.agent.md
├─ test-engineer.agent.md
├─ documentation-writer.agent.md
└─ refactoring-expert.agent.md
```

---

## New Terraform Analysis Components

### Terraform State Analysis
```
When Terraform files detected:

1. State Management Check
   ├─ Remote state configuration (S3, Terraform Cloud, etc.)
   ├─ State locking enabled (DynamoDB)
   ├─ Encryption at rest (KMS)
   ├─ Encryption in transit (SSL/TLS)
   └─ Backup retention policy

2. Security Analysis
   ├─ IAM policy analysis
   ├─ Security group rules (least privilege)
   ├─ Database accessibility (private/public)
   ├─ Encryption settings
   ├─ Secrets management (no hardcoding)
   └─ Network isolation

3. Code Quality Review
   ├─ Variable validation rules
   ├─ Module structure
   ├─ Naming conventions
   ├─ Documentation quality
   └─ Format compliance (terraform fmt)

4. Cost Optimization
   ├─ Instance right-sizing
   ├─ Reserved capacity usage
   ├─ Auto-scaling configuration
   ├─ Storage optimization
   └─ Unused resource detection

5. Best Practices
   ├─ Provider version pinning
   ├─ Terraform version specification
   ├─ Dependency management (explicit vs implicit)
   ├─ Tag standardization
   ├─ Environment separation
   └─ Testing coverage (terraform validate, tflint)
```

---

## Agent Architecture with Infrastructure Support

### All 6 Agents Active + Infrastructure Focus

```
Code Reviewer Agent
├─ Analyzes application code
├─ Analyzes infrastructure code ← NEW
└─ Multi-perspective review

Security Expert Agent
├─ Application security (OWASP)
├─ Infrastructure security ← NEW
│  ├─ IAM policies
│  ├─ Security groups
│  ├─ Encryption settings
│  └─ Secrets management
└─ Compliance verification

Performance Optimizer Agent
├─ Application optimization
├─ Infrastructure optimization ← NEW
│  ├─ Resource right-sizing
│  ├─ Auto-scaling configs
│  └─ Cost efficiency
└─ Scalability analysis

Test Engineer Agent
├─ Code testing
├─ Infrastructure testing ← NEW
│  ├─ terraform validate
│  ├─ policy as code testing
│  └─ DR validation
└─ Coverage metrics

Documentation Writer Agent
├─ Code documentation
├─ Infrastructure documentation ← NEW
│  ├─ Terraform module docs
│  ├─ Variable descriptions
│  └─ Output documentation
└─ Completeness check

Refactoring Expert Agent
├─ Code improvements
├─ Infrastructure improvements ← NEW
│  ├─ Module optimization
│  ├─ DRY principle (don't repeat yourself)
│  └─ Reusability enhancement
└─ Maintainability analysis
```

---

## Infrastructure Analysis Workflow

```
Git Repository
    │
    ├─ Application Code (Java, Python, React, etc.)
    │  └─ Reviewed by agents for: security, performance, quality, tests
    │
    └─ Infrastructure Code (Terraform files)
       │
       ├─ Detect Terraform
       │  └─ Scan for: *.tf, terraform.tfvars, .terraform.lock.hcl
       │
       ├─ Download terraform.instructions.md
       │  └─ Best practices, patterns, guidelines
       │
       ├─ Analyze by Agents:
       │  │
       │  ├─ Code Reviewer
       │  │  └─ Structure, naming, organization
       │  │
       │  ├─ Security Expert
       │  │  └─ IAM, encryption, compliance
       │  │
       │  ├─ Performance Optimizer
       │  │  └─ Right-sizing, cost optimization
       │  │
       │  ├─ Test Engineer
       │  │  └─ Validation, policy testing
       │  │
       │  ├─ Documentation Writer
       │  │  └─ Module docs, variable descriptions
       │  │
       │  └─ Refactoring Expert
       │     └─ DRY, reusability, patterns
       │
       └─ Generate Infrastructure-Specific Findings
          ├─ State management issues
          ├─ Security vulnerabilities
          ├─ Cost optimization opportunities
          ├─ Best practice violations
          └─ Documentation gaps
```

---

## Terraform Detection Logic

```bash
# In scripts/enhanced-copilot-review-v3.sh:

detect_terraform() {
    # Check for Terraform files
    find "$CODE_PATH" -name "*.tf" | head -n 1 | grep -q . && echo "true" || echo "false"
}

# Sets: TERRAFORM_DETECTED=true/false
# If true: downloads terraform.instructions.md
#          analyzes .tf files for security, cost, best practices
```

---

## Updated Report Generation

```
reports/
├─ enhanced-copilot-review.md
│  ├─ Application findings
│  ├─ Infrastructure findings (if Terraform detected)
│  ├─ Overall score
│  └─ Recommendations
│
├─ copilot-review.json
│  ├─ issues[] (all findings)
│  │  ├─ type: "security", "performance", "quality", "terraform"
│  │  ├─ severity: "critical", "high", "medium", "low"
│  │  └─ category: "infrastructure" (for Terraform issues)
│  └─ Infrastructure metrics:
│     ├─ state_management_score
│     ├─ security_score
│     ├─ cost_optimization_score
│     └─ best_practices_score
│
└─ copilot-review.txt
   └─ Raw Copilot output
```

---

## Configuration with Infrastructure Guidance

### Updated .github/copilot-instructions.md

```markdown
# Copilot Configuration

## Role
Expert code reviewer + infrastructure architect

## Technologies
- Application: Java, Spring Boot, Python, React, TypeScript
- Infrastructure: Terraform, AWS
- Security & Performance

## Review Areas

### Application Code
- Security (OWASP)
- Performance
- Code quality
- Testing

### Infrastructure Code (Terraform)
- State management
- Security (IAM, encryption)
- Cost optimization
- Best practices
- Module structure
```

---

## Performance Impact (v1.0.1)

| Scenario | Time | Note |
|----------|------|------|
| App code only | 30-45 sec | Existing |
| Terraform only | 30-60 sec | New - depends on config complexity |
| App + Terraform | 45-90 sec | Combined analysis |
| Small PR (<100 lines) | 30-45 sec | Same |
| Large Terraform config | 60-120 sec | New - scales with state complexity |

**Why Terraform slower:** Analyzing state management, IAM policies, and security implications requires deeper inspection.

---

## Error Handling for Terraform

```bash
# New error checks:

# 1. Invalid Terraform syntax
terraform validate || {
    Log: "Invalid Terraform syntax detected"
    Fallback: Use syntax-only analysis
}

# 2. Missing required files
[ ! -f main.tf ] && {
    Log: "No main.tf found"
    Review: Variables and outputs still analyzed
}

# 3. State file issues
[ -f terraform.tfstate ] && {
    Warning: "State file in repository (should be remote)"
    Recommendation: "Configure remote backend"
}
```

---

## Data Privacy for Infrastructure Analysis

```
✓ Code diffs: Local only
✓ Terraform configs: Local only (not stored)
✓ State content: Never analyzed
✓ Secrets: Skipped (marked as sensitive)
✓ AWS credentials: Never transmitted
✓ API keys: Never transmitted

✗ Only diff sent to Copilot
✗ Never full state file
✗ Never credentials
✗ Never secrets
```

---

## Integration Points

### Terraform Module Testing

```bash
# Pre-review testing
terraform validate
terraform fmt -check
tflint

# Then run review
./scripts/enhanced-copilot-review-v3.sh main feature/infra ./terraform
```

### Terraform Cloud Integration

```bash
# Copilot review + TFC validation
./scripts/enhanced-copilot-review-v3.sh main feature/config ./terraform

# Then: terraform apply with TFC checks
```

---

## Version Management

```hcl
# Reviewed by Security Expert Agent:

✓ terraform { required_version = ">= 1.0, < 2.0" }
✓ provider "aws" { version = "~> 5.0" }

❌ No version constraints
❌ Allows breaking changes
❌ Terraform major version upgrades silently
```

---

## Extension Points for Infrastructure

### Custom Terraform Analysis

```bash
# In scripts/enhanced-copilot-review-v3.sh, before reporting:

# Add custom Terraform metrics
terraform_metrics=$(tflint ./terraform)
merge_results "$terraform_metrics" reports/copilot-review.json

# Add custom policy checks
policy_check=$(conftest test ./terraform)
merge_results "$policy_check" reports/copilot-review.json
```

---

**Architecture Version:** 1.0.1  
**Last Updated:** February 2026  
**Components:** 6 agents, 10 instructions, Terraform support, Git CLI, GitHub Copilot
