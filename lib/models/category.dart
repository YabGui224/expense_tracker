import 'package:flutter/material.dart';

/// Expense categories enum
/// Defines the different types of expense categories available in the app
enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  other,
}

/// Extension methods for ExpenseCategory to get display names, icons, and colors
extension ExpenseCategoryExtension on ExpenseCategory {
  /// Returns a user-friendly display name for the category
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Returns an appropriate icon for each category
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  /// Returns a unique color for each category (for charts and visual distinction)
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.travel:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.purple;
      case ExpenseCategory.bills:
        return Colors.red;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}
