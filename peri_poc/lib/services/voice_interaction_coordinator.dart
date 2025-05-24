import '../interfaces/i_voice_service.dart';
import '../interfaces/i_storage_service.dart';
import '../interfaces/i_template_service.dart';
import '../models/voice_models.dart';
import '../models/template_models.dart';
import '../models/habit_completion.dart';
import '../core/utils/result.dart';
import 'voice_command_parser.dart';

/// Coordinates complete voice interaction flow from speech input to response
///
/// This service orchestrates the entire voice interaction process:
/// 1. Speech recognition via VoiceService
/// 2. Command parsing via VoiceCommandParser
/// 3. Business logic execution via StorageService
/// 4. Response generation via TemplateService
/// 5. Speech output via VoiceService
class VoiceInteractionCoordinator {
  final IVoiceService _voiceService;
  final IStorageService _storageService;
  final ITemplateService _templateService;
  final VoiceCommandParser _commandParser;

  /// Current interaction state
  VoiceInteractionState _currentState = VoiceInteractionState.idle;

  /// Callbacks for state changes and events
  void Function(VoiceInteractionState state)? _onStateChanged;
  void Function(String message)? _onInteractionResult;
  void Function(String error)? _onError;

  /// Interaction session data
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  final List<VoiceInteractionEvent> _sessionEvents = [];

  VoiceInteractionCoordinator({
    required IVoiceService voiceService,
    required IStorageService storageService,
    required ITemplateService templateService,
    VoiceCommandParser? commandParser,
  }) : _voiceService = voiceService,
       _storageService = storageService,
       _templateService = templateService,
       _commandParser = commandParser ?? VoiceCommandParser();

  /// Initialize the voice interaction coordinator
  Future<Result<void>> initialize() async {
    try {
      // Initialize all dependent services
      final voiceInit = await _voiceService.initialize();
      if (voiceInit.isFailure) {
        return Result.failure(
          'Voice service initialization failed: ${voiceInit.error}',
        );
      }

      final storageInit = await _storageService.initialize();
      if (storageInit.isFailure) {
        return Result.failure(
          'Storage service initialization failed: ${storageInit.error}',
        );
      }

      final templateInit = await _templateService.initialize();
      if (templateInit.isFailure) {
        return Result.failure(
          'Template service initialization failed: ${templateInit.error}',
        );
      }

      // Set up voice service callbacks
      _voiceService.setOnSpeechResultCallback(_handleSpeechResult);
      _voiceService.setOnRecognitionStatusChangedCallback(
        _handleRecognitionStatusChanged,
      );
      _voiceService.setOnSpeechStatusChangedCallback(
        _handleSpeechStatusChanged,
      );

      _setState(VoiceInteractionState.ready);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Initialization error: $e');
    }
  }

  /// Start a new voice interaction session
  Future<Result<void>> startInteraction() async {
    if (_currentState != VoiceInteractionState.ready &&
        _currentState != VoiceInteractionState.idle) {
      return Result.failure(
        'Cannot start interaction in current state: $_currentState',
      );
    }

    try {
      // Start new session
      _currentSessionId = _generateSessionId();
      _sessionStartTime = DateTime.now();
      _sessionEvents.clear();

      _addSessionEvent(
        VoiceInteractionEventType.sessionStarted,
        'Voice interaction session started',
      );

      // Start listening for speech
      final result = await _voiceService.startListening();
      if (result.isFailure) {
        _addSessionEvent(
          VoiceInteractionEventType.error,
          'Failed to start listening: ${result.error}',
        );
        return Result.failure('Failed to start listening: ${result.error}');
      }

      _setState(VoiceInteractionState.listening);
      return Result.success(null);
    } catch (e) {
      _addSessionEvent(
        VoiceInteractionEventType.error,
        'Start interaction error: $e',
      );
      return Result.failure('Start interaction error: $e');
    }
  }

  /// Stop the current voice interaction
  Future<Result<void>> stopInteraction() async {
    try {
      // Stop listening
      await _voiceService.stopListening();

      // Stop any ongoing speech
      await _voiceService.stopSpeaking();

      _addSessionEvent(
        VoiceInteractionEventType.sessionEnded,
        'Voice interaction session ended',
      );

      // Reset session data
      _currentSessionId = null;
      _sessionStartTime = null;

      _setState(VoiceInteractionState.idle);
      return Result.success(null);
    } catch (e) {
      _addSessionEvent(
        VoiceInteractionEventType.error,
        'Stop interaction error: $e',
      );
      return Result.failure('Stop interaction error: $e');
    }
  }

