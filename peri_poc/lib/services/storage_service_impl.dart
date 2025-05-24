import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/models/user_data.dart';
import 'package:path/path.dart' as path;
import 'package:meta/meta.dart';

/// Implementation of the storage service using SharedPreferences and file storage
class StorageServiceImpl implements IStorageService {
  /// Creates a new StorageServiceImpl with default settings
  StorageServiceImpl();

  /// Creates a new StorageServiceImpl with test settings
  /// Only use this constructor for testing
  @visibleForTesting
  StorageServiceImpl.forTest({
    SharedPreferences? prefs,
    Directory? appDir,
    Directory? completionsDir,
    Directory? streaksDir,
    bool isInitialized = true,
  }) {
    _prefs = prefs;
    _appDir = appDir;
    _completionsDirectory = completionsDir;
    _streaksDirectory = streaksDir;
    _isInitialized = isInitialized;
  }

  /// Prefix for keys used in SharedPreferences
  static const String _keyPrefix = 'peritest_';

  /// Key for user data in SharedPreferences
  static const String _userDataKey = '${_keyPrefix}user_data';

  /// Directory name for habit completions
  static const String _completionsDir = 'completions';

  /// Directory name for streak data
  static const String _streaksDir = 'streaks';

  /// The SharedPreferences instance
  SharedPreferences? _prefs;

  /// The application documents directory
  Directory? _appDir;

  /// The directory for habit completions
  Directory? _completionsDirectory;

  /// The directory for streak data
  Directory? _streaksDirectory;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  @override
  Future<Result<void>> initialize({
    Directory Function(String)? directoryFactory,
  }) async {
    try {
      // Get the SharedPreferences instance if not already set
      _prefs ??= await SharedPreferences.getInstance();

      // Get the application documents directory if not already set
      _appDir ??= await getApplicationDocumentsDirectory();

      // Create directories if they don't exist
      final createDirectory =
          directoryFactory ?? ((String path) => Directory(path));

      _completionsDirectory ??= createDirectory(
        path.join(_appDir!.path, _completionsDir),
      );

      _streaksDirectory ??= createDirectory(
        path.join(_appDir!.path, _streaksDir),
      );

      if (!await _completionsDirectory!.exists()) {
        await _completionsDirectory!.create(recursive: true);
      }

      if (!await _streaksDirectory!.exists()) {
        await _streaksDirectory!.create(recursive: true);
      }

      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to initialize storage service: $e');
    }
  }

  /// Ensures the service is initialized before use
  Future<Result<void>> _ensureInitialized() async {
    if (!_isInitialized) {
      return Result.failure(
        'Storage service not initialized. Call initialize() first.',
      );
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> saveUserData(UserData userData) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) return initResult;

    try {
      final jsonData = userData.toJson();
      final jsonString = jsonEncode(jsonData);

      await _prefs!.setString(_userDataKey, jsonString);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save user data: $e');
    }
  }

