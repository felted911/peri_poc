import '../models/template_models.dart';

/// Static template data for the application
///
/// This class contains all the response templates organized by response type.
/// Templates support variable substitution and conditional content.
class AppTemplates {
  /// Get the default template collection for the application
  static TemplateCollection getDefaultCollection() {
    return TemplateCollection(
      name: 'Default Templates',
      description: 'Core templates for voice interactions',
      templates: _buildTemplateMap(),
      metadata: {
        'version': '1.0.0',
        'created': DateTime.now().toIso8601String(),
        'variableFormat': '{{variableName}}',
        'conditionalFormat': '{{#if variable}}content{{/if}}',
      },
    );
  }

  /// Build the complete template map
  static Map<ResponseType, List<ResponseTemplate>> _buildTemplateMap() {
    return {
      // Acknowledgment responses
      ResponseType.confirmationPositive: _confirmationPositiveTemplates,
      ResponseType.confirmationNegative: _confirmationNegativeTemplates,
      ResponseType.acknowledged: _acknowledgedTemplates,

      // Habit-related responses
      ResponseType.habitCompleted: _habitCompletedTemplates,
      ResponseType.habitReminder: _habitReminderTemplates,
      ResponseType.habitStreak: _habitStreakTemplates,
      ResponseType.habitMotivation: _habitMotivationTemplates,
      ResponseType.habitProgress: _habitProgressTemplates,

      // Status responses
      ResponseType.streakUpdate: _streakUpdateTemplates,
      ResponseType.progressReport: _progressReportTemplates,
      ResponseType.dailySummary: _dailySummaryTemplates,
      ResponseType.weeklyReport: _weeklyReportTemplates,

      // Error and help responses
      ResponseType.commandNotUnderstood: _commandNotUnderstoodTemplates,
      ResponseType.helpGeneral: _helpGeneralTemplates,
      ResponseType.helpVoiceCommands: _helpVoiceCommandsTemplates,
      ResponseType.errorGeneric: _errorGenericTemplates,
      ResponseType.errorPermission: _errorPermissionTemplates,
      ResponseType.errorNetwork: _errorNetworkTemplates,

      // Greeting and conversation
      ResponseType.greeting: _greetingTemplates,
      ResponseType.goodbye: _goodbyeTemplates,
      ResponseType.conversationStarter: _conversationStarterTemplates,
      ResponseType.encouragement: _encouragementTemplates,

      // System responses
      ResponseType.systemReady: _systemReadyTemplates,
      ResponseType.systemBusy: _systemBusyTemplates,
      ResponseType.systemError: _systemErrorTemplates,
      ResponseType.permissionRequest: _permissionRequestTemplates,

      // Context-specific responses
      ResponseType.firstTimeUser: _firstTimeUserTemplates,
      ResponseType.returningUser: _returningUserTemplates,
      ResponseType.achievementUnlocked: _achievementUnlockedTemplates,
      ResponseType.milestone: _milestoneTemplates,
    };
  }

  // Confirmation responses
  static final List<ResponseTemplate> _confirmationPositiveTemplates = [
    ResponseTemplate(
      id: 'confirm_pos_1',
      responseType: ResponseType.confirmationPositive,
      template: 'Yes, that\'s correct!',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'confirm_pos_2',
      responseType: ResponseType.confirmationPositive,
      template: 'Absolutely! You got it right.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'confirm_pos_3',
      responseType: ResponseType.confirmationPositive,
      template:
          'That\'s right! {{#if userName}}{{userName}}, {{/if}}you nailed it.',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 1,
    ),
  ];

  static final List<ResponseTemplate> _confirmationNegativeTemplates = [
    ResponseTemplate(
      id: 'confirm_neg_1',
      responseType: ResponseType.confirmationNegative,
      template: 'No, that\'s not quite right.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'confirm_neg_2',
      responseType: ResponseType.confirmationNegative,
      template: 'Actually, that\'s not correct. Let me help you.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'confirm_neg_3',
      responseType: ResponseType.confirmationNegative,
      template:
          'Not exactly{{#if userName}}, {{userName}}{{/if}}. Let\'s try again.',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 1,
    ),
  ];

