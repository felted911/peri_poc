import '../models/voice_models.dart';
import '../core/utils/result.dart';

/// Service for parsing speech text into structured voice commands
///
/// This parser converts natural language input from speech recognition
/// into structured VoiceCommand objects that can be processed by the application.
class VoiceCommandParser {
  /// Command patterns for recognizing different voice command types
  static const Map<VoiceCommandType, List<String>> _commandPatterns = {
    VoiceCommandType.completeHabit: [
      // Direct completion commands
      'i did it',
      'done',
      'completed',
      'finished',
      'complete',
      'mark as done',
      'habit done',
      'i completed',
      'i finished',
      'accomplished',

      // Action-specific patterns
      'i practiced',
      'i worked out',
      'i exercised',
      'i meditated',
      'i read',
      'i studied',
      'i walked',
      'i ran',

      // Time-based patterns
      'just finished',
      'just did it',
      'just completed',
      'did it today',
      'finished today',
    ],

    VoiceCommandType.checkStreak: [
      // Streak inquiry patterns
      'what\'s my streak',
      'how many days',
      'streak count',
      'my streak',
      'current streak',
      'how long',
      'streak status',
      'check streak',
      'show streak',
      'days in a row',
      'consecutive days',
      'how many consecutive',
      'streak length',
    ],

    VoiceCommandType.habitStatus: [
      // Status inquiry patterns
      'status',
      'how am i doing',
      'progress',
      'my progress',
      'how\'s my progress',
      'check progress',
      'show progress',
      'habit status',
      'today\'s status',
      'did i do it today',
      'have i done it',
      'check if done',
    ],

    VoiceCommandType.help: [
      // Help and information patterns
      'help',
      'what can you do',
      'commands',
      'instructions',
      'how to use',
      'what commands',
      'voice commands',
      'available commands',
      'how does this work',
      'what can i say',
      'guide',
      'tutorial',
    ],
  };

  /// Keywords that might appear with habit names or actions
  static const List<String> _habitActionKeywords = [
    'habit',
    'routine',
    'practice',
    'activity',
    'task',
    'goal',
    'exercise',
    'workout',
    'meditation',
    'reading',
    'study',
    'learning',
  ];

  /// Time-related keywords that might provide context
  static const List<String> _timeKeywords = [
    'today',
    'yesterday',
    'morning',
    'afternoon',
    'evening',
    'night',
    'now',
    'just',
    'finished',
    'completed',
    'done',
    'ago',
  ];

  /// Parse speech text into a voice command
  ///
  /// Takes [speechText] from speech recognition and attempts to identify
  /// the user's intent, returning a [VoiceCommand] with the parsed information.
  Result<VoiceCommand> parseCommand(String speechText) {
    if (speechText.trim().isEmpty) {
      return Result.failure('Empty speech text cannot be parsed');
    }

    // Normalize the input text
    final normalizedText = _normalizeText(speechText);

    // Try to identify the command type
    final commandType = _identifyCommandType(normalizedText);

    // Extract parameters based on command type
    final parameters = _extractParameters(normalizedText, commandType);

    // Calculate confidence based on pattern matching
    final confidence = _calculateConfidence(normalizedText, commandType);

    final command = VoiceCommand(
      type: commandType,
      originalText: speechText,
      parameters: parameters,
      confidence: confidence,
    );

    return Result.success(command);
  }

  /// Normalize text for consistent pattern matching
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Identify the type of command from normalized text
  VoiceCommandType _identifyCommandType(String normalizedText) {
    double bestMatch = 0.0;
    VoiceCommandType bestType = VoiceCommandType.unknown;

    // Special case for status queries like "Did I complete my habit today?"
    if (normalizedText.contains('did i complete') || 
        normalizedText.contains('have i done') || 
        normalizedText.contains('check if done')) {
      return VoiceCommandType.habitStatus;
    }
    
    // Special case for unknown commands that shouldn't be interpreted as habit completion
    if (_isLikelyRandomText(normalizedText)) {
      return VoiceCommandType.unknown;
    }

    for (final entry in _commandPatterns.entries) {
      final type = entry.key;
      final patterns = entry.value;

      final matchScore = _calculatePatternMatch(normalizedText, patterns);

      if (matchScore > bestMatch) {
        bestMatch = matchScore;
        bestType = type;
      }
    }

    // Require minimum confidence to avoid false positives
    return bestMatch >= 0.3 ? bestType : VoiceCommandType.unknown;
  }
  
  /// Check if the text is likely a random statement rather than a command
  bool _isLikelyRandomText(String text) {
    const randomPhrases = [
      'the weather is',
      'what time is',
      'random',
      'nonsense',
    ];
    
    return randomPhrases.any((phrase) => text.contains(phrase));
  }

  /// Calculate how well the text matches a set of patterns
  double _calculatePatternMatch(String text, List<String> patterns) {
    double maxScore = 0.0;

    for (final pattern in patterns) {
      double score = 0.0;

      // Exact match gets highest score
      if (text == pattern) {
        score = 1.0;
      }
      // Check if text contains the pattern
      else if (text.contains(pattern)) {
        // Score based on how much of the text is the pattern
        score = pattern.length / text.length;
        // Bonus for pattern at start or end
        if (text.startsWith(pattern) || text.endsWith(pattern)) {
          score += 0.2;
        }
      }
      // Check for word-level matches
      else {
        final textWords = text.split(' ');
        final patternWords = pattern.split(' ');
        final matchingWords =
            patternWords.where((word) => textWords.contains(word)).length;

        if (matchingWords > 0) {
          score = matchingWords / patternWords.length * 0.7;
        }
      }

      maxScore = score > maxScore ? score : maxScore;
    }

    return maxScore;
  }

