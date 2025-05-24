import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/interfaces/i_voice_service.dart';
import 'package:peri_poc/models/voice_models.dart';
import 'package:peri_poc/services/tensorflow_stt_service.dart';

/// Enhanced implementation of [IVoiceService] with TensorFlow STT support
///
/// This implementation combines TensorFlow Lite speech recognition
/// with flutter_tts for a complete voice interaction solution.
class VoiceServiceImpl implements IVoiceService {
  /// The text to speech plugin instance
  final FlutterTts _flutterTts;

  /// TensorFlow STT service instance
  final TensorFlowSTTService _tensorflowSTT;

  /// Current voice recognition status
  VoiceRecognitionStatus _recognitionStatus = VoiceRecognitionStatus.inactive;

  /// Current text to speech status
  TextToSpeechStatus _speechStatus = TextToSpeechStatus.inactive;

  /// Callback for speech recognition results
  void Function(SpeechResult)? _onSpeechResultCallback;

  /// Callback for recognition status changes
  void Function(VoiceRecognitionStatus)? _onRecognitionStatusChangedCallback;

  /// Callback for speech status changes
  void Function(TextToSpeechStatus)? _onSpeechStatusChangedCallback;

  /// Flag indicating if the service has been initialized
  bool _isInitialized = false;

  /// Subscription to TensorFlow STT results
  StreamSubscription<SpeechResult>? _speechSubscription;

  /// Creates a new VoiceServiceImpl instance
  ///
  /// Optionally accepts specific instances of [FlutterTts] and [TensorFlowSTTService]
  /// for testing purposes or custom configuration.
  VoiceServiceImpl({
    FlutterTts? flutterTts,
    TensorFlowSTTService? tensorflowSTT,
  }) : _flutterTts = flutterTts ?? FlutterTts(),
       _tensorflowSTT = tensorflowSTT ?? TensorFlowSTTService();

