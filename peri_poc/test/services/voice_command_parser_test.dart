import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/services/voice_command_parser.dart';
import 'package:peri_poc/models/voice_models.dart';

void main() {
  group('VoiceCommandParser', () {
    late VoiceCommandParser parser;

    setUp(() {
      parser = VoiceCommandParser();
    });

    group('parseCommand', () {
      test('should handle empty input', () {
        final result = parser.parseCommand('');

        expect(result.isFailure, isTrue);
        expect(result.error, contains('Empty speech text'));
      });

      test('should handle whitespace-only input', () {
        final result = parser.parseCommand('   ');

        expect(result.isFailure, isTrue);
        expect(result.error, contains('Empty speech text'));
      });

      test('should recognize completion commands', () {
        final testCases = [
          'i did it',
          'done',
          'completed',
          'finished',
          'complete',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);

          expect(result.isSuccess, isTrue, reason: 'Failed for input: $input');
          final command = result.value;
          expect(command.type, equals(VoiceCommandType.completeHabit));
          expect(command.originalText, equals(input));
          expect(command.confidence, greaterThan(0.3));
        }
      });

      test('should recognize streak check commands', () {
        final testCases = [
          'what\'s my streak',
          'how many days',
          'streak count',
          'my streak',
          'current streak',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);

          expect(result.isSuccess, isTrue, reason: 'Failed for input: $input');
          final command = result.value;
          expect(command.type, equals(VoiceCommandType.checkStreak));
        }
      });

      test('should recognize help commands', () {
        final testCases = [
          'help',
          'what can you do',
          'commands',
          'instructions',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);

          expect(result.isSuccess, isTrue, reason: 'Failed for input: $input');
          final command = result.value;
          expect(command.type, equals(VoiceCommandType.help));
        }
      });

      test('should handle unknown commands', () {
        final testCases = [
          'random nonsense text',
          'the weather is nice today',
          'what time is it',
        ];

        for (final input in testCases) {
          final result = parser.parseCommand(input);

          expect(result.isSuccess, isTrue, reason: 'Failed for input: $input');
          final command = result.value;
          expect(command.type, equals(VoiceCommandType.unknown));
          expect(command.confidence, equals(0.0));
        }
      });
    });

    group('utility methods', () {
      test('should return supported command types', () {
        final supportedTypes = parser.getSupportedCommandTypes();

        expect(supportedTypes, contains(VoiceCommandType.completeHabit));
        expect(supportedTypes, contains(VoiceCommandType.checkStreak));
        expect(supportedTypes, contains(VoiceCommandType.habitStatus));
        expect(supportedTypes, contains(VoiceCommandType.help));
        expect(supportedTypes, isNot(contains(VoiceCommandType.unknown)));
      });

      test('should return pattern examples for command types', () {
        final examples = parser.getPatternExamples(
          VoiceCommandType.completeHabit,
        );

        expect(examples, isNotEmpty);
        expect(examples.length, lessThanOrEqualTo(5));
        expect(examples, contains('i did it'));
      });

      test('should return empty list for unknown command type', () {
        final examples = parser.getPatternExamples(VoiceCommandType.unknown);

        expect(examples, isEmpty);
      });

      test('should return parser metadata', () {
        final metadata = parser.getParserMetadata();

        expect(metadata['supported_command_types'], isA<int>());
        expect(metadata['total_patterns'], isA<int>());
        expect(metadata['version'], isA<String>());
      });
    });
  });
}
