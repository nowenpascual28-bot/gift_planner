import 'package:flutter/material.dart';

import '../../models/occasion.dart';
import '../../models/gift_plan.dart';
import '../../models/recipient.dart';
import '../../services/gift_plan_service.dart';
import '../../services/occasion_service.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_state_views.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/gift_plan_card.dart';
import '../../widgets/occasion_card.dart';
import '../../widgets/section_header.dart';
import '../gift_plans/gift_plan_form_screen.dart';
import '../occasions/occasion_form_screen.dart';
import 'recipient_form_screen.dart';

/// Full detail view for a single recipient: their info plus their occasions
/// and gift plans, with quick actions to add more of either.
class RecipientDetailsScreen extends StatefulWidget {
  final String recipientId;

  const RecipientDetailsScreen({super.key, required this.recipientId});

  @override
  State<RecipientDetailsScreen> createState() => _RecipientDetailsScreenState();
}

class _RecipientDetailsScreenState extends State<RecipientDetailsScreen> {
  final _recipientService = RecipientService();
  final _occasionService = OccasionService();
  final _giftPlanService = GiftPlanService();

  late Future<_DetailsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailsData> _load() async {
    final results = await Future.wait([
      _recipientService.getRecipient(widget.recipientId),
      _occasionService.getOccasions(recipientId: widget.recipientId),
      _giftPlanService.getGiftPlans(recipientId: widget.recipientId),
    ]);
    return _DetailsData(
      recipient: results[0] as Recipient,
      occasions: results[1] as List<Occasion>,
      giftPlans: results[2] as List<GiftPlan>,
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Recipient details', showBack: true),
      body: FutureBuilder<_DetailsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorStateView(
              message: 'Could not load this recipient. ${snapshot.error}',
              onRetry: _refresh,
            );
          }
          final data = snapshot.data!;
          final recipient = data.recipient;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipient.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              await Navigator.of(context).push<Recipient>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecipientFormScreen(recipient: recipient),
                                ),
                              );
                              _refresh();
                            },
                          ),
                        ],
                      ),
                      if (recipient.relationship.isNotEmpty)
                        Text(
                          recipient.relationship,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (recipient.interests.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          'Interests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          recipient.interests,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (recipient.notes.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          recipient.notes,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              SectionHeader(
                title: 'Occasions',
                actionLabel: 'Add',
                onAction: () async {
                  await Navigator.of(context).push<Occasion>(
                    MaterialPageRoute(
                      builder: (_) =>
                          OccasionFormScreen(initialRecipientId: recipient.id),
                    ),
                  );
                  _refresh();
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              if (data.occasions.isEmpty)
                const EmptyStateView(
                  icon: Icons.event_outlined,
                  title: 'No occasions yet',
                  message:
                      'Add a birthday or other date to remember for this person.',
                )
              else
                ...data.occasions.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                    child: OccasionCard(
                      occasion: o,
                      showRecipientName: false,
                      onTap: () async {
                        await Navigator.of(context).push<Occasion>(
                          MaterialPageRoute(
                            builder: (_) => OccasionFormScreen(occasion: o),
                          ),
                        );
                        _refresh();
                      },
                      onEdit: () async {
                        await Navigator.of(context).push<Occasion>(
                          MaterialPageRoute(
                            builder: (_) => OccasionFormScreen(occasion: o),
                          ),
                        );
                        _refresh();
                      },
                      onDelete: () async {
                        await _occasionService.deleteOccasion(o.id);
                        _refresh();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.space24),
              SectionHeader(
                title: 'Gift plans',
                actionLabel: 'Add',
                onAction: () async {
                  await Navigator.of(context).push<GiftPlan>(
                    MaterialPageRoute(
                      builder: (_) =>
                          GiftPlanFormScreen(initialRecipientId: recipient.id),
                    ),
                  );
                  _refresh();
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              if (data.giftPlans.isEmpty)
                const EmptyStateView(
                  icon: Icons.card_giftcard_outlined,
                  title: 'No gift plans yet',
                  message:
                      'Create a gift plan to start tracking budget and status.',
                )
              else
                ...data.giftPlans.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                    child: GiftPlanCard(
                      plan: p,
                      onTap: () async {
                        await Navigator.of(context).push<GiftPlan>(
                          MaterialPageRoute(
                            builder: (_) => GiftPlanFormScreen(plan: p),
                          ),
                        );
                        _refresh();
                      },
                      onEdit: () async {
                        await Navigator.of(context).push<GiftPlan>(
                          MaterialPageRoute(
                            builder: (_) => GiftPlanFormScreen(plan: p),
                          ),
                        );
                        _refresh();
                      },
                      onDelete: () async {
                        await _giftPlanService.deleteGiftPlan(p.id);
                        _refresh();
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailsData {
  final Recipient recipient;
  final List<Occasion> occasions;
  final List<GiftPlan> giftPlans;

  _DetailsData({
    required this.recipient,
    required this.occasions,
    required this.giftPlans,
  });
}
