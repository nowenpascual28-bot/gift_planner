import 'package:flutter/material.dart';

import '../models/gift_plan.dart';
import 'budget_progress.dart';
import 'status_chip.dart';

class GiftPlanCard extends StatelessWidget {
  final GiftPlan plan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddSpent;

  const GiftPlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddSpent,
  });

  @override
  Widget build(BuildContext context) {
    final canAddSpent =
        plan.status != GiftPlanStatus.completed &&
        plan.status != GiftPlanStatus.cancelled;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.giftName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip(status: plan.status),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit gift')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              if (plan.recipientName != null || plan.occasionTitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    [
                      if (plan.recipientName != null) plan.recipientName!,
                      if (plan.occasionTitle != null) plan.occasionTitle!,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              BudgetProgress(budget: plan.budget, spent: plan.spent),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spent: ₱${plan.spent.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (canAddSpent && onAddSpent != null)
                    OutlinedButton.icon(
                      onPressed: onAddSpent,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add Spent'),
                    ),
                ],
              ),
              if (plan.isOverBudget) ...[
                const SizedBox(height: 6),
                Text(
                  'Over budget by ₱${plan.remaining.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