  @override
  Future<Result<UserData>> getUserData() async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) {
      return Result.failure(initResult.error);
    }

    try {
      final jsonString = _prefs!.getString(_userDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return Result.failure('User data not found');
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final userData = UserData.fromJson(jsonData);

      return Result.success(userData);
    } catch (e) {
      return Result.failure('Failed to get user data: $e');
    }
  }

  @override
  Future<Result<void>> saveHabitCompletion(
    HabitCompletion completion, {
    File Function(String)? fileFactory,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) return initResult;

    try {
      final completionPath = path.join(
        _completionsDirectory!.path,
        '${completion.id}.json',
      );

      final createFile = fileFactory ?? ((String path) => File(path));
      final file = createFile(completionPath);
      final jsonData = completion.toJson();
      final jsonString = jsonEncode(jsonData);

      await file.writeAsString(jsonString);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save habit completion: $e');
    }
  }

  @override
  Future<Result<List<HabitCompletion>>> getHabitCompletions({
    required DateTime startDate,
    required DateTime endDate,
    String? habitId,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) {
      return Result.failure(initResult.error);
    }

    try {
      final completions = <HabitCompletion>[];
      final directory = _completionsDirectory!;

      // Ensure dates are normalized to start and end of day
      final normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      // List all files in the completions directory
      final files = await directory.list().toList();

      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final jsonString = await entity.readAsString();
            final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
            final completion = HabitCompletion.fromJson(jsonData);

            // Check if completion is within date range
            final completionDate = completion.completedAt;
            final isInDateRange =
                completionDate.isAfter(normalizedStartDate) &&
                completionDate.isBefore(normalizedEndDate);

            // Check if completion matches habitId filter (if provided)
            final matchesHabit =
                habitId == null || completion.habitId == habitId;

            if (isInDateRange && matchesHabit) {
              completions.add(completion);
            }
          } catch (e) {
            // Skip files that can't be parsed
            continue;
          }
        }
      }

      // Sort completions by date (newest first)
      completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return Result.success(completions);
    } catch (e) {
      return Result.failure('Failed to get habit completions: $e');
    }
  }

  @override
  Future<Result<StreakData>> getStreakData(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) {
      return Result.failure(initResult.error);
    }

    try {
      final streakPath = path.join(_streaksDirectory!.path, '$habitId.json');

      final createFile = fileFactory ?? ((String path) => File(path));
      final file = createFile(streakPath);

      if (!await file.exists()) {
        // Return a new streak data object if none exists
        return Result.success(StreakData.initial(habitId));
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final streakData = StreakData.fromJson(jsonData);

      return Result.success(streakData);
    } catch (e) {
      return Result.failure('Failed to get streak data: $e');
    }
  }

  @override
  Future<Result<void>> updateStreakData(
    StreakData streakData, {
    File Function(String)? fileFactory,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) return initResult;

    try {
      final streakPath = path.join(
        _streaksDirectory!.path,
        '${streakData.habitId}.json',
      );

      final createFile = fileFactory ?? ((String path) => File(path));
      final file = createFile(streakPath);
      final jsonData = streakData.toJson();
      final jsonString = jsonEncode(jsonData);

      await file.writeAsString(jsonString);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update streak data: $e');
    }
  }

  @override
  Future<Result<int>> calculateCurrentStreak(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    final streakResult = await getStreakData(habitId, fileFactory: fileFactory);

    if (streakResult.isSuccess) {
      return Result.success(streakResult.value.currentStreak);
    } else {
      return Result.failure(streakResult.error);
    }
  }

  @override
  Future<Result<int>> calculateLongestStreak(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    final streakResult = await getStreakData(habitId, fileFactory: fileFactory);

    if (streakResult.isSuccess) {
      return Result.success(streakResult.value.longestStreak);
    } else {
      return Result.failure(streakResult.error);
    }
  }

  @override
  Future<Result<void>> clearAllData() async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) return initResult;

    try {
      // Clear SharedPreferences data
      await _prefs!.remove(_userDataKey);

      // Clear completions directory
      if (await _completionsDirectory!.exists()) {
        await _completionsDirectory!.delete(recursive: true);
        await _completionsDirectory!.create(recursive: true);
      }

      // Clear streaks directory
      if (await _streaksDirectory!.exists()) {
        await _streaksDirectory!.delete(recursive: true);
        await _streaksDirectory!.create(recursive: true);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear all data: $e');
    }
  }

  @override
  Future<Result<String>> exportDataAsJson() async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) {
      return Result.failure(initResult.error);
    }

    try {
      final exportData = <String, dynamic>{};

      // Export user data
      final userDataResult = await getUserData();
      if (userDataResult.isSuccess) {
        exportData['userData'] = userDataResult.value.toJson();
      }

      // Export all completions
      final completionsDir = _completionsDirectory!;
      final completionFiles = await completionsDir.list().toList();
      final completions = <Map<String, dynamic>>[];

      for (final entity in completionFiles) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final jsonString = await entity.readAsString();
            final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
            completions.add(jsonData);
          } catch (e) {
            // Skip files that can't be parsed
            continue;
          }
        }
      }

      exportData['completions'] = completions;

      // Export all streak data
      final streaksDir = _streaksDirectory!;
      final streakFiles = await streaksDir.list().toList();
      final streaks = <Map<String, dynamic>>[];

      for (final entity in streakFiles) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final jsonString = await entity.readAsString();
            final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
            streaks.add(jsonData);
          } catch (e) {
            // Skip files that can't be parsed
            continue;
          }
        }
      }

      exportData['streaks'] = streaks;

      // Convert to JSON string
      final jsonString = jsonEncode(exportData);
      return Result.success(jsonString);
    } catch (e) {
      return Result.failure('Failed to export data: $e');
    }
  }

  @override
  Future<Result<void>> importDataFromJson(String jsonData) async {
    final initResult = await _ensureInitialized();
    if (initResult.isFailure) return initResult;

    try {
      // Clear existing data first
      final clearResult = await clearAllData();
      if (clearResult.isFailure) {
        return clearResult;
      }

      // Parse JSON data
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;

      // Import user data
      if (importData.containsKey('userData')) {
        final userData = UserData.fromJson(
          importData['userData'] as Map<String, dynamic>,
        );
        await saveUserData(userData);
      }

      // Import completions
      if (importData.containsKey('completions')) {
        final completions =
            (importData['completions'] as List)
                .cast<Map<String, dynamic>>()
                .map((json) => HabitCompletion.fromJson(json))
                .toList();

        for (final completion in completions) {
          await saveHabitCompletion(completion);
        }
      }

      // Import streak data
      if (importData.containsKey('streaks')) {
        final streaks =
            (importData['streaks'] as List)
                .cast<Map<String, dynamic>>()
                .map((json) => StreakData.fromJson(json))
                .toList();

        for (final streak in streaks) {
          await updateStreakData(streak);
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to import data: $e');
    }
  }

  @override
  Future<void> dispose() async {
    // No resources need to be disposed in this implementation
  }
}
