import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/services/tensorflow_stt_service.dart';
import 'package:peri_poc/services/voice_service_impl.dart';
import 'package:peri_poc/utils/audio_processor.dart';
import 'package:peri_poc/models/voice_models.dart';

void main() {
  // Initialize Flutter bindings for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TensorFlowSTTService', () {
    late TensorFlowSTTService service;

    setUp(() {
      service = TensorFlowSTTService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should create service instance', () {
      expect(service, isNotNull);
      expect(service.isInitialized, isFalse);
      expect(service.isRecording, isFalse);
    });

    test('should provide supported commands list', () {
      final commands = service.supportedCommands;
      expect(commands, isNotEmpty);
      expect(commands, contains('complete'));
      expect(commands, contains('help'));
      expect(commands, contains('streak'));
    });

    test('should handle initialization gracefully when model missing', () async {
      // This test will fail if model is missing, but service should handle it gracefully
      final result = await service.initialize();

      // We expect this to fail in test environment without model file
      // but service should not crash
      expect(result, isNotNull);
      expect(() => service.dispose(), returnsNormally);
    });

    test('should not start listening if not initialized', () async {
      expect(service.isInitialized, isFalse);

      final result = await service.startListening();
      expect(result.isSuccess, isFalse);
      expect(result.error, contains('not initialized'));
    });

    test('should handle stop listening when not recording', () async {
      final result = await service.stopListening();
      expect(result.isSuccess, isTrue);
    });
  });

  group('AudioProcessor', () {
    test('should process audio data correctly', () {
      // Create sample 16-bit PCM audio data
      final sampleData = List.generate(1000, (i) => i % 256);
      final audioBytes = Uint8List.fromList(sampleData);

      final processed = AudioProcessor.preprocessAudio(audioBytes);

      expect(processed, isNotNull);
      expect(processed.length, equals(AudioProcessor.audioLength));
    });

    test('should normalize audio correctly', () {
      final testAudio = Float32List.fromList([0.5, -0.8, 0.3, -0.2]);
      final normalized = AudioProcessor.normalizeAudio(testAudio);

      expect(normalized, isNotNull);
      expect(normalized.length, equals(testAudio.length));

      // Check that maximum absolute value is 1.0 or less
      final maxVal = normalized
          .map((x) => x.abs())
          .reduce((a, b) => a > b ? a : b);
      expect(maxVal, lessThanOrEqualTo(1.0));
    });

    test('should calculate energy correctly', () {
      final silentAudio = Float32List.fromList([0.0, 0.0, 0.0, 0.0]);
      final loudAudio = Float32List.fromList([0.8, -0.6, 0.4, -0.9]);

      final silentEnergy = AudioProcessor.calculateEnergy(silentAudio);
      final loudEnergy = AudioProcessor.calculateEnergy(loudAudio);

      expect(silentEnergy, equals(0.0));
      expect(loudEnergy, greaterThan(0.0));
      expect(loudEnergy, greaterThan(silentEnergy));
    });

    test('should detect speech correctly', () {
      final silentAudio = Float32List.fromList([0.0, 0.0, 0.0, 0.0]);
      final speechAudio = Float32List.fromList([0.1, -0.15, 0.12, -0.08]);

      expect(AudioProcessor.containsSpeech(silentAudio), isFalse);
      expect(AudioProcessor.containsSpeech(speechAudio), isTrue);
    });

    test('should apply high-pass filter', () {
      final testAudio = Float32List.fromList([0.1, 0.2, 0.3, 0.4, 0.5]);
      final filtered = AudioProcessor.applyHighPassFilter(testAudio);

      expect(filtered, isNotNull);
      expect(filtered.length, equals(testAudio.length));
    });
  });

  group('VoiceServiceImpl Integration', () {
    late VoiceServiceImpl voiceService;

    setUp(() {
      voiceService = VoiceServiceImpl();
    });

    tearDown(() async {
      await voiceService.dispose();
    });

    test('should provide STT info', () {
      final info = voiceService.getSTTInfo();

      expect(info, isNotNull);
      expect(info, containsPair('isInitialized', false));
      expect(info, containsPair('isRecording', false));
      expect(info, contains('supportedCommands'));
      expect(info, contains('recognitionStatus'));
    });

    test('should interpret speech results correctly', () {
      final completeResult = SpeechResult(text: 'complete', confidence: 0.9);

      final streakResult = SpeechResult(text: 'check', confidence: 0.8);

      final helpResult = SpeechResult(text: 'help', confidence: 0.85);

      final completeCommand = voiceService.interpretSpeechResult(
        completeResult,
      );
      final streakCommand = voiceService.interpretSpeechResult(streakResult);
      final helpCommand = voiceService.interpretSpeechResult(helpResult);

      expect(completeCommand.type, equals(VoiceCommandType.completeHabit));
      expect(streakCommand.type, equals(VoiceCommandType.checkStreak));
      expect(helpCommand.type, equals(VoiceCommandType.help));
    });

    test('should handle unknown commands', () {
      final unknownResult = SpeechResult(text: 'gibberish', confidence: 0.7);

      final unknownCommand = voiceService.interpretSpeechResult(unknownResult);
      expect(unknownCommand.type, equals(VoiceCommandType.unknown));
    });
  });
}
