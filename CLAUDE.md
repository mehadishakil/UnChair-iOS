# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UnChair is an iOS app designed to combat sedentary lifestyles by providing comprehensive health tracking, break reminders, and exercise routines. The app integrates with HealthKit, Firebase authentication, and includes subscription management through RevenueCat.

## Build Commands

```bash
# Build the project
xcodebuild -project UnChair-iOS.xcodeproj -scheme "Copy of UnChair-iOS" -configuration Debug build

# Build for release
xcodebuild -project UnChair-iOS.xcodeproj -scheme "Copy of UnChair-iOS" -configuration Release build

# Clean build folder
xcodebuild clean -project UnChair-iOS.xcodeproj -scheme "Copy of UnChair-iOS"
```

## Architecture

### Core Structure
The app follows an MVVM pattern with SwiftUI and is organized into core modules:

- **Authentication**: Firebase Auth integration with Google Sign-In, email verification, password reset
- **Home**: Main dashboard with health metrics, break reminders, and tracking
- **Break**: Exercise routines categorized by duration (Quick, Short, Medium, Long)
- **Profile**: User settings, analytics, subscription management
- **OnBoarding**: Initial user setup flow
- **Models**: Core data models and persistence

### Key Components

#### Main App Flow
- `UnChair_iOSApp.swift`: Main app entry point with scene management
- `MainView.swift`: Root navigation between authenticated/unauthenticated states
- `ContentView.swift`: Primary content container

#### State Management
- `BreakManager`: Singleton managing break timing and notifications
- `HealthDataViewModel`: HealthKit integration for steps, sleep, water tracking
- `AuthController`: Firebase authentication state management
- `NotificationManager`: Local notification scheduling and handling

#### Data Persistence
- SwiftData for local storage (`UserData`, chart models)
- Firebase Firestore for cloud data synchronization
- HealthKit for health metrics

### Dependencies

Key Swift Package Manager dependencies:
- Firebase iOS SDK (11.5.0) - Authentication, Firestore, Storage
- RevenueCat (5.24.0) - Subscription management
- GoogleSignIn (8.0.0) - OAuth authentication
- Lottie (4.5.2) - Animations

## Development Notes

### Notifications
The app uses local notifications for break reminders. Permission is requested during onboarding and managed through `NotificationManager.shared`.

### Health Integration
HealthKit integration requires specific entitlements and privacy descriptions. Health data is accessed through `HealthDataService` and cached locally.

### Subscription Model
Premium features are managed through RevenueCat with StoreKit integration. Configuration is stored in `UnChair_StoreKitConfig.storekit`.

### Theme System
The app supports light/dark mode through `ThemeManager.swift` and uses custom color sets defined in Assets.xcassets.

## File Structure Highlights

- `Core/Authentication/`: Firebase auth, Google Sign-In, user management
- `Core/Home/ViewModels/`: Business logic for health tracking and break management  
- `Core/Home/Views/`: UI components for dashboard and health metrics
- `Core/Break/Views/`: Exercise routine UI and break management
- `Core/Profile/ViewGroups/Analytics/`: Data visualization and charts
- `Assets.xcassets/`: Theme colors, exercise images, app icons