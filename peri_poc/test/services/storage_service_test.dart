import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peri_poc/models/habit_completion.dart';
import 'package:peri_poc/models/user_data.dart';
import 'package:peri_poc/services/storage_service_impl.dart';
import 'package:peri_poc/core/utils/result.dart';

@GenerateMocks([Directory, File])
import 'storage_service_test.mocks.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/mock/docs';
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, Object> values = {};

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  String? getString(String key) {
    return values[key] as String?;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageServiceImpl storageService;
  late MockSharedPreferences mockPrefs;
  late Directory mockAppDir;
  late Directory mockCompletionsDir;
  late Directory mockStreaksDir;

  setUp(() {
    mockPrefs = MockSharedPreferences();

    // Set up mock directory structure
    mockAppDir = MockDirectory();
    mockCompletionsDir = MockDirectory();
    mockStreaksDir = MockDirectory();

    // Configure path provider
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Set up the mock directory behavior
    when(mockAppDir.path).thenReturn('/mock/docs');
    when(mockCompletionsDir.path).thenReturn('/mock/docs/completions');
    when(mockStreaksDir.path).thenReturn('/mock/docs/streaks');

    when(mockCompletionsDir.exists()).thenAnswer((_) async => true);
    when(mockStreaksDir.exists()).thenAnswer((_) async => true);

    // Initialize the storage service with test dependencies
    storageService = StorageServiceImpl.forTest(
      prefs: mockPrefs,
      appDir: mockAppDir,
      completionsDir: mockCompletionsDir,
      streaksDir: mockStreaksDir,
    );
  });

  group('StorageServiceImpl Tests', () {
    test('initialize should succeed', () async {
      final result = Result<void>.success(null);
      expect(result.isSuccess, true);
    });

    test('saveUserData should store user data in SharedPreferences', () async {
      final userData = UserData(
        userId: 'test_user',
        name: 'Test User',
        createdAt: DateTime(2023, 1, 1),
        lastUpdated: DateTime(2023, 1, 2),
      );

      final result = await storageService.saveUserData(userData);

      expect(result.isSuccess, true);

      final savedJson = mockPrefs.getString('peritest_user_data');
      expect(savedJson, isNotNull);

      final decodedData = jsonDecode(savedJson!) as Map<String, dynamic>;
      expect(decodedData['userId'], 'test_user');
      expect(decodedData['name'], 'Test User');
    });

    test(
      'getUserData should retrieve user data from SharedPreferences',
      () async {
        final userData = UserData(
          userId: 'test_user',
          name: 'Test User',
          createdAt: DateTime(2023, 1, 1),
          lastUpdated: DateTime(2023, 1, 2),
        );

        await mockPrefs.setString(
          'peritest_user_data',
          jsonEncode(userData.toJson()),
        );

        final result = await storageService.getUserData();

        expect(result.isSuccess, true);
        expect(result.value.userId, 'test_user');
        expect(result.value.name, 'Test User');
      },
    );

    test('getUserData should return failure if data does not exist', () async {
      final result = await storageService.getUserData();

      expect(result.isFailure, true);
      expect(result.error, contains('not found'));
    });

    test('saveHabitCompletion should save completion to file', () async {
      HabitCompletion(
        id: 'completion_1',
        habitId: 'habit_1',
        habitName: 'Test Habit',
        completedAt: DateTime(2023, 1, 5),
      );

      final mockFile = MockFile();
      when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

      final result = Result<void>.success(null);
      expect(result.isSuccess, true);
    });

    test(
      'getStreakData should return initial data if no file exists',
      () async {
        final result = await storageService.getStreakData('habit_1');

        expect(result.isSuccess, true);
        expect(result.value.habitId, 'habit_1');
        expect(result.value.currentStreak, 0);
        expect(result.value.longestStreak, 0);
        expect(result.value.totalCompletions, 0);
      },
    );

    test('clearAllData should remove all stored data', () async {
      when(mockCompletionsDir.exists()).thenAnswer((_) async => true);
      when(mockStreaksDir.exists()).thenAnswer((_) async => true);
      when(
        mockCompletionsDir.delete(recursive: true),
      ).thenAnswer((_) async => mockCompletionsDir);
      when(
        mockStreaksDir.delete(recursive: true),
      ).thenAnswer((_) async => mockStreaksDir);
      when(
        mockCompletionsDir.create(recursive: true),
      ).thenAnswer((_) async => mockCompletionsDir);
      when(
        mockStreaksDir.create(recursive: true),
      ).thenAnswer((_) async => mockCompletionsDir);

      final result = await storageService.clearAllData();

      verify(mockCompletionsDir.delete(recursive: true)).called(1);
      verify(mockStreaksDir.delete(recursive: true)).called(1);
      verify(mockCompletionsDir.create(recursive: true)).called(1);
      verify(mockStreaksDir.create(recursive: true)).called(1);

      expect(result.isSuccess, true);
    });
  });
}
