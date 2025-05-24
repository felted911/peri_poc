import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:peri_poc/presentation/home/home_view_model.dart';
import 'package:peri_poc/presentation/widgets/voice_button.dart';
import 'package:peri_poc/presentation/widgets/streak_display.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';

/// The main home screen of the application
///
/// This screen displays the voice button and streak information,
/// and provides an interface for voice interaction.
class HomeScreen extends StatefulWidget {
  /// The title of the home screen
  final String title;

  /// Creates a new home screen
  const HomeScreen({
    super.key,
    required this.title,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  /// View model for the home screen
  late HomeViewModel _viewModel;

  /// Animation controller for the response message
  late AnimationController _messageAnimationController;
  late Animation<double> _messageAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize view model
    final serviceLocator = GetIt.instance;
    _viewModel = HomeViewModel(
      voiceInteractionCoordinator: serviceLocator.get<VoiceInteractionCoordinator>(),
      storageService: serviceLocator.get<IStorageService>(),
    );

    // Set up animation for response messages
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _messageAnimation = CurvedAnimation(
      parent: _messageAnimationController,
      curve: Curves.easeInOut,
    );

    // Listen for changes in the view model
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    // Animate the message container when response changes
    if (_viewModel.responseMessage.isNotEmpty) {
      _messageAnimationController.forward();
    } else {
      _messageAnimationController.reverse();
    }

    // Force UI update
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messageAnimationController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Streak display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: StreakDisplay(
                  currentStreak: _viewModel.currentStreak,
                  longestStreak: _viewModel.longestStreak,
                ),
              ),

              const Spacer(),

              // Status message
              _buildStatusMessage(context),
              
              // Response message
              _buildResponseMessage(context),

              const Spacer(),

              // Voice button
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: VoiceButton(
                    state: _viewModel.interactionState,
                    onPressed: _viewModel.toggleVoiceInteraction,
                    size: 80,
                    iconSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status message based on the current state
  Widget _buildStatusMessage(BuildContext context) {
    final theme = Theme.of(context);
    String message;

    switch (_viewModel.interactionState) {
      case VoiceInteractionState.idle:
      case VoiceInteractionState.ready:
        message = 'Tap the microphone to start';
        break;
      case VoiceInteractionState.listening:
        message = 'Listening...';
        break;
      case VoiceInteractionState.processing:
        message = 'Processing...';
        break;
      case VoiceInteractionState.responding:
        message = 'Responding...';
        break;
      case VoiceInteractionState.error:
        message = _viewModel.errorMessage ?? 'An error occurred';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: _viewModel.hasError
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
          fontWeight: _viewModel.isInteracting
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  /// Builds the response message with animation
  Widget _buildResponseMessage(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _messageAnimation,
      builder: (context, child) {
        return Container(
          height: 120 * _messageAnimation.value,
          constraints: BoxConstraints(
            minHeight: _viewModel.responseMessage.isEmpty ? 0 : 60,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                _viewModel.responseMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
