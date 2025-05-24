import 'package:flutter/foundation.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';

/// ViewModel for the home screen that manages voice interaction state
class HomeViewModel extends ChangeNotifier {
  final VoiceInteractionCoordinator _voiceInteractionCoordinator;
  final IStorageService _storageService;

  /// Current voice interaction state
  VoiceInteractionState _interactionState = VoiceInteractionState.idle;

  /// Last recognized text from speech
  String _recognizedText = '';

  /// Last response message
  String _responseMessage = '';

  /// Current streak for the default habit
  int _currentStreak = 0;

  /// Longest streak achieved
  int _longestStreak = 0;

  /// Whether an interaction is in progress
  bool _isInteracting = false;

  /// Error message, if any
  String? _errorMessage;

  /// Constructor
  HomeViewModel({
    required VoiceInteractionCoordinator voiceInteractionCoordinator,
    required IStorageService storageService,
  }) : _voiceInteractionCoordinator = voiceInteractionCoordinator,
       _storageService = storageService {
    _initialize();
  }

  /// Initialize the view model
  Future<void> _initialize() async {
    // Set up coordinator callbacks
    _voiceInteractionCoordinator.setOnStateChangedCallback(_onStateChanged);
    _voiceInteractionCoordinator.setOnInteractionResultCallback(_onInteractionResult);
    _voiceInteractionCoordinator.setOnErrorCallback(_onError);

    // Initialize interaction coordinator
    final initResult = await _voiceInteractionCoordinator.initialize();
    if (initResult.isFailure) {
      _errorMessage = 'Failed to initialize voice interaction: ${initResult.error}';
      notifyListeners();
      return;
    }

    // Load streak data
    await _loadStreakData();
  }

  /// Load streak data from storage
  Future<void> _loadStreakData() async {
    try {
      const defaultHabitId = 'default_habit';
      final streakResult = await _storageService.getStreakData(defaultHabitId);
      
      if (streakResult.isSuccess) {
        final streakData = streakResult.value;
        _currentStreak = streakData.currentStreak;
        _longestStreak = streakData.longestStreak;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading streak data: $e');
    }
  }

  /// Handle state changes from the voice interaction coordinator
  void _onStateChanged(VoiceInteractionState state) {
    _interactionState = state;
    
    // Update isInteracting flag based on state
    _isInteracting = state == VoiceInteractionState.listening || 
                    state == VoiceInteractionState.processing ||
                    state == VoiceInteractionState.responding;
    
    notifyListeners();
  }

  /// Handle interaction results
  void _onInteractionResult(String message) {
    _responseMessage = message;
    
    // After a successful interaction, reload streak data
    _loadStreakData();
    
    notifyListeners();
  }

  /// Handle errors
  void _onError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Start a voice interaction session
  Future<void> startVoiceInteraction() async {
    // Clear previous state
    _recognizedText = '';
    _responseMessage = '';
    _errorMessage = null;
    
    notifyListeners();
    
    // Start interaction
    final result = await _voiceInteractionCoordinator.startInteraction();
    if (result.isFailure) {
      _errorMessage = 'Failed to start voice interaction: ${result.error}';
      notifyListeners();
    }
  }

  /// Stop the current voice interaction
  Future<void> stopVoiceInteraction() async {
    final result = await _voiceInteractionCoordinator.stopInteraction();
    if (result.isFailure) {
      _errorMessage = 'Failed to stop voice interaction: ${result.error}';
      notifyListeners();
    }
  }

  /// Toggle between starting and stopping voice interaction
  Future<void> toggleVoiceInteraction() async {
    if (_isInteracting) {
      await stopVoiceInteraction();
    } else {
      await startVoiceInteraction();
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    _voiceInteractionCoordinator.dispose();
    super.dispose();
  }

  // Getters for the view
  VoiceInteractionState get interactionState => _interactionState;
  String get recognizedText => _recognizedText;
  String get responseMessage => _responseMessage;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  bool get isInteracting => _isInteracting;
  String? get errorMessage => _errorMessage;
  bool get isListening => _interactionState == VoiceInteractionState.listening;
  bool get isProcessing => _interactionState == VoiceInteractionState.processing;
  bool get isResponding => _interactionState == VoiceInteractionState.responding;
  bool get hasError => _interactionState == VoiceInteractionState.error;
}
