/// Represents a single completion of a habit
class HabitCompletion {
  /// Unique identifier for this completion record
  final String id;

  /// Identifier for the habit that was completed
  final String habitId;

  /// Name of the habit
  final String habitName;

  /// When the habit was completed
  final DateTime completedAt;

  /// Optional notes about this completion
  final String? notes;

  /// Duration of the habit activity in minutes (if applicable)
  final int? durationMinutes;

  /// Quality rating provided by the user (1-5)
  final int? qualityRating;

  /// Additional data as key-value pairs
  final Map<String, dynamic> metadata;

  /// Creates a new HabitCompletion instance
  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.completedAt,
    this.notes,
    this.durationMinutes,
    this.qualityRating,
    this.metadata = const {},
  });

  /// Creates a HabitCompletion instance from a JSON map
  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      qualityRating: json['qualityRating'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts this HabitCompletion instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'habitName': habitName,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'durationMinutes': durationMinutes,
      'qualityRating': qualityRating,
      'metadata': metadata,
    };
  }

  /// Returns a string representation of this HabitCompletion instance
  @override
  String toString() {
    return 'HabitCompletion(id: $id, habitId: $habitId, habitName: $habitName, '
        'completedAt: $completedAt, notes: $notes, '
        'durationMinutes: $durationMinutes, qualityRating: $qualityRating)';
  }

  /// Creates a copy of this HabitCompletion instance with the specified fields replaced
  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? habitName,
    DateTime? completedAt,
    String? notes,
    int? durationMinutes,
    int? qualityRating,
    Map<String, dynamic>? metadata,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      qualityRating: qualityRating ?? this.qualityRating,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HabitCompletion &&
        other.id == id &&
        other.habitId == habitId &&
        other.habitName == habitName &&
        other.completedAt.isAtSameMomentAs(completedAt) &&
        other.notes == notes &&
        other.durationMinutes == durationMinutes &&
        other.qualityRating == qualityRating &&
        _mapsEqual(other.metadata, metadata);
  }

  /// Hash code
  @override
  int get hashCode {
    return id.hashCode ^
        habitId.hashCode ^
        habitName.hashCode ^
        completedAt.hashCode ^
        notes.hashCode ^
        durationMinutes.hashCode ^
        qualityRating.hashCode ^
        metadata.hashCode;
  }

  /// Helper method to check if two maps are equal
  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }
}
