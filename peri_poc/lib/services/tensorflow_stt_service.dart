import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../core/utils/result.dart';
import '../models/voice_models.dart';
import '../utils/audio_processor.dart';

/// Mock TensorFlow STT service for development and testing
///
/// This service simulates TensorFlow Lite behavior using pattern matching
/// until TensorFlow packages have better Android support. It maintains
/// the exact same interface so you can swap to real TensorFlow later.
class TensorFlowSTTService {
  /// Command labels that the model can recognize
  static const List<String> _commandLabels = [
    'silence', // Background/no speech
    'complete', // Complete habit
    'done', // Alternative for complete
    'finished', // Another alternative for complete
    'streak', // Check streak
    'check', // General check command
    'help', // Request help
    'status', // Check status
    'yes', // Confirmation
    'no', // Negation
    'start', // Start something
    'stop', // Stop something
  ];

  /// Mock command responses for testing
  static const Map<String, String> _mockCommands = {
    'complete': 'complete',
    'done': 'done',
    'finished': 'finished',
    'streak': 'streak',
    'check': 'check',
    'help': 'help',
    'status': 'status',
  };

  /// Audio recorder instance
  final AudioRecorder _recorder = AudioRecorder();

  /// Timer for periodic audio processing
  Timer? _recordingTimer;

  /// Service initialization state
  bool _isInitialized = false;

  /// Recording state
  bool _isRecording = false;

  /// Stream controller for speech results
  StreamController<SpeechResult>? _resultController;

  /// Current recording file path
  String? _currentRecordingPath;

  /// Audio processing interval in milliseconds
  static const int _processingIntervalMs = 3000; // Slower for demo

  /// Mock counter for generating test commands
  int _mockCommandCounter = 0;

  /// Initialize the TensorFlow STT service
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      return Result.success(null);
    }

    try {
      debugPrint('Initializing Mock TensorFlow STT service...');
      debugPrint(
        'Note: Using mock service until TensorFlow packages support current Android builds',
      );

      // Simulate model loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Create stream controller for results
      _resultController = StreamController<SpeechResult>.broadcast();

      _isInitialized = true;
      debugPrint('Mock TensorFlow STT service initialized successfully');
      debugPrint('Supported commands: $_commandLabels');

      return Result.success(null);
    } catch (e) {
      debugPrint('Failed to initialize Mock TensorFlow STT: $e');
      return Result.failure('Failed to initialize Mock TensorFlow STT: $e');
    }
  }

  /// Start listening for speech input
  Future<Result<void>> startListening() async {
    if (!_isInitialized) {
      return Result.failure('Service not initialized');
    }

    if (_isRecording) {
      return Result.failure('Already recording');
    }

    try {
      debugPrint('Starting mock speech recognition...');

      // Check microphone permissions
      if (!await _recorder.hasPermission()) {
        debugPrint('Microphone permission denied');
        return Result.failure('Microphone permission denied');
      }

      // Prepare recording file path
      final tempDir = await getTemporaryDirectory();
      _currentRecordingPath = path.join(
        tempDir.path,
        'speech_recording_${DateTime.now().millisecondsSinceEpoch}.wav',
      );

      // Configure recording settings
      const recordConfig = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: AudioProcessor.sampleRate,
        bitRate: 256000,
        numChannels: 1,
      );

      // Start recording
      await _recorder.start(recordConfig, path: _currentRecordingPath!);

      _isRecording = true;
      debugPrint('Mock recording started at: $_currentRecordingPath');

      // Start periodic mock processing
      _recordingTimer = Timer.periodic(
        const Duration(milliseconds: _processingIntervalMs),
        (_) => _processMockAudio(),
      );

      return Result.success(null);
    } catch (e) {
      debugPrint('Failed to start mock recording: $e');
      _isRecording = false;
      return Result.failure('Failed to start mock recording: $e');
    }
  }

  /// Stop listening for speech input
  Future<Result<void>> stopListening() async {
    if (!_isRecording) {
      return Result.success(null);
    }

    try {
      debugPrint('Stopping mock speech recognition...');

      // Cancel the processing timer
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Stop recording
      await _recorder.stop();
      _isRecording = false;

      // Clean up recording file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
      }

      debugPrint('Mock speech recognition stopped');
      return Result.success(null);
    } catch (e) {
      debugPrint('Failed to stop mock recording: $e');
      _isRecording = false;
      return Result.failure('Failed to stop mock recording: $e');
    }
  }

  /// Process mock audio and generate test commands
  Future<void> _processMockAudio() async {
    if (!_isRecording || _currentRecordingPath == null) {
      return;
    }

    try {
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        return;
      }

      // Read the audio file to check if there's actual content
      final audioBytes = await file.readAsBytes();

      // Skip if file is too small
      if (audioBytes.length < 1000) {
        return;
      }

      // Skip WAV header and process audio
      final audioData = audioBytes.sublist(44);
      final processedAudio = AudioProcessor.preprocessAudio(audioData);

      // Check if audio contains speech
      if (!AudioProcessor.containsSpeech(processedAudio)) {
        debugPrint('Mock: No speech detected in audio');
        return;
      }

      // Generate mock command based on audio energy and counter
      final mockResult = _generateMockResult(processedAudio);

      if (mockResult != null) {
        debugPrint(
          'Mock command detected: ${mockResult.text} (confidence: ${mockResult.confidence.toStringAsFixed(3)})',
        );
        _resultController?.add(mockResult);
      }
    } catch (e) {
      debugPrint('Error processing mock audio: $e');
    }
  }

  /// Generate mock speech results based on audio characteristics
  SpeechResult? _generateMockResult(Float32List audioData) {
    // Calculate audio energy
    final energy = AudioProcessor.calculateEnergy(audioData);

    // Only generate results for audio with sufficient energy
    if (energy < 0.02) {
      return null;
    }

    // Cycle through commands for demonstration
    final commands = _mockCommands.keys.toList();
    final commandIndex = _mockCommandCounter % commands.length;
    final selectedCommand = commands[commandIndex];

    _mockCommandCounter++;

    // Generate confidence based on audio energy (higher energy = higher confidence)
    final confidence = (energy * 10).clamp(0.7, 0.95);

    return SpeechResult(
      text: selectedCommand,
      confidence: confidence,
      isFinal: true,
    );
  }

  /// Simulate a specific command (useful for testing)
  void simulateCommand(String command, {double confidence = 0.9}) {
    if (_isInitialized && _mockCommands.containsKey(command)) {
      final result = SpeechResult(
        text: command,
        confidence: confidence,
        isFinal: true,
      );

      debugPrint(
        'Simulating command: ${result.text} (confidence: ${result.confidence})',
      );
      _resultController?.add(result);
    }
  }

  /// Get the stream of speech recognition results
  Stream<SpeechResult>? get speechResults => _resultController?.stream;

  /// Check if the service is currently recording
  bool get isRecording => _isRecording;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the list of supported command labels
  List<String> get supportedCommands => List.unmodifiable(_commandLabels);

  /// Dispose of all resources used by the service
  Future<void> dispose() async {
    debugPrint('Disposing Mock TensorFlow STT service...');

    // Stop listening if currently active
    await stopListening();

    // Close the results stream
    await _resultController?.close();
    _resultController = null;

    _isInitialized = false;
    debugPrint('Mock TensorFlow STT service disposed');
  }

  /// Check if this is the mock implementation
  bool get isMockImplementation => true;
}
