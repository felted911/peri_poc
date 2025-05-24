import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/models/user_data.dart';
import 'package:peri_poc/core/utils/result.dart';

class MockStorageService implements IStorageService {
  bool initialized = false;
  UserData? storedUserData;
  final Map<String, HabitCompletion> completions = {};
  final Map<String, StreakData> streaks = {};

  @override
  Future<Result<void>> initialize({
    Directory Function(String)? directoryFactory,
  }) async {
    initialized = true;
    return Result.success(null);
  }

  @override
  Future<Result<void>> saveUserData(UserData userData) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }
    storedUserData = userData;
    return Result.success(null);
  }

  @override
  Future<Result<UserData>> getUserData() async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }
    if (storedUserData == null) {
      return Result.failure('User data not found');
    }
    return Result.success(storedUserData!);
  }

  @override
  Future<Result<void>> saveHabitCompletion(
    HabitCompletion completion, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }
    completions[completion.id] = completion;
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

    final results =
        completions.values.where((completion) {
          final date = completion.completedAt;
          final matchesDate = date.isAfter(startDate) && date.isBefore(endDate);
          final matchesHabit = habitId == null || completion.habitId == habitId;
          return matchesDate && matchesHabit;
        }).toList();

    return Result.success(results);
  }

  @override
  Future<Result<StreakData>> getStreakData(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    if (!streaks.containsKey(habitId)) {
      return Result.success(StreakData.initial(habitId));
    }

    return Result.success(streaks[habitId]!);
  }

  @override
  Future<Result<void>> updateStreakData(
    StreakData streakData, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    streaks[streakData.habitId] = streakData;
    return Result.success(null);
  }

  @override
  Future<Result<int>> calculateCurrentStreak(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    if (!streaks.containsKey(habitId)) {
      return Result.success(0);
    }

    return Result.success(streaks[habitId]!.currentStreak);
  }

  @override
  Future<Result<int>> calculateLongestStreak(
    String habitId, {
    File Function(String)? fileFactory,
  }) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    if (!streaks.containsKey(habitId)) {
      return Result.success(0);
    }

    return Result.success(streaks[habitId]!.longestStreak);
  }

  @override
  Future<Result<void>> clearAllData() async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    storedUserData = null;
    completions.clear();
    streaks.clear();

    return Result.success(null);
  }

  @override
  Future<Result<String>> exportDataAsJson() async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    return Result.success('{"mock":"data"}');
  }

  @override
  Future<Result<void>> importDataFromJson(String jsonData) async {
    if (!initialized) {
      return Result.failure('Not initialized');
    }

    return Result.success(null);
  }

  @override
  Future<void> dispose() async {
    initialized = false;
  }
}

