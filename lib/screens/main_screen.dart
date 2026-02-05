import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_edit_expense_screen.dart';
import 'reports_screen.dart';
import 'budget_screen.dart';

/// MainScreen is the root screen of the app
/// Contains bottom navigation to switch between Home, Reports, and Budget
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // The three main screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportsScreen(),
    const BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Floating Action Button - Positioned at bottom right for better visibility
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
      // Bottom Navigation Bar - Responsive and Elegant Design
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home tab
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                // Reports tab
                _buildNavItem(
                  index: 1,
                  icon: Icons.pie_chart_outline,
                  activeIcon: Icons.pie_chart,
                  label: 'Reports',
                ),
                // Budget tab
                _buildNavItem(
                  index: 2,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Budget',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a navigation item with icon, label, and colored background for active state
  /// Responsive design that adapts to different screen sizes
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              // Add colored background for active tab
              color: isActive
                  ? colorScheme.primaryContainer.withOpacity(0.7)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handles bottom navigation tab changes
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Navigates to the Add Expense screen
  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditExpenseScreen(),
      ),
    );

    // Refresh the current screen if an expense was added
    // This ensures the budget updates when new expenses are added
    if (result == true && mounted) {
      setState(() {
        // This will trigger a rebuild and refresh the data in all screens
      });
    }
  }
}
