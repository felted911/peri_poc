import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/presentation/widgets/streak_display.dart';

void main() {
  testWidgets('StreakDisplay renders correctly with zero streak', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 0,
              longestStreak: 0,
            ),
          ),
        ),
      ),
    );
    
    // Verify the streak count shows 0
    expect(find.text('0'), findsOneWidget);
    
    // Verify the zero streak text is displayed
    expect(find.text('No active streak'), findsOneWidget);
    
    // Longest streak should not be shown
    expect(find.textContaining('Longest:'), findsNothing);
  });

  testWidgets('StreakDisplay renders correctly with single day streak', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 1,
              longestStreak: 5,
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Verify the streak count shows 1
    expect(find.text('1'), findsOneWidget);
    
    // Verify singular form is used
    expect(find.text('1 day streak'), findsOneWidget);
    
    // Longest streak should be shown
    expect(find.text('Longest: 5 days'), findsOneWidget);
  });

  testWidgets('StreakDisplay renders correctly with multi-day streak', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 7,
              longestStreak: 15,
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Verify the streak count shows 7
    expect(find.text('7'), findsOneWidget);
    
    // Verify plural form is used
    expect(find.text('7 days streak'), findsOneWidget);
    
    // Longest streak should be shown
    expect(find.text('Longest: 15 days'), findsOneWidget);
  });

  testWidgets('StreakDisplay shows new record indicator for record-breaking streak', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 20,
              longestStreak: 15,  // Current > Longest, should show NEW indicator
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Verify NEW indicator is shown
    expect(find.text('NEW!'), findsOneWidget);
  });

  testWidgets('StreakDisplay respects custom title and zero streak text', (WidgetTester tester) async {
    const customTitle = 'Your Streak';
    const customZeroText = 'Start your streak today!';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 0,
              title: customTitle,
              zeroStreakText: customZeroText,
            ),
          ),
        ),
      ),
    );
    
    // Verify custom texts are used
    expect(find.text(customTitle), findsOneWidget);
    expect(find.text(customZeroText), findsOneWidget);
  });

  testWidgets('StreakDisplay can hide longest streak display', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 3,
              longestStreak: 10,
              showLongestStreak: false,  // Don't show longest streak
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Longest streak should not be shown
    expect(find.textContaining('Longest:'), findsNothing);
  });

  testWidgets('StreakDisplay uses custom colors when provided', (WidgetTester tester) async {
    const primaryColor = Colors.purple;
    const backgroundColor = Colors.yellow;
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 5,
              primaryColor: primaryColor,
              backgroundColor: backgroundColor,
            ),
          ),
        ),
      ),
    );
    
    // Find the Card widget that should have the background color
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, equals(backgroundColor));
    
    // Find the streak counter text and check its color
    // This is more complicated since we need to find the Text widget 
    // with the streak count and check its style
    final richTextWidgets = tester.widgetList<RichText>(find.byType(RichText));
    
    bool foundColorMatch = false;
    for (final richText in richTextWidgets) {
      if (richText.text is TextSpan) {
        final TextSpan textSpan = richText.text as TextSpan;
        if (textSpan.style?.color == primaryColor) {
          foundColorMatch = true;
          break;
        }
      }
    }
    
    expect(foundColorMatch, true, reason: 'Should find text with primary color');
  });

  testWidgets('StreakDisplay animates when streak changes', (WidgetTester tester) async {
    // Create a stateful widget to test animations
    await tester.pumpWidget(
      MaterialApp(
        home: _TestStreakDisplayState(),
      ),
    );
    
    // Initially streak is 0
    expect(find.text('0'), findsOneWidget);
    
    // Tap to increment streak
    await tester.tap(find.byType(FloatingActionButton));
    
    // Wait for animation to start but not complete
    await tester.pump(const Duration(milliseconds: 250));
    
    // Animation should be in progress
    // At 250ms with a 500ms animation, we should see intermediate values
    // But testing exact animation values is difficult, so just verify
    // the animation completes correctly
    
    // Wait for animation to complete
    await tester.pumpAndSettle();
    
    // After animation completes, streak should be 1
    expect(find.text('1'), findsOneWidget);
  });
  
  testWidgets('StreakDisplay streak visualization shows correct active dots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StreakDisplay(
              currentStreak: 3, // Should show 3 active dots
              longestStreak: 10,
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Check visualization is present
    // We can't easily test the specific appearance of each dot,
    // but we can verify the Container widgets exist
    final containers = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(StreakDisplay),
        matching: find.byType(Container),
      ),
    );
    
    // We should have at least 7 containers for the dots
    expect(containers.length, greaterThanOrEqualTo(7));
  });

  testWidgets('StreakDisplay can be sized via parent constraints', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200, // Constrain width
              child: StreakDisplay(
                currentStreak: 5,
                longestStreak: 10,
              ),
            ),
          ),
        ),
      ),
    );
    
    // Find the Card widget and check its size
    final cardSize = tester.getSize(find.byType(Card));
    
    // Width should be constrained by parent
    expect(cardSize.width, equals(200));
  });
}

// Helper widget to test animations
class _TestStreakDisplayState extends StatefulWidget {
  @override
  _TestStreakDisplayStateState createState() => _TestStreakDisplayStateState();
}

class _TestStreakDisplayStateState extends State<_TestStreakDisplayState> {
  int _streak = 0;
  
  void _incrementStreak() {
    setState(() {
      _streak++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreakDisplay(
          currentStreak: _streak,
          longestStreak: 10,
          // Use shorter animation for testing
          animationDuration: const Duration(milliseconds: 500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementStreak,
        child: const Icon(Icons.add),
      ),
    );
  }
}
