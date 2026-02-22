# 🏗️ Terraform Best Practices & Guidelines

> **v3 Update (2026-02-22):** Use `scripts/enhanced-copilot-review-v3.sh` for Terraform-focused reviews in this repository.

Complete Terraform-specific review patterns for the Agentic AI Code Reviewer.

---

## Terraform Review Focus Areas

### 1. State Management

**Critical Issues:**
- ❌ State file stored in git (SECRET LEAK)
- ❌ No remote state configured
- ❌ No state locking
- ❌ Unencrypted state files

**Solutions:**
```hcl
# ✅ CORRECT - Remote state with encryption
terraform {
  backend "s3" {
    bucket           = "company-terraform-state"
    key              = "prod/terraform.tfstate"
    region           = "us-east-1"
    encrypt          = true
    dynamodb_table   = "terraform-locks"
  }
}
```

### 2. Variable & Output Security

**Vulnerable Patterns:**
```hcl
# ❌ WRONG - Sensitive data exposed
variable "db_password" {
  default = "hardcoded-password"
  type    = string
}

# ❌ WRONG - Outputs sensitive data
output "database_password" {
  value = aws_db_instance.main.password
}
```

**Best Practices:**
```hcl
# ✅ CORRECT - Secure variable handling
variable "db_password" {
  type      = string
  sensitive = true
  # No default - must be provided
}

# ✅ CORRECT - Hidden sensitive output
output "database_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = false
}

# Sensitive outputs marked appropriately
output "database_password" {
  value     = aws_db_instance.main.password
  sensitive = true  # ← Hides from logs
}
```

### 3. Resource Naming & Organization

**Review Points:**
- Naming conventions consistency
- Resource grouping by environment
- Module structure clarity
- Tag standardization

```hcl
# ✅ CORRECT - Consistent naming
locals {
  project = "myapp"
  env     = var.environment
  common_tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

resource "aws_instance" "app_server" {
  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-${local.env}-app-server"
      Role = "application"
    }
  )
}
```

### 4. Module Usage

**Anti-Patterns:**
```hcl
# ❌ WRONG - Hardcoded values
module "network" {
  source = "./modules/network"
  
  cidr_block        = "10.0.0.0/16"
  availability_zone = "us-east-1a"
  instance_count    = 5
}
```

**Best Practices:**
```hcl
# ✅ CORRECT - Parameterized modules
module "network" {
  source = "./modules/network"
  
  # From variables
  cidr_block        = var.vpc_cidr
  availability_zone = var.primary_az
  instance_count    = var.instance_count
  
  # With sensible defaults
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}
```

### 5. Dependency Management

**Issues:**
```hcl
# ❌ WRONG - Implicit dependencies only
resource "aws_instance" "app" {
  subnet_id = aws_subnet.private.id
  # Depends on security group but not explicit
}

# ❌ WRONG - Circular dependencies possible
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id
}
```

**Best Practices:**
```hcl
# ✅ CORRECT - Explicit dependencies
resource "aws_instance" "app" {
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Explicit dependency when needed
  depends_on = [aws_nat_gateway.main]
}

# ✅ CORRECT - Avoid circular deps
resource "aws_security_group" "app" {
  name_prefix = "app-"
  vpc_id      = aws_vpc.main.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 6. Error Handling & Validation

**Missing Validation:**
```hcl
# ❌ WRONG - No validation
variable "instance_count" {
  type = number
}

variable "environment" {
  type = string
}
```

**With Validation:**
```hcl
# ✅ CORRECT - Input validation
variable "instance_count" {
  type = number
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
}

variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 7. Cost Optimization

**Review Points:**
- Resource right-sizing
- Reserved capacity usage
- Unused resource detection
- Auto-scaling configuration

```hcl
# ✅ GOOD - Cost-optimized instance selection
resource "aws_instance" "app" {
  # Use appropriate instance type
  instance_type = var.instance_type # "t3.small" not "c5.xlarge"
  
  # EBS optimization where needed
  ebs_optimized = var.enable_ebs_optimization
  
  # Spot instances for non-critical workloads
  spot_price = var.environment == "dev" ? var.spot_price : null
}

# ✅ GOOD - Auto-scaling
resource "aws_autoscaling_group" "app" {
  min_size         = 2
  max_size         = 10
  desired_capacity = 3
  
  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_launch_template = true
  }
}
```

### 8. Security Best Practices

**Critical Issues:**
```hcl
# ❌ WRONG - Overly permissive security groups
resource "aws_security_group" "app" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # OPEN TO WORLD
  }
}

# ❌ WRONG - No encryption
resource "aws_s3_bucket" "data" {
  # No encryption configured
}

# ❌ WRONG - Public access to sensitive resources
resource "aws_db_instance" "main" {
  publicly_accessible = true  # ← DANGER
}
```

