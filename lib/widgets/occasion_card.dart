import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/occasion.dart';

class OccasionCard extends StatelessWidget {
  final Occasion occasion;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showRecipientName;

  const OccasionCard({
    super.key,
    required this.occasion,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showRecipientName = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = occasion.daysRemaining();
    final dayLabel = days < 0
        ? 'Passed'
        : days == 0
            ? 'Today'
            : days == 1
                ? 'Tomorrow'
                : 'In $days days';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: scheme.tertiary.withValues(alpha: 0.25),
          foregroundColor: scheme.primary,
          child: const Icon(Icons.event),
        ),
        title: Text(occasion.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          [
            if (showRecipientName && occasion.recipientName != null)
              occasion.recipientName!,
            DateFormat.yMMMd().format(occasion.date),
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dayLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
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
      ),
    );
  }
}
