import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';
import 'package:peri_poc/models/streak_data.dart';
import 'package:peri_poc/presentation/home/home_screen.dart';
import 'package:peri_poc/presentation/widgets/streak_display.dart';
import 'package:peri_poc/presentation/widgets/voice_button.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<VoiceInteractionCoordinator>(),
  MockSpec<IStorageService>(),
])
import 'home_screen_test.mocks.dart';

void main() {
  late MockVoiceInteractionCoordinator mockCoordinator;
  late MockIStorageService mockStorageService;
  final getIt = GetIt.instance;

  setUp(() {
    mockCoordinator = MockVoiceInteractionCoordinator();
    mockStorageService = MockIStorageService();

    // Set up coordinator mocks
    when(mockCoordinator.initialize()).thenAnswer((_) async => Result.success(null));
    when(mockCoordinator.setOnStateChangedCallback(any)).thenAnswer((_) {});
    when(mockCoordinator.setOnInteractionResultCallback(any)).thenAnswer((_) {});
    when(mockCoordinator.setOnErrorCallback(any)).thenAnswer((_) {});
    when(mockCoordinator.startInteraction()).thenAnswer((_) async => Result.success(null));
    when(mockCoordinator.stopInteraction()).thenAnswer((_) async => Result.success(null));
    
    // Set up storage service mocks
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
    
    when(mockStorageService.initialize()).thenAnswer((_) async => Result.success(null));
    when(mockStorageService.getStreakData('default_habit', fileFactory: null))
        .thenAnswer((_) async => Result.success(streakData));
    
    // Register mocks with GetIt
    if (getIt.isRegistered<VoiceInteractionCoordinator>()) {
      getIt.unregister<VoiceInteractionCoordinator>();
    }
    if (getIt.isRegistered<IStorageService>()) {
      getIt.unregister<IStorageService>();
    }
    
    getIt.registerSingleton<VoiceInteractionCoordinator>(mockCoordinator);
    getIt.registerSingleton<IStorageService>(mockStorageService);
  });

  tearDown(() {
    // Clean up GetIt registrations
    if (getIt.isRegistered<VoiceInteractionCoordinator>()) {
      getIt.unregister<VoiceInteractionCoordinator>();
    }
    if (getIt.isRegistered<IStorageService>()) {
      getIt.unregister<IStorageService>();
    }
  });

  testWidgets('HomeScreen renders all required components', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization
    await tester.pump(const Duration(milliseconds: 300)); // Initial frame
    await tester.pump(const Duration(milliseconds: 300)); // Frame after initialization starts
    await tester.pumpAndSettle(const Duration(milliseconds: 300)); // Wait for animations to settle
    
    // Verify app bar with title
    expect(find.text('Test Home Screen'), findsOneWidget);
    
    // Verify streak display is present
    expect(find.byType(StreakDisplay), findsOneWidget);
    
    // Verify voice button is present
    expect(find.byType(VoiceButton), findsOneWidget);
    
    // Initial state message should be shown
    expect(find.text('Tap the microphone to start'), findsOneWidget);
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Voice button triggers interaction start/stop', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // Find and tap the voice button
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    
    // Verify startInteraction was called
    verify(mockCoordinator.startInteraction()).called(1);
    
    // Simulate state change to listening
    final stateCallback = verify(mockCoordinator.setOnStateChangedCallback(captureAny))
        .captured.first as Function(VoiceInteractionState);
    stateCallback(VoiceInteractionState.listening);
    
    // Pump to reflect state change
    await tester.pump();
    
    // Status should now show listening
    expect(find.text('Listening...'), findsOneWidget);
    
    // Tap again to stop
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    
    // Verify stopInteraction was called
    verify(mockCoordinator.stopInteraction()).called(1);
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Response message appears when result received', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // Capture the interaction result callback
    final resultCallback = verify(mockCoordinator.setOnInteractionResultCallback(captureAny))
        .captured.first as Function(String);
    
    // Simulate a response
    resultCallback('This is a test response message');
    
    // Pump to start animation
    await tester.pump();
    
    // Allow animation to complete
    await tester.pumpAndSettle();
    
    // Verify response message is displayed
    expect(find.text('This is a test response message'), findsOneWidget);
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Error state shows error message', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // Capture state and error callbacks
    final stateCallback = verify(mockCoordinator.setOnStateChangedCallback(captureAny))
        .captured.first as Function(VoiceInteractionState);
    
    final errorCallback = verify(mockCoordinator.setOnErrorCallback(captureAny))
        .captured.first as Function(String);
    
    // Simulate an error
    errorCallback('Test error occurred');
    stateCallback(VoiceInteractionState.error);
    
    // Pump to reflect state change
    await tester.pump();
    
    // Error message should be displayed
    expect(find.text('Test error occurred'), findsOneWidget);
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Screen updates when processing state changes', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // Capture state callback
    final stateCallback = verify(mockCoordinator.setOnStateChangedCallback(captureAny))
        .captured.first as Function(VoiceInteractionState);
    
    // Test all different states
    final states = [
      VoiceInteractionState.listening,
      VoiceInteractionState.processing,
      VoiceInteractionState.responding,
      VoiceInteractionState.ready,
      VoiceInteractionState.idle,
    ];
    
    final stateMessages = [
      'Listening...',
      'Processing...',
      'Responding...',
      'Tap the microphone to start',
      'Tap the microphone to start',
    ];
    
    for (var i = 0; i < states.length; i++) {
      // Set the state
      stateCallback(states[i]);
      
      // Pump to reflect state change
      await tester.pump();
      
      // Verify correct message is shown
      expect(find.text(stateMessages[i]), findsOneWidget);
    }
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Streak display shows current streak from storage', (WidgetTester tester) async {
    // Set a larger window size to avoid overflow issues in testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization and animations
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // Check the streak display has loaded data
    // We configured the mock to return streak of 5
    final streakDisplayFinder = find.byType(StreakDisplay);
    expect(streakDisplayFinder, findsOneWidget);
    
    final streakDisplay = tester.widget<StreakDisplay>(streakDisplayFinder);
    expect(streakDisplay.currentStreak, equals(5));
    expect(streakDisplay.longestStreak, equals(10));
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Home screen layout is responsive', (WidgetTester tester) async {
    // Test with a small screen size but one large enough to avoid overflow in tests
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(title: 'Test Home Screen'),
      ),
    );
    
    // Allow time for async initialization and animations
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    
    // All elements should still be visible
    expect(find.byType(StreakDisplay), findsOneWidget);
    expect(find.byType(VoiceButton), findsOneWidget);
    
    // Reset the test window size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
