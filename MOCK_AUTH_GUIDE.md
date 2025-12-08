# Mock Authentication Guide

This project includes a fully functional **mock authentication system** for development and testing. The mock system simulates real API authentication without requiring a backend server.

## 🎯 Features

- ✅ **Login** with email and password validation
- ✅ **Registration** with duplicate email checking
- ✅ **Token management** (access & refresh tokens)
- ✅ **Session persistence** using secure storage
- ✅ **Logout** functionality
- ✅ **User profile** retrieval
- ✅ **Network delay simulation** (800ms) for realistic UX
- ✅ **Error handling** (invalid credentials, validation, etc.)

## 🧪 Demo Credentials

The mock system includes 3 pre-configured test users:

| Name       | Email            | Password      |
| ---------- | ---------------- | ------------- |
| Demo User  | `demo@test.com`  | `password123` |
| Admin User | `admin@test.com` | `admin123`    |
| Test User  | `test@test.com`  | `test123`     |

### Quick Fill Feature

On the login page, simply **tap any credential card** to automatically fill the email and password fields!

## 🏗️ Architecture

### Mock Data Source

- **Location**: `packages/features_auth/lib/data/datasources/remote/auth_mock_datasource.dart`
- **Functionality**:
  - Maintains in-memory user database
  - Generates mock JWT tokens
  - Simulates network delays
  - Validates credentials
  - Tracks current session

### Repository Integration

- **Location**: `packages/features_auth/lib/data/repositories/auth_repository_impl.dart`
- **Features**:
  - Accepts both `AuthRemoteDataSource` and `AuthMockDataSource`
  - Prioritizes mock datasource when available
  - Clean Architecture compliance
  - Easy switching between mock and real API

### Dependency Injection

- **Location**: `packages/app/lib/injection_container.dart`
- **Configuration**:

```dart
// Using mock auth (current)
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    mockDataSource: getIt<AuthMockDataSource>(),
    tokenStorage: getIt<TokenStorage>(),
  ),
);

// Switch to real API (when ready)
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: getIt<AuthRemoteDataSource>(),
    tokenStorage: getIt<TokenStorage>(),
  ),
);
```

## 🔄 Complete Flow

### 1. First Launch

```
App Start
  ↓
Splash Screen (checks tokens + onboarding)
  ↓
Onboarding (4 pages) - First time only
  ↓
Login Page (with demo credentials)
```

### 2. Login Flow

```
Login Page
  ↓
Tap demo credential card (auto-fill)
  ↓
Tap "Login" button
  ↓
Mock API validates credentials (800ms delay)
  ↓
Tokens saved to secure storage
  ↓
Navigate to Home Page
```

### 3. Authenticated Session

```
Home Page
  ↓
Shows user info (name, email, avatar)
  ↓
Logout button available
  ↓
Network test features accessible
```

### 4. Logout Flow

```
Tap "Logout" button
  ↓
Tokens cleared from storage
  ↓
Navigate back to Login Page
  ↓
Ready for next login
```

## 🧪 Testing the Flow

1. **Run the app**:

   ```bash
   cd packages/app
   flutter run
   ```

2. **Complete onboarding** (if first launch)

3. **Try login**:

   - Tap on any demo credential card
   - Click "Login"
   - See 800ms loading state
   - Navigate to home page

4. **Verify session**:

   - See authenticated user info
   - Check network test page works

5. **Test logout**:

   - Click "Logout" button
   - See success message
   - Verify navigation to login

6. **Test error handling**:
   - Try wrong password
   - Try non-existent email
   - See appropriate error messages

## 🔐 Token System

### Mock Token Format

```
Access Token: mock_token_<userId>_<timestamp>
Refresh Token: mock_refresh_token_<userId>_<timestamp>
```

### Token Storage

- Uses `flutter_secure_storage` for security
- Persists across app restarts
- Automatically handled by repository layer

### Token Retrieval

The mock datasource can extract user ID from tokens:

```dart
// Token: "mock_token_1_1234567890"
// Extracted userId: "1"
```

## 📝 Registration (Bonus)

You can also test new user registration:

```dart
// Add a registration page using AuthBloc
context.read<AuthBloc>().add(
  AuthRegisterRequested(
    name: 'New User',
    email: 'newuser@test.com',
    password: 'securepass123',
  ),
);
```

**Validation Rules**:

- Email must be unique
- Password minimum 6 characters
- Successful registration auto-logs in the user

## 🚀 Switching to Real API

When your backend is ready:

1. **Update `injection_container.dart`**:

   ```dart
   // Comment out mock
   // mockDataSource: getIt<AuthMockDataSource>(),

   // Uncomment real API
   remoteDataSource: getIt<AuthRemoteDataSource>(),
   ```

2. **Configure API endpoints** in `packages/core/lib/src/routes/api_routes.dart`:

   ```dart
   static const String login = '/auth/login';
   static const String register = '/auth/register';
   ```

3. **Set BASE_URL** when running:
   ```bash
   flutter run --dart-define=BASE_URL=https://api.yourapp.com
   ```

That's it! No other code changes needed thanks to Clean Architecture.

## 🎨 UI Features

### Login Page

- Email and password fields with validation
- Password visibility toggle
- Interactive demo credential cards
- Tap-to-fill functionality
- Loading states
- Error messages

### Home Page

- User profile display
- Authentication status card
- Logout button
- Network test navigation
- BLoC state management

## 🛠️ Mock Datasource API

### Available Methods

```dart
// Login
Future<AuthTokenModel> login({
  required String email,
  required String password,
});

// Register
Future<AuthTokenModel> register({
  required String name,
  required String email,
  required String password,
});

// Refresh Token
Future<AuthTokenModel> refreshToken({
  required String refreshToken,
});

// Get Current User
Future<UserModel> getCurrentUser();

// Utility Methods
static Map<String, dynamic>? getMockUserByEmail(String email);
static List<Map<String, dynamic>> getAllMockUsers();
void setCurrentUserId(String? userId);
```

## 📦 Dependencies

The mock system uses:

- `dartz` - Functional programming (Either)
- `equatable` - Value equality
- `flutter_secure_storage` - Secure token storage
- `get_it` - Dependency injection

## ✨ Benefits

1. **No Backend Required**: Develop and test without API
2. **Realistic Behavior**: Network delays and error states
3. **Easy Testing**: Predictable test data
4. **Clean Switch**: One line change to use real API
5. **Learning Tool**: Understand auth flow without backend complexity

## 🎓 Learning Resources

- Study `auth_mock_datasource.dart` to understand mock patterns
- Review `auth_repository_impl.dart` for Clean Architecture
- Check `login_form.dart` for BLoC integration
- Explore token storage in `secure_token_storage.dart`

---

**Happy coding! 🚀** Switch to real API when ready - it's just one line!
