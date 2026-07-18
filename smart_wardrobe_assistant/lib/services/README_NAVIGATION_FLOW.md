# Smart Wardrobe Assistant - Navigation Flow Documentation

## Overview
This document explains how the professional navigation and onboarding system works in the Smart Wardrobe Assistant app.

## Navigation Flow Diagram

```
┌─────────────────┐
│  App Launches   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Splash Screen   │ (3 seconds)
└────────┬────────┘
         │
         ▼
    ┌────────────────────────────────────┐
    │ AppInitializationService           │
    │ determines which screen to show    │
    └────────┬───────────────────────────┘
             │
    ┌────────┴────────┐
    │  Decision Tree  │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────────────┐
    │ Is user logged in?      │
    └────────┬────────────────┘
             │
      ┌──────┴──────┐
      │             │
     YES           NO
      │             │
      ▼             ▼
  ┌──────┐   ┌──────────────────────────┐
  │ HOME │   │ Has completed onboarding? │
  └──────┘   └──────┬───────────────────┘
                    │
             ┌──────┴──────┐
             │             │
            YES           NO
             │             │
             ▼             ▼
        ┌────────┐   ┌──────────────┐
        │ LOGIN  │   │ ONBOARDING   │
        └────────┘   └──────────────┘
```

## File Structure

```
lib/
├── services/
│   ├── onboarding_service.dart           # Manages onboarding completion status
│   ├── app_initialization_service.dart   # Determines initial route
│   └── auth_service.dart                 # Handles authentication
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart            # Entry point, uses initialization service
│   ├── onboarding/
│   │   └── onboarding_screen.dart        # Marks onboarding as completed
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       └── home_dashboard_screen.dart
```

## Services Explanation

### 1. OnboardingService (`onboarding_service.dart`)
**Purpose:** Manages onboarding completion status using SharedPreferences

**Key Methods:**
- `hasCompletedOnboarding()` - Returns true if user has finished onboarding before
- `completeOnboarding()` - Marks onboarding as completed (called when user finishes onboarding)
- `resetOnboarding()` - Resets status (for testing only)

**Storage:**
- Uses SharedPreferences key: `has_completed_onboarding`
- Value: `true` (completed) or `false` (not completed)

### 2. AppInitializationService (`app_initialization_service.dart`)
**Purpose:** Determines which screen to show on app startup

**Decision Logic:**
1. Check if user is logged in (highest priority)
   - YES → Navigate to Home
2. Check if user has completed onboarding
   - YES → Navigate to Login
   - NO → Navigate to Onboarding

**Key Methods:**
- `determineInitialRoute()` - Returns enum: InitialRoute.onboarding/login/home
- `getInitialRouteName()` - Returns route string: '/onboarding', '/login', or '/home'
- `getInitializationStatus()` - Returns detailed status (for debugging)

### 3. AuthService (`auth_service.dart`)
**Purpose:** Handles user authentication and session management

**Key Methods:**
- `isLoggedIn()` - Checks if user is currently logged in
- `getCurrentUser()` - Returns current logged-in user
- `login()` - Logs in user and saves session
- `logout()` - Clears session

## Screen Modifications

### 1. SplashScreen (`splash_screen.dart`)
**What Changed:**
- Removed hardcoded navigation to `/onboarding`
- Added `_initializeApp()` method that:
  1. Shows splash screen for 3 seconds
  2. Calls `AppInitializationService` to determine route
  3. Navigates to the correct screen based on user status

**Before:**
```dart
Timer(const Duration(seconds: 3), () {
  Navigator.of(context).pushReplacementNamed('/onboarding');
});
```

**After:**
```dart
Future<void> _initializeApp() async {
  await Future.delayed(const Duration(seconds: 3));
  final routeName = await AppInitializationService.instance.getInitialRouteName();
  if (mounted) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }
}
```

### 2. OnboardingScreen (`onboarding_screen.dart`)
**What Changed:**
- Added `_completeOnboarding()` method
- Modified `_nextPage()` to call `OnboardingService.instance.completeOnboarding()`
- Modified `_skipToLogin()` to call `_completeOnboarding()`
- Added error handling for failed saves

