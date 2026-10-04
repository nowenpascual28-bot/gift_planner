import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recipient.dart';

class RecipientService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No signed-in user.');
    return id;
  }

  Future<List<Recipient>> getRecipients({String? search}) async {
    var query = _client.from('recipients').select().eq('user_id', _uid);
    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('name', '%${search.trim()}%');
    }
    final rows = await query.order('name');
    return rows.map((r) => Recipient.fromMap(r)).toList();
  }

  Future<Recipient> getRecipient(String id) async {
    final row = await _client
        .from('recipients')
        .select()
        .eq('user_id', _uid)
        .eq('id', id)
        .single();
    return Recipient.fromMap(row);
  }

  Future<Recipient> createRecipient({
    required String name,
    required String relationship,
    required String interests,
    required String notes,
  }) async {
    final row = await _client
        .from('recipients')
        .insert({
          'user_id': _uid,
          'name': name,
          'relationship': relationship,
          'interests': interests,
          'notes': notes,
        })
        .select()
        .single();
    return Recipient.fromMap(row);
  }

  Future<Recipient> updateRecipient(Recipient recipient) async {
    final row = await _client
        .from('recipients')
        .update(recipient.toUpdateMap())
        .eq('user_id', _uid)
        .eq('id', recipient.id)
        .select()
        .single();
    return Recipient.fromMap(row);
  }

  Future<void> deleteRecipient(String id) async {
    await _client.from('recipients').delete().eq('user_id', _uid).eq('id', id);
  }
}
