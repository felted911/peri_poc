import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';
import 'package:peri_poc/presentation/home/home_view_model.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<VoiceInteractionCoordinator>(),
  MockSpec<IStorageService>(),
])
import 'home_view_model_test.mocks.dart';

void main() {
  late MockVoiceInteractionCoordinator mockCoordinator;
  late MockIStorageService mockStorageService;
  late HomeViewModel viewModel;
  late Function(VoiceInteractionState) stateCallback;
  late Function(String) resultCallback;
  late Function(String) errorCallback;

  setUp(() {
    mockCoordinator = MockVoiceInteractionCoordinator();
    mockStorageService = MockIStorageService();

    // Capture callbacks
    when(mockCoordinator.setOnStateChangedCallback(any)).thenAnswer((invocation) {
      stateCallback = invocation.positionalArguments[0] as Function(VoiceInteractionState);
    });
    
    when(mockCoordinator.setOnInteractionResultCallback(any)).thenAnswer((invocation) {
      resultCallback = invocation.positionalArguments[0] as Function(String);
    });
    
    when(mockCoordinator.setOnErrorCallback(any)).thenAnswer((invocation) {
      errorCallback = invocation.positionalArguments[0] as Function(String);
    });

    // Setup mock coordinator initialize
    when(mockCoordinator.initialize()).thenAnswer((_) async => Result.success(null));

    // Setup mock storage service
    final now = DateTime.now();
    final streakData = StreakData(
      habitId: 'default_habit',
      currentStreak: 5,
      longestStreak: 10,
      lastCompletionDate: now,
      currentStreakStartDate: now.subtract(const Duration(days: 5)),
      totalCompletions: 5,
      lastUpdated: now,
    );
    
    when(mockStorageService.getStreakData('default_habit', fileFactory: null)).thenAnswer((_) async => Result.success(streakData));
    when(mockStorageService.initialize()).thenAnswer((_) async => Result.success(null));

    // Create view model
    viewModel = HomeViewModel(
      voiceInteractionCoordinator: mockCoordinator,
      storageService: mockStorageService,
    );
  });

  test('initializes with correct default values', () {
    expect(viewModel.interactionState, equals(VoiceInteractionState.idle));
    expect(viewModel.recognizedText, equals(''));
    expect(viewModel.responseMessage, equals(''));
    expect(viewModel.isInteracting, equals(false));
    expect(viewModel.errorMessage, equals(null));
  });

  test('initializes services and loads streak data', () async {
    // Instead of verifying method calls which can be sensitive to mock setup,
    // directly verify the expected outcome
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Verify the streak data was loaded correctly by checking the view model properties
    expect(viewModel.currentStreak, equals(5));
    expect(viewModel.longestStreak, equals(10));
    
    // Verify that error state is not set, indicating successful initialization
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.interactionState, isNot(equals(VoiceInteractionState.error)));
  });

  test('starts voice interaction', () async {
    when(mockCoordinator.startInteraction()).thenAnswer((_) async => Result.success(null));
    
    await viewModel.startVoiceInteraction();
    
    verify(mockCoordinator.startInteraction()).called(1);
    expect(viewModel.errorMessage, isNull);
  });

  test('stops voice interaction', () async {
    when(mockCoordinator.stopInteraction()).thenAnswer((_) async => Result.success(null));
    
    await viewModel.stopVoiceInteraction();
    
    verify(mockCoordinator.stopInteraction()).called(1);
    expect(viewModel.errorMessage, isNull);
  });

  test('toggles voice interaction when not interacting', () async {
    when(mockCoordinator.startInteraction()).thenAnswer((_) async => Result.success(null));
    
    await viewModel.toggleVoiceInteraction();
    
    verify(mockCoordinator.startInteraction()).called(1);
    verifyNever(mockCoordinator.stopInteraction());
  });

  test('toggles voice interaction when already interacting', () async {
    // Set state to listening
    stateCallback(VoiceInteractionState.listening);
    
    when(mockCoordinator.stopInteraction()).thenAnswer((_) async => Result.success(null));
    
    await viewModel.toggleVoiceInteraction();
    
    verify(mockCoordinator.stopInteraction()).called(1);
    verifyNever(mockCoordinator.startInteraction());
  });

  test('updates state when coordinator state changes', () {
    stateCallback(VoiceInteractionState.listening);
    expect(viewModel.interactionState, equals(VoiceInteractionState.listening));
    expect(viewModel.isInteracting, equals(true));
    expect(viewModel.isListening, equals(true));
    
    stateCallback(VoiceInteractionState.processing);
    expect(viewModel.interactionState, equals(VoiceInteractionState.processing));
    expect(viewModel.isInteracting, equals(true));
    expect(viewModel.isProcessing, equals(true));
    
    stateCallback(VoiceInteractionState.responding);
    expect(viewModel.interactionState, equals(VoiceInteractionState.responding));
    expect(viewModel.isInteracting, equals(true));
    expect(viewModel.isResponding, equals(true));
    
    stateCallback(VoiceInteractionState.error);
    expect(viewModel.interactionState, equals(VoiceInteractionState.error));
    expect(viewModel.isInteracting, equals(false));
    expect(viewModel.hasError, equals(true));
    
    stateCallback(VoiceInteractionState.ready);
    expect(viewModel.interactionState, equals(VoiceInteractionState.ready));
    expect(viewModel.isInteracting, equals(false));
  });

  test('updates response message when interaction result received', () async {
    resultCallback('Test response message');
    
    // We shouldn't verify the exact call - just check that result is as expected
    expect(viewModel.responseMessage, equals('Test response message'));
  });

  test('updates error message when error received', () {
    errorCallback('Test error message');
    
    expect(viewModel.errorMessage, equals('Test error message'));
  });

  test('handles initialization failure', () async {
    // Create a new mock coordinator that fails to initialize
    final failingCoordinator = MockVoiceInteractionCoordinator();
    when(failingCoordinator.setOnStateChangedCallback(any)).thenAnswer((invocation) {
      stateCallback = invocation.positionalArguments[0] as Function(VoiceInteractionState);
    });
    
    when(failingCoordinator.setOnInteractionResultCallback(any)).thenAnswer((invocation) {
      resultCallback = invocation.positionalArguments[0] as Function(String);
    });
    
    when(failingCoordinator.setOnErrorCallback(any)).thenAnswer((invocation) {
      errorCallback = invocation.positionalArguments[0] as Function(String);
    });
    
    when(failingCoordinator.initialize()).thenAnswer((_) async => 
      Result.failure('Initialization failed'));
    
    final failingViewModel = HomeViewModel(
      voiceInteractionCoordinator: failingCoordinator,
      storageService: mockStorageService,
    );
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(failingViewModel.errorMessage, contains('Initialization failed'));
  });

  test('handles streak data loading failure', () async {
    // Create a new mock storage service that fails to get streak data
    final failingStorageService = MockIStorageService();
    when(failingStorageService.initialize()).thenAnswer((_) async => Result.success(null));
    when(failingStorageService.getStreakData(any, fileFactory: anyNamed('fileFactory'))).thenAnswer((_) async => 
      Result.failure('Failed to load streak data'));
    
    final newViewModel = HomeViewModel(
      voiceInteractionCoordinator: mockCoordinator,
      storageService: failingStorageService,
    );
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Streak should default to 0
    expect(newViewModel.currentStreak, equals(0));
    expect(newViewModel.longestStreak, equals(0));
  });

  test('cleans up resources on dispose', () async {
    // Use a fresh instance of the view model for this test
    final disposableViewModel = HomeViewModel(
      voiceInteractionCoordinator: mockCoordinator,
      storageService: mockStorageService,
    );
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Now dispose
    disposableViewModel.dispose();
    
    verify(mockCoordinator.dispose()).called(1);
  });
}
