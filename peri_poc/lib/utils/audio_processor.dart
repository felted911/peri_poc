import 'dart:typed_data';
import 'dart:math' as math;

/// Audio processing utilities for TensorFlow STT
///
/// This class provides utilities for preprocessing audio data
/// to be compatible with TensorFlow Lite speech recognition models.
class AudioProcessor {
  /// Standard sample rate for speech recognition models
  static const int sampleRate = 16000;

  /// Standard audio length for command recognition (1 second)
  static const int audioLength = 16000;

  /// Confidence threshold for accepting speech commands
  static const double confidenceThreshold = 0.7;

  /// Convert audio bytes to Float32List for model input
  ///
  /// Takes raw audio bytes (assumed to be 16-bit PCM) and converts
  /// them to a normalized Float32List suitable for TensorFlow inference.
  ///
  /// [audioBytes] - Raw audio data as bytes
  /// Returns normalized audio data as Float32List
  static Float32List preprocessAudio(Uint8List audioBytes) {
    // Convert bytes to 16-bit PCM values
    final pcmData = <double>[];

    // Read 16-bit little-endian PCM data
    for (int i = 0; i < audioBytes.length - 1; i += 2) {
      int sample = (audioBytes[i + 1] << 8) | audioBytes[i];
      // Convert unsigned to signed
      if (sample > 32767) sample -= 65536;
      // Normalize to [-1, 1] range
      pcmData.add(sample / 32768.0);
    }

    // Pad or trim to required length
    final processedData = Float32List(audioLength);
    final copyLength = math.min(pcmData.length, audioLength);

    for (int i = 0; i < copyLength; i++) {
      processedData[i] = pcmData[i];
    }

    // Apply additional normalization
    return normalizeAudio(processedData);
  }

  /// Normalize audio to ensure consistent amplitude
  ///
  /// Normalizes the audio data to have maximum amplitude of 1.0
  /// while preserving the original signal characteristics.
  ///
  /// [audio] - Input audio data
  /// Returns normalized audio data
  static Float32List normalizeAudio(Float32List audio) {
    double maxVal = 0.0;

    // Find maximum absolute value
    for (double sample in audio) {
      maxVal = math.max(maxVal, sample.abs());
    }

    // Normalize if maximum value is greater than 0
    if (maxVal > 0) {
      for (int i = 0; i < audio.length; i++) {
        audio[i] = audio[i] / maxVal;
      }
    }

    return audio;
  }

  /// Apply a simple high-pass filter to remove low-frequency noise
  ///
  /// This can help improve speech recognition accuracy by reducing
  /// background noise and emphasizing speech frequencies.
  ///
  /// [audio] - Input audio data
  /// [cutoffFreq] - High-pass filter cutoff frequency
  /// Returns filtered audio data
  static Float32List applyHighPassFilter(
    Float32List audio, {
    double cutoffFreq = 300.0,
  }) {
    // Simple first-order high-pass filter
    final alpha = cutoffFreq / (cutoffFreq + sampleRate / (2 * math.pi));
    final filtered = Float32List(audio.length);

    if (audio.isNotEmpty) {
      filtered[0] = audio[0];

      for (int i = 1; i < audio.length; i++) {
        filtered[i] = alpha * (filtered[i - 1] + audio[i] - audio[i - 1]);
      }
    }

    return filtered;
  }

  /// Calculate energy/volume level of audio sample
  ///
  /// Useful for voice activity detection and ensuring
  /// sufficient audio signal for processing.
  ///
  /// [audio] - Input audio data
  /// Returns energy level (0.0 to 1.0)
  static double calculateEnergy(Float32List audio) {
    double energy = 0.0;

    for (double sample in audio) {
      energy += sample * sample;
    }

    return math.sqrt(energy / audio.length);
  }

  /// Check if audio contains speech based on energy level
  ///
  /// Simple voice activity detection based on audio energy.
  ///
  /// [audio] - Input audio data
  /// [threshold] - Energy threshold for speech detection
  /// Returns true if speech is likely present
  static bool containsSpeech(Float32List audio, {double threshold = 0.01}) {
    return calculateEnergy(audio) > threshold;
  }
}
