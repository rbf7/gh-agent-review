# ⚛️ React Developers Guide

> **v3 Update (2026-02-22):** Use `scripts/enhanced-copilot-review-v3.sh` for React/TypeScript reviews in this repository.

Complete guide for React developers using the Agentic AI Code Reviewer.

---

## Quick Start

```bash
# Review your React code
./scripts/enhanced-copilot-review-v3.sh main develop ./src

# Check just components
./scripts/enhanced-copilot-review-v3.sh main develop ./src/components

# Check tests
./scripts/enhanced-copilot-review-v3.sh main develop ./src/__tests__
```

---

## What Gets Reviewed

### Security
- ✅ XSS vulnerabilities
- ✅ Unsafe HTML rendering
- ✅ Dependency vulnerabilities
- ✅ API security
- ✅ Authentication handling
- ✅ CSRF protection

### Performance
- ✅ Memory leaks (useEffect cleanup)
- ✅ Unnecessary re-renders
- ✅ Missing React.memo
- ✅ Bundle size impact
- ✅ Image optimization
- ✅ Code splitting

### Code Quality
- ✅ Component structure
- ✅ Prop drilling
- ✅ State management
- ✅ Hook usage
- ✅ TypeScript types
- ✅ Code duplication

### Testing
- ✅ Component tests
- ✅ Event handling
- ✅ Async operations
- ✅ Coverage
- ✅ Edge cases

---

## Common Issues & Fixes

### 1. Missing useEffect Cleanup

**Issue:**
```jsx
useEffect(() => {
    const subscription = eventBus.subscribe('update', handleUpdate);
    // Memory leak! Subscription never unsubscribed
}, []);
```

**Fix:**
```jsx
useEffect(() => {
    const subscription = eventBus.subscribe('update', handleUpdate);
    
    return () => {
        subscription.unsubscribe(); // Cleanup!
    };
}, []);
```

### 2. Missing Key in Lists

**Issue:**
```jsx
{items.map(item => (
    <div>{item.name}</div>  // No key prop!
))}
```

**Fix:**
```jsx
{items.map(item => (
    <div key={item.id}>{item.name}</div>
))}
```

### 3. XSS Vulnerability

**Issue:**
```jsx
const html = '<img src=x onerror="alert(1)">';
<div dangerouslySetInnerHTML={{__html: html}} />
```

**Fix:**
```jsx
// Use sanitization library
import DOMPurify from 'dompurify';

const html = DOMPurify.sanitize(userContent);
<div dangerouslySetInnerHTML={{__html: html}} />
```

### 4. No Error Boundary

**Issue:**
```jsx
export function App() {
    return <UserProfile userId={123} />;
    // If UserProfile errors, whole app crashes!
}
```

**Fix:**
```jsx
class ErrorBoundary extends React.Component {
    state = { hasError: false };
    
    static getDerivedStateFromError() {
        return { hasError: true };
    }
    
    render() {
        if (this.state.hasError) {
            return <div>Error loading component</div>;
        }
        return this.props.children;
    }
}

export function App() {
    return (
        <ErrorBoundary>
            <UserProfile userId={123} />
        </ErrorBoundary>
    );
}
```

### 5. Prop Drilling

**Issue:**
```jsx
// App.jsx passes to Layout, which passes to Header, which passes to Title
<App theme={theme}>
    <Layout theme={theme}>
        <Header theme={theme}>
            <Title theme={theme} />
```

**Fix:**
```jsx
// Use Context API
const ThemeContext = React.createContext();

export function App() {
    return (
        <ThemeContext.Provider value={theme}>
            <Layout />
        </ThemeContext.Provider>
    );
}

function Title() {
    const theme = useContext(ThemeContext);
    return <h1 style={{color: theme.color}}>Title</h1>;
}
```

### 6. Missing TypeScript Types

**Issue:**
```jsx
function UserCard({ user, onSelect }) {
    return <div onClick={onSelect}>{user.name}</div>;
}
```

