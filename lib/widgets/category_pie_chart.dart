import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

/// CategoryPieChart displays spending distribution across categories
/// Uses a pie chart to visualize the percentage spent on each category
class CategoryPieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;

  const CategoryPieChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total amount across all categories
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    // If no expenses, show empty state
    if (total == 0) {
      return _buildEmptyState(context);
    }

    // Filter out categories with zero spending
    final nonZeroCategories = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList();

    return Column(
      children: [
        // Pie chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: nonZeroCategories.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage = (amount / total) * 100;

                return PieChartSectionData(
                  color: category.color,
                  value: amount,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Legend showing categories with amounts
        _buildLegend(context, nonZeroCategories, total),
      ],
    );
  }

  /// Builds the legend below the pie chart
  Widget _buildLegend(
    BuildContext context,
    List<MapEntry<ExpenseCategory, double>> categories,
    double total,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: categories.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = (amount / total) * 100;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Category name and amount
            Text(
              '${category.displayName}: ${amount.toStringAsFixed(2)} GNF (${percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Builds the empty state when there are no expenses
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
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
            'Add some expenses to see the breakdown',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
