/// App-wide constants for the Peritest voice application
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Application name
  static const String appName = 'Peritest Voice App';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Shared Preferences keys
  static const String prefsKeyUserData = 'user_data';
  static const String prefsKeyHabitCompletions = 'habit_completions';
  static const String prefsKeyStreakData = 'streak_data';

  /// Voice interaction constants
  static const int listeningTimeoutSeconds = 10;
  static const double speechConfidenceThreshold = 0.7;

  /// Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  /// Storage limits
  static const int maxStoredCompletions = 1000;
  static const int maxStoredTemplates = 100;

  /// Debug constants
  static const bool enableVerboseLogging = true;
  static const bool enablePerformanceMonitoring = true;
}
