import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../database/database_helper.dart';
import '../utils/budget_helper.dart';
import '../utils/theme_provider.dart';
import '../widgets/expense_card.dart';
import 'add_edit_expense_screen.dart';

/// HomeScreen displays a beautiful dashboard with statistics
/// Shows category breakdown, budget status, and recent expenses
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Expense> _expenses = [];
  Map<ExpenseCategory, double> _categoryTotals = {};
  double _monthlyBudget = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads all data: expenses, category totals, and budget
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load expenses
    final expenses = await _dbHelper.getAllExpenses();

    // Load category totals for current month
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    final monthExpenses = await _dbHelper.getExpensesByDateRange(monthStart, monthEnd);

    // Calculate totals by category
    final Map<ExpenseCategory, double> categoryTotals = {};
    for (var category in ExpenseCategory.values) {
      categoryTotals[category] = 0.0;
    }
    for (var expense in monthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Load budget
    final budget = await BudgetHelper.getMonthlyBudget();

    setState(() {
      _expenses = expenses;
      _categoryTotals = categoryTotals;
      _monthlyBudget = budget;
      _isLoading = false;
    });
  }

  /// Gets the number of categories that have expenses this month
  int get _activeCategories {
    return _categoryTotals.values.where((total) => total > 0).length;
  }

  /// Gets total spent this month
  double get _totalSpent {
    return _categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
  }

  /// Shows a confirmation dialog before deleting an expense
  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteExpense(expense);
    }
  }

  /// Deletes an expense from the database
  Future<void> _deleteExpense(Expense expense) async {
    await _dbHelper.deleteExpense(expense.id!);
    _loadData(); // Reload all data

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${expense.name} deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navigates to the Add/Edit screen for editing an expense
  Future<void> _editExpense(Expense expense) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    );

    // Reload data if the edit was successful
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Expense Tracker'),
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Changer le thème',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Dashboard Statistics
                      _buildDashboardStats(),
                      const SizedBox(height: 24),

                      // Budget Status by Category
                      _buildCategoryBudgetStatus(),
                      const SizedBox(height: 24),

                      // Recent Expenses Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Expenses',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_expenses.length} total',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recent Expenses List
                      ..._expenses.take(10).map((expense) => ExpenseCard(
                            expense: expense,
                            onEdit: () => _editExpense(expense),
                            onDelete: () => _confirmDelete(expense),
                          )),
                    ],
                  ),
                ),
    );
  }

  /// Builds the dashboard statistics cards
  Widget _buildDashboardStats() {
    return Row(
      children: [
        // Active Categories Card
        Expanded(
          child: _buildStatCard(
            title: 'Categories',
            value: '$_activeCategories',
            subtitle: 'with expenses',
            icon: Icons.category,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        // Total Spent Card
        Expanded(
          child: _buildStatCard(
            title: 'This Month',
            value: '${_totalSpent.toStringAsFixed(0)} GNF',
            subtitle: _monthlyBudget > 0
                ? '${((_totalSpent / _monthlyBudget) * 100).toStringAsFixed(0)}% of budget'
                : 'No budget set',
            icon: Icons.payments,
            color: _monthlyBudget > 0 && _totalSpent > _monthlyBudget
                ? Colors.red
                : Colors.green,
          ),
        ),
      ],
    );
  }

  /// Builds a single stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the budget status section by category
  Widget _buildCategoryBudgetStatus() {
    // Filter categories with expenses
    final activeCategories = _categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (activeCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...activeCategories.map((entry) => _buildCategoryItem(
              category: entry.key,
              amount: entry.value,
              totalSpent: _totalSpent,
            )),
      ],
    );
  }

  /// Builds a single category item with progress bar
  Widget _buildCategoryItem({
    required ExpenseCategory category,
    required double amount,
    required double totalSpent,
  }) {
    final percentage = totalSpent > 0 ? (amount / totalSpent) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Category Name and Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${amount.toStringAsFixed(2)} GNF',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // Percentage
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: category.color,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state when there are no expenses
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
