import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/services/storage_service_impl.dart';
// import 'package:mockito/mockito.dart'; // Not directly used in tests
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([Directory, File, SharedPreferences])
// import 'streak_calculation_test.mocks.dart'; // Not directly used in tests
// Custom mock class for the storage service to test streak calculations
class MockStorageService extends StorageServiceImpl {
  final List<HabitCompletion> mockCompletions = [];
  StreakData? mockStreakData;
  bool initialized = false;

  @override
  Future<Result<void>> initialize({
    Directory Function(String)? directoryFactory,
  }) async {
    initialized = true;
    return Result.success(null);
  }

  @override
  Future<Result<List<HabitCompletion>>> getHabitCompletions({
    required DateTime startDate,
    required DateTime endDate,
    String? habitId,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    final filteredCompletions =
        mockCompletions.where((completion) {
          final date = completion.completedAt;
          final matchesDate = date.isAfter(startDate) && date.isBefore(endDate);
          final matchesHabit = habitId == null || completion.habitId == habitId;
          return matchesDate && matchesHabit;
        }).toList();

    return Result.success(filteredCompletions);
  }

  @override
  Future<Result<StreakData>> getStreakData(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    if (mockStreakData == null || mockStreakData!.habitId != habitId) {
      return Result.success(StreakData.initial(habitId));
    }

    return Result.success(mockStreakData!);
  }

  @override
  Future<Result<void>> updateStreakData(
    StreakData streakData, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    mockStreakData = streakData;
    return Result.success(null);
  }

  // Method to add test completions
  void addMockCompletions(List<HabitCompletion> completions) {
    mockCompletions.addAll(completions);
  }

  // Method to set test streak data
  void setMockStreakData(StreakData streakData) {
    mockStreakData = streakData;
  }

  // Method to clear test data
  void clearMockData() {
    mockCompletions.clear();
    mockStreakData = null;
  }
}

void main() {
  late MockStorageService storageService;

  setUp(() {
    storageService = MockStorageService();
    storageService.initialize();
  });

  group('Streak Calculation Tests', () {
    test('calculateCurrentStreak should return 0 for no completions', () async {
      // No completions added
      final result = await storageService.calculateCurrentStreak('habit_1');

      expect(result.isSuccess, true);
      expect(result.value, 0);
    });

    test(
      'calculateCurrentStreak should return 1 for single completion today',
      () async {
        final now = DateTime.now();

        // Add a single completion for today
        storageService.addMockCompletions([
          HabitCompletion(
            id: 'completion_1',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: now,
          ),
        ]);

        // Set initial streak data (which would be updated by the saveHabitCompletion method)
        storageService.setMockStreakData(
          StreakData(
            habitId: 'habit_1',
            currentStreak: 1,
            longestStreak: 1,
            currentStreakStartDate: now,
            lastCompletionDate: now,
            totalCompletions: 1,
            lastUpdated: now,
          ),
        );

        final result = await storageService.calculateCurrentStreak('habit_1');

        expect(result.isSuccess, true);
        expect(result.value, 1);
      },
    );

    test(
      'calculateCurrentStreak should count consecutive days correctly',
      () async {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

        // Add completions for consecutive days
        storageService.addMockCompletions([
          HabitCompletion(
            id: 'completion_1',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: twoDaysAgo,
          ),
          HabitCompletion(
            id: 'completion_2',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: yesterday,
          ),
          HabitCompletion(
            id: 'completion_3',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: now,
          ),
        ]);

        // Set streak data (which would be updated by the saveHabitCompletion method)
        storageService.setMockStreakData(
          StreakData(
            habitId: 'habit_1',
            currentStreak: 3,
            longestStreak: 3,
            currentStreakStartDate: twoDaysAgo,
            lastCompletionDate: now,
            totalCompletions: 3,
            lastUpdated: now,
          ),
        );

        final result = await storageService.calculateCurrentStreak('habit_1');

        expect(result.isSuccess, true);
        expect(result.value, 3);
      },
    );

    test('calculateCurrentStreak should break streak for missed days', () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final threeDaysAgo = DateTime(now.year, now.month, now.day - 3);

      // Add completions with a gap (missing 2 days ago)
      storageService.addMockCompletions([
        HabitCompletion(
          id: 'completion_1',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: threeDaysAgo,
        ),
        HabitCompletion(
          id: 'completion_2',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: yesterday,
        ),
        HabitCompletion(
          id: 'completion_3',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: now,
        ),
      ]);

      // Set streak data (which would be updated by the saveHabitCompletion method)
      // The streak should have reset when the day was missed
      storageService.setMockStreakData(
        StreakData(
          habitId: 'habit_1',
          currentStreak: 2, // Only yesterday and today count
          longestStreak: 2,
          currentStreakStartDate: yesterday,
          lastCompletionDate: now,
          totalCompletions: 3,
          lastUpdated: now,
        ),
      );

      final result = await storageService.calculateCurrentStreak('habit_1');

      expect(result.isSuccess, true);
      expect(result.value, 2); // Only yesterday and today count
    });

    test('calculateLongestStreak should return the longest streak', () async {
      final now = DateTime.now();
      final oneWeekAgo = DateTime(now.year, now.month, now.day - 7);
      final sixDaysAgo = DateTime(now.year, now.month, now.day - 6);
      final fiveDaysAgo = DateTime(now.year, now.month, now.day - 5);
      final fourDaysAgo = DateTime(now.year, now.month, now.day - 4);
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      // Add completions with two separate streaks
      // First streak: 3 days (7, 6, 5 days ago)
      // Second streak: 2 days (yesterday, today)
      storageService.addMockCompletions([
        HabitCompletion(
          id: 'completion_1',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: oneWeekAgo,
        ),
        HabitCompletion(
          id: 'completion_2',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: sixDaysAgo,
        ),
        HabitCompletion(
          id: 'completion_3',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: fiveDaysAgo,
        ),
        HabitCompletion(
          id: 'completion_4',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: fourDaysAgo,
        ),
        HabitCompletion(
          id: 'completion_5',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: yesterday,
        ),
        HabitCompletion(
          id: 'completion_6',
          habitId: 'habit_1',
          habitName: 'Test Habit',
          completedAt: now,
        ),
      ]);

      // Set streak data
      storageService.setMockStreakData(
        StreakData(
          habitId: 'habit_1',
          currentStreak: 2, // Current streak is 2 days
          longestStreak: 4, // Longest streak was 4 days
          currentStreakStartDate: yesterday,
          lastCompletionDate: now,
          totalCompletions: 6,
          lastUpdated: now,
        ),
      );

      final result = await storageService.calculateLongestStreak('habit_1');

      expect(result.isSuccess, true);
      expect(result.value, 4); // Longest streak was 4 days
    });

    test(
      'StreakData.updateWithCompletion handles streak continuation correctly',
      () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

        final streakData = StreakData(
          habitId: 'habit_1',
          currentStreak: 2,
          longestStreak: 5,
          currentStreakStartDate: twoDaysAgo,
          lastCompletionDate: yesterday,
          totalCompletions: 10,
          lastUpdated: yesterday,
        );

        // Update with today's completion (continuing the streak)
        final updatedStreak = streakData.updateWithCompletion(now);

        expect(updatedStreak.currentStreak, 3); // Incremented
        expect(updatedStreak.longestStreak, 5); // Unchanged
        expect(updatedStreak.currentStreakStartDate, twoDaysAgo); // Unchanged
        expect(updatedStreak.lastCompletionDate, now); // Updated
        expect(updatedStreak.totalCompletions, 11); // Incremented
      },
    );

    test('StreakData.updateWithCompletion handles streak break correctly', () {
      final now = DateTime.now();
      final threeDaysAgo = DateTime(now.year, now.month, now.day - 3);
      final fourDaysAgo = DateTime(now.year, now.month, now.day - 4);

      final streakData = StreakData(
        habitId: 'habit_1',
        currentStreak: 2,
        longestStreak: 5,
        currentStreakStartDate: fourDaysAgo,
        lastCompletionDate: threeDaysAgo,
        totalCompletions: 10,
        lastUpdated: threeDaysAgo,
      );

      // Update with today's completion (breaking the streak - missed 2 days)
      final updatedStreak = streakData.updateWithCompletion(now);

      expect(updatedStreak.currentStreak, 1); // Reset to 1
      expect(updatedStreak.longestStreak, 5); // Unchanged
      expect(updatedStreak.currentStreakStartDate, now); // Updated to today
      expect(updatedStreak.lastCompletionDate, now); // Updated
      expect(updatedStreak.totalCompletions, 11); // Incremented
    });

    test(
      'StreakData.updateWithCompletion updates longest streak when needed',
      () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final fourDaysAgo = DateTime(now.year, now.month, now.day - 4);

        final streakData = StreakData(
          habitId: 'habit_1',
          currentStreak: 4,
          longestStreak: 4, // Current equals longest
          currentStreakStartDate: fourDaysAgo,
          lastCompletionDate: yesterday,
          totalCompletions: 10,
          lastUpdated: yesterday,
        );

        // Update with today's completion (extending beyond previous longest)
        final updatedStreak = streakData.updateWithCompletion(now);

        expect(updatedStreak.currentStreak, 5); // Incremented
        expect(updatedStreak.longestStreak, 5); // Also incremented
        expect(updatedStreak.currentStreakStartDate, fourDaysAgo); // Unchanged
        expect(updatedStreak.lastCompletionDate, now); // Updated
        expect(updatedStreak.totalCompletions, 11); // Incremented
      },
    );

