class Recipient {
  final String id;
  final String userId;
  final String name;
  final String relationship;
  final String interests;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipient({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.interests,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipient.fromMap(Map<String, dynamic> map) {
    return Recipient(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String? ?? '',
      relationship: map['relationship'] as String? ?? '',
      interests: map['interests'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'relationship': relationship,
      'interests': interests,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'relationship': relationship,
      'interests': interests,
      'notes': notes,
    };
  }
}
