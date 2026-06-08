# Firebase Configuration Guide for SmartGo AI

## Overview

SmartGo AI is now fully integrated with Firebase for authentication and Firestore database. This guide walks you through the setup process.

## What's Configured

✅ Firebase Core initialization
✅ Firebase Authentication (Email/Password & Google Sign-In)
✅ Cloud Firestore for user data persistence
✅ Riverpod providers for auth state management
✅ Automatic navigation based on login state (Splash → Login/Dashboard)

## Project Structure

### Firebase Services
```
lib/
├── config/
│   └── firebase_options.dart        # Firebase configuration (needs your credentials)
├── services/
│   ├── auth_service.dart            # Firebase authentication logic
│   └── firestore_service.dart       # Firestore database operations
└── core/providers/
    └── auth_provider.dart           # Riverpod auth state management
```

### Authentication Screens
- **Splash Screen**: Auto-detects login state, navigates automatically
- **Login Screen**: Email/password + Google Sign-In
- **Signup Screen**: Create account with exam selection
- **Dashboard Screen**: Main app after authentication

## Firebase Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Name it "smartgo-ai"
4. Disable Google Analytics (optional)
5. Create the project

### 2. Update `firebase_options.dart`

Replace the placeholder values in [lib/config/firebase_options.dart](lib/config/firebase_options.dart) with your Firebase credentials:

**For Web:**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  databaseURL: 'https://YOUR_PROJECT_ID.firebaseio.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

Find these values in:
- Firebase Console → Project Settings
- Project Settings → Your apps → Web app configuration

**For Android:**
1. Go to Firebase Console → Project Settings
2. Download `google-services.json`
3. Place in `android/app/` directory

**For iOS:**
1. Go to Firebase Console → Project Settings
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/` directory using Xcode

### 3. Enable Authentication Methods

In Firebase Console:

1. **Email/Password Authentication:**
   - Go to Authentication → Sign-in method
   - Enable Email/Password
   - Click Save

2. **Google Sign-In:**
   - Enable Google
   - Set up OAuth consent screen (if not done)
   - Add authorized redirect URIs
   - Save

### 4. Create Firestore Database

1. Go to Firestore Database
2. Click "Create database"
3. Select "Start in test mode" (for development)
4. Choose region closest to you
5. Create

**Security Rules (for production):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

## Authentication Flow

### Sign Up Process
1. User enters name, email, password, selects exam
2. `SignupScreen` calls `authStateProvider.notifier.signupWithEmail()`
3. Firebase creates user account
4. `SmartGoUser` created and stored in Firestore
5. User automatically logged in and navigated to Dashboard

### Login Process
1. User enters email and password
2. `LoginScreen` calls `authStateProvider.notifier.loginWithEmail()`
3. Firebase authenticates credentials
4. User data fetched from Firestore
5. User navigated to Dashboard

### Google Sign-In Process
1. User clicks "Continue with Google"
2. Google authentication dialog appears
3. If first time: new user created in Firestore with default values
4. User navigated to Dashboard

### Auto Navigation
- **Splash Screen** checks authentication state on app start
- If authenticated → Dashboard
- If not authenticated → Login
- State persists across app launches

## Firestore Data Model

### Users Collection

```
users/
├── {uid}/
│   ├── uid: string              # Firebase user ID
│   ├── name: string             # User's full name
│   ├── email: string            # User's email
│   ├── examType: string         # Selected exam (IELTS, GRE, GMAT)
│   ├── targetScore: number      # Target score for exam
│   ├── studyStreak: number      # Days studied consecutively
│   ├── readinessScore: number   # Percentage (0-100)
│   └── createdAt: timestamp     # Account creation time
```

## Available Methods

### AuthService (lib/services/auth_service.dart)

```dart
// Email/Password
AuthService.signUpWithEmail(email, password)
AuthService.loginWithEmail(email, password)

// Google Sign-In
AuthService.signInWithGoogle()

// Logout
AuthService.logout()

