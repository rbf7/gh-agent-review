# 📚 Real-World Examples

> **v3 Update (2026-02-22):** Replace command examples with `scripts/enhanced-copilot-review-v3.sh` when running in this repository.

Complete, ready-to-run examples of the Agentic AI Code Reviewer in action.

---

## Example 1: Java Spring Boot Application

### Scenario
Reviewing a pull request that adds a new REST endpoint to a Spring Boot microservice.

### Files Changed
```
src/main/java/com/company/api/UserController.java (modified)
src/main/java/com/company/api/dto/UserDTO.java (modified)
src/test/java/com/company/api/UserControllerTest.java (added)
pom.xml (modified - added dependency)
```

### Command
```bash
./scripts/enhanced-copilot-review-v3.sh main feature/user-api ./
```

### Output
```
✅ Detected: Java, Spring Boot, Maven
✅ Stack Detection: Spring Boot application (Maven project)
✅ Downloading: java.instructions.md, springboot.instructions.md + others
✅ Loading: 6 specialized agents
✅ Analyzing code changes...

📊 Review Results:
├─ CRITICAL (1)
│  └─ UserDTO has potential SQL injection in query builder
├─ HIGH (3)
│  ├─ UserController missing @Valid annotation on request body
│  ├─ No JWT token validation on endpoint
│  └─ UserControllerTest needs more coverage (45% vs 80% target)
├─ MEDIUM (5)
│  ├─ Naming: should be `getUserById` not `getUser`
│  ├─ Missing JavaDoc for public method
│  ├─ UserDTO could use Lombok @Data
│  ├─ Performance: N+1 query in user fetch
│  └─ Test: missing edge case tests
└─ LOW (2)
   ├─ Inconsistent spacing in pom.xml
   └─ Missing @Deprecated documentation

✨ Highlights:
• Code quality: 75/100
• Security: 68/100
• Test coverage: 45/100 (needs improvement)
• Performance: 82/100
```

### Report Markdown
```markdown
# Code Review: UserController Enhancement

## Critical Issues

### 1. SQL Injection Risk
**Location:** UserDTO.java, line 42
**Severity:** CRITICAL

User input not properly escaped in SQL query:
\`\`\`java
String query = "SELECT * FROM users WHERE name = '" + name + "'";
\`\`\`

**Fix:**
Use prepared statements:
\`\`\`java
PreparedStatement stmt = connection.prepareStatement("SELECT * FROM users WHERE name = ?");
stmt.setString(1, name);
\`\`\`

## High Severity Issues

### 2. Missing Input Validation
**Location:** UserController.java, line 15
**Severity:** HIGH

@PostMapping endpoint should validate input:
\`\`\`java
@PostMapping("/users")
public ResponseEntity<?> createUser(UserDTO dto) {
    // Should be: public ResponseEntity<?> createUser(@Valid UserDTO dto) {
\`\`\`

### 3. Insufficient Test Coverage
**Location:** UserControllerTest.java
**Severity:** HIGH

Current coverage: 45%
Target coverage: 80%

Missing tests:
- Invalid user creation
- Duplicate user handling
- Boundary cases
```

---

## Example 2: Python Django Application

### Scenario
Reviewing infrastructure and application changes for a Django REST API.

### Files Changed
```
myapp/views.py (modified)
myapp/serializers.py (modified)
myapp/tests/test_views.py (modified)
requirements.txt (modified)
```

### Command
```bash
./scripts/enhanced-copilot-review-v3.sh main feature/api-upgrade ./
```

### Output
```
✅ Detected: Python, Django, pip
✅ Downloading: python.instructions.md, django.instructions.md + others
✅ Loading: 6 specialized agents
✅ Analyzing...

📊 Results:
├─ CRITICAL (0)
├─ HIGH (2)
│  ├─ views.py: Missing authentication on endpoints
│  └─ requirements.txt: Security vulnerability in dependency
├─ MEDIUM (4)
│  ├─ Code style: 4 PEP8 violations
│  ├─ Performance: Inefficient database queries
│  ├─ Testing: Missing async test handling
│  └─ Documentation: Missing docstrings
└─ LOW (1)
   └─ Unused imports in serializers.py
```

