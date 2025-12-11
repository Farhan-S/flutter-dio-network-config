# Authentication State Persistence Fix

## Problem

User authentication state was not being persisted when reopening the app. After logging in successfully and closing the app, users would be shown as unauthenticated when reopening, despite tokens being correctly saved in `FlutterSecureStorage`.

## Root Cause Analysis

### Issue 1: Multiple AuthBloc Instances

The primary issue was that `AuthBloc` was registered as a **factory** in the dependency injection container:

```dart
// ❌ BEFORE - Creates new instance each time
getIt.registerFactory<AuthBloc>(() => AuthBloc(...));
```

In `main.dart`, `getIt<AuthBloc>()` was called **THREE times**:

1. To create the GoRouter (listens to auth state changes)
2. To trigger `AuthCheckRequested` on app start
3. To provide to `BlocProvider` for the widget tree

Since it was a factory, each call created a **separate AuthBloc instance**:

- Router listened to **Instance #1**
- `AuthCheckRequested` was sent to **Instance #2**
- Widget tree used **Instance #3**

**Result**: Auth state updates were not shared across instances. When Instance #2 loaded user data, the router (listening to Instance #1) and widget tree (using Instance #3) never received the updates.

### Issue 2: No Auth Check on App Start

The app was not triggering `AuthCheckRequested` when starting up, so even if tokens existed in storage, the AuthBloc remained in `AuthInitial` state instead of loading the user data.

## Solution

### Fix 1: Make AuthBloc a Singleton

Changed AuthBloc registration from `factory` to `lazySingleton`:

```dart
// ✅ AFTER - Single instance shared throughout app
getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(
  loginUseCase: getIt<LoginUseCase>(),
  logoutUseCase: getIt<LogoutUseCase>(),
  getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
));
```

**Benefits**:

- All components (router, widgets, event dispatchers) use the **same AuthBloc instance**
- Auth state changes propagate correctly to all listeners
- Maintains single source of truth for authentication state

### Fix 2: Trigger Auth Check on App Start

Added auth check in `MyApp` initialization:

```dart
@override
void initState() {
  super.initState();
  _router = AppRouter.createRouter(authBloc: getIt<AuthBloc>());

  // Check authentication status on app start to restore user session
  // This loads user data if tokens exist in storage
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getIt<AuthBloc>().add(const AuthCheckRequested());
  });
}
```

**How it works**:

1. App starts → `initState()` called
2. Router created with AuthBloc instance
3. After first frame, `AuthCheckRequested` is dispatched
4. AuthBloc calls `GetCurrentUserUseCase`
5. Use case reads token from `SecureTokenStorage`
6. If token exists, extracts userId and loads user data
7. Emits `AuthAuthenticated(user)` state
8. Router and widgets react to auth state change

## Authentication Flow

### First Time User (No Tokens)

```
App Start
  → AuthCheckRequested
  → getCurrentUser()
  → No token found
  → emit(AuthUnauthenticated)
  → Router redirects to Login
```

### Returning User (Has Tokens)

```
App Start
  → AuthCheckRequested
  → getCurrentUser()
  → Token found in SecureStorage
  → Extract userId from token
  → Load user data
  → emit(AuthAuthenticated(user))
  → Router allows access to protected routes
  → HomePage shows user info
```

### After Login

```
Login Form Submit
  → AuthLoginRequested
  → LoginUseCase.call()
  → API returns tokens
  → Save to SecureStorage
  → emit(AuthAuthenticated(user))
  → Router redirects to Home
```

### After Logout

```
Logout Button
  → AuthLogoutRequested
  → LogoutUseCase.call()
  → Clear tokens from SecureStorage
  → emit(AuthUnauthenticated)
  → Router redirects to Login
```

## Token Storage Implementation

The app uses `SecureTokenStorage` which leverages `FlutterSecureStorage`:

```dart
class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
```

**Security Features**:

- **Android**: Uses EncryptedSharedPreferences (AES-256 encryption)
- **iOS**: Uses Keychain with `first_unlock` accessibility
- **Persistence**: Tokens survive app restarts
- **Isolation**: Data encrypted per-app, not accessible by other apps

## Mock Token Format

For development/testing, `AuthMockDataSource` generates tokens in this format:

```
mock_token_<userId>_<timestamp>
```

Example: `mock_token_1_1702345678901`

When `getCurrentUser()` is called:

1. Read token from SecureStorage
2. Split by underscore: `['mock', 'token', '1', '1702345678901']`
3. Extract userId from `parts[2]`: `'1'`
4. Look up user in mock database by ID
5. Return user data

## Testing the Fix

### Scenario 1: New Installation

1. Install app
2. Complete onboarding
3. Login with credentials
4. **Close app completely**
5. **Reopen app**
6. ✅ Should remain logged in, go directly to HomePage

### Scenario 2: After Logout

1. Open app (while logged in)
2. Logout
3. **Close app**
4. **Reopen app**
5. ✅ Should show Login screen (not HomePage)

### Scenario 3: Token Expiry (Future Enhancement)

When implementing real API with token expiry:

1. App start with expired token
2. Auth check fails
3. Attempt token refresh
4. If refresh succeeds → AuthAuthenticated
5. If refresh fails → AuthUnauthenticated → Login

## Related Files Modified

1. **`packages/app/lib/injection_container.dart`**

   - Changed `AuthBloc` from `registerFactory` to `registerLazySingleton`

2. **`packages/app/lib/main.dart`**
   - Added `AuthCheckRequested` dispatch in `initState()`

## Best Practices Applied

✅ **Single Source of Truth**: One AuthBloc instance for entire app  
✅ **Secure Storage**: Tokens encrypted on device  
✅ **Proper Lifecycle**: Check auth on app start  
✅ **State Synchronization**: All components listen to same BLoC  
✅ **Clean Architecture**: Separation of concerns maintained

## Future Enhancements

1. **Token Refresh Logic**: Implement automatic token refresh when expired
2. **Biometric Auth**: Add fingerprint/face unlock for returning users
3. **Session Timeout**: Auto-logout after period of inactivity
4. **Remember Me**: Optional token persistence duration
5. **Multi-Device Sync**: Detect login from another device

## Summary

The authentication persistence issue was caused by multiple AuthBloc instances not sharing state. By making AuthBloc a singleton and ensuring auth status is checked on app start, the app now correctly:

- ✅ Persists tokens securely across app restarts
- ✅ Restores user session automatically
- ✅ Maintains auth state consistency
- ✅ Works correctly with go_router redirects
