# ☁️ AWS Developers Guide

> **v3 Update (2026-02-22):** Use `scripts/enhanced-copilot-review-v3.sh` for AWS infrastructure reviews in this repository.

Complete guide for AWS developers using the Agentic AI Code Reviewer.

---

## Quick Start

```bash
# Review your AWS infrastructure code
./scripts/enhanced-copilot-review-v3.sh main develop ./

# Check CloudFormation templates
./scripts/enhanced-copilot-review-v3.sh main develop ./infrastructure

# Check Lambda functions
./scripts/enhanced-copilot-review-v3.sh main develop ./lambdas
```

---

## What Gets Reviewed

### Security
- ✅ IAM policy permissions (least privilege)
- ✅ Security group rules
- ✅ Encryption settings (KMS, S3, DB)
- ✅ Public access configuration
- ✅ Secrets management
- ✅ VPC/Subnet isolation
- ✅ Network ACLs
- ✅ Compliance violations

### Performance
- ✅ Instance right-sizing
- ✅ Auto-scaling configuration
- ✅ Caching strategies
- ✅ Database indexing
- ✅ Batch processing
- ✅ Connection pooling
- ✅ Lambda timeout tuning

### Cost Optimization
- ✅ Unused resources
- ✅ Reserved capacity
- ✅ Auto-scaling efficiency
- ✅ Storage optimization
- ✅ Data transfer costs
- ✅ Compute utilization

### Best Practices
- ✅ Monitoring/Alarms
- ✅ Backup strategy
- ✅ Disaster recovery
- ✅ Tagging consistency
- ✅ Resource naming
- ✅ Environment separation

---

## Common Issues & Fixes

### 1. Overly Permissive IAM Policy

**Issue:**
```json
{
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
}
```

**Fix (Least Privilege):**
```json
{
    "Effect": "Allow",
    "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ],
    "Resource": [
        "arn:aws:dynamodb:*:*:table/users",
        "arn:aws:logs:*:*:log-group:/aws/lambda/*"
    ]
}
```

### 2. Database Publicly Accessible

**Issue:**
```python
db_instance = aws_rds_instance.new(
    publicly_accessible=True,
    allocated_storage=100
)
```

**Fix:**
```python
db_instance = aws_rds_instance.new(
    publicly_accessible=False,
    db_subnet_group_name=private_subnet_group.name,
    storage_encrypted=True,
    kms_key_id=kms_key.arn
)
```

### 3. No Encryption at Rest

**Issue:**
```yaml
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: my-data-bucket
    # No encryption!
```

**Fix:**
```yaml
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: my-data-bucket
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: arn:aws:kms:region:account:key/id
```

### 4. Missing State Backup

**Issue:**
```hcl
resource "aws_rds_instance" "main" {
    backup_retention_period = 0  # No backups!
}
```

**Fix:**
```hcl
resource "aws_rds_instance" "main" {
    backup_retention_period = 30
    backup_window = "03:00-04:00"
    copy_tags_to_snapshot = true
    
    tags = {
        Name = "production-db"
        Backup = "required"
    }
}
```

### 5. Secrets in Environment Variables

**Issue:**
```python
db_password = "MyPassword123"  # Hardcoded!

lambda_function = aws_lambda.Function(
    environment={
        "DB_PASSWORD": db_password
    }
)
```

**Fix:**
```python
# Use AWS Secrets Manager
db_secret = aws_secretsmanager.Secret(
    name="prod/rds/password",
    secret_string="securely-stored-value"
)

# Reference in Lambda
lambda_function = aws_lambda.Function(
    environment={
        "SECRET_ARN": db_secret.arn
    }
)

# In Lambda code
import json
import boto3

secrets_client = boto3.client('secretsmanager')

def get_db_password():
    response = secrets_client.get_secret_value(SecretId=secret_arn)
    return json.loads(response['SecretString'])['password']
```

### 6. No Monitoring/Alarms

**Issue:**
```yaml
RDSInstance:
  Type: AWS::RDS::DBInstance
  Properties:
    # No CloudWatch alarms configured!
```

**Fix:**
```yaml
CPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    MetricName: CPUUtilization
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    AlarmActions:
      - !Ref SNSTopic

StorageAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    MetricName: FreeStorageSpace
    Statistic: Average
    Period: 300
    Threshold: 5368709120  # 5GB
    AlarmActions:
      - !Ref SNSTopic
```

---

## Service-Specific Tips

### Lambda

