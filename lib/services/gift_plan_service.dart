import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gift_plan.dart';

class GiftPlanService {
  final SupabaseClient _client = Supabase.instance.client;

  static const _selectJoined = '*, recipients(name), occasions(title)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No signed-in user.');
    return id;
  }

  Future<List<GiftPlan>> getGiftPlans({
    String? recipientId,
    String? occasionId,
    GiftPlanStatus? status,
  }) async {
    var query = _client
        .from('gift_plans')
        .select(_selectJoined)
        .eq('user_id', _uid);
    if (recipientId != null) query = query.eq('recipient_id', recipientId);
    if (occasionId != null) query = query.eq('occasion_id', occasionId);
    if (status != null) query = query.eq('status', status.dbValue);
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => GiftPlan.fromMap(r)).toList();
  }

  Future<GiftPlan> createGiftPlan({
    required String recipientId,
    String? occasionId,
    required String giftName,
    required double budget,
    required GiftPlanStatus status,
    required String notes,
  }) async {
    final row = await _client
        .from('gift_plans')
        .insert({
          'user_id': _uid,
          'recipient_id': recipientId,
          'occasion_id': occasionId,
          'gift_name': giftName,
          'budget': budget,
          'spent': 0,
          'status': status.dbValue,
          'notes': notes,
        })
        .select(_selectJoined)
        .single();
    return GiftPlan.fromMap(row);
  }

  Future<GiftPlan> updateGiftPlan(GiftPlan plan) async {
    final row = await _client
        .from('gift_plans')
        .update(plan.toUpdateMap())
        .eq('user_id', _uid)
        .eq('id', plan.id)
        .select(_selectJoined)
        .single();
    return GiftPlan.fromMap(row);
  }

  Future<GiftPlan> addSpent(String id, double amount) async {
    if (amount <= 0) {
      throw ArgumentError('Spent amount must be greater than zero.');
    }

    final current = await _client
        .from('gift_plans')
        .select('spent')
        .eq('user_id', _uid)
        .eq('id', id)
        .single();

    final currentSpent = (current['spent'] as num?)?.toDouble() ?? 0;

    final row = await _client
        .from('gift_plans')
        .update({'spent': currentSpent + amount})
        .eq('user_id', _uid)
        .eq('id', id)
        .select(_selectJoined)
        .single();

    return GiftPlan.fromMap(row);
  }

  Future<void> deleteGiftPlan(String id) async {
    await _client.from('gift_plans').delete().eq('user_id', _uid).eq('id', id);
  }
}
