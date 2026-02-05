# 💰 Expense Tracker

A modern Flutter application for tracking and managing personal expenses with intuitive UI and powerful features.

## ✨ Features

- **Expense Management** - Add, edit, and delete expenses easily
- **Category Organization** - Categorize spending for better insights
- **Budget Tracking** - Set and monitor budgets
- **Visual Reports** - Charts and analytics for spending patterns
- **Data Persistence** - Local storage of all expense data

## 🛠️ Tech Stack

- **Framework:** Flutter 3.10.1+
- **Language:** Dart
- **Design:** Material Design 3
- **Storage:** SQLite (sqflite)
- **State Management:** Provider
- **Preferences:** Shared Preferences

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK (included with Flutter)
- Android Studio or Xcode (for mobile development)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd expense_tracker
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the application
```bash
flutter run
```

## 📱 Available Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔨 Development Commands

### Running the App
```bash
# Run on default device
flutter run

# Run on specific device
flutter devices          # List available devices
flutter run -d <device-id>
```

### Building
```bash
# Android
flutter build apk          # Release APK
flutter build appbundle    # App Bundle for Play Store

# iOS (requires macOS)
flutter build ios

# Web
flutter build web

# Desktop
flutter build windows      # Windows
flutter build macos        # macOS
flutter build linux        # Linux
```

### Maintenance
```bash
# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated

# Clean build
flutter clean && flutter pub get
```

## 📝 Dependencies

Key packages used in this project:
- `sqflite` - SQLite database
- `provider` - State management
- `shared_preferences` - Local preferences
- `fl_chart` - Data visualization
- `flutter_lints` - Lint rules

For complete dependencies, see [pubspec.yaml](pubspec.yaml)

## 📫 Contact

- **LinkedIn:** [Pierre Foromo Guilavogui](https://www.linkedin.com/in/pierre-foromo-guilavogui)

## 📄 License

This project is open source and available under the MIT License.

---

**Happy tracking! 🎉**
