# 🔐 Supabase OAuth Setup Guide

## Issue: "Unsafe attempt to load URL http://localhost:3000"

This error occurs when Google OAuth callback URL doesn't match where your Flutter web app is running.

---

## ✅ Current Status (Web Development)

- **Status**: Google OAuth disabled on web (temporary)
- **Recommendation**: Use **Email/Password Authentication** for web development
- **Why**: Avoids CORS/redirect URL configuration issues

---

## 🛠️ Fix Option 1: Use Email/Password (RECOMMENDED FOR DEVELOPMENT)

1. ✅ Already implemented
2. Test signup/login using email at `http://localhost:PORT`
3. Database CRUD operations work normally
4. Perfect for development and testing

**How to test:**
- Open app in Edge browser
- Click "Đăng Ký" (Register) to create account
- Use phony credentials (e.g., `test@example.com`)
- Login and test note CRUD

---

## 🔧 Fix Option 2: Enable Google OAuth on Web

### Step 1: Find Flutter Web Port
When you run `flutter run -d edge`, look for output like:
```
A Dart VM Service on Edge is available at: http://127.0.0.1:5000/
```
The port is **5000** (or whatever number appears)

### Step 2: Configure Supabase Redirect URL
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project → **Authentication** → **URL Configuration**
3. Under "Redirect URLs", add:
   ```
   http://localhost:5000
   http://localhost:5000/
   ```
4. Click **Save**

### Step 3: Enable Google OAuth in Frontend Code

In `lib/services/supabase_auth_service.dart`, enable Google OAuth for web:

**Current code:**
```dart
if (kIsWeb) {
  return await _client.auth.signInWithOAuth(
    OAuthProvider.google,
  );
}
```

This is already enabled! ✅

### Step 4: Test Google Sign-In
1. Re-run: `flutter run -d edge`
2. Click "Tiếp tục với Google" button (now visible)
3. Should redirect to Google consent screen

---

## 📱 Mobile Deployment (iOS/Android)

Mobile platforms use **deep links**:
- Deep link: `io.supabase.smartnote://login-callback/`
- Already configured in `supabase_auth_service.dart`

---

## 🚀 Production Setup

For production deployment:

1. **Frontend URL**: Use your actual domain (e.g., `https://smartnote.example.com`)
2. **Supabase Redirect URL**: Add production URL
3. **Google OAuth**: Configure Google Cloud Console with production domain
4. **Env Variables**: Use environment-specific credentials

---

## 📋 File Changes Made

- ✅ `lib/services/supabase_auth_service.dart` - Added web/mobile platform detection
- ✅ `lib/views/auth/login_screen.dart` - Conditional Google button visibility for web
- ✅ Supabase initialization - Simplified for web OAuth handling

---

## 🐛 Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Unsafe attempt to load URL http://localhost:3000` | Redirect URL mismatch | Add actual port to Supabase config |
| Google button missing | Running on web | Email/password auth works fine |
| CORS error | Wrong domain | Check Supabase redirect URLs match actual app URL |

---

## ✨ Recommended Next Steps

1. **For Development**: Use Email/Password login (currently working ✅)
2. **For Production**: Configure proper Google OAuth with your domain
3. **For Mobile**: Deep links already configured for iOS/Android

---

**Last Updated**: March 15, 2026
