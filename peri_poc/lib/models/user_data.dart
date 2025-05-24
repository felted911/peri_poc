import 'dart:convert';

/// Represents the user's profile and configuration data
class UserData {
  /// Unique identifier for the user
  final String userId;

  /// User's display name
  final String name;

  /// When the user first started using the app
  final DateTime createdAt;

  /// When the user's data was last updated
  final DateTime lastUpdated;

  /// User's preferred interaction frequency (in days)
  final int reminderFrequency;

  /// Whether the user has enabled voice reminders
  final bool voiceRemindersEnabled;

  /// The time of day the user prefers to be reminded
  final DateTime? preferredReminderTime;

  /// Additional custom settings as key-value pairs
  final Map<String, dynamic> settings;

  /// Creates a new UserData instance
  UserData({
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.lastUpdated,
    this.reminderFrequency = 1,
    this.voiceRemindersEnabled = true,
    this.preferredReminderTime,
    this.settings = const {},
  });

  /// Creates a UserData instance from a JSON map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      reminderFrequency: json['reminderFrequency'] as int? ?? 1,
      voiceRemindersEnabled: json['voiceRemindersEnabled'] as bool? ?? true,
      preferredReminderTime:
          json['preferredReminderTime'] != null
              ? DateTime.parse(json['preferredReminderTime'] as String)
              : null,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts this UserData instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'reminderFrequency': reminderFrequency,
      'voiceRemindersEnabled': voiceRemindersEnabled,
      'preferredReminderTime': preferredReminderTime?.toIso8601String(),
      'settings': settings,
    };
  }

  /// Returns a string representation of this UserData instance
  @override
  String toString() {
    return 'UserData(userId: $userId, name: $name, createdAt: $createdAt, '
        'lastUpdated: $lastUpdated, reminderFrequency: $reminderFrequency, '
        'voiceRemindersEnabled: $voiceRemindersEnabled, '
        'preferredReminderTime: $preferredReminderTime, '
        'settings: ${jsonEncode(settings)})';
  }

  /// Creates a copy of this UserData instance with the specified fields replaced
  UserData copyWith({
    String? userId,
    String? name,
    DateTime? createdAt,
    DateTime? lastUpdated,
    int? reminderFrequency,
    bool? voiceRemindersEnabled,
    DateTime? preferredReminderTime,
    Map<String, dynamic>? settings,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      voiceRemindersEnabled:
          voiceRemindersEnabled ?? this.voiceRemindersEnabled,
      preferredReminderTime:
          preferredReminderTime ?? this.preferredReminderTime,
      settings: settings ?? this.settings,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.userId == userId &&
        other.name == name &&
        other.createdAt.isAtSameMomentAs(createdAt) &&
        other.lastUpdated.isAtSameMomentAs(lastUpdated) &&
        other.reminderFrequency == reminderFrequency &&
        other.voiceRemindersEnabled == voiceRemindersEnabled &&
        (other.preferredReminderTime == null && preferredReminderTime == null ||
            other.preferredReminderTime != null &&
                preferredReminderTime != null &&
                other.preferredReminderTime!.isAtSameMomentAs(
                  preferredReminderTime!,
                )) &&
        _mapsEqual(other.settings, settings);
  }

  /// Hash code
  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        lastUpdated.hashCode ^
        reminderFrequency.hashCode ^
        voiceRemindersEnabled.hashCode ^
        preferredReminderTime.hashCode ^
        settings.hashCode;
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
