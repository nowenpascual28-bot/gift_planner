import 'package:flutter/material.dart';

enum GiftPlanStatus {
  planned,
  purchased,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case GiftPlanStatus.planned:
        return 'Planned';
      case GiftPlanStatus.purchased:
        return 'Purchased';
      case GiftPlanStatus.completed:
        return 'Completed';
      case GiftPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get dbValue => name;

  static GiftPlanStatus fromDb(String value) {
    return GiftPlanStatus.values.firstWhere(
      (s) => s.dbValue == value,
      orElse: () => GiftPlanStatus.planned,
    );
  }
}

class GiftPlan {
  final String id;
  final String userId;
  final String recipientId;
  final String? occasionId;
  final String giftName;
  final double budget;
  final double spent;
  final GiftPlanStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? recipientName;
  final String? occasionTitle;

  const GiftPlan({
    required this.id,
    required this.userId,
    required this.recipientId,
    required this.occasionId,
    required this.giftName,
    required this.budget,
    required this.spent,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.recipientName,
    this.occasionTitle,
  });

  double get remaining => budget - spent;

  bool get isOverBudget => spent > budget;

  double get progress => budget <= 0 ? 0 : spent / budget;

  factory GiftPlan.fromMap(Map<String, dynamic> map) {
    final recipient = map['recipients'] as Map<String, dynamic>?;
    final occasion = map['occasions'] as Map<String, dynamic>?;
    return GiftPlan(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      recipientId: map['recipient_id'] as String,
      occasionId: map['occasion_id'] as String?,
      giftName: map['gift_name'] as String? ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0,
      spent: (map['spent'] as num?)?.toDouble() ?? 0,
      status: GiftPlanStatus.fromDb(map['status'] as String? ?? 'planned'),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      recipientName: recipient == null ? null : recipient['name'] as String?,
      occasionTitle: occasion == null ? null : occasion['title'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'recipient_id': recipientId,
      'occasion_id': occasionId,
      'gift_name': giftName,
      'budget': budget,
      'spent': spent,
      'status': status.dbValue,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'recipient_id': recipientId,
      'occasion_id': occasionId,
      'gift_name': giftName,
      'budget': budget,
      'spent': spent,
      'status': status.dbValue,
      'notes': notes,
    };
  }
}

extension GiftPlanStatusColor on GiftPlanStatus {
  Color color(ColorScheme scheme) {
    switch (this) {
      case GiftPlanStatus.planned:
        return scheme.secondary;
      case GiftPlanStatus.purchased:
        return scheme.primary;
      case GiftPlanStatus.completed:
        return scheme.tertiary;
      case GiftPlanStatus.cancelled:
        return scheme.error;
    }
  }
}
