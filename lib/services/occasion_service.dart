import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/occasion.dart';

class OccasionService {
  final SupabaseClient _client = Supabase.instance.client;

  static const _selectWithRecipient = '*, recipients(name)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No signed-in user.');
    return id;
  }

  Future<List<Occasion>> getOccasions({String? recipientId}) async {
    var query = _client
        .from('occasions')
        .select(_selectWithRecipient)
        .eq('user_id', _uid);
    if (recipientId != null) {
      query = query.eq('recipient_id', recipientId);
    }
    final rows = await query.order('date');
    return rows.map((r) => Occasion.fromMap(r)).toList();
  }

  Future<List<Occasion>> getUpcoming({int limit = 5}) async {
    final all = await getOccasions();
    final upcoming = all.where((o) => o.daysRemaining() >= 0).toList();
    upcoming.sort((a, b) => a.daysRemaining().compareTo(b.daysRemaining()));
    return upcoming.take(limit).toList();
  }

  Future<Occasion> createOccasion({
    required String recipientId,
    required String title,
    required DateTime date,
    required String notes,
  }) async {
    final row = await _client
        .from('occasions')
        .insert({
          'user_id': _uid,
          'recipient_id': recipientId,
          'title': title,
          'date': date.toIso8601String().split('T').first,
          'notes': notes,
        })
        .select(_selectWithRecipient)
        .single();
    return Occasion.fromMap(row);
  }

  Future<Occasion> updateOccasion(Occasion occasion) async {
    final row = await _client
        .from('occasions')
        .update(occasion.toUpdateMap())
        .eq('user_id', _uid)
        .eq('id', occasion.id)
        .select(_selectWithRecipient)
        .single();
    return Occasion.fromMap(row);
  }

  Future<void> deleteOccasion(String id) async {
    await _client.from('occasions').delete().eq('user_id', _uid).eq('id', id);
  }
}
