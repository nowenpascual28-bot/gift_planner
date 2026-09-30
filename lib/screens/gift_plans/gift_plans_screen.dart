import 'package:flutter/material.dart';

import '../../models/gift_plan.dart';
import '../../services/gift_plan_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/gift_plan_card.dart';
import 'gift_plan_form_screen.dart';

class GiftPlansScreen extends StatefulWidget {
  const GiftPlansScreen({super.key});

  @override
  State<GiftPlansScreen> createState() => _GiftPlansScreenState();
}

class _GiftPlansScreenState extends State<GiftPlansScreen> {
  final _service = GiftPlanService();
  List<GiftPlan> _plans = [];
  bool _loading = true;
  String? _error;
  GiftPlanStatus? _statusFilter;

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
      final plans = await _service.getGiftPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load gift plans. $e';
      });
    }
  }

  void _refresh() => _load();

  Future<void> _openForm({GiftPlan? plan}) async {
    final saved = await Navigator.of(context).push<GiftPlan>(
      MaterialPageRoute(builder: (_) => GiftPlanFormScreen(plan: plan)),
    );
    if (!mounted || saved == null) return;
    setState(() {
      final index = _plans.indexWhere((p) => p.id == saved.id);
      if (index == -1) {
        _plans = [saved, ..._plans];
      } else {
        final updated = [..._plans];
        updated[index] = saved;
        _plans = updated;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(plan == null ? 'Gift plan added.' : 'Gift plan updated.')),
    );
  }

  Future<void> _confirmDelete(GiftPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete gift plan?'),
        content: Text('This removes "${plan.giftName}".'),
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
      await _service.deleteGiftPlan(plan.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Gift plans'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          children: [
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () {
                    setState(() => _statusFilter = null);
                  },
                ),
                for (final status in GiftPlanStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: _statusFilter == status,
                    onTap: () {
                      setState(() => _statusFilter = status);
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorStateView(message: _error!, onRetry: _refresh)
                      : Builder(
                          builder: (context) {
                            final plans = _statusFilter == null
                                ? _plans
                                : _plans.where((p) => p.status == _statusFilter).toList();
                            if (plans.isEmpty) {
                              return EmptyStateView(
                                icon: Icons.card_giftcard_outlined,
                                title: 'No gift plans yet',
                                message: 'Create a gift plan to start tracking budget and status.',
                                actionLabel: 'New gift plan',
                                onAction: () => _openForm(),
                              );
                            }
                            return ListView.builder(
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                                  child: GiftPlanCard(
                                    plan: plan,
                                    onTap: () => _openForm(plan: plan),
                                    onEdit: () => _openForm(plan: plan),
                                    onDelete: () => _confirmDelete(plan),
                                  ),
                                );
                              },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