    test(
      'StreakData.updateWithCompletion handles same-day completions correctly',
      () {
        final now = DateTime.now();

        final streakData = StreakData(
          habitId: 'habit_1',
          currentStreak: 1,
          longestStreak: 3,
          currentStreakStartDate: now,
          lastCompletionDate: now, // Already completed today
          totalCompletions: 5,
          lastUpdated: now,
        );

        // Update with another completion on the same day
        final updatedStreak = streakData.updateWithCompletion(now);

        expect(updatedStreak.currentStreak, 1); // Still 1 (same day)
        expect(updatedStreak.longestStreak, 3); // Unchanged
        expect(updatedStreak.currentStreakStartDate, now); // Unchanged
        expect(updatedStreak.lastCompletionDate, now); // Unchanged
        expect(updatedStreak.totalCompletions, 6); // Incremented
      },
    );

    test(
      'Multiple completions in a day count as one day for streak purposes',
      () async {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);

        // Add multiple completions for today
        storageService.addMockCompletions([
          HabitCompletion(
            id: 'completion_1',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: yesterday,
          ),
          HabitCompletion(
            id: 'completion_2',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: now.add(const Duration(hours: 1)),
          ),
          HabitCompletion(
            id: 'completion_3',
            habitId: 'habit_1',
            habitName: 'Test Habit',
            completedAt: now.add(const Duration(hours: 2)),
          ),
        ]);

        // Set streak data
        storageService.setMockStreakData(
          StreakData(
            habitId: 'habit_1',
            currentStreak: 2, // Two days (yesterday and today)
            longestStreak: 2,
            currentStreakStartDate: yesterday,
            lastCompletionDate: now.add(const Duration(hours: 2)),
            totalCompletions: 3,
            lastUpdated: now.add(const Duration(hours: 2)),
          ),
        );

        final result = await storageService.calculateCurrentStreak('habit_1');

        expect(result.isSuccess, true);
        expect(result.value, 2); // Still counts as 2 days
      },
    );

    test(
      'Completions for different habits do not affect each other\'s streaks',
      () async {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

        // Add completions for two different habits
        storageService.addMockCompletions([
          // Habit 1: completed yesterday and today (streak of 2)
          HabitCompletion(
            id: 'completion_1',
            habitId: 'habit_1',
            habitName: 'Test Habit 1',
            completedAt: yesterday,
          ),
          HabitCompletion(
            id: 'completion_2',
            habitId: 'habit_1',
            habitName: 'Test Habit 1',
            completedAt: now,
          ),

          // Habit 2: completed all three days (streak of 3)
          HabitCompletion(
            id: 'completion_3',
            habitId: 'habit_2',
            habitName: 'Test Habit 2',
            completedAt: twoDaysAgo,
          ),
          HabitCompletion(
            id: 'completion_4',
            habitId: 'habit_2',
            habitName: 'Test Habit 2',
            completedAt: yesterday,
          ),
          HabitCompletion(
            id: 'completion_5',
            habitId: 'habit_2',
            habitName: 'Test Habit 2',
            completedAt: now,
          ),
        ]);

        // Set streak data for habit 1
        storageService.setMockStreakData(
          StreakData(
            habitId: 'habit_1',
            currentStreak: 2,
            longestStreak: 2,
            currentStreakStartDate: yesterday,
            lastCompletionDate: now,
            totalCompletions: 2,
            lastUpdated: now,
          ),
        );

        // Check streak for habit 1
        final result1 = await storageService.calculateCurrentStreak('habit_1');
        expect(result1.isSuccess, true);
        expect(result1.value, 2);

        // Set streak data for habit 2
        storageService.setMockStreakData(
          StreakData(
            habitId: 'habit_2',
            currentStreak: 3,
            longestStreak: 3,
            currentStreakStartDate: twoDaysAgo,
            lastCompletionDate: now,
            totalCompletions: 3,
            lastUpdated: now,
          ),
        );

        // Check streak for habit 2
        final result2 = await storageService.calculateCurrentStreak('habit_2');
        expect(result2.isSuccess, true);
        expect(result2.value, 3);
      },
    );
  });
}
