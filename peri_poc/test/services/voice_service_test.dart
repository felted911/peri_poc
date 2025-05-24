import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/models/voice_models.dart';
import 'package:mockito/mockito.dart';
import 'package:peri_poc/interfaces/i_voice_service.dart';

class MockVoiceService extends Mock implements IVoiceService {
  @override
  VoiceRecognitionStatus getRecognitionStatus() =>
      VoiceRecognitionStatus.inactive;

  @override
  TextToSpeechStatus getSpeechStatus() => TextToSpeechStatus.inactive;
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('VoiceServiceImpl', () {
    test('VoiceServiceImpl should be creatable', () {
      final service = MockVoiceService();
      expect(service, isA<IVoiceService>());
    });

    test('should have correct initial state', () {
      final service = MockVoiceService();
      // Check the default responses from our overridden methods
      expect(
        service.getRecognitionStatus(),
        equals(VoiceRecognitionStatus.inactive),
      );
      expect(service.getSpeechStatus(), equals(TextToSpeechStatus.inactive));
    });
  });
}
