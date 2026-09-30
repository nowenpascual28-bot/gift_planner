import 'package:flutter/material.dart';

import '../../models/occasion.dart';
import '../../models/recipient.dart';
import '../../services/occasion_service.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/occasion_card.dart';
import 'occasion_form_screen.dart';

class OccasionsScreen extends StatefulWidget {
  const OccasionsScreen({super.key});

  @override
  State<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends State<OccasionsScreen> {
  final _occasionService = OccasionService();
  final _recipientService = RecipientService();

  List<Occasion> _occasions = [];
  List<Recipient> _recipients = [];
  bool _loading = true;
  String? _error;
  String? _recipientFilter;

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
      final results = await Future.wait([
        _occasionService.getOccasions(recipientId: _recipientFilter),
        _recipientService.getRecipients(),
      ]);
      if (!mounted) return;
      setState(() {
        _occasions = results[0] as List<Occasion>;
        _recipients = results[1] as List<Recipient>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load occasions. $e';
      });
    }
  }

  void _refresh() => _load();

  Future<void> _openForm({Occasion? occasion}) async {
    final saved = await Navigator.of(context).push<Occasion>(
      MaterialPageRoute(builder: (_) => OccasionFormScreen(occasion: occasion)),
    );
    if (!mounted || saved == null) return;
    setState(() {
      final index = _occasions.indexWhere((o) => o.id == saved.id);
      if (index == -1) {
        _occasions = [..._occasions, saved]
          ..sort((a, b) => a.date.compareTo(b.date));
      } else {
        final updated = [..._occasions];
        updated[index] = saved;
        updated.sort((a, b) => a.date.compareTo(b.date));
        _occasions = updated;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(occasion == null ? 'Occasion added.' : 'Occasion updated.')),
    );
  }

  Future<void> _confirmDelete(Occasion occasion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete occasion?'),
        content: Text('This removes "${occasion.title}".'),
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
    if (confirmed == true) {
      await _occasionService.deleteOccasion(occasion.id);
      if (!mounted) return;
      setState(() {
        _occasions = _occasions.where((o) => o.id != occasion.id).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Occasions'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          children: [
            if (_recipients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space16),
                child: DropdownButtonFormField<String?>(
                  initialValue: _recipientFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by recipient',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All recipients'),
                    ),
                    ..._recipients.map(
                      (r) => DropdownMenuItem<String?>(
                        value: r.id,
                        child: Text(r.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _recipientFilter = value);
                    _load();
                  },
                ),
              ),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorStateView(message: _error!, onRetry: _refresh)
                      : _occasions.isEmpty
                          ? EmptyStateView(
                              icon: Icons.event_outlined,
                              title: 'No occasions yet',
                              message: 'Add a birthday or other date worth remembering.',
                              actionLabel: 'Add occasion',
                              onAction: () => _openForm(),
                            )
                          : ListView.builder(
                              itemCount: _occasions.length,
                              itemBuilder: (context, index) {
                                final occasion = _occasions[index];
                                return OccasionCard(
                                  occasion: occasion,
                                  onTap: () => _openForm(occasion: occasion),
                                  onEdit: () => _openForm(occasion: occasion),
                                  onDelete: () => _confirmDelete(occasion),
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