---

## Example 3: React Frontend Application

### Scenario
Reviewing React component updates with TypeScript.

### Files Changed
```
src/components/UserProfile.tsx (modified)
src/hooks/useUserData.ts (modified)
src/components/__tests__/UserProfile.test.tsx (modified)
```

### Command
```bash
./scripts/enhanced-copilot-review-v3.sh main feature/profile-redesign ./src
```

### Output
```
✅ Detected: React, TypeScript, Jest
✅ Downloading: reactjs.instructions.md, typescript.instructions.md + others
✅ Loading: 6 specialized agents
✅ Analyzing...

📊 Results:
├─ CRITICAL (1)
│  └─ Memory leak: useEffect missing cleanup
├─ HIGH (3)
│  ├─ Missing error boundary
│  ├─ No loading state handling
│  └─ Accessibility: missing ARIA labels
├─ MEDIUM (5)
│  ├─ Performance: missing React.memo
│  ├─ Type safety: any type used
│  ├─ Testing: 60% coverage (target 80%)
│  ├─ Prop drilling: too many levels
│  └─ State management: could use Context API
└─ LOW (2)
   ├─ Naming convention inconsistent
   └─ Missing comment on complex logic
```

---

## Example 4: AWS Infrastructure with Terraform

### Scenario
Reviewing Terraform configuration for AWS Lambda + RDS setup.

### Files Changed
```
terraform/main.tf (modified)
terraform/variables.tf (modified)
terraform/outputs.tf (modified)
terraform/rds.tf (added)
```

### Command
```bash
./scripts/enhanced-copilot-review-v3.sh main feature/db-infrastructure ./terraform
```

### Output
```
✅ Detected: Terraform, AWS
✅ Downloading: terraform.instructions.md, aws.instructions.md + others
✅ Loading: 6 specialized agents + Infrastructure focus
✅ Analyzing infrastructure...

📊 Infrastructure Review:
├─ CRITICAL (3)
│  ├─ RDS database is publicly accessible
│  ├─ IAM policy too permissive (allows all actions)
│  └─ No encryption enabled on database
├─ HIGH (4)
│  ├─ State file stored in git (should be remote)
│  ├─ Lambda execution role has too many permissions
│  ├─ Secrets hardcoded in variables
│  └─ No backup retention policy configured
├─ MEDIUM (6)
│  ├─ Missing environment tags
│  ├─ No monitoring/alarms configured
│  ├─ Inconsistent naming conventions
│  ├─ Lambda timeout too short (3s)
│  ├─ Database instance too large for workload
│  └─ Missing auto-scaling configuration
└─ LOW (2)
   ├─ Documentation missing
   └─ Variable descriptions incomplete
```

### Detailed Findings
```
CRITICAL ISSUES:

1. Database Publicly Accessible
   Location: rds.tf, line 15
   
   Current:
   publicly_accessible = true
   
   Risk: Database exposed to internet, unencrypted connections
   
   Fix:
   publicly_accessible = false
   db_subnet_group_name = aws_db_subnet_group.private.name

2. Overly Permissive IAM Policy
   Location: main.tf, line 42
   
   Current:
   "Action": ["*"]
   "Resource": "*"
   
   Risk: Lambda can perform any action on any resource
   
   Fix (least privilege):
   "Action": [
     "dynamodb:GetItem",
     "dynamodb:Query",
     "logs:CreateLogGroup",
     "logs:CreateLogStream",
     "logs:PutLogEvents"
   ]

3. Database Not Encrypted
   Location: rds.tf, line 8
   
   Current:
   storage_encrypted = false
   
   Risk: Data at rest unencrypted
   
   Fix:
   storage_encrypted = true
   kms_key_id = aws_kms_key.rds.arn
```

---

## Example 5: Full Stack Review (App + Infrastructure)

### Scenario
Complete review of application + infrastructure in monorepo.

### Structure
```
project/
├── src/                          # Application code (Java)
├── terraform/                    # Infrastructure code
├── kubernetes/                   # K8s configs
└── tests/
```

