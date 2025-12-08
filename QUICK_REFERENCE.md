# 🚀 Quick Reference: Mock Authentication

## 📱 How to Run

```bash
cd packages/app
flutter run
```

## 🔑 Demo Credentials (Tap to Auto-Fill)

```
Email: demo@test.com     Password: password123
Email: admin@test.com    Password: admin123
Email: test@test.com     Password: test123
```

## 🔄 Complete Flow

```
App Start → Splash → Onboarding (first time) → Login → Home
```

## 🎯 What You Can Test

1. **Login**: Tap credential card → Click Login → See home page
2. **Logout**: Click red Logout button → See login page
3. **Re-login**: Login with different user → See new user info
4. **Errors**: Try wrong password → See error message
5. **Persistence**: Close app → Reopen → Still logged in

## 🔧 Switch to Real API (One Line!)

**File**: `packages/app/lib/injection_container.dart`

```dart
// Change this line (around line 38):
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    // mockDataSource: getIt<AuthMockDataSource>(),  ← Comment out
    remoteDataSource: getIt<AuthRemoteDataSource>(),  ← Uncomment
    tokenStorage: getIt<TokenStorage>(),
  ),
);
```

## 📚 Documentation

- **[MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md)** - Full guide
- **[AUTH_FLOW_DIAGRAM.md](AUTH_FLOW_DIAGRAM.md)** - Visual diagrams
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - What was built

## 🎨 UI Features

- ✅ Tap demo credential cards to auto-fill
- ✅ Password visibility toggle
- ✅ Form validation
- ✅ Loading states (800ms delay)
- ✅ Success/error messages
- ✅ User profile on home page
- ✅ Logout button

## 🔐 How Mock Works

1. **3 users in memory** (Demo, Admin, Test)
2. **Login validates** email + password
3. **Generates tokens** like: `mock_token_1_1702056789`
4. **Saves to secure storage** (persists across restarts)
5. **Gets user from token** when needed
6. **Clears tokens** on logout

## ✨ Key Files

```
packages/features_auth/lib/
  ├── data/datasources/remote/auth_mock_datasource.dart  ← Mock DB
  ├── data/repositories/auth_repository_impl.dart        ← Switch here
  └── presentation/widgets/login_form.dart               ← Tap to fill

packages/app/lib/
  └── injection_container.dart                           ← Configure here
```

## 🧪 Testing Checklist

- [ ] Run app
- [ ] Complete onboarding (first launch)
- [ ] Tap "Demo User" credential
- [ ] Click "Login"
- [ ] See home page with user info
- [ ] Click "Logout"
- [ ] Return to login page
- [ ] Tap "Admin User" credential
- [ ] Login again
- [ ] See different user info

## 🎉 That's It!

Everything works like a real app. When backend is ready, change 1 line and go live! 🚀
