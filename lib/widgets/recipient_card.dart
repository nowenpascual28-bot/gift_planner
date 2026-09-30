import 'package:flutter/material.dart';

import '../models/recipient.dart';

class RecipientCard extends StatelessWidget {
  final Recipient recipient;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecipientCard({
    super.key,
    required this.recipient,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: 0.15),
          foregroundColor: scheme.primary,
          child: Text(
            recipient.name.isNotEmpty ? recipient.name[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(recipient.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          recipient.relationship.isEmpty
              ? (recipient.interests.isEmpty ? 'No details yet' : recipient.interests)
              : recipient.relationship,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit?.call();
            if (value == 'delete') onDelete?.call();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
