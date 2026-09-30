import 'package:flutter/material.dart';

import '../../models/recipient.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/recipient_card.dart';
import 'recipient_details_screen.dart';
import 'recipient_form_screen.dart';

class RecipientListScreen extends StatefulWidget {
  const RecipientListScreen({super.key});

  @override
  State<RecipientListScreen> createState() => _RecipientListScreenState();
}

class _RecipientListScreenState extends State<RecipientListScreen> {
  final _service = RecipientService();
  List<Recipient> _recipients = [];
  String _search = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final recipients = await _service.getRecipients();
      if (!mounted) return;
      setState(() {
        _recipients = recipients;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load recipients. $e';
      });
    }
  }

  Future<void> _openForm({Recipient? recipient}) async {
    final saved = await Navigator.of(context).push<Recipient>(
      MaterialPageRoute(
        builder: (_) => RecipientFormScreen(recipient: recipient),
      ),
    );
    if (!mounted || saved == null) return;

    setState(() {
      final index = _recipients.indexWhere((r) => r.id == saved.id);
      if (index == -1) {
        _recipients = [..._recipients, saved]
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        final updated = [..._recipients];
        updated[index] = saved;
        updated.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _recipients = updated;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(recipient == null ? 'Recipient added.' : 'Recipient updated.')),
    );
  }

  Future<void> _confirmDelete(Recipient recipient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipient?'),
        content: Text(
          'This removes ${recipient.name} along with their occasions and gift plans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deleteRecipient(recipient.id);
      if (!mounted) return;
      setState(() {
        _recipients = _recipients.where((r) => r.id != recipient.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipient deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete recipient. $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.trim().toLowerCase();
    final recipients = query.isEmpty
        ? _recipients
        : _recipients
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      appBar: const AppTopBar(title: 'Recipients'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          children: [
            AppSearchBar(
              hint: 'Search recipients',
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: AppSpacing.space16),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorStateView(message: _error!, onRetry: _load)
                      : recipients.isEmpty
                          ? EmptyStateView(
                              icon: Icons.people_outline,
                              title: _search.isEmpty ? 'No recipients yet' : 'No matches found',
                              message: _search.isEmpty
                                  ? 'Add your first recipient to start planning gifts.'
                                  : 'Try a different name.',
                              actionLabel: _search.isEmpty ? 'Add recipient' : null,
                              onAction: _search.isEmpty ? () => _openForm() : null,
                            )
                          : ListView.builder(
                              itemCount: recipients.length,
                              itemBuilder: (context, index) {
                                final recipient = recipients[index];
                                return RecipientCard(
                                  recipient: recipient,
                                  onTap: () async {
                                    await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => RecipientDetailsScreen(
                                          recipientId: recipient.id,
                                        ),
                                      ),
                                    );
                                    _load();
                                  },
                                  onEdit: () => _openForm(recipient: recipient),
                                  onDelete: () => _confirmDelete(recipient),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
