// import 'dart:convert'; // Not directly used in tests

import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/models/user_data.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/streak_data.dart';

void main() {
  group('Data Models Tests', () {
    group('UserData', () {
      test('UserData should serialize and deserialize correctly', () {
        final originalUserData = UserData(
          userId: 'test_user_123',
          name: 'John Doe',
          createdAt: DateTime(2023, 1, 1, 12, 0),
          lastUpdated: DateTime(2023, 1, 2, 14, 30),
          reminderFrequency: 2,
          voiceRemindersEnabled: true,
          preferredReminderTime: DateTime(2023, 1, 1, 9, 0),
          settings: {'theme': 'dark', 'volume': 0.8},
        );

        final json = originalUserData.toJson();
        final deserializedUserData = UserData.fromJson(json);

        expect(deserializedUserData.userId, originalUserData.userId);
        expect(deserializedUserData.name, originalUserData.name);
        expect(
          deserializedUserData.createdAt.isAtSameMomentAs(
            originalUserData.createdAt,
          ),
          true,
        );
        expect(
          deserializedUserData.lastUpdated.isAtSameMomentAs(
            originalUserData.lastUpdated,
          ),
          true,
        );
        expect(
          deserializedUserData.reminderFrequency,
          originalUserData.reminderFrequency,
        );
        expect(
          deserializedUserData.voiceRemindersEnabled,
          originalUserData.voiceRemindersEnabled,
        );
        expect(
          deserializedUserData.preferredReminderTime!.isAtSameMomentAs(
            originalUserData.preferredReminderTime!,
          ),
          true,
        );
        expect(deserializedUserData.settings, originalUserData.settings);
      });

      test(
        'UserData.copyWith should create a new instance with specified fields replaced',
        () {
          final originalUserData = UserData(
            userId: 'test_user_123',
            name: 'John Doe',
            createdAt: DateTime(2023, 1, 1),
            lastUpdated: DateTime(2023, 1, 2),
            reminderFrequency: 2,
            voiceRemindersEnabled: true,
          );

          final updatedUserData = originalUserData.copyWith(
            name: 'Jane Doe',
            reminderFrequency: 3,
          );

          expect(updatedUserData.userId, originalUserData.userId);
          expect(updatedUserData.name, 'Jane Doe');
          expect(updatedUserData.reminderFrequency, 3);
          expect(
            updatedUserData.voiceRemindersEnabled,
            originalUserData.voiceRemindersEnabled,
          );
        },
      );

      test('UserData equality operator should work correctly', () {
        final userData1 = UserData(
          userId: 'test_user_123',
          name: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          lastUpdated: DateTime(2023, 1, 2),
        );

        final userData2 = UserData(
          userId: 'test_user_123',
          name: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          lastUpdated: DateTime(2023, 1, 2),
        );

        final userData3 = UserData(
          userId: 'different_user',
          name: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          lastUpdated: DateTime(2023, 1, 2),
        );

        expect(userData1, userData2);
        expect(userData1 == userData3, false);
      });

      test('UserData toString should return a string representation', () {
        final userData = UserData(
          userId: 'test_user_123',
          name: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          lastUpdated: DateTime(2023, 1, 2),
        );

        final stringRepresentation = userData.toString();
        expect(stringRepresentation.contains('test_user_123'), true);
        expect(stringRepresentation.contains('John Doe'), true);
      });
    });

    group('HabitCompletion', () {
      test('HabitCompletion should serialize and deserialize correctly', () {
        final originalCompletion = HabitCompletion(
          id: 'completion_123',
          habitId: 'habit_456',
          habitName: 'Morning Meditation',
          completedAt: DateTime(2023, 1, 5, 8, 30),
          notes: 'Felt very peaceful today',
          durationMinutes: 15,
          qualityRating: 4,
          metadata: {'location': 'home', 'mood': 'relaxed'},
        );

        final json = originalCompletion.toJson();
        final deserializedCompletion = HabitCompletion.fromJson(json);

        expect(deserializedCompletion.id, originalCompletion.id);
        expect(deserializedCompletion.habitId, originalCompletion.habitId);
        expect(deserializedCompletion.habitName, originalCompletion.habitName);
        expect(
          deserializedCompletion.completedAt.isAtSameMomentAs(
            originalCompletion.completedAt,
          ),
          true,
        );
        expect(deserializedCompletion.notes, originalCompletion.notes);
        expect(
          deserializedCompletion.durationMinutes,
          originalCompletion.durationMinutes,
        );
        expect(
          deserializedCompletion.qualityRating,
          originalCompletion.qualityRating,
        );
        expect(deserializedCompletion.metadata, originalCompletion.metadata);
      });

      test(
        'HabitCompletion.copyWith should create a new instance with specified fields replaced',
        () {
          final originalCompletion = HabitCompletion(
            id: 'completion_123',
            habitId: 'habit_456',
            habitName: 'Morning Meditation',
            completedAt: DateTime(2023, 1, 5),
            durationMinutes: 15,
          );

          final updatedCompletion = originalCompletion.copyWith(
            notes: 'Added notes',
            qualityRating: 5,
          );

          expect(updatedCompletion.id, originalCompletion.id);
          expect(updatedCompletion.habitName, originalCompletion.habitName);
          expect(updatedCompletion.notes, 'Added notes');
          expect(updatedCompletion.qualityRating, 5);
          expect(
            updatedCompletion.durationMinutes,
            originalCompletion.durationMinutes,
          );
        },
      );

      test('HabitCompletion equality operator should work correctly', () {
        final completion1 = HabitCompletion(
          id: 'completion_123',
          habitId: 'habit_456',
          habitName: 'Morning Meditation',
          completedAt: DateTime(2023, 1, 5),
        );

        final completion2 = HabitCompletion(
          id: 'completion_123',
          habitId: 'habit_456',
          habitName: 'Morning Meditation',
          completedAt: DateTime(2023, 1, 5),
        );

        final completion3 = HabitCompletion(
          id: 'different_id',
          habitId: 'habit_456',
          habitName: 'Morning Meditation',
          completedAt: DateTime(2023, 1, 5),
        );

        expect(completion1, completion2);
        expect(completion1 == completion3, false);
      });

      test(
        'HabitCompletion toString should return a string representation',
        () {
          final completion = HabitCompletion(
            id: 'completion_123',
            habitId: 'habit_456',
            habitName: 'Morning Meditation',
            completedAt: DateTime(2023, 1, 5),
          );

          final stringRepresentation = completion.toString();
          expect(stringRepresentation.contains('completion_123'), true);
          expect(stringRepresentation.contains('Morning Meditation'), true);
        },
      );
    });

    group('StreakData', () {
      test('StreakData should serialize and deserialize correctly', () {
        final originalStreakData = StreakData(
          habitId: 'habit_456',
          currentStreak: 7,
          longestStreak: 14,
          currentStreakStartDate: DateTime(2023, 1, 1),
          lastCompletionDate: DateTime(2023, 1, 7),
          totalCompletions: 25,
          lastUpdated: DateTime(2023, 1, 7, 9, 30),
        );

        final json = originalStreakData.toJson();
        final deserializedStreakData = StreakData.fromJson(json);

        expect(deserializedStreakData.habitId, originalStreakData.habitId);
        expect(
          deserializedStreakData.currentStreak,
          originalStreakData.currentStreak,
        );
        expect(
          deserializedStreakData.longestStreak,
          originalStreakData.longestStreak,
        );
        expect(
          deserializedStreakData.currentStreakStartDate.isAtSameMomentAs(
            originalStreakData.currentStreakStartDate,
          ),
          true,
        );
        expect(
          deserializedStreakData.lastCompletionDate.isAtSameMomentAs(
            originalStreakData.lastCompletionDate,
          ),
          true,
        );
        expect(
          deserializedStreakData.totalCompletions,
          originalStreakData.totalCompletions,
        );
        expect(
          deserializedStreakData.lastUpdated.isAtSameMomentAs(
            originalStreakData.lastUpdated,
          ),
          true,
        );
      });

      test('StreakData.initial should create correct default instance', () {
        final habitId = 'habit_123';
        final streakData = StreakData.initial(habitId);

        expect(streakData.habitId, habitId);
        expect(streakData.currentStreak, 0);
        expect(streakData.longestStreak, 0);
        expect(streakData.totalCompletions, 0);

        // These should be around now, but we can't check exact time
        expect(streakData.currentStreakStartDate.day, DateTime.now().day);
        expect(streakData.lastCompletionDate.day, DateTime.now().day);
        expect(streakData.lastUpdated.day, DateTime.now().day);
      });

      test(
        'StreakData.copyWith should create a new instance with specified fields replaced',
        () {
          final originalStreakData = StreakData(
            habitId: 'habit_456',
            currentStreak: 7,
            longestStreak: 14,
            currentStreakStartDate: DateTime(2023, 1, 1),
            lastCompletionDate: DateTime(2023, 1, 7),
            totalCompletions: 25,
            lastUpdated: DateTime(2023, 1, 7),
          );

          final updatedStreakData = originalStreakData.copyWith(
            currentStreak: 8,
            totalCompletions: 26,
            lastCompletionDate: DateTime(2023, 1, 8),
          );

          expect(updatedStreakData.habitId, originalStreakData.habitId);
          expect(updatedStreakData.currentStreak, 8);
          expect(
            updatedStreakData.longestStreak,
            originalStreakData.longestStreak,
          );
          expect(updatedStreakData.totalCompletions, 26);
          expect(updatedStreakData.lastCompletionDate, DateTime(2023, 1, 8));
        },
      );

      test(
        'StreakData.updateWithCompletion should handle consecutive day correctly',
        () {
          final now = DateTime.now();
          final yesterday = DateTime(now.year, now.month, now.day - 1);

          final streakData = StreakData(
            habitId: 'habit_456',
            currentStreak: 3,
            longestStreak: 5,
            currentStreakStartDate: DateTime(now.year, now.month, now.day - 3),
            lastCompletionDate: yesterday,
            totalCompletions: 10,
            lastUpdated: yesterday,
          );

          final updatedStreakData = streakData.updateWithCompletion(now);

          expect(updatedStreakData.currentStreak, 4); // Incremented by 1
          expect(updatedStreakData.longestStreak, 5); // Unchanged
          expect(updatedStreakData.totalCompletions, 11); // Incremented by 1
          expect(updatedStreakData.lastCompletionDate, now);
          // Start date should be unchanged since it's a continuation
          expect(
            updatedStreakData.currentStreakStartDate,
            streakData.currentStreakStartDate,
          );
        },
      );

      test(
        'StreakData.updateWithCompletion should handle streak break correctly',
        () {
          final now = DateTime.now();
          final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

          final streakData = StreakData(
            habitId: 'habit_456',
            currentStreak: 3,
            longestStreak: 5,
            currentStreakStartDate: DateTime(now.year, now.month, now.day - 5),
            lastCompletionDate: twoDaysAgo,
            totalCompletions: 10,
            lastUpdated: twoDaysAgo,
          );

          final updatedStreakData = streakData.updateWithCompletion(now);

          expect(updatedStreakData.currentStreak, 1); // Reset to 1
          expect(updatedStreakData.longestStreak, 5); // Unchanged
          expect(updatedStreakData.totalCompletions, 11); // Incremented by 1
          expect(updatedStreakData.lastCompletionDate, now);
          // Start date should be updated to today
          expect(updatedStreakData.currentStreakStartDate, now);
        },
      );

      test(
        'StreakData.updateWithCompletion should update longest streak when needed',
        () {
          final now = DateTime.now();
          final yesterday = DateTime(now.year, now.month, now.day - 1);

          final streakData = StreakData(
            habitId: 'habit_456',
            currentStreak: 5,
            longestStreak: 5, // Current equals longest
            currentStreakStartDate: DateTime(now.year, now.month, now.day - 5),
            lastCompletionDate: yesterday,
            totalCompletions: 10,
            lastUpdated: yesterday,
          );

          final updatedStreakData = streakData.updateWithCompletion(now);

          expect(updatedStreakData.currentStreak, 6); // Incremented by 1
          expect(updatedStreakData.longestStreak, 6); // Also incremented
          expect(updatedStreakData.totalCompletions, 11); // Incremented by 1
        },
      );

      test('StreakData equality operator should work correctly', () {
        final streakData1 = StreakData(
          habitId: 'habit_456',
          currentStreak: 7,
          longestStreak: 14,
          currentStreakStartDate: DateTime(2023, 1, 1),
          lastCompletionDate: DateTime(2023, 1, 7),
          totalCompletions: 25,
          lastUpdated: DateTime(2023, 1, 7),
        );

        final streakData2 = StreakData(
          habitId: 'habit_456',
          currentStreak: 7,
          longestStreak: 14,
          currentStreakStartDate: DateTime(2023, 1, 1),
          lastCompletionDate: DateTime(2023, 1, 7),
          totalCompletions: 25,
          lastUpdated: DateTime(2023, 1, 7),
        );

        final streakData3 = StreakData(
          habitId: 'different_habit',
          currentStreak: 7,
          longestStreak: 14,
          currentStreakStartDate: DateTime(2023, 1, 1),
          lastCompletionDate: DateTime(2023, 1, 7),
          totalCompletions: 25,
          lastUpdated: DateTime(2023, 1, 7),
        );

        expect(streakData1, streakData2);
        expect(streakData1 == streakData3, false);
      });

      test('StreakData toString should return a string representation', () {
        final streakData = StreakData(
          habitId: 'habit_456',
          currentStreak: 7,
          longestStreak: 14,
          currentStreakStartDate: DateTime(2023, 1, 1),
          lastCompletionDate: DateTime(2023, 1, 7),
          totalCompletions: 25,
          lastUpdated: DateTime(2023, 1, 7),
        );

        final stringRepresentation = streakData.toString();
        expect(stringRepresentation.contains('habit_456'), true);
        expect(stringRepresentation.contains('currentStreak: 7'), true);
        expect(stringRepresentation.contains('longestStreak: 14'), true);
      });
    });
  });
}
