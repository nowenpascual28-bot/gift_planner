import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/gift_plan.dart';
import '../../services/gift_plan_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/status_chip.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = GiftPlanService();
  late Future<List<GiftPlan>> _future;
  GiftPlanStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _future = _service.getGiftPlans();
  }

  void _refresh() => setState(() => _future = _service.getGiftPlans());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Gift planning history'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          children: [
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _statusFilter == null,
                  onSelected: (_) {
                    setState(() => _statusFilter = null);
                  },
                ),
                for (final status in GiftPlanStatus.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: _statusFilter == status,
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Expanded(
              child: FutureBuilder<List<GiftPlan>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorStateView(
                      message: 'Could not load history. ${snapshot.error}',
                      onRetry: _refresh,
                    );
                  }
                  final allPlans = snapshot.data!;
                  final plans = _statusFilter == null
                      ? allPlans
                      : allPlans
                            .where((p) => p.status == _statusFilter)
                            .toList();
                  if (plans.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.history,
                      title: 'Nothing here yet',
                      message:
                          'Gift plans you create will show up here so you can look back on them.',
                    );
                  }
                  return ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return ListTile(
                        title: Text(plan.giftName),
                        subtitle: Text(
                          [
                            if (plan.recipientName != null) plan.recipientName!,
                            if (plan.occasionTitle != null) plan.occasionTitle!,
                            DateFormat.yMMMd().format(plan.createdAt),
                          ].join(' · '),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusChip(status: plan.status),
                            const SizedBox(height: 4),
                            Text(
                              '₱${plan.spent.toStringAsFixed(2)} / ₱${plan.budget.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