**Key Addition:**
```dart
Future<void> _completeOnboarding() async {
  await OnboardingService.instance.completeOnboarding();
  Navigator.of(context).pushReplacementNamed('/login');
}
```

## Navigation Scenarios

### Scenario 1: First-Time User
```
1. User installs app
2. Splash Screen shows
3. AppInitializationService checks:
   - isLoggedIn = false
   - hasCompletedOnboarding = false
4. Navigate to Onboarding
5. User completes onboarding
6. OnboardingService saves: has_completed_onboarding = true
7. Navigate to Login
```

### Scenario 2: Returning User (Not Logged In)
```
1. User opens app
2. Splash Screen shows
3. AppInitializationService checks:
   - isLoggedIn = false
   - hasCompletedOnboarding = true
4. Navigate directly to Login (skip onboarding)
```

### Scenario 3: Logged-In User
```
1. User opens app
2. Splash Screen shows
3. AppInitializationService checks:
   - isLoggedIn = true
4. Navigate directly to Home (skip onboarding and login)
```

## Data Storage

### SharedPreferences Keys
| Key | Type | Purpose |
|-----|------|---------|
| `has_completed_onboarding` | bool | Tracks if user has finished onboarding |
| `is_logged_in` | bool | Tracks if user is currently logged in |
| `user_id` | int | Stores logged-in user's ID |

## Testing the Implementation

### Test Case 1: Fresh Install
1. Delete app from emulator
2. Reinstall app
3. **Expected:** Onboarding screens appear
4. Complete onboarding
5. **Expected:** Navigate to Login
6. Close and reopen app
7. **Expected:** Login screen appears (onboarding skipped)

### Test Case 2: Logged-In User
1. Login to app
2. Close app completely
3. Reopen app
4. **Expected:** Home screen appears directly (skip onboarding and login)

### Test Case 3: Logout
1. Login to app
2. Navigate to profile and logout
3. Close and reopen app
4. **Expected:** Login screen appears (onboarding already completed)

## Best Practices Followed

### 1. Separation of Concerns
- UI logic in screens
- Business logic in services
- No navigation logic hardcoded in widgets

### 2. Singleton Pattern
- Services use singleton pattern
- Single source of truth for data
- Prevents multiple instances

### 3. Clean Architecture
```
Presentation Layer (Screens)
        ↓
Business Logic Layer (Services)
        ↓
Data Layer (SharedPreferences, SQLite)
```

### 4. Null Safety
- All methods use null-safe Dart syntax
- Proper error handling with try-catch
- Safe navigation checks (`if (mounted)`)

### 5. Provider Pattern
- AuthProvider manages authentication state
- Integrated with existing Provider setup
- No breaking changes to existing code

### 6. Documentation
- Every method has clear documentation
- Usage examples included
- Decision flow explained

## Error Handling

### If OnboardingService Fails
- Defaults to showing onboarding (safe fallback)
- Logs error to console
- Shows SnackBar to user (optional)

### If AuthService Fails
- Defaults to showing onboarding
- Logs error to console
- User can still access app

### If Navigation Fails
- Checks `mounted` state before navigation
- Prevents navigation on disposed widgets
- Graceful error handling

## Future Enhancements

### Potential Improvements:
1. Add analytics to track onboarding completion rate
2. Add A/B testing for different onboarding flows
3. Add onboarding progress persistence (resume where left off)
4. Add skip onboarding option with confirmation dialog
5. Add animated transitions between screens

## Debugging

### Enable Debug Logs
The implementation includes debug logs:
```
App Initialization Status:
  - Is Logged In: false
  - Has Completed Onboarding: false
  - Initial Route: InitialRoute.onboarding
  - Route Name: /onboarding
```

### Reset Onboarding (for Testing)
```dart
// WARNING: Only for testing!
await OnboardingService.instance.resetOnboarding();
await AuthService.instance.logout();
// Restart app
```

## Conclusion

This implementation provides a professional, user-friendly navigation experience that:
- Shows onboarding only once
- Remembers logged-in users
- Follows Flutter best practices
- Uses clean architecture
- Is maintainable and testable
- Provides clear error handling
