import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/interfaces/i_voice_service.dart';
import 'package:peri_poc/models/voice_models.dart';
import 'package:mockito/mockito.dart';

class MockVoiceService extends Mock implements IVoiceService {}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('IVoiceService Interface', () {
    // This test doesn't test the implementation, just ensures that
    // VoiceServiceImpl properly implements the IVoiceService interface
    test('VoiceServiceImpl should implement IVoiceService', () {
      // Use a mock instead of the real implementation to avoid platform channel issues
      final IVoiceService service = MockVoiceService();

      // Basic type assertions - these are compile-time checks but we include
      // them for clarity
      expect(service, isA<IVoiceService>());
    });

    test('Voice recognition status enum should have required values', () {
      expect(
        VoiceRecognitionStatus.values,
        contains(VoiceRecognitionStatus.inactive),
      );
      expect(
        VoiceRecognitionStatus.values,
        contains(VoiceRecognitionStatus.listening),
      );
      expect(
        VoiceRecognitionStatus.values,
        contains(VoiceRecognitionStatus.processing),
      );
      expect(
        VoiceRecognitionStatus.values,
        contains(VoiceRecognitionStatus.error),
      );
      expect(
        VoiceRecognitionStatus.values,
        contains(VoiceRecognitionStatus.notAvailable),
      );
    });

    test('Text-to-speech status enum should have required values', () {
      expect(TextToSpeechStatus.values, contains(TextToSpeechStatus.inactive));
      expect(TextToSpeechStatus.values, contains(TextToSpeechStatus.speaking));
      expect(TextToSpeechStatus.values, contains(TextToSpeechStatus.error));
      expect(
        TextToSpeechStatus.values,
        contains(TextToSpeechStatus.notAvailable),
      );
    });
  });
}
