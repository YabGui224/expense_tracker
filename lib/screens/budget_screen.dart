import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../utils/budget_helper.dart';

/// BudgetScreen displays monthly budget information
/// Shows budget amount, spending, remaining balance, and progress
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  double _monthlyBudget = 0.0;
  double _totalSpent = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  /// Loads the budget and calculates current month's spending
  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    // Load the saved monthly budget
    final budget = await BudgetHelper.getMonthlyBudget();

    // Calculate total spent this month
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final expenses = await _dbHelper.getExpensesByDateRange(monthStart, monthEnd);
    final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    setState(() {
      _monthlyBudget = budget;
      _totalSpent = total;
      _isLoading = false;
    });
  }

  /// Shows a dialog to update the monthly budget
  Future<void> _showUpdateBudgetDialog() async {
    final controller = TextEditingController(
      text: _monthlyBudget > 0 ? _monthlyBudget.toStringAsFixed(0) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            suffixText: 'GNF',
            hintText: 'e.g., 1000',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await BudgetHelper.setMonthlyBudget(result);
      _loadBudgetData(); // Reload to show updated budget

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget set to ${result.toStringAsFixed(2)} GNF'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Calculates the remaining budget
  double get _remaining => _monthlyBudget - _totalSpent;

  /// Calculates the budget usage percentage (0.0 to 1.0+)
  double get _budgetProgress {
    if (_monthlyBudget <= 0) return 0.0;
    return _totalSpent / _monthlyBudget;
  }

  /// Checks if the budget has been exceeded
  bool get _isOverBudget => _totalSpent > _monthlyBudget && _monthlyBudget > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
        actions: [
          // Icon button to update budget
          if (_monthlyBudget > 0)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: _showUpdateBudgetDialog,
              tooltip: 'Update Budget',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBudgetData,
              child: _monthlyBudget <= 0
                  ? _buildNoBudgetState()
                  : _buildBudgetView(),
            ),
    );
  }

  /// Builds the view when no budget is set
  Widget _buildNoBudgetState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Budget Set',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Set a monthly budget to track your spending and stay on target',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showUpdateBudgetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Set Budget'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main budget view with spending information
  Widget _buildBudgetView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Circular progress indicator
        _buildCircularProgress(),
        const SizedBox(height: 32),

        // Budget summary cards
        _buildSummaryCards(),
        const SizedBox(height: 24),

        // Warning message if over budget
        if (_isOverBudget) _buildOverBudgetWarning(),
        if (_isOverBudget) const SizedBox(height: 24),
      ],
    );
  }

  /// Builds the circular progress indicator showing budget usage
  Widget _buildCircularProgress() {
    // Clamp progress between 0 and 1 for display (actual value can be > 1)
    final displayProgress = _budgetProgress.clamp(0.0, 1.0);

    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isOverBudget
                  ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              _isOverBudget
                  ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isOverBudget
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: displayProgress,
                strokeWidth: 18,
                strokeCap: StrokeCap.round,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                color: _isOverBudget
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            // Center text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_budgetProgress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isOverBudget
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_isOverBudget
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isOverBudget ? 'Over Budget' : 'Used',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isOverBudget
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the summary cards showing budget, spent, and remaining
  Widget _buildSummaryCards() {
    return Column(
      children: [
        // Budget Amount Card
        _buildInfoCard(
          'Monthly Budget',
          '${_monthlyBudget.toStringAsFixed(2)} GNF',
          Icons.account_balance_wallet,
          Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),

        // Spent and Remaining in a row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Spent',
                '${_totalSpent.toStringAsFixed(2)} GNF',
                Icons.shopping_cart,
                _isOverBudget
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Remaining',
                '${_remaining.abs().toStringAsFixed(2)} GNF',
                _remaining >= 0 ? Icons.savings : Icons.warning,
                _remaining >= 0
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single info card
  Widget _buildInfoCard(String title, String amount, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 20,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the warning message when budget is exceeded
  Widget _buildOverBudgetWarning() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.errorContainer,
            Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Exceeded!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You\'ve spent ${(_totalSpent - _monthlyBudget).toStringAsFixed(2)} GNF over your budget this month.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
