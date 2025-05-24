import 'package:peri_poc/core/utils/result.dart';
import 'package:peri_poc/models/voice_models.dart';

/// Interface for voice interaction services
///
/// This interface defines the contract for speech recognition and text-to-speech
/// capabilities that the application uses for voice interactions.
abstract class IVoiceService {
  /// Initialize the voice service
  ///
  /// This should be called before any other methods to set up
  /// the voice service and check for necessary permissions.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> initialize();

  /// Start listening for speech input
  ///
  /// Begins the speech recognition process. The recognized speech
  /// will be provided through the [onSpeechResult] callback.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> startListening();

  /// Stop listening for speech input
  ///
  /// Stops the speech recognition process if it is currently active.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> stopListening();

  /// Convert text to speech
  ///
  /// Takes the provided [text] and speaks it through the device's audio output.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> speak(String text);

  /// Stop any ongoing text-to-speech output
  ///
  /// Immediately stops any active speech output.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> stopSpeaking();

  /// Get the current voice recognition status
  ///
  /// Returns the current [VoiceRecognitionStatus] indicating if the service
  /// is listening, processing, or inactive
  VoiceRecognitionStatus getRecognitionStatus();

  /// Get the current text-to-speech status
  ///
  /// Returns the current [TextToSpeechStatus] indicating if the service
  /// is speaking or inactive
  TextToSpeechStatus getSpeechStatus();

  /// Set the callback for speech recognition results
  ///
  /// The provided [callback] will be called whenever speech is recognized,
  /// with a [SpeechResult] containing the recognized text and confidence level
  void setOnSpeechResultCallback(void Function(SpeechResult result) callback);

  /// Set the callback for speech recognition status changes
  ///
  /// The provided [callback] will be called whenever the recognition status changes,
  /// with the new [VoiceRecognitionStatus]
  void setOnRecognitionStatusChangedCallback(
    void Function(VoiceRecognitionStatus status) callback,
  );

  /// Set the callback for text-to-speech status changes
  ///
  /// The provided [callback] will be called whenever the speech status changes,
  /// with the new [TextToSpeechStatus]
  void setOnSpeechStatusChangedCallback(
    void Function(TextToSpeechStatus status) callback,
  );

  /// Dispose of any resources used by the voice service
  ///
  /// This should be called when the voice service is no longer needed
  /// to release any held resources.
  Future<void> dispose();
}