  @override
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      return Result.success(null);
    }

    try {
      debugPrint('Initializing enhanced voice service with TensorFlow STT...');

      // Initialize TensorFlow STT service
      final sttResult = await _tensorflowSTT.initialize();
      if (!sttResult.isSuccess) {
        debugPrint('TensorFlow STT initialization failed: ${sttResult.error}');
        _updateRecognitionStatus(VoiceRecognitionStatus.notAvailable);
      } else {
        debugPrint('TensorFlow STT initialized successfully');

        // Set up speech result listener
        _speechSubscription = _tensorflowSTT.speechResults?.listen(
          (speechResult) {
            debugPrint(
              'Received speech result: ${speechResult.text} (${speechResult.confidence})',
            );

            // Update recognition status to processing
            _updateRecognitionStatus(VoiceRecognitionStatus.processing);

            // Interpret the speech result and notify callback
            _onSpeechResultCallback?.call(speechResult);

            // Return to listening state
            _updateRecognitionStatus(VoiceRecognitionStatus.listening);
          },
          onError: (error) {
            debugPrint('Speech recognition error: $error');
            _updateRecognitionStatus(VoiceRecognitionStatus.error);
          },
        );
      }

      // Initialize text-to-speech service
      await _initializeTTS();

      _isInitialized = true;
      debugPrint('Voice service initialized successfully');

      return Result.success(null);
    } catch (e) {
      debugPrint('Voice service initialization error: $e');
      _updateRecognitionStatus(VoiceRecognitionStatus.notAvailable);
      _updateSpeechStatus(TextToSpeechStatus.notAvailable);
      return Result.failure('Voice service initialization failed: $e');
    }
  }

  /// Initialize the text-to-speech service
  Future<void> _initializeTTS() async {
    // Configure TTS settings
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Set up TTS status listeners
    _flutterTts.setStartHandler(() {
      debugPrint('TTS started speaking');
      _updateSpeechStatus(TextToSpeechStatus.speaking);
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint('TTS completed speaking');
      _updateSpeechStatus(TextToSpeechStatus.inactive);
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS error: $msg');
      _updateSpeechStatus(TextToSpeechStatus.error);
    });

    debugPrint('TTS initialized successfully');
  }

  @override
  Future<Result<void>> startListening() async {
    if (!_isInitialized) {
      return Result.failure('Voice service not initialized');
    }

    debugPrint('Starting voice recognition...');
    _updateRecognitionStatus(VoiceRecognitionStatus.listening);

    final result = await _tensorflowSTT.startListening();
    if (!result.isSuccess) {
      debugPrint('Failed to start listening: ${result.error}');
      _updateRecognitionStatus(VoiceRecognitionStatus.error);
    }

    return result;
  }

  @override
  Future<Result<void>> stopListening() async {
    if (!_isInitialized) {
      return Result.failure('Voice service not initialized');
    }

    debugPrint('Stopping voice recognition...');

    final result = await _tensorflowSTT.stopListening();
    _updateRecognitionStatus(VoiceRecognitionStatus.inactive);

    return result;
  }

  @override
  Future<Result<void>> speak(String text) async {
    if (!_isInitialized) {
      return Result.failure('Voice service not initialized');
    }

    if (text.isEmpty) {
      return Result.failure('Cannot speak empty text');
    }

    try {
      debugPrint('Speaking: "$text"');
      final result = await _flutterTts.speak(text);
      if (result == 1) {
        return Result.success(null);
      } else {
        return Result.failure('Failed to start text-to-speech');
      }
    } catch (e) {
      debugPrint('Speak error: $e');
      _updateSpeechStatus(TextToSpeechStatus.error);
      return Result.failure('Speak failed: $e');
    }
  }

  @override
  Future<Result<void>> stopSpeaking() async {
    if (!_isInitialized) {
      return Result.failure('Voice service not initialized');
    }

    if (_speechStatus != TextToSpeechStatus.speaking) {
      return Result.success(null); // Not currently speaking
    }

    try {
      debugPrint('Stopping speech...');
      final result = await _flutterTts.stop();
      if (result == 1) {
        _updateSpeechStatus(TextToSpeechStatus.inactive);
        return Result.success(null);
      } else {
        return Result.failure('Failed to stop text-to-speech');
      }
    } catch (e) {
      debugPrint('Stop speaking error: $e');
      return Result.failure('Stop speaking failed: $e');
    }
  }

  @override
  VoiceRecognitionStatus getRecognitionStatus() {
    return _recognitionStatus;
  }

  @override
  TextToSpeechStatus getSpeechStatus() {
    return _speechStatus;
  }

  @override
  void setOnSpeechResultCallback(void Function(SpeechResult) callback) {
    _onSpeechResultCallback = callback;
  }

  @override
  void setOnRecognitionStatusChangedCallback(
    void Function(VoiceRecognitionStatus) callback,
  ) {
    _onRecognitionStatusChangedCallback = callback;
  }

  @override
  void setOnSpeechStatusChangedCallback(
    void Function(TextToSpeechStatus) callback,
  ) {
    _onSpeechStatusChangedCallback = callback;
  }

  @override
  Future<void> dispose() async {
    debugPrint('Disposing voice service...');

    // Stop any active operations
    await stopListening();
    await stopSpeaking();

    // Cancel subscriptions
    await _speechSubscription?.cancel();
    _speechSubscription = null;

    // Dispose services
    await _flutterTts.stop();
    await _tensorflowSTT.dispose();

    _isInitialized = false;
    debugPrint('Voice service disposed');
  }

  /// Updates the recognition status and notifies listeners
  void _updateRecognitionStatus(VoiceRecognitionStatus status) {
    if (_recognitionStatus != status) {
      _recognitionStatus = status;
      debugPrint('Recognition status changed to: $status');
      _onRecognitionStatusChangedCallback?.call(status);
    }
  }

  /// Updates the speech status and notifies listeners
  void _updateSpeechStatus(TextToSpeechStatus status) {
    if (_speechStatus != status) {
      _speechStatus = status;
      debugPrint('Speech status changed to: $status');
      _onSpeechStatusChangedCallback?.call(status);
    }
  }

  /// Interpret TensorFlow STT results into voice commands
  ///
  /// This method maps the raw speech recognition results from TensorFlow
  /// to the application's [VoiceCommand] types for habit tracking.
  VoiceCommand interpretSpeechResult(SpeechResult result) {
    final text = result.text.toLowerCase().trim();

    // Map recognized commands to voice command types
    if (_isCompletionCommand(text)) {
      return VoiceCommand(
        type: VoiceCommandType.completeHabit,
        originalText: result.text,
        confidence: result.confidence,
      );
    } else if (_isStreakCommand(text)) {
      return VoiceCommand(
        type: VoiceCommandType.checkStreak,
        originalText: result.text,
        confidence: result.confidence,
      );
    } else if (_isHelpCommand(text)) {
      return VoiceCommand(
        type: VoiceCommandType.help,
        originalText: result.text,
        confidence: result.confidence,
      );
    } else if (_isStatusCommand(text)) {
      return VoiceCommand(
        type: VoiceCommandType.habitStatus,
        originalText: result.text,
        confidence: result.confidence,
      );
    }

    // Default to unknown command
    return VoiceCommand(
      type: VoiceCommandType.unknown,
      originalText: result.text,
      confidence: result.confidence,
    );
  }

  /// Check if the recognized text represents a habit completion command
  bool _isCompletionCommand(String text) {
    const completionKeywords = ['complete', 'done', 'finished'];
    return completionKeywords.any((keyword) => text.contains(keyword));
  }

  /// Check if the recognized text represents a streak check command
  bool _isStreakCommand(String text) {
    const streakKeywords = ['streak', 'check'];
    return streakKeywords.any((keyword) => text.contains(keyword));
  }

  /// Check if the recognized text represents a help command
  bool _isHelpCommand(String text) {
    return text.contains('help');
  }

  /// Check if the recognized text represents a status command
  bool _isStatusCommand(String text) {
    return text.contains('status');
  }

  /// Get information about the TensorFlow STT service
  ///
  /// Returns debug information about the current state of the STT service
  Map<String, dynamic> getSTTInfo() {
    return {
      'isInitialized': _tensorflowSTT.isInitialized,
      'isRecording': _tensorflowSTT.isRecording,
      'supportedCommands': _tensorflowSTT.supportedCommands,
      'recognitionStatus': _recognitionStatus.toString(),
    };
  }
}
