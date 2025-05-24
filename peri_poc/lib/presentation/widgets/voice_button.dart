import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:peri_poc/services/voice_interaction_coordinator.dart';

/// A customizable animated voice button widget
///
/// This widget represents a voice interaction button that provides visual
/// feedback based on the current voice interaction state.
class VoiceButton extends StatefulWidget {
  /// Current voice interaction state
  final VoiceInteractionState state;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Size of the button
  final double size;

  /// Icon size
  final double iconSize;

  /// Button elevation
  final double elevation;

  /// Primary color used for the button
  final Color? primaryColor;

  /// Secondary color used for animations
  final Color? secondaryColor;

  /// Error color shown when in error state
  final Color? errorColor;

  /// Icon displayed in idle/ready state
  final IconData idleIcon;

  /// Icon displayed in listening state
  final IconData listeningIcon;

  /// Icon displayed in processing state
  final IconData processingIcon;

  /// Icon displayed in responding state
  final IconData respondingIcon;

  /// Icon displayed in error state
  final IconData errorIcon;

  /// Creates a new voice button
  const VoiceButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.size = 72.0,
    this.iconSize = 36.0,
    this.elevation = 6.0,
    this.primaryColor,
    this.secondaryColor,
    this.errorColor,
    this.idleIcon = Icons.mic_none,
    this.listeningIcon = Icons.mic,
    this.processingIcon = Icons.hourglass_top,
    this.respondingIcon = Icons.volume_up,
    this.errorIcon = Icons.error_outline,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotationController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for processing state
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Rotation animation for processing state
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Update animation based on initial state
    _updateAnimationsForState(widget.state);
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimationsForState(widget.state);
    }
  }

  void _updateAnimationsForState(VoiceInteractionState state) {
    switch (state) {
      case VoiceInteractionState.listening:
        _pulseController.repeat(reverse: true);
        _waveController.stop();
        _rotationController.stop();
        break;
      case VoiceInteractionState.processing:
        _pulseController.stop();
        _waveController.repeat();
        _rotationController.repeat();
        break;
      case VoiceInteractionState.responding:
        _pulseController.repeat(reverse: true);
        _waveController.stop();
        _rotationController.stop();
        break;
      case VoiceInteractionState.error:
      case VoiceInteractionState.idle:
      case VoiceInteractionState.ready:
        _pulseController.stop();
        _waveController.stop();
        _rotationController.stop();
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Use provided colors or fallback to theme colors
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final secondaryColor = widget.secondaryColor ?? theme.colorScheme.secondary;
    final errorColor = widget.errorColor ?? theme.colorScheme.error;

    // Determine button and icon properties based on state
    Color buttonColor;
    Color iconColor;
    IconData icon;
    double scale = 1.0;
    Widget? buttonChild;

    switch (widget.state) {
      case VoiceInteractionState.idle:
      case VoiceInteractionState.ready:
        buttonColor = primaryColor;
        iconColor = theme.colorScheme.onPrimary;
        icon = widget.idleIcon;
        break;
      case VoiceInteractionState.listening:
        buttonColor = secondaryColor;
        iconColor = theme.colorScheme.onSecondary;
        icon = widget.listeningIcon;
        buttonChild = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            scale = _pulseAnimation.value;
            return child!;
          },
          child: Icon(icon, size: widget.iconSize, color: iconColor),
        );
        break;
      case VoiceInteractionState.processing:
        buttonColor = primaryColor;
        iconColor = theme.colorScheme.onPrimary;
        icon = widget.processingIcon;
        buttonChild = AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            );
          },
          child: Icon(icon, size: widget.iconSize, color: iconColor),
        );
        break;
      case VoiceInteractionState.responding:
        buttonColor = secondaryColor;
        iconColor = theme.colorScheme.onSecondary;
        icon = widget.respondingIcon;
        break;
      case VoiceInteractionState.error:
        buttonColor = errorColor;
        iconColor = theme.colorScheme.onError;
        icon = widget.errorIcon;
        break;
    }

    // Build the base button
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size * scale,
        height: widget.size * scale,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.3),
              blurRadius: widget.elevation,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: buttonChild ?? Icon(
            icon,
            size: widget.iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
