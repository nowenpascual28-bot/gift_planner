import 'package:flutter/material.dart';

/// A labelled progress bar showing spent-vs-budget, turning error-colored
/// when spending has gone over budget.
class BudgetProgress extends StatelessWidget {
  final double budget;
  final double spent;

  const BudgetProgress({super.key, required this.budget, required this.spent});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overBudget = spent > budget;
    final progress = budget <= 0 ? (spent > 0 ? 1.0 : 0.0) : (spent / budget).clamp(0.0, 1.0);
    final color = overBudget ? scheme.error : scheme.primary;
    final remaining = budget - spent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: scheme.secondary.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₱${spent.toStringAsFixed(2)} of ₱${budget.toStringAsFixed(2)} spent'
          '${overBudget ? '  ·  ₱${(-remaining).toStringAsFixed(2)} over budget' : '  ·  ₱${remaining.toStringAsFixed(2)} left'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: overBudget ? scheme.error : null,
                fontWeight: overBudget ? FontWeight.bold : null,
              ),
        ),
      ],
    );
  }
}
