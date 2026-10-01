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
import '../../widgets/theme_toggle_button.dart';

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
    final activePlans = (results[2] as List<GiftPlan>)
        .where(
          (p) =>
              p.status != GiftPlanStatus.completed &&
              p.status != GiftPlanStatus.cancelled,
        )
        .toList();
    return _DashboardData(
      upcoming: results[0] as List<Occasion>,
      recipientCount: (results[1] as List).length,
      activePlans: activePlans,
      totalBudget: activePlans.fold(0.0, (sum, p) => sum + p.budget),
      totalSpent: activePlans.fold(0.0, (sum, p) => sum + p.spent),
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Gift Planner'),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space8,
                AppSpacing.space16,
                AppSpacing.space32,
              ),
              children: [
                _WelcomeBanner(
                  occasionCount: data.upcoming.length,
                  activePlanCount: data.activePlans.length,
                ),
                const SizedBox(height: AppSpacing.space16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_alt_rounded,
                        label: 'Recipients',
                        value: '${data.recipientCount}',
                        accent: Theme.of(context).colorScheme.primary,
                        onTap: widget.onSeeRecipients,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Active plans',
                        value: '${data.activePlans.length}',
                        accent: Theme.of(context).colorScheme.tertiary,
                        onTap: widget.onSeeGiftPlans,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                _BudgetSummaryCard(
                  budget: data.totalBudget,
                  spent: data.totalSpent,
                  onTap: widget.onSeeGiftPlans,
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Keep every gift idea in one place and stay within your budget.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
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

class _WelcomeBanner extends StatelessWidget {
  final int occasionCount;
  final int activePlanCount;

  const _WelcomeBanner({
    required this.occasionCount,
    required this.activePlanCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.65)!,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan something thoughtful 🎁',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '$occasionCount upcoming occasion${occasionCount == 1 ? '' : 's'} · $activePlanCount active plan${activePlanCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final List<Occasion> upcoming;
  final int recipientCount;
  final List<GiftPlan> activePlans;
  final double totalBudget;
  final double totalSpent;

  _DashboardData({
    required this.upcoming,
    required this.recipientCount,
    required this.activePlans,
    required this.totalBudget,
    required this.totalSpent,
  });
}

class _BudgetSummaryCard extends StatelessWidget {
  final double budget;
  final double spent;
  final VoidCallback onTap;

  const _BudgetSummaryCard({
    required this.budget,
    required this.spent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overBudget = spent > budget;
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final remaining = budget - spent;
    final progressColor = overBudget ? scheme.error : scheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gift budget',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '₱${spent.toStringAsFixed(2)} spent of ₱${budget.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overBudget
                    ? '₱${(-remaining).toStringAsFixed(2)} over budget'
                    : '₱${remaining.toStringAsFixed(2)} remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: overBudget ? scheme.error : scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: AppSpacing.space12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
