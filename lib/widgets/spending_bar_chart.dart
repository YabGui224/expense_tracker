import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

/// SpendingBarChart displays daily spending for the last 7 days
/// Uses a bar chart to show trends in spending over time
class SpendingBarChart extends StatelessWidget {
  final List<Expense> expenses;

  const SpendingBarChart({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate spending for the last 7 days
    final dailySpending = _calculateDailySpending();

    // If no expenses, show empty state
    if (dailySpending.isEmpty || dailySpending.values.every((v) => v == 0)) {
      return _buildEmptyState(context);
    }

    // Find the maximum spending to scale the chart
    final maxSpending = dailySpending.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSpending * 1.2, // Add 20% padding at top
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = _getDayLabel(6 - groupIndex);
                      return BarTooltipItem(
                        '$day\n${rod.toY.toStringAsFixed(2)} GNF',
                        TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getDayLabel(6 - value.toInt()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final daysAgo = 6 - index;
                  final amount = dailySpending[daysAgo] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: Theme.of(context).colorScheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Calculates total spending for each of the last 7 days
  Map<int, double> _calculateDailySpending() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<int, double> dailySpending = {};

    // Initialize all 7 days with 0
    for (int i = 0; i < 7; i++) {
      dailySpending[i] = 0;
    }

    // Sum up expenses for each day
    for (var expense in expenses) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final daysAgo = today.difference(expenseDate).inDays;

      if (daysAgo >= 0 && daysAgo < 7) {
        dailySpending[daysAgo] = (dailySpending[daysAgo] ?? 0) + expense.amount;
      }
    }

    return dailySpending;
  }

  /// Returns a short label for the day (e.g., "Mon", "Tue", or "Today")
  String _getDayLabel(int daysAgo) {
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yest.';

    final date = DateTime.now().subtract(Duration(days: daysAgo));
    final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekday[date.weekday % 7];
  }

  /// Builds the empty state when there are no expenses
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No data to display',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see spending trends',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
