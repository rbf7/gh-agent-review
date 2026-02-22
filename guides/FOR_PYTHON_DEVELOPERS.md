# 🐍 Python Developers Guide

> **v3 Update (2026-02-22):** Use `scripts/enhanced-copilot-review-v3.sh` for Python reviews in this repository.

Complete guide for Python developers using the Agentic AI Code Reviewer.

---

## Quick Start

```bash
# Review your Python code
./scripts/enhanced-copilot-review-v3.sh main develop ./

# Check just application code
./scripts/enhanced-copilot-review-v3.sh main develop ./src

# Check tests
./scripts/enhanced-copilot-review-v3.sh main develop ./tests
```

---

## What Gets Reviewed

### Security
- ✅ SQL injection (raw queries)
- ✅ XSS vulnerabilities
- ✅ CSRF protection
- ✅ Authentication/Authorization
- ✅ Hardcoded credentials
- ✅ Insecure dependencies
- ✅ Code injection risks

### Performance
- ✅ N+1 query problems
- ✅ Inefficient algorithms
- ✅ Memory leaks
- ✅ Database connection pooling
- ✅ Blocking operations
- ✅ Resource cleanup

### Code Quality
- ✅ PEP 8 compliance
- ✅ Type hints usage
- ✅ Docstrings
- ✅ Code complexity
- ✅ DRY principle
- ✅ SOLID principles

### Testing
- ✅ Test coverage
- ✅ Unit tests
- ✅ Integration tests
- ✅ Mocking
- ✅ Edge cases

---

## Common Issues & Fixes

### 1. Missing Type Hints

**Issue:**
```python
def process_user(user_data):
    return user_data.get('name', 'Unknown')
```

**Fix:**
```python
from typing import Dict, Optional

def process_user(user_data: Dict[str, str]) -> str:
    return user_data.get('name', 'Unknown')
```

### 2. SQL Injection

**Issue:**
```python
email = request.args.get('email')
query = f"SELECT * FROM users WHERE email = '{email}'"
result = db.execute(query)
```

**Fix:**
```python
email = request.args.get('email')
query = "SELECT * FROM users WHERE email = %s"
result = db.execute(query, (email,))
```

### 3. Missing Error Handling

**Issue:**
```python
def get_user(user_id):
    user = User.objects.get(id=user_id)
    return user.name
```

**Fix:**
```python
def get_user(user_id):
    try:
        user = User.objects.get(id=user_id)
        return user.name
    except User.DoesNotExist:
        logger.error(f"User {user_id} not found")
        raise ValueError(f"User {user_id} not found")
```

### 4. Hardcoded Credentials

**Issue:**
```python
DATABASE_URL = "postgresql://admin:password123@localhost/mydb"
SECRET_KEY = "my-secret-key-123"
```

**Fix:**
```python
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')
SECRET_KEY = os.getenv('SECRET_KEY')
```

### 5. N+1 Queries

**Issue:**
```python
users = User.objects.all()
for user in users:
    print(user.department.name)  # Query per iteration!
```

**Fix:**
```python
users = User.objects.select_related('department').all()
for user in users:
    print(user.department.name)  # No extra queries
```

### 6. Missing Docstrings

**Issue:**
```python
def calculate_discount(price, quantity):
    if quantity > 100:
        return price * 0.1
    return 0
```

**Fix:**
```python
def calculate_discount(price: float, quantity: int) -> float:
    """
    Calculate discount based on quantity.
    
    Args:
        price: Product price in dollars
        quantity: Quantity ordered
        
    Returns:
        Discount amount in dollars
        
    Raises:
        ValueError: If price or quantity is negative
    """
    if price < 0 or quantity < 0:
        raise ValueError("Price and quantity must be positive")
    
    if quantity > 100:
        return price * 0.1
    return 0
```

---

## Framework-Specific Tips

### Django

