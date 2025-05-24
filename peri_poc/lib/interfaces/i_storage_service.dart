import 'dart:io';

import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/models/user_data.dart';

/// Interface for data storage services
///
/// This interface defines the contract for persistent data storage
/// capabilities that the application uses for user data, habit tracking,
/// and streak calculations.
abstract class IStorageService {
  /// Initialize the storage service
  ///
  /// This should be called before any other methods to set up
  /// the storage service and ensure all necessary storage areas exist.
  ///
  /// [directoryFactory] is an optional parameter used for testing to mock Directory creation.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> initialize({
    Directory Function(String)? directoryFactory,
  });

  /// Save user data to persistent storage
  ///
  /// Takes the provided [userData] and saves it to the appropriate storage medium.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> saveUserData(UserData userData);

  /// Retrieve user data from persistent storage
  ///
  /// Returns a [Result] containing the [UserData] if successful,
  /// or an error message if the operation fails
  Future<Result<UserData>> getUserData();

  /// Save a habit completion record
  ///
  /// Takes the provided [completion] and saves it to the appropriate storage medium.
  /// [fileFactory] is an optional parameter used for testing to mock File creation.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> saveHabitCompletion(
    HabitCompletion completion, {
    File Function(String)? fileFactory,
  });

  /// Get all habit completions within a date range
  ///
  /// Retrieves all habit completions between [startDate] and [endDate] inclusive.
  /// If [habitId] is provided, only completions for that habit are returned.
  ///
  /// Returns a [Result] containing a list of [HabitCompletion] objects if successful,
  /// or an error message if the operation fails
  Future<Result<List<HabitCompletion>>> getHabitCompletions({
    required DateTime startDate,
    required DateTime endDate,
    String? habitId,
  });

  /// Get the current streak data
  ///
  /// Retrieves the current streak data for the specified [habitId].
  /// [fileFactory] is an optional parameter used for testing to mock File creation.
  ///
  /// Returns a [Result] containing the [StreakData] if successful,
  /// or an error message if the operation fails
  Future<Result<StreakData>> getStreakData(
    String habitId, {
    File Function(String)? fileFactory,
  });

  /// Update streak data
  ///
  /// Takes the provided [streakData] and updates the stored data.
  /// [fileFactory] is an optional parameter used for testing to mock File creation.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> updateStreakData(
    StreakData streakData, {
    File Function(String)? fileFactory,
  });

  /// Calculate current streak length
  ///
  /// Calculates the current streak length for the specified [habitId]
  /// based on stored completion records.
  /// [fileFactory] is an optional parameter used for testing to mock File creation.
  ///
  /// Returns a [Result] containing the streak length as an integer if successful,
  /// or an error message if the operation fails
  Future<Result<int>> calculateCurrentStreak(
    String habitId, {
    File Function(String)? fileFactory,
  });

  /// Calculate longest streak
  ///
  /// Calculates the longest streak ever achieved for the specified [habitId]
  /// based on stored completion records.
  /// [fileFactory] is an optional parameter used for testing to mock File creation.
  ///
  /// Returns a [Result] containing the longest streak length as an integer if successful,
  /// or an error message if the operation fails
  Future<Result<int>> calculateLongestStreak(
    String habitId, {
    File Function(String)? fileFactory,
  });

  /// Clear all stored data
  ///
  /// Removes all user data, habit completions, and streak data from storage.
  /// Primarily used for testing or when a user wants to reset the application.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> clearAllData();

  /// Export data as JSON
  ///
  /// Exports all stored data in a JSON format that can be used for backup
  /// or transferring data to another device.
  ///
  /// Returns a [Result] containing the JSON string if successful,
  /// or an error message if the operation fails
  Future<Result<String>> exportDataAsJson();

  /// Import data from JSON
  ///
  /// Imports data from a JSON string, replacing all current data.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> importDataFromJson(String jsonData);

  /// Dispose of any resources used by the storage service
  ///
  /// This should be called when the storage service is no longer needed
  /// to release any held resources.
  Future<void> dispose();
}