**Security Patterns:**
```hcl
# ✅ CORRECT - Least privilege security groups
resource "aws_security_group" "app" {
  ingress {
    description = "HTTPS from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    description = "To Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ CORRECT - S3 encryption
resource "aws_s3_bucket" "data" {
  bucket              = "company-data-${var.environment}"
  force_destroy       = var.environment != "prod"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ CORRECT - Database security
resource "aws_db_instance" "main" {
  publicly_accessible            = false  # ← SECURE
  storage_encrypted              = true
  iam_database_authentication_enabled = true
  backup_retention_period        = 30
  multi_az                       = var.enable_multi_az
}
```

### 9. Code Quality & Standards

**Issues:**
```hcl
# ❌ WRONG - Poor formatting
resource "aws_instance" "server"{
instance_type="t3.micro"
tags={
Name="server"
}}

# ❌ WRONG - No documentation
resource "aws_security_group" "web" {
  # ...
}
```

**Standards:**
```hcl
# ✅ CORRECT - Proper formatting (terraform fmt)
resource "aws_instance" "server" {
  instance_type = "t3.micro"
  
  tags = {
    Name = "server"
  }
}

# ✅ CORRECT - Documentation
resource "aws_security_group" "web" {
  name_prefix = "web-"
  description = "Security group for web tier - allows HTTPS inbound, all outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from CloudFront"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
```

### 10. Version Management

**Issues:**
```hcl
# ❌ WRONG - No version constraints
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# ❌ WRONG - Allows breaking changes
provider "aws" {
  region = var.aws_region
  # No version specified
}
```

**Best Practices:**
```hcl
# ✅ CORRECT - Pinned versions
terraform {
  required_version = ">= 1.0, < 2.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Allows 5.x but not 6.0
    }
  }
  
  backend "s3" {
    # ...
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

### 11. Testing & Validation

**Review Points:**
- `terraform validate` passes
- `terraform plan` without errors
- Resource count reasonable
- Drift detection enabled

```bash
# ✅ Testing checklist
terraform validate                    # Syntax validation
terraform fmt -check                 # Format checking
tflint                              # Linting
terraform plan -out=tfplan          # Plan generation
terraform show tfplan               # Review plan
```

### 12. Documentation

**Missing Documentation:**
```hcl
# ❌ WRONG - No variable descriptions
variable "tags" {
  type = map(string)
}
```

**With Documentation:**
```hcl
# ✅ CORRECT - Complete documentation
variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources for billing and tracking"
  default = {
    CostCenter = "engineering"
    Team       = "platform"
  }
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable CloudWatch monitoring and alarms for all resources"
  default     = true
}
```

---

## Common Terraform Anti-Patterns

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| Hardcoded values | Not reusable | Use variables and locals |
| Mixed environments | Easy to break prod | Separate tfvars files |
| No state locking | Race conditions | Enable DynamoDB locks |
| Secrets in code | Security breach | Use secrets manager |
| Missing validation | Bad inputs accepted | Add variable validation |
| Circular dependencies | Complex graphs | Use explicit depends_on |
| No tagging strategy | Cost tracking fails | Implement tag standards |
| Overly permissive rules | Security risk | Use least privilege |
| No version pinning | Breaking upgrades | Pin provider versions |
| Missing remote state | State drift | Use S3/Terraform Cloud |

---

## Terraform Security Checklist

- [ ] State file encrypted in transit and at rest
- [ ] Remote state with locking enabled
- [ ] Sensitive variables marked as sensitive
- [ ] No credentials in code
- [ ] Security groups follow least privilege
- [ ] Database not publicly accessible
- [ ] S3 buckets not public
- [ ] IAM policies least privilege
- [ ] KMS encryption for sensitive data
- [ ] CloudTrail enabled for audit
- [ ] VPC Flow Logs enabled
- [ ] Security group audit logging
- [ ] Backup and disaster recovery configured
- [ ] Provider versions pinned
- [ ] Terraform version specified

---

## Terraform Module Structure

```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── README.md
│   └── terraform.tfvars.example
│
├── rds/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── README.md
│   └── terraform.tfvars.example
│
└── security/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    └── terraform.tfvars.example

environments/
├── dev/
│   ├── main.tf
│   ├── terraform.tfvars
│   └── backend.tf
│
├── staging/
│   ├── main.tf
│   ├── terraform.tfvars
│   └── backend.tf
│
└── prod/
    ├── main.tf
    ├── terraform.tfvars
    ├── backend.tf
    └── .terraform-lock.hcl
```

---

**Terraform Review Version:** 1.0  
**Last Updated:** February 2026  
**Compatibility:** Terraform >= 1.0
