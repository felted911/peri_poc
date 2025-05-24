/// Represents the current status of voice recognition
enum VoiceRecognitionStatus {
  /// Not currently listening or processing speech
  inactive,

  /// Actively listening for speech input
  listening,

  /// Processing detected speech
  processing,

  /// Error occurred during speech recognition
  error,

  /// Not available (e.g., permissions denied)
  notAvailable,
}

/// Represents the current status of text-to-speech
enum TextToSpeechStatus {
  /// Not currently speaking
  inactive,

  /// Actively speaking text
  speaking,

  /// Error occurred during text-to-speech
  error,

  /// Not available (e.g., audio system issue)
  notAvailable,
}

/// Represents the result of speech recognition
class SpeechResult {
  /// The recognized text from speech
  final String text;

  /// Confidence level in the recognition result (0.0 to 1.0)
  final double confidence;

  /// Whether this is a final result (vs. intermediate)
  final bool isFinal;

  /// Creates a new speech result instance
  SpeechResult({
    required this.text,
    required this.confidence,
    this.isFinal = true,
  });

  /// Creates a copy of this result with optional new values
  SpeechResult copyWith({String? text, double? confidence, bool? isFinal}) {
    return SpeechResult(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
    );
  }

  @override
  String toString() =>
      'SpeechResult{text: $text, confidence: $confidence, isFinal: $isFinal}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeechResult &&
        other.text == text &&
        other.confidence == confidence &&
        other.isFinal == isFinal;
  }

  @override
  int get hashCode => Object.hash(text, confidence, isFinal);
}

/// Represents a command extracted from speech input
class VoiceCommand {
  /// Type of voice command detected
  final VoiceCommandType type;

  /// The original text from which the command was extracted
  final String originalText;

  /// Parameters extracted from the command (if any)
  final Map<String, dynamic> parameters;

  /// Confidence level in the command interpretation (0.0 to 1.0)
  final double confidence;

  /// Creates a new voice command instance
  VoiceCommand({
    required this.type,
    required this.originalText,
    this.parameters = const {},
    this.confidence = 1.0,
  });

  /// Creates a copy of this command with optional new values
  VoiceCommand copyWith({
    VoiceCommandType? type,
    String? originalText,
    Map<String, dynamic>? parameters,
    double? confidence,
  }) {
    return VoiceCommand(
      type: type ?? this.type,
      originalText: originalText ?? this.originalText,
      parameters: parameters ?? this.parameters,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() =>
      'VoiceCommand{type: $type, originalText: $originalText, '
      'parameters: $parameters, confidence: $confidence}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceCommand &&
        other.type == type &&
        other.originalText == originalText &&
        _mapEquals(other.parameters, parameters) &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
    type,
    originalText,
    Object.hashAll(parameters.entries),
    confidence,
  );

  /// Helper method to compare maps for equality
  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;

    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) {
        return false;
      }
    }

    return true;
  }
}

/// Types of voice commands the application can recognize
enum VoiceCommandType {
  /// Record a habit completion
  completeHabit,

  /// Ask about current streak
  checkStreak,

  /// Request information about the app
  help,

  /// Ask about a habit status
  habitStatus,

  /// Unknown or unrecognized command
  unknown,
}

/// Configuration options for text-to-speech
class TextToSpeechOptions {
  /// Speaking rate (1.0 is normal speed)
  final double rate;

  /// Speaking pitch (1.0 is normal pitch)
  final double pitch;

  /// Speaking volume (1.0 is full volume)
  final double volume;

  /// Creates a new text-to-speech options instance
  const TextToSpeechOptions({
    this.rate = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  /// Default options for text-to-speech
  static const TextToSpeechOptions defaultOptions = TextToSpeechOptions();

  /// Creates a copy of this options with optional new values
  TextToSpeechOptions copyWith({double? rate, double? pitch, double? volume}) {
    return TextToSpeechOptions(
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() =>
      'TextToSpeechOptions{rate: $rate, pitch: $pitch, volume: $volume}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextToSpeechOptions &&
        other.rate == rate &&
        other.pitch == pitch &&
        other.volume == volume;
  }

  @override
  int get hashCode => Object.hash(rate, pitch, volume);
}
