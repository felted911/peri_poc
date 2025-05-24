# TensorFlow Lite Models for Peritest STT

This directory contains TensorFlow Lite models for speech recognition in the Peritest app.

## Required Model

You need to place a speech commands TensorFlow Lite model here:

### File: `speech_commands.tflite`

**Option 1: Download Pre-trained Model**
1. Visit [TensorFlow Hub Speech Commands Models](https://tfhub.dev/s?q=speech%20commands)
2. Download a `.tflite` model (look for speech command recognition models)
3. Rename it to `speech_commands.tflite` and place it in this directory

**Option 2: Use Google's Speech Commands Model**
1. Download from: https://storage.googleapis.com/download.tensorflow.org/models/tflite/speech_commands/speech_commands.tflite
2. Place it in this directory

**Option 3: Train Your Own Model**
Follow the TensorFlow tutorial for training speech commands:
https://www.tensorflow.org/tutorials/audio/simple_audio

## Model Requirements

The model should:
- Accept 16kHz, 1-second audio samples
- Output probabilities for command classes
- Include at least these command classes:
  - silence (background)
  - complete/done/finished
  - streak/check
  - help
  - status
  - yes/no

## Testing the Model

Once you have the model file:

1. Run `flutter pub get` to install dependencies
2. Test the voice service:
   ```dart
   final voiceService = VoiceServiceImpl();
   await voiceService.initialize();
   await voiceService.startListening();
   ```

## Supported Commands

Current implementation recognizes:
- **Habit Completion**: "complete", "done", "finished"
- **Streak Check**: "streak", "check"
- **Help**: "help"
- **Status**: "status"
- **Confirmation**: "yes", "no"

## Troubleshooting

If the model doesn't work:
1. Check the model file exists in this directory
2. Verify the model input/output shapes match expectations
3. Check the Flutter debug console for TensorFlow initialization errors
4. Ensure microphone permissions are granted

## Model Performance

For best results:
- Speak clearly and at normal volume
- Minimize background noise
- Use the exact command words
- Wait for the app to process each command

## Future Improvements

- Custom model training with app-specific vocabulary
- Support for continuous speech recognition
- Multiple language support
- Improved noise handling