void main() {
  group('IStorageService Interface Tests', () {
    late IStorageService storageService;

    setUp(() {
      storageService = MockStorageService();
    });

    test('initialize should return success result', () async {
      final result = await storageService.initialize();
      expect(result.isSuccess, true);
    });

    test('saveUserData should save data correctly', () async {
      await storageService.initialize();

      final userData = UserData(
        userId: 'test_user',
        name: 'Test User',
        createdAt: DateTime(2023, 1, 1),
        lastUpdated: DateTime(2023, 1, 1),
      );

      final result = await storageService.saveUserData(userData);
      expect(result.isSuccess, true);

      final retrieveResult = await storageService.getUserData();
      expect(retrieveResult.isSuccess, true);
      expect(retrieveResult.value.userId, 'test_user');
      expect(retrieveResult.value.name, 'Test User');
    });

    test('saveHabitCompletion should save completion correctly', () async {
      await storageService.initialize();

      final completion = HabitCompletion(
        id: 'completion_1',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 1, 1),
      );

      final result = await storageService.saveHabitCompletion(completion);
      expect(result.isSuccess, true);

      final retrieveResult = await storageService.getHabitCompletions(
        startDate: DateTime(2022, 12, 31),
        endDate: DateTime(2023, 1, 2),
      );

      expect(retrieveResult.isSuccess, true);
      expect(retrieveResult.value.length, 1);
      expect(retrieveResult.value.first.id, 'completion_1');
    });

    test('getHabitCompletions should filter by date range', () async {
      await storageService.initialize();

      // Add completions on different dates
      final completion1 = HabitCompletion(
        id: 'completion_1',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 1, 1),
      );

      final completion2 = HabitCompletion(
        id: 'completion_2',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 1, 15),
      );

      final completion3 = HabitCompletion(
        id: 'completion_3',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 2, 1),
      );

      await storageService.saveHabitCompletion(completion1);
      await storageService.saveHabitCompletion(completion2);
      await storageService.saveHabitCompletion(completion3);

      // Should only return completions within the date range
      final retrieveResult = await storageService.getHabitCompletions(
        startDate: DateTime(2023, 1, 10),
        endDate: DateTime(2023, 1, 31),
      );

      expect(retrieveResult.isSuccess, true);
      expect(retrieveResult.value.length, 1);
      expect(retrieveResult.value.first.id, 'completion_2');
    });

    test('getHabitCompletions should filter by habitId', () async {
      await storageService.initialize();

      // Add completions for different habits
      final completion1 = HabitCompletion(
        id: 'completion_1',
        habitId: 'habit_1',
        habitName: 'Test Habit 1',
        completedAt: DateTime(2023, 1, 1),
      );

      final completion2 = HabitCompletion(
        id: 'completion_2',
        habitId: 'habit_2',
        habitName: 'Test Habit 2',
        completedAt: DateTime(2023, 1, 1),
      );

      await storageService.saveHabitCompletion(completion1);
      await storageService.saveHabitCompletion(completion2);

      // Should only return completions for the specified habit
      final retrieveResult = await storageService.getHabitCompletions(
        startDate: DateTime(2022, 12, 31),
        endDate: DateTime(2023, 1, 2),
        habitId: 'habit_1',
      );

      expect(retrieveResult.isSuccess, true);
      expect(retrieveResult.value.length, 1);
      expect(retrieveResult.value.first.habitId, 'habit_1');
    });

    test('updateStreakData should save streak data correctly', () async {
      await storageService.initialize();

      final streakData = StreakData(
        habitId: 'habit_1',
        currentStreak: 5,
        longestStreak: 10,
        currentStreakStartDate: DateTime(2023, 1, 1),
        lastCompletionDate: DateTime(2023, 1, 5),
        totalCompletions: 15,
        lastUpdated: DateTime(2023, 1, 5),
      );

      final result = await storageService.updateStreakData(streakData);
      expect(result.isSuccess, true);

      final retrieveResult = await storageService.getStreakData('habit_1');
      expect(retrieveResult.isSuccess, true);
      expect(retrieveResult.value.currentStreak, 5);
      expect(retrieveResult.value.longestStreak, 10);
    });

    test('calculateCurrentStreak should return correct streak', () async {
      await storageService.initialize();

      final streakData = StreakData(
        habitId: 'habit_1',
        currentStreak: 5,
        longestStreak: 10,
        currentStreakStartDate: DateTime(2023, 1, 1),
        lastCompletionDate: DateTime(2023, 1, 5),
        totalCompletions: 15,
        lastUpdated: DateTime(2023, 1, 5),
      );

      await storageService.updateStreakData(streakData);

      final result = await storageService.calculateCurrentStreak('habit_1');
      expect(result.isSuccess, true);
      expect(result.value, 5);
    });

    test('calculateLongestStreak should return correct streak', () async {
      await storageService.initialize();

      final streakData = StreakData(
        habitId: 'habit_1',
        currentStreak: 5,
        longestStreak: 10,
        currentStreakStartDate: DateTime(2023, 1, 1),
        lastCompletionDate: DateTime(2023, 1, 5),
        totalCompletions: 15,
        lastUpdated: DateTime(2023, 1, 5),
      );

      await storageService.updateStreakData(streakData);

      final result = await storageService.calculateLongestStreak('habit_1');
      expect(result.isSuccess, true);
      expect(result.value, 10);
    });

    test('clearAllData should remove all stored data', () async {
      await storageService.initialize();

      // Add some data
      final userData = UserData(
        userId: 'test_user',
        name: 'Test User',
        createdAt: DateTime(2023, 1, 1),
        lastUpdated: DateTime(2023, 1, 1),
      );

      final completion = HabitCompletion(
        id: 'completion_1',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 1, 1),
      );

      final streakData = StreakData(
        habitId: 'habit_1',
        currentStreak: 5,
        longestStreak: 10,
        currentStreakStartDate: DateTime(2023, 1, 1),
        lastCompletionDate: DateTime(2023, 1, 5),
        totalCompletions: 15,
        lastUpdated: DateTime(2023, 1, 5),
      );

      await storageService.saveUserData(userData);
      await storageService.saveHabitCompletion(completion);
      await storageService.updateStreakData(streakData);

      // Clear all data
      final clearResult = await storageService.clearAllData();
      expect(clearResult.isSuccess, true);

      // Check that data has been cleared
      final userDataResult = await storageService.getUserData();
      expect(userDataResult.isFailure, true);

      final completionsResult = await storageService.getHabitCompletions(
        startDate: DateTime(2022, 12, 31),
        endDate: DateTime(2023, 1, 2),
      );

      expect(completionsResult.isSuccess, true);
      expect(completionsResult.value.isEmpty, true);

      final streakResult = await storageService.getStreakData('habit_1');
      expect(streakResult.isSuccess, true);
      expect(streakResult.value.currentStreak, 0); // Should be initial value
    });
  });
}