// Profile
AuthService.updateUserProfile(displayName, photoURL)
AuthService.currentUser              // Get current user
AuthService.userStream              // Listen to auth changes
```

### FirestoreService (lib/services/firestore_service.dart)

```dart
// User Operations
FirestoreService.createUser(user)           // Create new user
FirestoreService.getUser(uid)               // Fetch user
FirestoreService.getUserStream(uid)         // Real-time updates
FirestoreService.updateUser(uid, data)      // Update user
FirestoreService.deleteUser(uid)            // Delete user

// Specific Updates
FirestoreService.updateStudyStreak(uid, streak)
FirestoreService.updateReadinessScore(uid, score)
FirestoreService.updateTargetScore(uid, targetScore)
```

### AuthProvider (lib/core/providers/auth_provider.dart)

```dart
// Via Riverpod
final authStateProvider        // Current auth state

// Auth Notifier Methods
signupWithEmail(...)           // Create account
loginWithEmail(...)            // Login with email
signInWithGoogle()             // Login with Google
logout()                       // Logout
checkAuthState()               // Verify login status
```

## Testing

### Test Email/Password Auth
1. Run app: `flutter run -d chrome`
2. Navigate to Signup
3. Create account with test email/password
4. Should see user in Firebase Console → Firestore → users collection
5. Should auto-navigate to Dashboard

### Test Google Sign-In
1. Click "Continue with Google"
2. Sign in with Google account
3. Verify user created in Firestore with Google account info

### Test Persistence
1. Login successfully
2. Close and reopen app
3. Should skip login and go directly to Dashboard

## Troubleshooting

### "Firebase Not Initialized" Error
- Ensure `Firebase.initializeApp()` is called in `main.dart` before `runApp()`
- Check `firebase_options.dart` has correct credentials

### "Google Sign-In Failed"
- Verify Google Sign-In is enabled in Firebase Console
- Check OAuth redirect URIs match your app domain
- For web: ensure localhost:port is added to authorized domains

### "User Not Found in Firestore"
- After signup, manually navigate to Dashboard
- Check Firestore permissions in Security Rules
- Verify user document created with correct UID

### "Auth State Not Persisting"
- Firebase automatically persists login state
- Check that `checkAuthState()` is called in Splash Screen
- Verify no logout calls are preventing persistence

## Security Best Practices

✅ Use HTTPS for all communications (Firebase handles this)
✅ Never expose API keys in frontend code (use Web API Key, not service account key)
✅ Enable Firestore security rules before production
✅ Validate all user input before sending to Firebase
✅ Use environment variables for credentials (optional for web)
✅ Implement rate limiting for auth attempts (Firebase handles this)
✅ Use strong password requirements (enforced in signup)

## Next Steps

1. **Configure your Firebase project** with real credentials
2. **Test authentication flow** end-to-end
3. **Monitor Firestore** for user data creation
4. **Add profile editing** functionality
5. **Implement exam-specific features** in Dashboard
6. **Set up Firestore security rules** before production
7. **Add error handling** for edge cases (network errors, etc.)
8. **Implement email verification** (optional)
9. **Add password reset** functionality
10. **Set up analytics** tracking

## Production Checklist

- [ ] Firebase project created and configured
- [ ] `firebase_options.dart` updated with production credentials
- [ ] Web, Android, iOS credentials properly configured
- [ ] Authentication methods enabled (Email/Password, Google)
- [ ] Firestore database created and initialized
- [ ] Security rules configured for production
- [ ] Test authentication flow end-to-end
- [ ] Verify user data persistence
- [ ] Test on real devices/browsers
- [ ] Set up error logging and monitoring
- [ ] Deploy to production
- [ ] Monitor Firebase usage and costs

## Useful Links

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Setup Guide](https://firebase.flutter.dev/docs/overview)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review Firestore security rules
3. Check authentication status in Firebase Console
4. Review console output for error messages
5. Check Firebase documentation for specific features
