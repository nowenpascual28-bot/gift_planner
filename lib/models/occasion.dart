/// A date worth remembering for a recipient (birthday, anniversary, etc).
class Occasion {
  final String id;
  final String userId;
  final String recipientId;
  final String title;
  final DateTime date;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Populated only when the occasion was loaded joined with its recipient,
  /// so screens can show a name without a second query. Null otherwise.
  final String? recipientName;

  const Occasion({
    required this.id,
    required this.userId,
    required this.recipientId,
    required this.title,
    required this.date,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.recipientName,
  });

  factory Occasion.fromMap(Map<String, dynamic> map) {
    final recipient = map['recipients'] as Map<String, dynamic>?;
    return Occasion(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      recipientId: map['recipient_id'] as String,
      title: map['title'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      recipientName: recipient == null ? null : recipient['name'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'recipient_id': recipientId,
      'title': title,
      'date': date.toIso8601String().split('T').first,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'recipient_id': recipientId,
      'title': title,
      'date': date.toIso8601String().split('T').first,
      'notes': notes,
    };
  }

  /// Number of days from today until this saved occasion date.
  ///
  /// Occasions are treated as specific saved events. A past event stays in
  /// the history/list as a past event instead of being moved to next year.
  int daysRemaining({DateTime? from}) {
    final today = _dateOnly(from ?? DateTime.now());
    final eventDate = _dateOnly(date);
    return eventDate.difference(today).inDays;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
