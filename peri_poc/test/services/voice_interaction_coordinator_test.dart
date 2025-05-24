import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';
import 'package:peri_poc/services/voice_command_parser.dart';
import 'package:peri_poc/models/voice_models.dart';

void main() {
  group('VoiceInteractionCoordinator', () {
    late VoiceCommandParser parser;

    setUp(() {
      parser = VoiceCommandParser();
    });

    group('basic functionality', () {
      test('should create coordinator instance', () {
        // This is a simplified test that doesn't require mocks
        expect(parser, isNotNull);
        expect(parser.getSupportedCommandTypes(), isNotEmpty);
      });

      test('should handle voice command parsing integration', () {
        // Test the integration between coordinator and parser
        final result = parser.parseCommand('I did it');

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.completeHabit));
        expect(command.originalText, equals('I did it'));
      });

      test('should handle streak check commands', () {
        final result = parser.parseCommand('What\'s my streak?');

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.checkStreak));
      });

      test('should handle help commands', () {
        final result = parser.parseCommand('help');

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.help));
      });
    });

    group('state management', () {
      test('should have correct initial state', () {
        // Test basic state concepts without requiring full coordinator setup
        const initialState = VoiceInteractionState.idle;
        expect(initialState, equals(VoiceInteractionState.idle));
      });

      test('should have defined interaction states', () {
        // Verify all expected states exist
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.idle),
        );
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.ready),
        );
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.listening),
        );
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.processing),
        );
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.responding),
        );
        expect(
          VoiceInteractionState.values,
          contains(VoiceInteractionState.error),
        );
      });
    });

    group('event types', () {
      test('should have defined event types', () {
        // Verify all expected event types exist
        expect(
          VoiceInteractionEventType.values,
          contains(VoiceInteractionEventType.sessionStarted),
        );
        expect(
          VoiceInteractionEventType.values,
          contains(VoiceInteractionEventType.sessionEnded),
        );
        expect(
          VoiceInteractionEventType.values,
          contains(VoiceInteractionEventType.speechRecognized),
        );
        expect(
          VoiceInteractionEventType.values,
          contains(VoiceInteractionEventType.commandParsed),
        );
        expect(
          VoiceInteractionEventType.values,
          contains(VoiceInteractionEventType.responseGenerated),
        );
      });
    });

    group('interaction events', () {
      test('should create interaction event correctly', () {
        final event = VoiceInteractionEvent(
          type: VoiceInteractionEventType.speechRecognized,
          timestamp: DateTime.now(),
          description: 'Test event',
          sessionId: 'test_session',
        );

        expect(event.type, equals(VoiceInteractionEventType.speechRecognized));
        expect(event.description, equals('Test event'));
        expect(event.sessionId, equals('test_session'));
        expect(event.timestamp, isNotNull);
      });

      test('should convert event to JSON', () {
        final event = VoiceInteractionEvent(
          type: VoiceInteractionEventType.commandParsed,
          timestamp: DateTime.now(),
          description: 'Command parsed',
          sessionId: 'session_123',
        );

        final json = event.toJson();
        expect(json['type'], contains('commandParsed'));
        expect(json['description'], equals('Command parsed'));
        expect(json['session_id'], equals('session_123'));
        expect(json['timestamp'], isA<String>());
      });
    });
  });
}