**Good Practices:**
```python
# 1. Proper timeout and memory
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Handler with proper error handling
    
    Context:
        memory_limit_in_mb: 256
        invoked_function_arn: arn:aws:...
        request_id: unique-id
        remaining_time_in_millis: 15000
    """
    
    try:
        # 2. Validate input
        if not event.get('user_id'):
            raise ValueError("user_id is required")
        
        # 3. Use environment variables
        db_host = os.environ.get('DB_HOST')
        secret_arn = os.environ.get('SECRET_ARN')
        
        # 4. Proper logging
        logger.info(f"Processing user: {event['user_id']}")
        
        # 5. Error handling
        result = process_user(event['user_id'])
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
```

### RDS

**Good Practices:**
```hcl
resource "aws_db_instance" "main" {
    # 1. Encryption
    storage_encrypted = true
    kms_key_id = aws_kms_key.rds.arn
    
    # 2. Backups
    backup_retention_period = 30
    backup_window = "03:00-04:00"
    copy_tags_to_snapshot = true
    
    # 3. Multi-AZ for HA
    multi_az = true
    
    # 4. Private network
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.private.name
    
    # 5. Monitoring
    monitoring_interval = 60
    monitoring_role_arn = aws_iam_role.rds_monitoring.arn
    
    # 6. Maintenance
    maintenance_window = "sun:03:00-sun:04:00"
    auto_minor_version_upgrade = true
    
    # 7. Deletion protection
    deletion_protection = true
    
    # 8. Tags
    tags = {
        Name = "production-database"
        Environment = "production"
        Backup = "required"
    }
}
```

### S3

**Good Practices:**
```yaml
MyS3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    # 1. Encryption
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms

    # 2. Block public access
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true

    # 3. Versioning
    VersioningConfiguration:
      Status: Enabled

    # 4. Logging
    LoggingConfiguration:
      DestinationBucketName: !Ref LoggingBucket
      LogFilePrefix: access-logs/

    # 5. Lifecycle rules
    LifecycleConfiguration:
      Rules:
        - Id: DeleteOldVersions
          Status: Enabled
          NoncurrentVersionExpirationInDays: 90

    # 6. Tags
    Tags:
      - Key: Name
        Value: production-data
      - Key: Environment
        Value: production
```

---

## Security Checklist

Before deploying:

- [ ] IAM policies follow least privilege
- [ ] No hardcoded credentials
- [ ] Encryption enabled (at rest and in transit)
- [ ] Security groups properly configured
- [ ] RDS not publicly accessible
- [ ] S3 public access blocked
- [ ] Secrets in Secrets Manager
- [ ] Logging enabled
- [ ] Monitoring/Alarms configured
- [ ] Backup strategy configured

---

## Cost Optimization Checklist

Before deploying:

- [ ] Instance types right-sized
- [ ] Auto-scaling configured
- [ ] Reserved instances considered
- [ ] Unused resources identified
- [ ] Data transfer optimized
- [ ] Storage tiering used
- [ ] Spot instances evaluated
- [ ] Regional costs compared

---

## Example Review Output

```
✅ Detected: AWS, Lambda, RDS, S3

📊 Infrastructure Review:

CRITICAL (3):
- RDS database publicly accessible
- IAM policy allows all actions
- S3 bucket public access not blocked

HIGH (4):
- Database not encrypted
- No backup retention policy
- Lambda execution role too permissive
- Secrets hardcoded in environment

MEDIUM (6):
- Missing CloudWatch alarms
- No monitoring configured
- Instance size not optimized
- Tags missing
- Auto-scaling not configured
- No disaster recovery plan

LOW (2):
- Documentation missing
- Cost optimization opportunity

✨ Scores:
- Security: 45/100 (URGENT)
- Cost: 62/100
- Best Practices: 55/100
- HA/DR: 35/100 (CRITICAL)
```

---

## Integration with Your Workflow

### Pre-Deployment Check

```bash
#!/bin/bash

# Run review
./scripts/enhanced-copilot-review-v3.sh main develop ./

# Parse critical issues
CRITICAL=$(jq '.issues[] | select(.severity=="critical")' reports/copilot-review.json)

if [ ! -z "$CRITICAL" ]; then
    echo "❌ Critical security issues found!"
    echo "$CRITICAL"
    exit 1
fi

echo "✅ Review passed - safe to deploy"
```

---

## Quick Tips

1. **Always use encryption** - S3, RDS, EBS, everything
2. **Follow least privilege** - Minimal IAM permissions
3. **Enable backups** - At least 30 days retention
4. **Monitor everything** - CloudWatch alarms on key metrics
5. **Use Secrets Manager** - Never hardcode credentials
6. **Enable MFA** - Protect root account
7. **Tag resources** - For cost tracking and organization
8. **Test disaster recovery** - Annual DR drills

---

**AWS Guide v1.0.1 - February 2026**
