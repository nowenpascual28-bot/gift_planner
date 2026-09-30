import 'package:flutter/material.dart';

import '../../models/gift_plan.dart';
import '../../models/occasion.dart';
import '../../services/auth_service.dart';
import '../../services/gift_plan_service.dart';
import '../../services/occasion_service.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/occasion_card.dart';
import '../../widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onSeeRecipients;
  final VoidCallback onSeeOccasions;
  final VoidCallback onSeeGiftPlans;
  final VoidCallback onSeeHistory;

  const DashboardScreen({
    super.key,
    required this.onSeeRecipients,
    required this.onSeeOccasions,
    required this.onSeeGiftPlans,
    required this.onSeeHistory,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _occasionService = OccasionService();
  final _recipientService = RecipientService();
  final _giftPlanService = GiftPlanService();
  final _auth = AuthService();

  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final results = await Future.wait([
      _occasionService.getUpcoming(limit: 5),
      _recipientService.getRecipients(),
      _giftPlanService.getGiftPlans(),
    ]);
    return _DashboardData(
      upcoming: results[0] as List<Occasion>,
      recipientCount: (results[1] as List).length,
      activePlans: (results[2] as List<GiftPlan>)
          .where((p) => p.status != GiftPlanStatus.completed && p.status != GiftPlanStatus.cancelled)
          .toList(),
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Planner'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ErrorStateView(
                message: 'Could not load your dashboard. ${snapshot.error}',
                onRetry: _refresh,
              );
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        label: 'Recipients',
                        value: '${data.recipientCount}',
                        onTap: widget.onSeeRecipients,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.card_giftcard,
                        label: 'Active plans',
                        value: '${data.activePlans.length}',
                        onTap: widget.onSeeGiftPlans,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),
                SectionHeader(
                  title: 'Upcoming occasions',
                  actionLabel: 'See all',
                  onAction: widget.onSeeOccasions,
                ),
                const SizedBox(height: AppSpacing.space8),
                if (data.upcoming.isEmpty)
                  const EmptyStateView(
                    icon: Icons.event_outlined,
                    title: 'No occasions yet',
                    message: 'Add a recipient and an occasion to see it here.',
                  )
                else
                  ...data.upcoming.map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                      child: OccasionCard(occasion: o),
                    ),
                  ),
                const SizedBox(height: AppSpacing.space24),
                SectionHeader(
                  title: 'Gift planning history',
                  actionLabel: 'See all',
                  onAction: widget.onSeeHistory,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Review completed and past gift plans any time.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardData {
  final List<Occasion> upcoming;
  final int recipientCount;
  final List<GiftPlan> activePlans;

  _DashboardData({
    required this.upcoming,
    required this.recipientCount,
    required this.activePlans,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: AppSpacing.space8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