**Good Practices:**
```python
# 1. Use ORM queries
users = User.objects.filter(active=True).select_related('profile')

# 2. Use views properly
from django.views import View
from django.utils.decorators import method_decorator
from django.views.decorators.http import require_http_methods

class UserView(View):
    @method_decorator(require_http_methods(["GET", "POST"]))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)

# 3. Use middleware for logging
class LoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        logger.info(f"Request: {request.method} {request.path}")
        response = self.get_response(request)
        logger.info(f"Response: {response.status_code}")
        return response
```

### FastAPI

**Good Practices:**
```python
# 1. Use type hints
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class User(BaseModel):
    name: str
    email: str
    age: int

@app.post("/users/")
async def create_user(user: User):
    return user

# 2. Use dependency injection
from fastapi import Depends

async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Verify token
    return user

@app.get("/users/me")
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

# 3. Use proper status codes
@app.delete("/users/{user_id}")
async def delete_user(user_id: int):
    user = await User.get(id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    await user.delete()
    return {"deleted": True}
```

### Flask

**Good Practices:**
```python
# 1. Use blueprints for organization
from flask import Blueprint

users_bp = Blueprint('users', __name__, url_prefix='/api/users')

@users_bp.route('/', methods=['GET'])
def get_users():
    return jsonify(User.query.all())

# 2. Use decorators for auth
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('user_id'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# 3. Use proper error handling
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404
```

---

## Performance Checklist

Before committing:

- [ ] No N+1 queries
- [ ] Proper indexing on database queries
- [ ] Connection pooling configured
- [ ] Caching strategy in place
- [ ] Lazy loading used appropriately
- [ ] No unnecessary list comprehensions
- [ ] Generators used for large datasets
- [ ] Async/await for I/O operations

---

## Security Checklist

Before committing:

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] CSRF tokens enabled
- [ ] Authentication required
- [ ] Authorization verified
- [ ] No credentials in code
- [ ] Secrets in environment variables
- [ ] HTTPS enforced
- [ ] Dependencies up to date
- [ ] Rate limiting enabled

---

## Testing Checklist

Before committing:

- [ ] Unit tests for business logic
- [ ] Integration tests for APIs
- [ ] Edge cases covered
- [ ] Error scenarios tested
- [ ] Fixtures used properly
- [ ] Mocks used appropriately
- [ ] Test coverage >80%
- [ ] Tests run in <10 seconds

---

## Example Review Output

```
✅ Detected: Python, Django
✅ Stack Detection: Django REST application

📊 Review Results:

CRITICAL (1):
- SQL Injection risk in views.py line 45
  Using f-string for database query

HIGH (3):
- Missing type hints on function parameters
- Hardcoded database credentials in settings.py
- N+1 query in UserViewSet

MEDIUM (5):
- PEP 8: Line too long (128 chars vs 79 max)
- Missing docstrings on public methods
- No error handling on API endpoint
- Missing input validation
- Unused import: datetime

LOW (2):
- Inconsistent naming (snake_case vs camelCase)
- Missing blank line before class definition

✨ Scores:
- Security: 72/100
- Performance: 78/100
- Quality: 75/100
- Testing: 65/100
```

---

## Integration with Your Workflow

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
chmod +x scripts/enhanced-copilot-review-v3.sh
./scripts/enhanced-copilot-review-v3.sh main develop ./

if grep -q "CRITICAL" reports/enhanced-copilot-review.md; then
    echo "❌ Critical issues found - commit blocked"
    exit 1
fi
```

### Pytest Integration

Add to `pytest.ini`:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```

---

## Quick Tips

1. **Use type hints** - Improves code clarity and IDE support
2. **Write docstrings** - Document your APIs
3. **Use virtual environments** - Avoid dependency conflicts
4. **Keep requirements updated** - Security is important
5. **Use logging, not print()** - Better debugging
6. **Test edge cases** - Most bugs hide there
7. **Use environment variables** - Never hardcode secrets
8. **Profile your code** - Find performance bottlenecks

---

**Python Guide v1.0.1 - February 2026**