**Fix:**
```jsx
interface User {
    id: string;
    name: string;
    email: string;
}

interface UserCardProps {
    user: User;
    onSelect: (userId: string) => void;
}

function UserCard({ user, onSelect }: UserCardProps) {
    return <div onClick={() => onSelect(user.id)}>{user.name}</div>;
}
```

---

## Framework-Specific Tips

### Using Hooks

**Good Practices:**
```jsx
// 1. Custom hooks for reusable logic
function useWindowSize() {
    const [size, setSize] = useState({ width: 0, height: 0 });
    
    useEffect(() => {
        const handleResize = () => {
            setSize({ width: window.innerWidth, height: window.innerHeight });
        };
        
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);
    
    return size;
}

// 2. Proper dependency arrays
useEffect(() => {
    // This only runs on mount and unmount
}, []);

useEffect(() => {
    // This runs when userId changes
    fetchUser(userId);
}, [userId]);

// 3. useCallback for memoized functions
const handleClick = useCallback(() => {
    console.log('Clicked!');
}, []);
```

### State Management

**Good Practices:**
```jsx
// 1. Use useState for local state
const [count, setCount] = useState(0);

// 2. Use Context for global state
const UserContext = createContext();

// 3. Use useReducer for complex state
const initialState = { count: 0, error: null };

function reducer(state, action) {
    switch(action.type) {
        case 'INCREMENT':
            return { ...state, count: state.count + 1 };
        default:
            return state;
    }
}

const [state, dispatch] = useReducer(reducer, initialState);
```

---

## Performance Checklist

Before committing:

- [ ] No unnecessary re-renders
- [ ] useEffect dependencies correct
- [ ] React.memo used for expensive components
- [ ] useCallback/useMemo used appropriately
- [ ] Images optimized
- [ ] Code splitting implemented
- [ ] Bundle size acceptable
- [ ] No memory leaks

---

## Security Checklist

Before committing:

- [ ] No dangerouslySetInnerHTML without sanitization
- [ ] No eval() or similar dynamic code
- [ ] Environment variables not exposed
- [ ] API keys not in code
- [ ] Input validated
- [ ] Output encoded
- [ ] CSRF token included in forms
- [ ] HTTPS enforced

---

## Testing Checklist

Before committing:

- [ ] Unit tests for components
- [ ] Event handlers tested
- [ ] Async operations mocked
- [ ] Error cases covered
- [ ] Accessibility tested
- [ ] Edge cases considered
- [ ] Coverage >80%
- [ ] Snapshot tests reviewed

---

## Example Review Output

```
✅ Detected: React, TypeScript
✅ Stack Detection: React application with TypeScript

📊 Review Results:

CRITICAL (1):
- Memory leak in UserProfile useEffect (cleanup missing)

HIGH (3):
- Missing error boundary in App component
- dangerouslySetInnerHTML without sanitization
- useEffect dependency array incomplete

MEDIUM (5):
- Missing key prop in list rendering
- Prop drilling: theme passed through 4 components
- No TypeScript types on component props
- Unnecessary re-render in useCallback
- Test coverage 65% (target 80%)

LOW (2):
- Inconsistent component naming
- Missing JSDoc comments

✨ Scores:
- Security: 78/100
- Performance: 72/100
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
./scripts/enhanced-copilot-review-v3.sh main develop ./src

if grep -q "CRITICAL" reports/enhanced-copilot-review.md; then
    echo "❌ Critical issues found - commit blocked"
    exit 1
fi
```

### npm Integration

Add to `package.json`:

```json
{
  "scripts": {
    "review": "bash scripts/enhanced-copilot-review-v3.sh main develop ./src"
  }
}
```

---

## Quick Tips

1. **Always use keys in lists** - Prevents bugs with dynamic lists
2. **Cleanup in useEffect** - Prevent memory leaks
3. **Use TypeScript** - Catch errors early
4. **Test components** - Especially complex logic
5. **Memoize expensive computations** - Improve performance
6. **Use Context API wisely** - Can slow down if overused
7. **Sanitize user input** - Prevent XSS
8. **Profile your app** - Find real bottlenecks

---

**React Guide v1.0.1 - February 2026**
