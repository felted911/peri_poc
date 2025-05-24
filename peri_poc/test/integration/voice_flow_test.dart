import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/services/voice_command_parser.dart';
import 'package:peri_poc/models/voice_models.dart';

/// Integration tests for voice flow components
///
/// These tests verify that the voice command parser integrates properly
/// with the voice models and command flow logic.
void main() {
  group('Voice Flow Integration Tests', () {
    late VoiceCommandParser parser;

    setUp(() {
      parser = VoiceCommandParser();
    });

    group('End-to-End Command Processing', () {
      test('should process complete habit completion flow', () {
        // Simulate complete flow from speech to command
        const speechInput = 'I finished my workout';

        // Parse command
        final parseResult = parser.parseCommand(speechInput);
        expect(parseResult.isSuccess, isTrue);

        final command = parseResult.value;
        expect(command.type, equals(VoiceCommandType.completeHabit));
        expect(command.originalText, equals(speechInput));
        expect(command.confidence, greaterThan(0.5));

        // Verify parameters extracted
        expect(command.parameters['action'], equals('complete'));
        expect(command.parameters.containsKey('habit_keywords'), isTrue);
      });

      test('should process complete streak check flow', () {
        const speechInput = 'How many days is my current streak?';

        final parseResult = parser.parseCommand(speechInput);
        expect(parseResult.isSuccess, isTrue);

        final command = parseResult.value;
        expect(command.type, equals(VoiceCommandType.checkStreak));
        expect(command.parameters['query'], equals('streak'));
        expect(command.confidence, greaterThan(0.5));
      });

      test('should process complete status check flow', () {
        const speechInput = 'Did I complete my habit today?';

        final parseResult = parser.parseCommand(speechInput);
        expect(parseResult.isSuccess, isTrue);

        final command = parseResult.value;
        expect(command.type, equals(VoiceCommandType.habitStatus));
        expect(command.parameters['query'], equals('status'));
      });

      test('should process complete help flow', () {
        const speechInput = 'What voice commands can I use?';

        final parseResult = parser.parseCommand(speechInput);
        expect(parseResult.isSuccess, isTrue);

        final command = parseResult.value;
        expect(command.type, equals(VoiceCommandType.help));
        expect(command.parameters['topic'], equals('commands'));
      });
    });

    group('Complex Speech Patterns', () {
      test('should handle conversational completion commands', () {
        final testCases = [
          'Yeah, I just finished my morning exercise routine',
          'Well, I did complete my meditation session today',
          'Oh yes, I worked out for 30 minutes this morning',
          'Actually, I just finished reading for the day',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue, reason: 'Failed for: $input');

          final command = result.value;
          expect(
            command.type,
            equals(VoiceCommandType.completeHabit),
            reason: 'Wrong type for: $input',
          );
          expect(
            command.confidence,
            greaterThan(0.3),
            reason: 'Low confidence for: $input',
          );
        }
      });

      test('should handle natural streak inquiries', () {
        final testCases = [
          'I\'m curious about my streak - how long is it?',
          'Can you tell me about my current streak?',
          'What\'s the status of my consecutive days?',
          'How am I doing with my streak lately?',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue, reason: 'Failed for: $input');

          final command = result.value;
          expect(
            [VoiceCommandType.checkStreak, VoiceCommandType.habitStatus],
            contains(command.type),
            reason: 'Wrong type for: $input',
          );
        }
      });

      test('should handle context-rich commands', () {
        final result = parser.parseCommand(
          'I just completed my daily meditation practice this morning at 7 AM',
        );

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.completeHabit));

        // Should extract time and habit context
        expect(command.parameters['time_keywords'], contains('morning'));
        expect(command.parameters['time_of_day'], equals('morning'));
        expect(command.parameters['habit_keywords'], contains('meditation'));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle ambiguous commands gracefully', () {
        final ambiguousInputs = [
          'I think maybe I did something earlier',
          'Well, sort of completed it',
          'I might have done the thing',
        ];

        for (final input in ambiguousInputs) {
          final result = parser.parseCommand(input);
          expect(
            result.isSuccess,
            isTrue,
            reason: 'Should not fail for: $input',
          );

          final command = result.value;
          // Should have low confidence or be unknown
          expect(
            command.confidence < 0.7 ||
                command.type == VoiceCommandType.unknown,
            isTrue,
            reason: 'Should have low confidence or be unknown for: $input',
          );
        }
      });

      test('should handle noisy speech input', () {
        final noisyInputs = [
          'um... I did it... uh... today',
          'well, you know, I finished the thing',
          'like, I totally completed it and stuff',
        ];

        for (final input in noisyInputs) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue, reason: 'Should handle: $input');

          final command = result.value;
          expect(
            command.type,
            equals(VoiceCommandType.completeHabit),
            reason: 'Should still parse completion for: $input',
          );
        }
      });

      test('should distinguish between similar sounding commands', () {
        // Commands that might be confused
        final commandPairs = [
          ('What\'s my streak?', VoiceCommandType.checkStreak),
          ('What\'s my status?', VoiceCommandType.habitStatus),
          ('I did it', VoiceCommandType.completeHabit),
          ('What can I do?', VoiceCommandType.help),
        ];

        for (final (input, expectedType) in commandPairs) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue, reason: 'Failed for: $input');

          final command = result.value;
          expect(
            command.type,
            equals(expectedType),
            reason: 'Wrong type for: $input',
          );
        }
      });
    });

    group('Performance and Reliability', () {
      test('should handle rapid command processing', () {
        final commands = [
          'I did it',
          'What\'s my streak?',
          'How am I doing?',
          'Help me',
          'I completed it',
        ];

        final results = <VoiceCommand>[];

        for (final input in commands) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue);
          results.add(result.value);
        }

        expect(results, hasLength(5));
        expect(
          results.map((c) => c.type).toSet(),
          hasLength(4),
        ); // Should have 4 different types
      });

      test('should maintain consistency across multiple parses', () {
        const input = 'I finished my daily exercise';

        final results = <VoiceCommand>[];
        for (int i = 0; i < 5; i++) {
          final result = parser.parseCommand(input);
          expect(result.isSuccess, isTrue);
          results.add(result.value);
        }

        // All results should be identical
        final firstResult = results.first;
        for (final result in results) {
          expect(result.type, equals(firstResult.type));
          expect(result.confidence, equals(firstResult.confidence));
          expect(result.originalText, equals(firstResult.originalText));
        }
      });
    });

    group('Command Parameter Extraction Integration', () {
      test('should extract comprehensive parameters for habit completion', () {
        final result = parser.parseCommand(
          'I just finished my morning workout routine today',
        );

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.completeHabit));

        // Should extract multiple types of parameters
        expect(command.parameters.containsKey('action'), isTrue);
        expect(command.parameters.containsKey('time_keywords'), isTrue);
        expect(command.parameters.containsKey('habit_keywords'), isTrue);
        expect(command.parameters.containsKey('time_context'), isTrue);

        expect(command.parameters['action'], equals('complete'));
        expect(command.parameters['time_context'], equals('time_of_day'));
        expect(command.parameters['time_of_day'], equals('morning'));
      });

      test('should handle commands with no extractable parameters', () {
        final result = parser.parseCommand('done');

        expect(result.isSuccess, isTrue);
        final command = result.value;
        expect(command.type, equals(VoiceCommandType.completeHabit));
        expect(command.parameters['action'], equals('complete'));

        // Should still have basic parameters even for simple commands
        expect(command.parameters, isNotEmpty);
      });
    });

    group('Voice Models Integration', () {
      test('should create valid SpeechResult objects', () {
        final speechResult = SpeechResult(
          text: 'I completed my habit',
          confidence: 0.95,
          isFinal: true,
        );

        expect(speechResult.text, equals('I completed my habit'));
        expect(speechResult.confidence, equals(0.95));
        expect(speechResult.isFinal, isTrue);

        // Test that it can be processed by parser
        final parseResult = parser.parseCommand(speechResult.text);
        expect(parseResult.isSuccess, isTrue);
      });

      test('should handle VoiceCommand objects correctly', () {
        final command = VoiceCommand(
          type: VoiceCommandType.completeHabit,
          originalText: 'I did it',
          confidence: 0.9,
          parameters: {'action': 'complete', 'test': 'value'},
        );

        expect(command.type, equals(VoiceCommandType.completeHabit));
        expect(command.originalText, equals('I did it'));
        expect(command.confidence, equals(0.9));
        expect(command.parameters['action'], equals('complete'));
        expect(command.parameters['test'], equals('value'));
      });

      test('should handle TextToSpeechOptions correctly', () {
        const options = TextToSpeechOptions(rate: 1.2, pitch: 0.8, volume: 0.9);

        expect(options.rate, equals(1.2));
        expect(options.pitch, equals(0.8));
        expect(options.volume, equals(0.9));

        // Test default options
        const defaultOptions = TextToSpeechOptions.defaultOptions;
        expect(defaultOptions.rate, equals(1.0));
        expect(defaultOptions.pitch, equals(1.0));
        expect(defaultOptions.volume, equals(1.0));
      });
    });
  });
}
