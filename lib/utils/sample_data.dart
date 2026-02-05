import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../models/category.dart';

/// SampleDataHelper manages the initialization of sample expenses
/// on first launch to help users test the app's features
class SampleDataHelper {
  static const String _firstLaunchKey = 'is_first_launch';

  /// Checks if this is the first launch and adds sample data if it is
  static Future<void> initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      await _addSampleExpenses();
      await prefs.setBool(_firstLaunchKey, false);
    }
  }

  /// Adds sample expenses to the database
  /// Creates a variety of expenses across different categories and dates
  /// to demonstrate all features of the app
  static Future<void> _addSampleExpenses() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    // Sample expenses for different categories and dates
    final sampleExpenses = [
      // Today's expenses
      Expense(
        name: 'Lunch at restaurant',
        amount: 25.50,
        date: now,
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Coffee',
        amount: 5.00,
        date: now,
        category: ExpenseCategory.food,
      ),

      // Yesterday
      Expense(
        name: 'Uber ride',
        amount: 15.75,
        date: now.subtract(const Duration(days: 1)),
        category: ExpenseCategory.travel,
      ),
      Expense(
        name: 'Groceries',
        amount: 87.30,
        date: now.subtract(const Duration(days: 1)),
        category: ExpenseCategory.food,
      ),

      // 2 days ago
      Expense(
        name: 'New shoes',
        amount: 89.99,
        date: now.subtract(const Duration(days: 2)),
        category: ExpenseCategory.shopping,
      ),
      Expense(
        name: 'Electricity bill',
        amount: 125.00,
        date: now.subtract(const Duration(days: 2)),
        category: ExpenseCategory.bills,
      ),

      // 3 days ago
      Expense(
        name: 'Movie tickets',
        amount: 35.00,
        date: now.subtract(const Duration(days: 3)),
        category: ExpenseCategory.other,
      ),
      Expense(
        name: 'Gas station',
        amount: 45.20,
        date: now.subtract(const Duration(days: 3)),
        category: ExpenseCategory.travel,
      ),

      // 4 days ago
      Expense(
        name: 'Dinner',
        amount: 58.40,
        date: now.subtract(const Duration(days: 4)),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Books',
        amount: 32.99,
        date: now.subtract(const Duration(days: 4)),
        category: ExpenseCategory.shopping,
      ),

      // 5 days ago
      Expense(
        name: 'Internet bill',
        amount: 60.00,
        date: now.subtract(const Duration(days: 5)),
        category: ExpenseCategory.bills,
      ),
      Expense(
        name: 'Taxi',
        amount: 12.50,
        date: now.subtract(const Duration(days: 5)),
        category: ExpenseCategory.travel,
      ),

      // 6 days ago
      Expense(
        name: 'Breakfast',
        amount: 18.75,
        date: now.subtract(const Duration(days: 6)),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Clothes shopping',
        amount: 145.00,
        date: now.subtract(const Duration(days: 6)),
        category: ExpenseCategory.shopping,
      ),

      // Last week
      Expense(
        name: 'Phone bill',
        amount: 50.00,
        date: now.subtract(const Duration(days: 7)),
        category: ExpenseCategory.bills,
      ),
    ];

    // Insert all sample expenses into the database
    for (var expense in sampleExpenses) {
      await db.createExpense(expense);
    }
  }
}