  static final List<ResponseTemplate> _acknowledgedTemplates = [
    ResponseTemplate(
      id: 'ack_1',
      responseType: ResponseType.acknowledged,
      template: 'Got it!',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'ack_2',
      responseType: ResponseType.acknowledged,
      template: 'Understood.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'ack_3',
      responseType: ResponseType.acknowledged,
      template: 'Okay, I hear you.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'ack_4',
      responseType: ResponseType.acknowledged,
      template:
          'Thanks for letting me know{{#if userName}}, {{userName}}{{/if}}.',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 1,
    ),
  ];

  // Habit completion responses
  static final List<ResponseTemplate> _habitCompletedTemplates = [
    ResponseTemplate(
      id: 'habit_complete_1',
      responseType: ResponseType.habitCompleted,
      template:
          'Awesome! You completed {{habitName}} today. Keep up the great work!',
      requiredVariables: ['habitName'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'habit_complete_2',
      responseType: ResponseType.habitCompleted,
      template: 'Well done! {{habitName}} is now checked off for today.',
      requiredVariables: ['habitName'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'habit_complete_3',
      responseType: ResponseType.habitCompleted,
      template:
          'Fantastic work on {{habitName}}! {{#if streakCount}}That\'s {{streakCount}} days in a row!{{/if}}',
      requiredVariables: ['habitName'],
      optionalVariables: ['streakCount'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'habit_complete_4',
      responseType: ResponseType.habitCompleted,
      template:
          'Yes! Another day of {{habitName}} completed. You\'re building amazing consistency!',
      requiredVariables: ['habitName'],
      weight: 1,
    ),
  ];

  // Habit reminder responses
  static final List<ResponseTemplate> _habitReminderTemplates = [
    ResponseTemplate(
      id: 'habit_reminder_1',
      responseType: ResponseType.habitReminder,
      template: 'Don\'t forget about {{habitName}} today!',
      requiredVariables: ['habitName'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'habit_reminder_2',
      responseType: ResponseType.habitReminder,
      template: 'Time for {{habitName}}! You\'ve got this.',
      requiredVariables: ['habitName'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'habit_reminder_3',
      responseType: ResponseType.habitReminder,
      template:
          'Hey{{#if userName}} {{userName}}{{/if}}, ready to tackle {{habitName}}?',
      requiredVariables: ['habitName'],
      optionalVariables: ['userName'],
      weight: 2,
    ),
  ];

  // Streak responses
  static final List<ResponseTemplate> _habitStreakTemplates = [
    ResponseTemplate(
      id: 'streak_1',
      responseType: ResponseType.habitStreak,
      template:
          'You\'re on a {{streakCount}}-day streak with {{habitName}}! Amazing!',
      requiredVariables: ['streakCount', 'habitName'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'streak_2',
      responseType: ResponseType.habitStreak,
      template:
          'Wow! {{streakCount}} consecutive days of {{habitName}}. You\'re unstoppable!',
      requiredVariables: ['streakCount', 'habitName'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'streak_3',
      responseType: ResponseType.habitStreak,
      template:
          'Your {{habitName}} streak is at {{streakCount}} days. Keep the momentum going!',
      requiredVariables: ['streakCount', 'habitName'],
      weight: 2,
    ),
  ];

  // Motivation responses
  static final List<ResponseTemplate> _habitMotivationTemplates = [
    ResponseTemplate(
      id: 'motivation_1',
      responseType: ResponseType.habitMotivation,
      template: 'Every small step counts. You\'re building something amazing!',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'motivation_2',
      responseType: ResponseType.habitMotivation,
      template: 'Consistency is key, and you\'re proving that every day!',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'motivation_3',
      responseType: ResponseType.habitMotivation,
      template:
          'Remember{{#if userName}} {{userName}}{{/if}}, progress beats perfection every time.',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'motivation_4',
      responseType: ResponseType.habitMotivation,
      template:
          'You\'re {{#if streakCount}}{{streakCount}} days{{/if}} closer to your goal. Don\'t stop now!',
      requiredVariables: [],
      optionalVariables: ['streakCount'],
      weight: 1,
    ),
  ];

  // Progress responses
  static final List<ResponseTemplate> _habitProgressTemplates = [
    ResponseTemplate(
      id: 'progress_1',
      responseType: ResponseType.habitProgress,
      template:
          'You\'ve completed {{completedDays}} out of {{totalDays}} days this month. Great job!',
      requiredVariables: ['completedDays', 'totalDays'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'progress_2',
      responseType: ResponseType.habitProgress,
      template:
          'Your completion rate for {{habitName}} is {{completionRate}}%. Keep it up!',
      requiredVariables: ['habitName', 'completionRate'],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'progress_3',
      responseType: ResponseType.habitProgress,
      template:
          'You\'re making steady progress! {{completedDays}} days completed so far.',
      requiredVariables: ['completedDays'],
      weight: 2,
    ),
  ];

  // Error and help responses
  static final List<ResponseTemplate> _commandNotUnderstoodTemplates = [
    ResponseTemplate(
      id: 'not_understood_1',
      responseType: ResponseType.commandNotUnderstood,
      template: 'I didn\'t quite catch that. Could you try again?',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'not_understood_2',
      responseType: ResponseType.commandNotUnderstood,
      template: 'I\'m not sure what you meant. Try saying "help" for commands.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'not_understood_3',
      responseType: ResponseType.commandNotUnderstood,
      template:
          'Sorry, I didn\'t understand that command. What would you like to do?',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _helpGeneralTemplates = [
    ResponseTemplate(
      id: 'help_general_1',
      responseType: ResponseType.helpGeneral,
      template:
          'I can help you track habits and build streaks. Try saying "mark habit complete" or "what\'s my streak?"',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'help_general_2',
      responseType: ResponseType.helpGeneral,
      template:
          'I\'m here to support your habit building journey. You can ask about your progress, complete habits, or get motivation.',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _helpVoiceCommandsTemplates = [
    ResponseTemplate(
      id: 'help_commands_1',
      responseType: ResponseType.helpVoiceCommands,
      template:
          'Try these commands: "complete habit", "check my streak", "how am I doing?", or "motivate me".',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'help_commands_2',
      responseType: ResponseType.helpVoiceCommands,
      template:
          'Voice commands include: habit completion, streak checking, progress reports, and motivation requests.',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  // System responses
  static final List<ResponseTemplate> _systemReadyTemplates = [
    ResponseTemplate(
      id: 'system_ready_1',
      responseType: ResponseType.systemReady,
      template: 'I\'m ready to help you with your habits!',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'system_ready_2',
      responseType: ResponseType.systemReady,
      template: 'All systems ready. What can I help you with today?',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _systemBusyTemplates = [
    ResponseTemplate(
      id: 'system_busy_1',
      responseType: ResponseType.systemBusy,
      template: 'I\'m processing your request. Please wait a moment.',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'system_busy_2',
      responseType: ResponseType.systemBusy,
      template: 'Working on that for you. Just a second...',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  // Greeting responses
  static final List<ResponseTemplate> _greetingTemplates = [
    ResponseTemplate(
      id: 'greeting_1',
      responseType: ResponseType.greeting,
      template:
          'Hello{{#if userName}} {{userName}}{{/if}}! Ready to work on your habits today?',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'greeting_2',
      responseType: ResponseType.greeting,
      template: 'Hi there! Let\'s make today count with your habit building.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'greeting_3',
      responseType: ResponseType.greeting,
      template: 'Good {{timeOfDay}}! What habit would you like to work on?',
      requiredVariables: ['timeOfDay'],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _goodbyeTemplates = [
    ResponseTemplate(
      id: 'goodbye_1',
      responseType: ResponseType.goodbye,
      template:
          'Goodbye{{#if userName}} {{userName}}{{/if}}! Keep up the great work with your habits.',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'goodbye_2',
      responseType: ResponseType.goodbye,
      template: 'See you later! Remember, consistency is key.',
      requiredVariables: [],
      weight: 2,
    ),
    ResponseTemplate(
      id: 'goodbye_3',
      responseType: ResponseType.goodbye,
      template:
          'Until next time! You\'re doing amazing with your habit journey.',
      requiredVariables: [],
      weight: 1,
    ),
  ];

  // Error templates
  static final List<ResponseTemplate> _errorGenericTemplates = [
    ResponseTemplate(
      id: 'error_generic_1',
      responseType: ResponseType.errorGeneric,
      template: 'Something went wrong. Let me try that again.',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'error_generic_2',
      responseType: ResponseType.errorGeneric,
      template: 'Oops! There was an issue. Please try your request again.',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _errorPermissionTemplates = [
    ResponseTemplate(
      id: 'error_permission_1',
      responseType: ResponseType.errorPermission,
      template:
          'I need microphone permission to hear you. Please enable it in settings.',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'error_permission_2',
      responseType: ResponseType.errorPermission,
      template: 'To use voice commands, please allow microphone access.',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  static final List<ResponseTemplate> _errorNetworkTemplates = [
    ResponseTemplate(
      id: 'error_network_1',
      responseType: ResponseType.errorNetwork,
      template:
          'I\'m having trouble connecting. Please check your internet connection.',
      requiredVariables: [],
      weight: 3,
    ),
    ResponseTemplate(
      id: 'error_network_2',
      responseType: ResponseType.errorNetwork,
      template: 'Network issue detected. Some features may be limited.',
      requiredVariables: [],
      weight: 2,
    ),
  ];

  // Additional templates (shortened for brevity)
  static final List<ResponseTemplate> _streakUpdateTemplates = [
    ResponseTemplate(
      id: 'streak_update_1',
      responseType: ResponseType.streakUpdate,
      template: 'Your current streak is {{streakCount}} days. Keep it going!',
      requiredVariables: ['streakCount'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _progressReportTemplates = [
    ResponseTemplate(
      id: 'progress_report_1',
      responseType: ResponseType.progressReport,
      template:
          'This week you completed {{completedDays}} out of {{totalDays}} days. {{#if improvementTip}}{{improvementTip}}{{/if}}',
      requiredVariables: ['completedDays', 'totalDays'],
      optionalVariables: ['improvementTip'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _dailySummaryTemplates = [
    ResponseTemplate(
      id: 'daily_summary_1',
      responseType: ResponseType.dailySummary,
      template:
          'Today you completed {{completedHabits}} habits. {{#if pendingHabits}}You still have {{pendingHabits}} habits to complete.{{/if}}',
      requiredVariables: ['completedHabits'],
      optionalVariables: ['pendingHabits'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _weeklyReportTemplates = [
    ResponseTemplate(
      id: 'weekly_report_1',
      responseType: ResponseType.weeklyReport,
      template:
          'This week\'s summary: {{completionRate}}% completion rate with {{totalCompletions}} habits completed.',
      requiredVariables: ['completionRate', 'totalCompletions'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _conversationStarterTemplates = [
    ResponseTemplate(
      id: 'conversation_1',
      responseType: ResponseType.conversationStarter,
      template: 'How are you feeling about your habit progress today?',
      requiredVariables: [],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _encouragementTemplates = [
    ResponseTemplate(
      id: 'encouragement_1',
      responseType: ResponseType.encouragement,
      template: 'You\'re doing great! Every day of progress matters.',
      requiredVariables: [],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _systemErrorTemplates = [
    ResponseTemplate(
      id: 'system_error_1',
      responseType: ResponseType.systemError,
      template: 'System error occurred. Restarting services...',
      requiredVariables: [],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _permissionRequestTemplates = [
    ResponseTemplate(
      id: 'permission_request_1',
      responseType: ResponseType.permissionRequest,
      template:
          'I need permission to access your microphone for voice commands. Would you like to enable it?',
      requiredVariables: [],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _firstTimeUserTemplates = [
    ResponseTemplate(
      id: 'first_time_1',
      responseType: ResponseType.firstTimeUser,
      template:
          'Welcome to your habit tracking journey! I\'m here to help you build consistent habits. Let\'s start by setting up your first habit.',
      requiredVariables: [],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _returningUserTemplates = [
    ResponseTemplate(
      id: 'returning_user_1',
      responseType: ResponseType.returningUser,
      template:
          'Welcome back{{#if userName}}, {{userName}}{{/if}}! Ready to continue building those amazing habits?',
      requiredVariables: [],
      optionalVariables: ['userName'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _achievementUnlockedTemplates = [
    ResponseTemplate(
      id: 'achievement_1',
      responseType: ResponseType.achievementUnlocked,
      template:
          'Achievement unlocked: {{achievementName}}! {{#if achievementDescription}}{{achievementDescription}}{{/if}}',
      requiredVariables: ['achievementName'],
      optionalVariables: ['achievementDescription'],
      weight: 3,
    ),
  ];

  static final List<ResponseTemplate> _milestoneTemplates = [
    ResponseTemplate(
      id: 'milestone_1',
      responseType: ResponseType.milestone,
      template:
          'Milestone reached! You\'ve completed {{milestoneCount}} {{milestoneType}}. This is a huge accomplishment!',
      requiredVariables: ['milestoneCount', 'milestoneType'],
      weight: 3,
    ),
  ];
}
