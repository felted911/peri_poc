import 'package:flutter/material.dart';

/// A widget to display streak information
///
/// This widget shows the current streak count and provides visual feedback
/// about streak progress.
class StreakDisplay extends StatelessWidget {
  /// The current streak count
  final int currentStreak;

  /// The longest streak achieved
  final int longestStreak;

  /// Title text to display above the streak count
  final String title;

  /// Text to display for zero streak
  final String zeroStreakText;

  /// Primary color for the streak display
  final Color? primaryColor;

  /// Background color for the streak display
  final Color? backgroundColor;

  /// Whether to show the longest streak
  final bool showLongestStreak;

  /// Animation duration for streak changes
  final Duration animationDuration;

  /// Creates a new streak display widget
  const StreakDisplay({
    super.key,
    required this.currentStreak,
    this.longestStreak = 0,
    this.title = 'Current Streak',
    this.zeroStreakText = 'No active streak',
    this.primaryColor,
    this.backgroundColor,
    this.showLongestStreak = true,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualPrimaryColor = primaryColor ?? theme.colorScheme.primary;
    final actualBackgroundColor = backgroundColor ?? theme.colorScheme.surface;

    return Card(
      elevation: 3,
      color: actualBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),

            // Streak display
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: currentStreak),
              duration: animationDuration,
              builder: (context, value, child) {
                return _buildStreakCounter(context, value, actualPrimaryColor);
              },
            ),

            const SizedBox(height: 12),

            // Streak status text
            Text(
              currentStreak == 0
                  ? zeroStreakText
                  : currentStreak == 1
                      ? '1 day streak'
                      : '$currentStreak days streak',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),

            // Longest streak (optional)
            if (showLongestStreak && longestStreak > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Longest: $longestStreak days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],

            // Streak visualization
            const SizedBox(height: 16),
            _buildStreakVisualization(context, actualPrimaryColor),
          ],
        ),
      ),
    );
  }

  /// Builds the streak counter with animated number
  Widget _buildStreakCounter(BuildContext context, int value, Color primaryColor) {
    final theme = Theme.of(context);
    final isNewRecord = currentStreak > 0 && currentStreak >= longestStreak;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.1),
          ),
        ),

        // Counter text
        Text(
          value.toString(),
          style: theme.textTheme.headlineLarge?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        // New record indicator
        if (isNewRecord)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'NEW!',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a visualization of the streak
  Widget _buildStreakVisualization(BuildContext context, Color primaryColor) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          // Define active dots (0-indexed, so add 1 for comparison)
          final isActive = index < currentStreak % 7;
          final isMilestone = (index + 1) % 7 == 0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: isActive ? 1.0 : 0.5),
              duration: animationDuration,
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: isMilestone ? 16 : 12,
                    height: isMilestone ? 16 : 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.2),
                      border: isMilestone
                          ? Border.all(color: primaryColor, width: 2)
                          : null,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
