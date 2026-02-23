# ☕ Java Developers Guide

> **v3 Update (2026-02-22):** Use `scripts/enhanced-copilot-review-v3.sh` for Java reviews in this repository.
> **v3.1 Update (2026-02-23):** Supports `--repo-root` for external repos, `--model` for model choice (default `gpt-5-mini`), and `.` for full-repo scans.

Complete guide for Java developers using the Agentic AI Code Reviewer.

---

## Quick Start

```bash
# Review your Java code
./scripts/enhanced-copilot-review-v3.sh main develop ./src

# Check just application code
./scripts/enhanced-copilot-review-v3.sh main develop ./src/main/java

# Check tests
./scripts/enhanced-copilot-review-v3.sh main develop ./src/test/java
```

---

## What Gets Reviewed

### Security (OWASP)
- ✅ SQL Injection risks
- ✅ XSS vulnerabilities
- ✅ Authentication/Authorization flaws
- ✅ Insecure cryptography
- ✅ Hardcoded credentials
- ✅ Unsafe deserialization

### Performance
- ✅ N+1 query problems
- ✅ Memory leaks
- ✅ Inefficient algorithms
- ✅ Thread synchronization issues
- ✅ Resource management
- ✅ Connection pooling

### Code Quality
- ✅ SOLID principles
- ✅ Design patterns
- ✅ Code complexity
- ✅ Naming conventions
- ✅ Documentation
- ✅ Code duplication

### Testing
- ✅ Test coverage
- ✅ Missing test cases
- ✅ Mock usage
- ✅ Assertion quality
- ✅ Edge cases

---

## Common Issues & Fixes

### 1. Missing Validation

**Issue:**
```java
@PostMapping("/users")
public ResponseEntity<?> createUser(UserDTO user) {
    // No validation!
    return ResponseEntity.ok(userService.save(user));
}
```

**Fix:**
```java
@PostMapping("/users")
public ResponseEntity<?> createUser(@Valid @RequestBody UserDTO user) {
    return ResponseEntity.ok(userService.save(user));
}
```

### 2. SQL Injection

**Issue:**
```java
String query = "SELECT * FROM users WHERE email = '" + email + "'";
```

**Fix:**
```java
String query = "SELECT * FROM users WHERE email = ?";
PreparedStatement stmt = connection.prepareStatement(query);
stmt.setString(1, email);
```

### 3. N+1 Queries

**Issue:**
```java
List<User> users = userRepository.findAll();
for (User user : users) {
    System.out.println(user.getDepartment().getName()); // Query per iteration!
}
```

**Fix:**
```java
@Query("SELECT u FROM User u LEFT JOIN FETCH u.department")
List<User> findAllWithDepartments();
```

### 4. Missing Null Checks

**Issue:**
```java
public String getUserName(Long userId) {
    User user = userRepository.findById(userId);
    return user.getName(); // NPE if user not found!
}
```

**Fix:**
```java
public String getUserName(Long userId) {
    return userRepository.findById(userId)
        .map(User::getName)
        .orElse("Unknown");
}
```

### 5. Hardcoded Credentials

**Issue:**
```java
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost/mydb",
    "admin",
    "password123"  // Don't do this!
);
```

**Fix:**
```java
String url = environment.getProperty("db.url");
String user = environment.getProperty("db.user");
String password = environment.getProperty("db.password");
Connection conn = DriverManager.getConnection(url, user, password);
```

### 6. Insufficient Logging

**Issue:**
```java
try {
    processUser(user);
} catch (Exception e) {
    // No logging!
}
```

**Fix:**
```java
try {
    processUser(user);
} catch (Exception e) {
    logger.error("Failed to process user: {}", user.getId(), e);
    throw new ProcessingException("User processing failed", e);
}
```

---

## Framework-Specific Tips

### Spring Boot

