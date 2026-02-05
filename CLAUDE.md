# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for tracking expenses. Currently contains the default Flutter counter app template and needs to be developed into a full expense tracking application.

**Tech Stack:**
- Flutter SDK 3.10.1+
- Dart
- Material Design UI

## Development Commands

### Running the Application
```bash
# Run on default device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run with hot reload (enabled by default in debug mode)
# Press 'r' in terminal to hot reload
# Press 'R' in terminal to hot restart
```

### Building
```bash
# Build for Android
flutter build apk          # Build release APK
flutter build appbundle    # Build App Bundle for Play Store

# Build for iOS (requires macOS)
flutter build ios

# Build for Web
flutter build web

# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib/ test/

# Check formatting without making changes
flutter format --set-exit-if-changed lib/ test/
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Add a new package
flutter pub add <package_name>

# Add a dev dependency
flutter pub add --dev <package_name>
```

### Cleaning
```bash
# Clean build artifacts
flutter clean

# Clean and reinstall dependencies
flutter clean && flutter pub get
```

## Project Structure

```
lib/
  main.dart           # Application entry point, contains MyApp and MyHomePage widgets

test/
  widget_test.dart    # Widget tests for the app

analysis_options.yaml # Dart analyzer configuration with flutter_lints
pubspec.yaml         # Project dependencies and metadata
```

## Code Architecture

**Current State:**
- Single-file application (lib/main.dart)
- Default Flutter counter app with StatefulWidget pattern
- Uses Material Design with ColorScheme.fromSeed for theming

**Expected Architecture for Expense Tracker:**
As this project grows into an expense tracker, consider organizing code into:
- `lib/models/` - Data models (Expense, Category, etc.)
- `lib/screens/` or `lib/pages/` - UI screens/pages
- `lib/widgets/` - Reusable widget components
- `lib/services/` - Business logic and data services
- `lib/utils/` - Helper functions and constants

## Flutter-Specific Notes

- The project uses `flutter_lints` package for recommended linting rules
- Hot reload is available during development (save files or press 'r')
- Hot restart clears state (press 'R')
- Material Design 3 theming is configured via ColorScheme
- The app supports multiple platforms: Android, iOS, Web, Windows, macOS, Linux
