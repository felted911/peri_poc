import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/presentation/widgets/voice_button.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';

void main() {
  testWidgets('VoiceButton renders correctly in idle state', (WidgetTester tester) async {
    bool buttonPressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.idle,
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      ),
    );
    
    // Verify button is rendered with idle icon
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    
    // Tap the button
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    
    // Verify onPressed callback was called
    expect(buttonPressed, true);
  });

  testWidgets('VoiceButton renders correctly in listening state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.listening,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify button is rendered with listening icon
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });

  testWidgets('VoiceButton renders correctly in processing state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.processing,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify button is rendered with processing icon
    expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
  });

  testWidgets('VoiceButton renders correctly in responding state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.responding,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify button is rendered with responding icon
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });

  testWidgets('VoiceButton renders correctly in error state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.error,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify button is rendered with error icon
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('VoiceButton uses custom icons when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.idle,
              onPressed: () {},
              idleIcon: Icons.access_time,
              listeningIcon: Icons.hearing,
              processingIcon: Icons.pending,
              respondingIcon: Icons.speaker,
              errorIcon: Icons.warning,
            ),
          ),
        ),
      ),
    );
    
    // Verify custom idle icon is used
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsNothing);
  });

  testWidgets('VoiceButton uses custom colors when provided', (WidgetTester tester) async {
    const primaryColor = Colors.purple;
    const secondaryColor = Colors.orange;
    const errorColor = Colors.red;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.idle,
              onPressed: () {},
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              errorColor: errorColor,
            ),
          ),
        ),
      ),
    );
    
    // Find the AnimatedContainer that should have the primary color
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(VoiceButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    
    // Extract the color from the BoxDecoration
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(primaryColor));
  });

  testWidgets('VoiceButton honors size and iconSize parameters', (WidgetTester tester) async {
    const double buttonSize = 100.0;
    const double iconSize = 50.0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceButton(
              state: VoiceInteractionState.idle,
              onPressed: () {},
              size: buttonSize,
              iconSize: iconSize,
            ),
          ),
        ),
      ),
    );
    
    // Verify the AnimatedContainer has the correct size constraints
    final containerSize = tester.getSize(
      find.descendant(
        of: find.byType(VoiceButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    
    expect(containerSize.width, equals(buttonSize));
    expect(containerSize.height, equals(buttonSize));
    
    // Find the icon and verify its size
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, equals(iconSize));
  });

  testWidgets('VoiceButton transitions between states correctly', (WidgetTester tester) async {
    // Create a stateful widget to test state transitions
    await tester.pumpWidget(
      MaterialApp(
        home: _TestVoiceButtonState(),
      ),
    );
    
    // Initially in idle state
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    
    // Transition to listening state
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    expect(find.byIcon(Icons.mic), findsOneWidget);
    
    // Transition to processing state
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    
    // Transition to responding state
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    
    // Transition to error state
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    
    // Back to idle state
    await tester.tap(find.byType(VoiceButton));
    await tester.pump();
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });
}

// Helper widget to test state transitions
class _TestVoiceButtonState extends StatefulWidget {
  @override
  _TestVoiceButtonStateState createState() => _TestVoiceButtonStateState();
}

class _TestVoiceButtonStateState extends State<_TestVoiceButtonState> {
  VoiceInteractionState _state = VoiceInteractionState.idle;
  
  void _cycleState() {
    setState(() {
      switch (_state) {
        case VoiceInteractionState.idle:
          _state = VoiceInteractionState.listening;
          break;
        case VoiceInteractionState.listening:
          _state = VoiceInteractionState.processing;
          break;
        case VoiceInteractionState.processing:
          _state = VoiceInteractionState.responding;
          break;
        case VoiceInteractionState.responding:
          _state = VoiceInteractionState.error;
          break;
        case VoiceInteractionState.error:
        case VoiceInteractionState.ready:
          _state = VoiceInteractionState.idle;
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VoiceButton(
          state: _state,
          onPressed: _cycleState,
        ),
      ),
    );
  }
}
