import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/spending_bar_chart.dart';

/// ReportsScreen displays spending statistics and visualizations
/// Shows today's, weekly, and monthly totals along with charts
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Expense> _allExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  /// Loads all expenses from the database
  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    final expenses = await _dbHelper.getAllExpenses();

    setState(() {
      _allExpenses = expenses;
      _isLoading = false;
    });
  }

  /// Calculates total spending for a given date range
  double _calculateTotal(DateTime start, DateTime end) {
    return _allExpenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            expense.date.isBefore(end.add(const Duration(seconds: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Gets today's total spending
  double get todayTotal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _calculateTotal(today, tomorrow);
  }

  /// Gets this week's total spending
  double get weekTotal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _calculateTotal(weekStart, weekEnd);
  }

  /// Gets this month's total spending
  double get monthTotal {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    return _calculateTotal(monthStart, monthEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Category breakdown section
                  _buildSectionHeader('Spending by Category', Icons.pie_chart),
                  const SizedBox(height: 16),
                  _buildCategorySection(),
                  const SizedBox(height: 32),

                  // Spending trends section
                  _buildSectionHeader('Last 7 Days Trend', Icons.bar_chart),
                  const SizedBox(height: 8),
                  _buildTrendsSection(),
                ],
              ),
            ),
    );
  }

  /// Builds the summary cards showing today's, week's, and month's totals
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Today',
            todayTotal,
            Icons.today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'This Week',
            weekTotal,
            Icons.calendar_view_week,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'This Month',
            monthTotal,
            Icons.calendar_month,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Builds a single summary card
  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(2)} GNF',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section header with icon
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// Builds the category breakdown section with pie chart
  Widget _buildCategorySection() {
    return FutureBuilder(
      future: _dbHelper.getTotalByCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final categoryTotals = snapshot.data ?? {};

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryPieChart(categoryTotals: categoryTotals),
          ),
        );
      },
    );
  }

  /// Builds the spending trends section with bar chart
  Widget _buildTrendsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SpendingBarChart(expenses: _allExpenses),
      ),
    );
  }
}