  /// Handle speech recognition results
  void _handleSpeechResult(SpeechResult speechResult) {
    if (!speechResult.isFinal) {
      // Handle intermediate results if needed
      _addSessionEvent(
        VoiceInteractionEventType.speechIntermediate,
        'Intermediate: ${speechResult.text}',
      );
      return;
    }

    _addSessionEvent(
      VoiceInteractionEventType.speechRecognized,
      'Recognized: ${speechResult.text} (confidence: ${speechResult.confidence})',
    );

    _setState(VoiceInteractionState.processing);

    // Process the final speech result
    _processVoiceCommand(speechResult);
  }

  /// Process a recognized voice command
  Future<void> _processVoiceCommand(SpeechResult speechResult) async {
    try {
      // Parse the speech into a command
      final parseResult = _commandParser.parseCommand(speechResult.text);
      if (parseResult.isFailure) {
        await _handleError('Failed to parse command: ${parseResult.error}');
        return;
      }

      final command = parseResult.value;
      _addSessionEvent(
        VoiceInteractionEventType.commandParsed,
        'Parsed command: ${command.type} (confidence: ${command.confidence})',
      );

      // Execute the command
      final executionResult = await _executeCommand(command);
      if (executionResult.isFailure) {
        await _handleError(
          'Failed to execute command: ${executionResult.error}',
        );
        return;
      }

      final responseContext = executionResult.value;

      // Generate response
      final responseResult = await _templateService.getResponse(
        responseContext,
      );
      if (responseResult.isFailure) {
        await _handleError(
          'Failed to generate response: ${responseResult.error}',
        );
        return;
      }

      final responseText = responseResult.value;
      _addSessionEvent(
        VoiceInteractionEventType.responseGenerated,
        'Generated response: $responseText',
      );

      // Speak the response
      _setState(VoiceInteractionState.responding);
      final speakResult = await _voiceService.speak(responseText);
      if (speakResult.isFailure) {
        await _handleError('Failed to speak response: ${speakResult.error}');
        return;
      }

      _addSessionEvent(
        VoiceInteractionEventType.responseSpoken,
        'Response spoken successfully',
      );
      _onInteractionResult?.call(responseText);
    } catch (e) {
      await _handleError('Voice command processing error: $e');
    }
  }

  /// Execute a parsed voice command
  Future<Result<TemplateContext>> _executeCommand(VoiceCommand command) async {
    try {
      switch (command.type) {
        case VoiceCommandType.completeHabit:
          return await _handleCompleteHabit(command);

        case VoiceCommandType.checkStreak:
          return await _handleCheckStreak(command);

        case VoiceCommandType.habitStatus:
          return await _handleHabitStatus(command);

        case VoiceCommandType.help:
          return await _handleHelp(command);

        case VoiceCommandType.unknown:
          return await _handleUnknownCommand(command);
      }
    } catch (e) {
      return Result.failure('Command execution error: $e');
    }
  }