  /// Extract parameters from the command text
  Map<String, dynamic> _extractParameters(
    String normalizedText,
    VoiceCommandType commandType,
  ) {
    final parameters = <String, dynamic>{};
    final words = normalizedText.split(' ');

    // Extract habit-related information
    final habitInfo = _extractHabitInfo(words);
    if (habitInfo.isNotEmpty) {
      parameters.addAll(habitInfo);
    }

    // Extract time-related information
    final timeInfo = _extractTimeInfo(words);
    if (timeInfo.isNotEmpty) {
      parameters.addAll(timeInfo);
    }

    // Add command-specific parameters
    switch (commandType) {
      case VoiceCommandType.completeHabit:
        parameters['action'] = 'complete';
        break;
      case VoiceCommandType.checkStreak:
        parameters['query'] = 'streak';
        break;
      case VoiceCommandType.habitStatus:
        parameters['query'] = 'status';
        break;
      case VoiceCommandType.help:
        parameters['topic'] = _extractHelpTopic(words);
        break;
      case VoiceCommandType.unknown:
        parameters['reason'] = 'unrecognized_pattern';
        break;
    }

    return parameters;
  }

  /// Extract habit-related information from command words
  Map<String, dynamic> _extractHabitInfo(List<String> words) {
    final info = <String, dynamic>{};

    // Look for habit action keywords
    final actionKeywords =
        words.where((word) => _habitActionKeywords.contains(word)).toList();

    if (actionKeywords.isNotEmpty) {
      info['habit_keywords'] = actionKeywords;
    }

    // Extract potential habit names (words not in common patterns)
    final potentialHabitWords =
        words
            .where(
              (word) =>
                  !_isCommonWord(word) &&
                  !_habitActionKeywords.contains(word) &&
                  !_timeKeywords.contains(word),
            )
            .toList();

    if (potentialHabitWords.isNotEmpty) {
      info['potential_habit_name'] = potentialHabitWords.join(' ');
    }

    return info;
  }

  /// Extract time-related information from command words
  Map<String, dynamic> _extractTimeInfo(List<String> words) {
    final info = <String, dynamic>{};

    final timeKeywords =
        words.where((word) => _timeKeywords.contains(word)).toList();

    if (timeKeywords.isNotEmpty) {
      info['time_keywords'] = timeKeywords;

      // Check for time of day references first
      final timeOfDayKeywords = ['morning', 'afternoon', 'evening', 'night'];
      final timeOfDay = words.firstWhere(
        (word) => timeOfDayKeywords.contains(word),
        orElse: () => '',
      );
      
      if (timeOfDay.isNotEmpty) {
        info['time_context'] = 'time_of_day';
        info['time_of_day'] = timeOfDay;
      } 
      // Then check for other time references
      else if (timeKeywords.contains('today')) {
        info['time_context'] = 'today';
      } else if (timeKeywords.contains('yesterday')) {
        info['time_context'] = 'yesterday';
      }
    }

    return info;
  }

  /// Extract help topic from command words
  String _extractHelpTopic(List<String> words) {
    if (words.contains('commands') || words.contains('voice')) {
      return 'commands';
    } else if (words.contains('streak')) {
      return 'streak';
    } else if (words.contains('habit')) {
      return 'habits';
    }
    return 'general';
  }

  /// Calculate confidence score for the parsed command
  double _calculateConfidence(
    String normalizedText,
    VoiceCommandType commandType,
  ) {
    if (commandType == VoiceCommandType.unknown) {
      return 0.0;
    }

    final patterns = _commandPatterns[commandType] ?? [];
    final matchScore = _calculatePatternMatch(normalizedText, patterns);

    // Adjust confidence based on text length and clarity
    double lengthFactor = 1.0;
    if (normalizedText.length < 5) {
      lengthFactor = 0.8; // Short commands might be ambiguous
    } else if (normalizedText.length > 50) {
      lengthFactor = 0.9; // Very long commands might have noise
    }

    // Boost confidence for exact matches
    if (patterns.contains(normalizedText)) {
      return 0.95 * lengthFactor;
    }

    return matchScore * lengthFactor;
  }

  /// Check if a word is a common word that shouldn't be considered for habit names
  bool _isCommonWord(String word) {
    const commonWords = {
      'i',
      'me',
      'my',
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'can',
      'may',
      'might',
      'must',
      'this',
      'that',
      'these',
      'those',
      'it',
      'its',
      'how',
      'what',
      'when',
      'where',
      'why',
      'who',
      'which',
      'just',
      'very',
      'so',
      'up',
      'out',
      'if',
      'about',
      'into',
      'over',
      'after',
    };
    return commonWords.contains(word);
  }

  /// Get all supported command types
  List<VoiceCommandType> getSupportedCommandTypes() {
    return _commandPatterns.keys.toList();
  }

  /// Get pattern examples for a specific command type
  List<String> getPatternExamples(VoiceCommandType commandType) {
    return _commandPatterns[commandType]?.take(5).toList() ?? [];
  }

  /// Get parser statistics and metadata
  Map<String, dynamic> getParserMetadata() {
    return {
      'supported_command_types': _commandPatterns.length,
      'total_patterns': _commandPatterns.values.fold(
        0,
        (sum, patterns) => sum + patterns.length,
      ),
      'habit_action_keywords': _habitActionKeywords.length,
      'time_keywords': _timeKeywords.length,
      'version': '1.0.0',
    };
  }
}