### Command
```bash
./scripts/enhanced-copilot-review-v3.sh main feature/full-stack-upgrade ./
```

### Output
```
✅ Detected: Java, Python, Terraform, Kubernetes, React
✅ Downloading: 10 instruction sets + all agents
✅ Loading: 6 specialized agents (multi-stack mode)
✅ Analyzing complete stack...

📊 Complete Analysis:

APPLICATION REVIEW:
├─ Security Score: 72/100
├─ Performance Score: 81/100
├─ Code Quality: 78/100
└─ Test Coverage: 65/100

INFRASTRUCTURE REVIEW:
├─ Security Score: 58/100 (needs work)
├─ Cost Score: 72/100
├─ Best Practices: 75/100
└─ Disaster Recovery: 45/100 (critical)

OVERALL:
└─ Issues Found: 32
   ├─ Critical: 4
   ├─ High: 8
   ├─ Medium: 15
   └─ Low: 5

RECOMMENDATIONS:
1. Fix database security (public access)
2. Improve infrastructure DR strategy
3. Add missing tests
4. Optimize Lambda configuration
```

---

## Example 6: Continuous Integration Check

### Scenario
Running review in GitHub Actions on every PR.

### Workflow Output
```
✅ Checkout complete
✅ Dependencies installed
✅ AI Code Review running...

Detected Changes:
- 12 files modified
- 450 lines added
- 120 lines removed

Stack Detection:
- Java: 8 files
- Terraform: 3 files
- Python: 1 file

Review Analysis:
- 180 seconds to download instructions
- 90 seconds to analyze changes
- 30 seconds to generate reports

📊 Summary:
- CRITICAL: 2 issues
- HIGH: 5 issues
- MEDIUM: 8 issues
- LOW: 3 issues

✅ Review complete - Report saved to artifacts
💬 Commenting on PR...
✅ Comment posted
```

---

## Example 7: Local Pre-Commit Check

### Scenario
Developer runs quick review before committing changes.

### Terminal Output
```bash
$ npm run review

🔍 Running AI Code Review...

Detected: Java, React

Checking changes:
✓ src/main/java/com/company/User.java
✓ src/components/Profile.tsx
✓ src/tests/User.test.ts

⚠️ Found issues:
- HIGH: Missing @Valid annotation (1 issue)
- MEDIUM: Missing test case (2 issues)
- LOW: Formatting (1 issue)

⏱️ Time: 45 seconds

Proceed with commit? (Y/n)
```

---

## Example 8: Monitoring Report

### Scenario
Weekly review metrics dashboard.

### Metrics
```
Last 7 Days Summary:

Total PRs Reviewed: 42
Bugs Found: 156
├─ Critical: 8 (5%)
├─ High: 47 (30%)
├─ Medium: 78 (50%)
└─ Low: 23 (15%)

Team Metrics:
- Avg Issues per PR: 3.7
- Critical Issues: 0.19% of lines reviewed
- Security Issues: 12 found, 10 fixed
- Test Coverage: 68% (up from 62%)

Trends:
- Critical issues ↓ 25% (good)
- Test coverage ↑ 10% (excellent)
- Security issues ↓ 15% (improving)

Top Issue Categories:
1. Missing tests (28)
2. Code style (24)
3. Security (18)
4. Performance (15)
5. Documentation (12)
```

---

## Quick Reference: Common Patterns

### Review Just Java Code
```bash
./scripts/enhanced-copilot-review-v3.sh main develop ./src/main/java
```

### Review Just Tests
```bash
./scripts/enhanced-copilot-review-v3.sh main develop ./src/test
```

### Review Terraform
```bash
./scripts/enhanced-copilot-review-v3.sh main develop ./terraform
```

### Review Everything
```bash
./scripts/enhanced-copilot-review-v3.sh main develop ./
```

### Focus on Security
```bash
./scripts/enhanced-copilot-review-v3.sh main develop ./ | grep -i "security\|critical\|high"
```

### Get JSON for Parsing
```bash
cat reports/copilot-review.json | jq '.issues[] | select(.severity=="critical")'
```

---

**Examples v1.0.1 - February 2026**