  /// Handle habit completion command
  Future<Result<TemplateContext>> _handleCompleteHabit(
    VoiceCommand command,
  ) async {
    try {
      // Get current user data
      final userDataResult = await _storageService.getUserData();
      if (userDataResult.isFailure) {
        return Result.failure(
          'Failed to get user data: ${userDataResult.error}',
        );
      }

      final userData = userDataResult.value;
      final today = DateTime.now();

      // For now, use a default habit (this could be configurable later)
      const habitId = 'default_habit';
      const habitName = 'Daily Habit';

      // Create habit completion
      final completion = HabitCompletion(
        id: _generateCompletionId(),
        habitId: habitId,
        habitName: habitName,
        completedAt: today,
        notes: 'Voice completion: ${command.originalText}',
        metadata: {
          'voice_command': true,
          'command_confidence': command.confidence,
          'session_id': _currentSessionId,
        },
      );

      // Save the completion
      final saveResult = await _storageService.saveHabitCompletion(completion);
      if (saveResult.isFailure) {
        return Result.failure('Failed to save completion: ${saveResult.error}');
      }

      // Get updated streak data
      final streakResult = await _storageService.getStreakData(habitId);
      if (streakResult.isFailure) {
        return Result.failure(
          'Failed to get streak data: ${streakResult.error}',
        );
      }

      final streakData = streakResult.value;

      // Create template context for positive response
      final context = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {
          'habit_name': habitName,
          'streak_count': streakData.currentStreak,
          'completion_time': _formatTime(today),
          'is_new_streak_record':
              streakData.currentStreak > streakData.longestStreak,
        },
        userId: userData.userId,
      );

      return Result.success(context);
    } catch (e) {
      return Result.failure('Complete habit error: $e');
    }
  }

  /// Handle streak check command
  Future<Result<TemplateContext>> _handleCheckStreak(
    VoiceCommand command,
  ) async {
    try {
      final userDataResult = await _storageService.getUserData();
      if (userDataResult.isFailure) {
        return Result.failure(
          'Failed to get user data: ${userDataResult.error}',
        );
      }

      final userData = userDataResult.value;

      // Use default habit ID
      const habitId = 'default_habit';
      const habitName = 'Daily Habit';

      final streakResult = await _storageService.getStreakData(habitId);
      if (streakResult.isFailure) {
        return Result.failure(
          'Failed to get streak data: ${streakResult.error}',
        );
      }

      final streakData = streakResult.value;

      final context = TemplateContext.now(
        responseType: ResponseType.streakUpdate,
        variables: {
          'habit_name': habitName,
          'current_streak': streakData.currentStreak,
          'longest_streak': streakData.longestStreak,
          'last_completion': streakData.lastCompletionDate.toIso8601String(),
          'streak_start_date':
              streakData.currentStreakStartDate.toIso8601String(),
        },
        userId: userData.userId,
      );

      return Result.success(context);
    } catch (e) {
      return Result.failure('Check streak error: $e');
    }
  }

  /// Handle habit status command
  Future<Result<TemplateContext>> _handleHabitStatus(
    VoiceCommand command,
  ) async {
    try {
      final userDataResult = await _storageService.getUserData();
      if (userDataResult.isFailure) {
        return Result.failure(
          'Failed to get user data: ${userDataResult.error}',
        );
      }

      final userData = userDataResult.value;

      // Use default habit
      const habitId = 'default_habit';
      const habitName = 'Daily Habit';

      // Check if habit was completed today
      final today = DateTime.now();
      final completionsResult = await _storageService.getHabitCompletions(
        startDate: DateTime(today.year, today.month, today.day),
        endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
        habitId: habitId,
      );

      bool completedToday = false;
      if (completionsResult.isSuccess) {
        completedToday = completionsResult.value.isNotEmpty;
      }

      final streakResult = await _storageService.getStreakData(habitId);
      final streakData = streakResult.isSuccess ? streakResult.value : null;

      final context = TemplateContext.now(
        responseType: ResponseType.progressReport,
        variables: {
          'habit_name': habitName,
          'completed_today': completedToday,
          'current_streak': streakData?.currentStreak ?? 0,
          'time_of_day': _getTimeOfDay(),
        },
        userId: userData.userId,
      );

      return Result.success(context);
    } catch (e) {
      return Result.failure('Check habit status error: $e');
    }
  }

  /// Handle help command
  Future<Result<TemplateContext>> _handleHelp(VoiceCommand command) async {
    final helpTopic = command.parameters['topic'] ?? 'general';

    ResponseType responseType;
    switch (helpTopic) {
      case 'commands':
        responseType = ResponseType.helpVoiceCommands;
        break;
      default:
        responseType = ResponseType.helpGeneral;
    }

    final context = TemplateContext.now(
      responseType: responseType,
      variables: {
        'help_topic': helpTopic,
        'available_commands':
            _commandParser
                .getSupportedCommandTypes()
                .map((type) => type.toString().split('.').last)
                .toList(),
      },
    );

    return Result.success(context);
  }

  /// Handle unknown command
  Future<Result<TemplateContext>> _handleUnknownCommand(
    VoiceCommand command,
  ) async {
    final context = TemplateContext.now(
      responseType: ResponseType.commandNotUnderstood,
      variables: {
        'original_text': command.originalText,
        'confidence': command.confidence,
        'suggestions': [
          'Try saying "I did it" to complete your habit',
          'Ask "What\'s my streak?" to check your progress',
          'Say "Help" for more information',
        ],
      },
    );

    return Result.success(context);
  }

  /// Handle errors during voice interaction
  Future<void> _handleError(String error) async {
    _addSessionEvent(VoiceInteractionEventType.error, error);
    _onError?.call(error);

    // Try to speak an error message
    try {
      final errorContext = TemplateContext.now(
        responseType: ResponseType.errorGeneric,
        variables: {'error_message': error},
      );

      final responseResult = await _templateService.getResponse(errorContext);
      if (responseResult.isSuccess) {
        await _voiceService.speak(responseResult.value);
      }
    } catch (e) {
      // If we can't even speak an error message, just update state
    }

    _setState(VoiceInteractionState.error);
  }

  /// Handle voice recognition status changes
  void _handleRecognitionStatusChanged(VoiceRecognitionStatus status) {
    _addSessionEvent(
      VoiceInteractionEventType.recognitionStatusChanged,
      'Recognition status: $status',
    );

    switch (status) {
      case VoiceRecognitionStatus.listening:
        _setState(VoiceInteractionState.listening);
        break;
      case VoiceRecognitionStatus.processing:
        _setState(VoiceInteractionState.processing);
        break;
      case VoiceRecognitionStatus.error:
        _setState(VoiceInteractionState.error);
        break;
      case VoiceRecognitionStatus.inactive:
        if (_currentState == VoiceInteractionState.listening) {
          _setState(VoiceInteractionState.ready);
        }
        break;
      case VoiceRecognitionStatus.notAvailable:
        _setState(VoiceInteractionState.error);
        break;
    }
  }

  /// Handle text-to-speech status changes
  void _handleSpeechStatusChanged(TextToSpeechStatus status) {
    _addSessionEvent(
      VoiceInteractionEventType.speechStatusChanged,
      'Speech status: $status',
    );

    switch (status) {
      case TextToSpeechStatus.speaking:
        _setState(VoiceInteractionState.responding);
        break;
      case TextToSpeechStatus.inactive:
        if (_currentState == VoiceInteractionState.responding) {
          _setState(VoiceInteractionState.ready);
        }
        break;
      case TextToSpeechStatus.error:
        _setState(VoiceInteractionState.error);
        break;
      case TextToSpeechStatus.notAvailable:
        _setState(VoiceInteractionState.error);
        break;
    }
  }

  /// Set the current interaction state and notify listeners
  void _setState(VoiceInteractionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _onStateChanged?.call(newState);
      _addSessionEvent(
        VoiceInteractionEventType.stateChanged,
        'State: $newState',
      );
    }
  }

  /// Add an event to the current session
  void _addSessionEvent(VoiceInteractionEventType type, String description) {
    if (_currentSessionId != null) {
      _sessionEvents.add(
        VoiceInteractionEvent(
          type: type,
          timestamp: DateTime.now(),
          description: description,
          sessionId: _currentSessionId!,
        ),
      );
    }
  }

  /// Generate a unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate a unique completion ID
  String _generateCompletionId() {
    return 'completion_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get current time of day
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  /// Set callback for state changes
  void setOnStateChangedCallback(
    void Function(VoiceInteractionState state) callback,
  ) {
    _onStateChanged = callback;
  }

  /// Set callback for interaction results
  void setOnInteractionResultCallback(void Function(String message) callback) {
    _onInteractionResult = callback;
  }

  /// Set callback for errors
  void setOnErrorCallback(void Function(String error) callback) {
    _onError = callback;
  }

  /// Get current interaction state
  VoiceInteractionState get currentState => _currentState;

  /// Get current session information
  Map<String, dynamic> getCurrentSessionInfo() {
    return {
      'session_id': _currentSessionId,
      'start_time': _sessionStartTime?.toIso8601String(),
      'current_state': _currentState.toString(),
      'events_count': _sessionEvents.length,
    };
  }

  /// Get session events for debugging/monitoring
  List<VoiceInteractionEvent> getSessionEvents() {
    return List.unmodifiable(_sessionEvents);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await stopInteraction();
    await _voiceService.dispose();
    _sessionEvents.clear();
  }
}

/// Represents the current state of voice interaction
enum VoiceInteractionState {
  /// Not initialized or stopped
  idle,

  /// Ready to start interaction
  ready,

  /// Actively listening for speech
  listening,

  /// Processing recognized speech
  processing,

  /// Speaking response
  responding,

  /// Error occurred
  error,
}

/// Types of events that occur during voice interaction
enum VoiceInteractionEventType {
  sessionStarted,
  sessionEnded,
  stateChanged,
  speechRecognized,
  speechIntermediate,
  commandParsed,
  responseGenerated,
  responseSpoken,
  recognitionStatusChanged,
  speechStatusChanged,
  error,
}

/// Represents an event that occurred during voice interaction
class VoiceInteractionEvent {
  final VoiceInteractionEventType type;
  final DateTime timestamp;
  final String description;
  final String sessionId;
  final Map<String, dynamic>? metadata;

  VoiceInteractionEvent({
    required this.type,
    required this.timestamp,
    required this.description,
    required this.sessionId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'session_id': sessionId,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'VoiceInteractionEvent{type: $type, timestamp: $timestamp, description: $description}';
  }
}
