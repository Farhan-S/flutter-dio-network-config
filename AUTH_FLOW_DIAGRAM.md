# Authentication Flow Diagram

## 🔄 Complete Application Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        APP STARTS                                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SPLASH SCREEN                                 │
│  • Check authentication status (tokens in secure storage)       │
│  • Check onboarding completion (SharedPreferences)              │
└────────────────────────┬────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
  First Launch                    Returning User
  (!onboarding)                  (onboarding complete)
         │                               │
         ▼                               │
┌─────────────────────┐                 │
│  ONBOARDING PAGES   │                 │
│  • 4 intro screens  │                 │
│  • Swipe/Skip       │                 │
│  • Mark completed   │                 │
└──────────┬──────────┘                 │
           │                            │
           └────────────┬───────────────┘
                        │
         ┌──────────────┴──────────────┐
         │                             │
         ▼                             ▼
    Authenticated                 Not Authenticated
    (has tokens)                  (no tokens)
         │                             │
         ▼                             ▼
┌─────────────────────┐      ┌─────────────────────┐
│    HOME PAGE        │      │    LOGIN PAGE       │
│  • User info        │      │  • Demo credentials │
│  • Logout button    │      │  • Tap to auto-fill│
│  • Network tests    │      │  • Form validation │
└──────────┬──────────┘      └──────────┬──────────┘
           │                            │
           │                            ▼
           │                 ┌─────────────────────┐
           │                 │   AUTH BLOC         │
           │                 │  • LoginUseCase     │
           │                 │  • Validation       │
           │                 └──────────┬──────────┘
           │                            │
           │                            ▼
           │                 ┌─────────────────────┐
           │                 │  AUTH REPOSITORY    │
           │                 │  • Choose datasource│
           │                 └──────────┬──────────┘
           │                            │
           │              ┌─────────────┴─────────────┐
           │              │                           │
           │              ▼                           ▼
           │    ┌──────────────────┐       ┌──────────────────┐
           │    │  MOCK DATASOURCE │       │ REMOTE DATASOURCE│
           │    │  • 3 test users  │       │  • Real API calls│
           │    │  • Validate creds│       │  • HTTP requests │
           │    │  • Generate token│       │  • Error handling│
           │    └────────┬─────────┘       └────────┬─────────┘
           │             │                           │
           │             └──────────┬────────────────┘
           │                        │
           │                        ▼
           │             ┌──────────────────────┐
           │             │   TOKEN STORAGE      │
           │             │  • Save access token │
           │             │  • Save refresh token│
           │             │  • Secure storage    │
           │             └──────────┬───────────┘
           │                        │
           │                        ▼
           │             ┌──────────────────────┐
           │             │  LOGIN SUCCESS       │
           │             │  • Show success msg  │
           │             │  • Navigate to home  │
           │             └──────────┬───────────┘
           │                        │
           └────────────────────────┘
                         │
                         ▼
           ┌──────────────────────────┐
           │      USER ACTIONS        │
           │  • View network tests    │
           │  • Check user profile    │
           │  • Logout                │
           └──────────────┬───────────┘
                          │
                (Logout clicked)
                          │
                          ▼
           ┌──────────────────────────┐
           │   LOGOUT USE CASE        │
           │  • Clear tokens          │
           │  • Update BLoC state     │
           └──────────────┬───────────┘
                          │
                          ▼
           ┌──────────────────────────┐
           │   NAVIGATE TO LOGIN      │
           │  • Show logout message   │
           │  • Ready for next login  │
           └──────────────────────────┘
```

## 🎯 Mock Authentication Details

### User Database (In-Memory)

```
┌─────┬──────────────┬──────────────────┬──────────────┐
│ ID  │ Name         │ Email            │ Password     │
├─────┼──────────────┼──────────────────┼──────────────┤
│ 1   │ Demo User    │ demo@test.com    │ password123  │
│ 2   │ Admin User   │ admin@test.com   │ admin123     │
│ 3   │ Test User    │ test@test.com    │ test123      │
└─────┴──────────────┴──────────────────┴──────────────┘
```

### Token Generation

```
Login Success
     │
     ▼
Generate Tokens
     │
     ├─► Access Token:  mock_token_<userId>_<timestamp>
     │   Example: "mock_token_1_1702056789123"
     │
     └─► Refresh Token: mock_refresh_token_<userId>_<timestamp>
         Example: "mock_refresh_token_1_1702056789123"
```

### Authentication Check

```
Get Current User
     │
     ▼
Check Session
     │
     ├─► Has _currentUserId? ──YES──► Use it
     │
     └─► NO ──► Check Token Storage
                     │
                     ▼
                Extract userId from token
                     │
                     ▼
                Find user in database
                     │
                     ▼
                Return user data
```

## 🔐 Security Features

### Token Storage

- **Package**: `flutter_secure_storage`
- **Platform Security**:
  - **iOS**: Keychain
  - **Android**: EncryptedSharedPreferences
  - **Web**: LocalStorage (encrypted)
  - **Desktop**: Secure platform storage

### Session Management

- Tokens persist across app restarts
- Automatic token validation
- Secure token clearing on logout

## 🧪 Error Scenarios

### Login Errors

```
Wrong Password
     │
     ▼
UnauthorizedException
     │
     ▼
BLoC emits AuthError
     │
     ▼
Show red SnackBar
     │
     ▼
Stay on login page
```

### Email Not Found

```
Unknown Email
     │
     ▼
UnauthorizedException
     │
     ▼
"Invalid email or password"
     │
     ▼
User stays on login
```

### Registration Duplicate

```
Email Already Exists
     │
     ▼
ValidationException
     │
     ▼
"Email already registered"
     │
     ▼
Show error to user
```

## 🔄 State Management (BLoC)

### Events

```dart
AuthLoginRequested(email, password)
    → Trigger login use case

AuthLogoutRequested()
    → Trigger logout use case

AuthGetCurrentUser()
    → Fetch current user data
```

### States

```dart
AuthInitial
    → Initial state

AuthLoading
    → Processing request (show loading)

AuthAuthenticated(user)
    → Login success (show home page)

AuthUnauthenticated
    → Logout success (show login page)

AuthError(message)
    → Something failed (show error)
```

## 🚀 Switching to Real API

### Current Setup (Mock)

```dart
AuthRepository(
  mockDataSource: AuthMockDataSource(),  ← Using mock
  tokenStorage: SecureTokenStorage(),
)
```

### Production Setup (Real API)

```dart
AuthRepository(
  remoteDataSource: AuthRemoteDataSource(DioClient()),  ← Using real API
  tokenStorage: SecureTokenStorage(),
)
```

**That's it!** Everything else works the same thanks to Clean Architecture.

---

## 📚 Related Documentation

- [MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md) - Complete mock auth documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Full system architecture
- [README.md](README.md) - Getting started guide
