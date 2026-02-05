import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';
import 'utils/sample_data.dart';
import 'utils/theme_provider.dart';

/// Main entry point of the Smart Expense Tracker app
/// Initializes the app and sets up sample data on first launch
void main() async {
  // Ensure Flutter binding is initialized before running async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sample data on first launch
  await SampleDataHelper.initializeSampleData();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application
/// Sets up themes, routes, and the main screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Smart Expense Tracker',
          debugShowCheckedModeBanner: false,

          // Light theme configuration
          theme: AppTheme.lightTheme,

          // Dark theme configuration
          darkTheme: AppTheme.darkTheme,

          // Use theme mode from provider
          themeMode: themeProvider.themeMode,

          // Home screen with bottom navigation
          home: const MainScreen(),
        );
      },
    );
  }
}