**Good Practices:**
```java
// 1. Use dependency injection
@Service
public class UserService {
    private final UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}

// 2. Use transactions
@Transactional
public User saveUser(User user) {
    return repository.save(user);
}

// 3. Use proper exception handling
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<?> handleNotFound(UserNotFoundException e) {
        return ResponseEntity.notFound().build();
    }
}
```

### JPA/Hibernate

**Good Practices:**
```java
// 1. Use eager loading when needed
@OneToMany(fetch = FetchType.EAGER)
private List<Order> orders;

// 2. Use proper cascade
@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
private List<Address> addresses;

// 3. Use DTOs for APIs
public class UserDTO {
    private String name;
    private String email;
    // Don't expose entity directly!
}
```

---

## Performance Checklist

Before committing:

- [ ] No N+1 queries detected
- [ ] Proper indexing on frequently queried columns
- [ ] Connection pooling configured
- [ ] Cache strategy in place
- [ ] Lazy loading where appropriate
- [ ] No unnecessary object creation in loops
- [ ] Proper thread management
- [ ] Memory leaks prevented (listeners unregistered)

---

## Security Checklist

Before committing:

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS protection (encode output)
- [ ] CSRF protection enabled
- [ ] Authentication required on protected endpoints
- [ ] Authorization verified (roles/permissions)
- [ ] Sensitive data logged? (Don't!)
- [ ] Credentials stored securely
- [ ] HTTPS enforced
- [ ] Dependencies up to date

---

## Testing Checklist

Before committing:

- [ ] Unit tests for business logic
- [ ] Integration tests for APIs
- [ ] Edge cases covered
- [ ] Error scenarios tested
- [ ] Mocks used appropriately
- [ ] Test coverage >80%
- [ ] No flaky tests
- [ ] Tests run in <10 seconds

---

## Example Review Output

```
✅ Detected: Java, Spring Boot, Maven
✅ Stack Detection: Spring Boot application

📊 Review Results:

CRITICAL (1):
- SQL Injection risk in UserDAO.java line 45
  Using string concatenation instead of parameterized queries

HIGH (3):
- Missing @Valid on UserController endpoint
- Test coverage 42% (target 80%)
- N+1 query in UserService.getAllUsers()

MEDIUM (5):
- Missing JavaDoc on public methods
- Inconsistent naming conventions
- No null checks on repository results
- Configuration hardcoded in application.properties
- Unused imports in UserRepository

LOW (2):
- Code style inconsistency
- Comment formatting

✨ Scores:
- Security: 72/100
- Performance: 81/100
- Quality: 78/100
- Testing: 42/100 (needs work)
```

---

## Integration with Your Workflow

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
chmod +x scripts/enhanced-copilot-review-v3.sh
./scripts/enhanced-copilot-review-v3.sh main develop ./src

if grep -q "CRITICAL" reports/enhanced-copilot-review.md; then
    echo "❌ Critical issues found - commit blocked"
    exit 1
fi
```

### Maven Integration

Add to `pom.xml`:

```xml
<build>
    <plugins>
        <plugin>
            <id>code-review</id>
            <phase>verify</phase>
            <goals>
                <goal>exec</goal>
            </goals>
            <configuration>
                <executable>bash</executable>
                <arguments>
                    <argument>scripts/enhanced-copilot-review-v3.sh</argument>
                    <argument>main</argument>
                    <argument>develop</argument>
                    <argument>./src</argument>
                </arguments>
            </configuration>
        </plugin>
    </plugins>
</build>
```

---

## Quick Tips

1. **Review early and often** - Don't wait until PR review
2. **Fix CRITICAL first** - Security issues must be resolved
3. **Aim for 80%+ test coverage** - Achievable with TDD
4. **Use Spring profiles** - Don't hardcode config
5. **Leverage Spring Cloud Config** - Externalize configuration
6. **Use logging framework** - SLF4J with Logback
7. **Monitor performance** - Use Spring Boot Actuator
8. **Keep dependencies updated** - Reduces security risks

---

**Java Guide v1.0.1 - February 2026**
