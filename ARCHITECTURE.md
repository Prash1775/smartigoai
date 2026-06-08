# SmartGo AI - Flutter Architecture Guide

## Overview

SmartGo AI is a production-ready Flutter application built with a feature-first architecture, using Riverpod for state management and GoRouter for navigation.

## Project Architecture

### Feature-First Structure

```
lib/
├── main.dart                          # App entry point
├── config/                            # Global configuration
│   ├── routes/
│   │   └── app_router.dart           # GoRouter setup and route definitions
│   └── theme/
│       └── app_theme.dart            # Material 3 theme configuration
├── core/                              # Shared utilities and models
│   ├── constants/
│   │   └── exam_types.dart           # Exam type enums and extensions
│   ├── models/
│   │   └── user_model.dart           # User data model for Firestore
│   └── providers/
│       ├── app_provider.dart         # App-level state (theme, locale)
│       └── auth_provider.dart        # Authentication state with Riverpod
└── features/                          # Feature-specific code
    ├── splash/                        # Splash screen
    │   ├── screens/
    │   │   └── splash_screen.dart
    │   └── providers/
    │       └── splash_provider.dart
    ├── auth/                          # Authentication (login/signup)
    │   ├── screens/
    │   │   ├── login_screen.dart
    │   │   └── signup_screen.dart
    │   └── providers/
    │       └── auth_provider.dart
    ├── exam_selection/                # Exam selection
    │   ├── screens/
    │   │   └── exam_selection_screen.dart
    │   └── providers/
    │       └── exam_provider.dart
    └── dashboard/                     # Main dashboard
        ├── screens/
        │   └── dashboard_screen.dart
        ├── widgets/
        │   ├── study_streak_card.dart
        │   ├── readiness_score_card.dart
        │   ├── today_goal_card.dart
        │   └── recent_test_score_card.dart
        └── providers/
            └── dashboard_provider.dart
```

## Key Technologies

- **Flutter 3.44.1+**: Cross-platform UI framework
- **Riverpod 2.4.0+**: State management and dependency injection
- **GoRouter 13.0.0+**: Type-safe routing
- **Material 3**: Modern UI design system
- **Firebase**: Authentication and Firestore (configured)
- **Google Sign-In**: OAuth authentication

## Screens

### 1. Splash Screen
- Display duration: 2 seconds
- Auto-navigates to login after splash
- Shows SmartGo AI branding

### 2. Login Screen
- Email/password authentication
- Google Sign-In button
- Responsive design (mobile, tablet, web)
- Link to signup screen

### 3. Signup Screen
- Registration with name, email, password
- Form validation
- Redirects to exam selection after signup

### 4. Exam Selection Screen
- Choose between IELTS, GRE, GMAT
- Visual exam cards with icons
- Target score presets per exam

### 5. Dashboard Screen
- Welcome card with personalized greeting
- Study Streak tracking (days)
- Readiness Score (percentage)
- Today's Goal tracking
- Recent Test Score display
- Bottom navigation for app features

## Bottom Navigation (6 destinations)

1. **Home** - Dashboard with stats and goals
2. **Learn** - Study materials and lessons (placeholder)
3. **Practice** - Practice questions and tests (placeholder)
4. **Progress** - Performance analytics and insights (placeholder)
5. **AI Coach** - AI-powered assistance (placeholder)
6. **Profile** - User account and settings (placeholder)

## State Management (Riverpod)

### Providers

- **`authStateProvider`**: Manages user authentication state
- **`appStateProvider`**: Global app settings (theme, locale)
- **`selectedExamProvider`**: Tracks selected exam type
- **`dashboardStatsProvider`**: Fetches and caches dashboard metrics
- **`splashDelayProvider`**: Splash screen timing
- **`goRouterProvider`**: Router configuration

## Navigation Routes

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | Splash | Initial app load |
| `/login` | Login | User authentication |
| `/signup` | Signup | New account creation |
| `/exam-selection` | Exam Selection | Choose exam type |
| `/dashboard` | Dashboard | Main app screen |
| `/learn` | Learn | Study materials |
| `/practice` | Practice | Practice tests |
| `/progress` | Progress | Analytics |
| `/ai-coach` | AI Coach | Assistant |
| `/profile` | Profile | User settings |

## Supported Exams

- **IELTS**: International English Language Testing System (Target: 7)
- **GRE**: Graduate Record Examination (Target: 320)
- **GMAT**: Graduate Management Admission Test (Target: 700)

## Getting Started

### Prerequisites
- Flutter SDK 3.44.1+
- Dart 3.12.1+
- VS Code or Android Studio

### Installation

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Configure Firebase** (optional, for full functionality):
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)

3. **Run the app**:
```bash
# Run on web (recommended for development)
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## Material 3 Features

- Custom color scheme with primary and secondary colors
- Rounded AppBar with Material 3 styling
- Modern card designs with elevation
- Responsive layouts for all screen sizes
- Support for dark mode (configured, not enabled by default)

## Next Steps

### TODO (Production Ready):

- [ ] Connect Firebase Authentication
- [ ] Implement Google Sign-In integration
- [ ] Add Firestore user data persistence
- [ ] Implement exam-specific features
- [ ] Create Learn screen with study materials
- [ ] Create Practice screen with mock tests
- [ ] Create Progress screen with analytics
- [ ] Create AI Coach screen with chat interface
- [ ] Create Profile screen with settings
- [ ] Add localization support (i18n)
- [ ] Add error handling and logging
- [ ] Implement notification system
- [ ] Add unit and integration tests
- [ ] Setup CI/CD pipeline

## Best Practices Implemented

✅ Feature-first architecture for scalability
✅ Riverpod for reactive state management
✅ GoRouter for type-safe navigation
✅ Material 3 for modern UI/UX
✅ Separation of concerns (screens, providers, widgets)
✅ Reusable components (dashboard cards)
✅ Responsive design for multiple platforms
✅ Clean code structure with clear naming conventions
✅ Provider-based dependency injection

## Troubleshooting

### Common Issues

**1. Go Router not navigating**
- Ensure `goRouterProvider` is wrapped in `ProviderScope`
- Check route paths match exactly

**2. Provider not updating**
- Use `ref.refresh()` to manually refresh
- Ensure provider is returning correct state

**3. Theme not applying**
- Restart the app after theme changes
- Check Material 3 is enabled in theme

## Contributing

When adding new features:
1. Create new feature folder in `lib/features/`
2. Follow the pattern: `screens/`, `providers/`, `widgets/`
3. Add routes to `app_router.dart`
4. Use Riverpod providers for state
5. Leverage Material 3 components

## License

Proprietary - SmartGo AI
