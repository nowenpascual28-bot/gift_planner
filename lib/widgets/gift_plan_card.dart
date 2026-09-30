import 'package:flutter/material.dart';

import '../models/gift_plan.dart';
import 'budget_progress.dart';
import 'status_chip.dart';

class GiftPlanCard extends StatelessWidget {
  final GiftPlan plan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GiftPlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              if (plan.recipientName != null || plan.occasionTitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    [
                      if (plan.recipientName != null) plan.recipientName!,
                      if (plan.occasionTitle != null) plan.occasionTitle!,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              BudgetProgress(budget: plan.budget, spent: plan.spent),
            ],
          ),
        ),
      ),
    );
  }
}
