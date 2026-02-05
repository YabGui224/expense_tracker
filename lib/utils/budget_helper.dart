import 'package:shared_preferences/shared_preferences.dart';

/// BudgetHelper manages the monthly budget amount
/// Uses SharedPreferences to persist the budget across app sessions
class BudgetHelper {
  // Key for storing budget in SharedPreferences
  static const String _budgetKey = 'monthly_budget';

  /// Gets the saved monthly budget amount
  /// Returns 0.0 if no budget has been set
  static Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 0.0;
  }

  /// Saves the monthly budget amount
  /// Takes a budget amount and stores it in SharedPreferences
  static Future<void> setMonthlyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  /// Checks if a budget has been set
  /// Returns true if a budget amount exists (greater than 0)
  static Future<bool> hasBudget() async {
    final budget = await getMonthlyBudget();
    return budget > 0;
  }

  /// Clears the saved budget (sets it to 0)
  /// Useful for resetting the budget
  static Future<void> clearBudget() async {
    await setMonthlyBudget(0.0);
  }
}
