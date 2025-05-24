import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/models/voice_models.dart';

void main() {
  group('Voice Models', () {
    group('SpeechResult', () {
      test('should create instance with required fields', () {
        const text = 'test speech';
        const confidence = 0.85;

        final result = SpeechResult(text: text, confidence: confidence);

        expect(result.text, text);
        expect(result.confidence, confidence);
        expect(result.isFinal, true); // Default value
      });

      test('should create instance with all fields', () {
        const text = 'test speech';
        const confidence = 0.85;
        const isFinal = false;

        final result = SpeechResult(
          text: text,
          confidence: confidence,
          isFinal: isFinal,
        );

        expect(result.text, text);
        expect(result.confidence, confidence);
        expect(result.isFinal, isFinal);
      });

      test('copyWith should create a copy with updated fields', () {
        final original = SpeechResult(
          text: 'original text',
          confidence: 0.5,
          isFinal: false,
        );

        final copy = original.copyWith(
          text: 'new text',
          confidence: 0.9,
          isFinal: true,
        );

        expect(copy.text, 'new text');
        expect(copy.confidence, 0.9);
        expect(copy.isFinal, true);

        // Original should be unchanged
        expect(original.text, 'original text');
        expect(original.confidence, 0.5);
        expect(original.isFinal, false);
      });
    });

    group('VoiceCommand', () {
      test('should create instance with required fields', () {
        const type = VoiceCommandType.completeHabit;
        const originalText = 'complete my habit';

        final command = VoiceCommand(type: type, originalText: originalText);

        expect(command.type, type);
        expect(command.originalText, originalText);
        expect(command.parameters, isEmpty);
        expect(command.confidence, 1.0); // Default value
      });

      test('should create instance with all fields', () {
        const type = VoiceCommandType.completeHabit;
        const originalText = 'complete my habit';
        final parameters = {'habitName': 'exercise'};
        const confidence = 0.85;

        final command = VoiceCommand(
          type: type,
          originalText: originalText,
          parameters: parameters,
          confidence: confidence,
        );

        expect(command.type, type);
        expect(command.originalText, originalText);
        expect(command.parameters, parameters);
        expect(command.confidence, confidence);
      });
    });

    group('TextToSpeechOptions', () {
      test('should create instance with default values', () {
        const options = TextToSpeechOptions();

        expect(options.rate, 1.0);
        expect(options.pitch, 1.0);
        expect(options.volume, 1.0);
      });

      test('should create instance with custom values', () {
        const options = TextToSpeechOptions(rate: 1.5, pitch: 0.8, volume: 0.9);

        expect(options.rate, 1.5);
        expect(options.pitch, 0.8);
        expect(options.volume, 0.9);
      });

      test('defaultOptions should have expected values', () {
        expect(TextToSpeechOptions.defaultOptions.rate, 1.0);
        expect(TextToSpeechOptions.defaultOptions.pitch, 1.0);
        expect(TextToSpeechOptions.defaultOptions.volume, 1.0);
      });
    });
  });
}
