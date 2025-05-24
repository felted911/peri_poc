/// Represents the streak data for a specific habit
class StreakData {
  /// Identifier for the habit this streak data belongs to
  final String habitId;

  /// The current streak count (consecutive days/completions)
  final int currentStreak;

  /// The longest streak ever achieved
  final int longestStreak;

  /// The start date of the current streak
  final DateTime currentStreakStartDate;

  /// The date of the last habit completion
  final DateTime lastCompletionDate;

  /// Total number of times the habit has been completed
  final int totalCompletions;

  /// The date when this streak data was last updated
  final DateTime lastUpdated;

  /// Creates a new StreakData instance
  StreakData({
    required this.habitId,
    required this.currentStreak,
    required this.longestStreak,
    required this.currentStreakStartDate,
    required this.lastCompletionDate,
    required this.totalCompletions,
    required this.lastUpdated,
  });

  /// Creates a StreakData instance from a JSON map
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      habitId: json['habitId'] as String,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      currentStreakStartDate: DateTime.parse(
        json['currentStreakStartDate'] as String,
      ),
      lastCompletionDate: DateTime.parse(json['lastCompletionDate'] as String),
      totalCompletions: json['totalCompletions'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Creates a new StreakData instance with default values
  factory StreakData.initial(String habitId) {
    final now = DateTime.now();
    return StreakData(
      habitId: habitId,
      currentStreak: 0,
      longestStreak: 0,
      currentStreakStartDate: now,
      lastCompletionDate: now,
      totalCompletions: 0,
      lastUpdated: now,
    );
  }

  /// Converts this StreakData instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'currentStreakStartDate': currentStreakStartDate.toIso8601String(),
      'lastCompletionDate': lastCompletionDate.toIso8601String(),
      'totalCompletions': totalCompletions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Returns a string representation of this StreakData instance
  @override
  String toString() {
    return 'StreakData(habitId: $habitId, currentStreak: $currentStreak, '
        'longestStreak: $longestStreak, '
        'currentStreakStartDate: $currentStreakStartDate, '
        'lastCompletionDate: $lastCompletionDate, '
        'totalCompletions: $totalCompletions, '
        'lastUpdated: $lastUpdated)';
  }

  /// Creates a copy of this StreakData instance with the specified fields replaced
  StreakData copyWith({
    String? habitId,
    int? currentStreak,
    int? longestStreak,
    DateTime? currentStreakStartDate,
    DateTime? lastCompletionDate,
    int? totalCompletions,
    DateTime? lastUpdated,
  }) {
    return StreakData(
      habitId: habitId ?? this.habitId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreakStartDate:
          currentStreakStartDate ?? this.currentStreakStartDate,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Updates the streak data based on a new habit completion
  StreakData updateWithCompletion(DateTime completionDate) {
    final now = DateTime.now();

    // Check if this is a same-day completion
    if (_isSameDay(lastCompletionDate, completionDate)) {
      // Same-day completion, just increment total completions
      return copyWith(totalCompletions: totalCompletions + 1, lastUpdated: now);
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isConsecutiveDay = _isSameDay(lastCompletionDate, yesterday);

    // Determine if this is a continuation of the current streak
    final newCurrentStreak = isConsecutiveDay ? currentStreak + 1 : 1;

    // Determine if we have a new longest streak
    final newLongestStreak =
        newCurrentStreak > longestStreak ? newCurrentStreak : longestStreak;

    // Determine the start date of the current streak
    final newStreakStartDate =
        isConsecutiveDay ? currentStreakStartDate : completionDate;

    return copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      currentStreakStartDate: newStreakStartDate,
      lastCompletionDate: completionDate,
      totalCompletions: totalCompletions + 1,
      lastUpdated: now,
    );
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StreakData &&
        other.habitId == habitId &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.currentStreakStartDate.isAtSameMomentAs(currentStreakStartDate) &&
        other.lastCompletionDate.isAtSameMomentAs(lastCompletionDate) &&
        other.totalCompletions == totalCompletions &&
        other.lastUpdated.isAtSameMomentAs(lastUpdated);
  }

  /// Hash code
  @override
  int get hashCode {
    return habitId.hashCode ^
        currentStreak.hashCode ^
        longestStreak.hashCode ^
        currentStreakStartDate.hashCode ^
        lastCompletionDate.hashCode ^
        totalCompletions.hashCode ^
        lastUpdated.hashCode;
  }
}
