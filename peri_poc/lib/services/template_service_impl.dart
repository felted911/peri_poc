import 'dart:math';
import '../interfaces/i_template_service.dart';
import '../models/template_models.dart';
import '../core/utils/result.dart';
import '../data/templates.dart';

/// Implementation of template service for response generation
///
/// This service manages template-based responses, providing dynamic content
/// generation with variable substitution and weighted random selection.
class TemplateServiceImpl implements ITemplateService {
  late TemplateCollection _templateCollection;
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  Future<Result<void>> initialize() async {
    try {
      // Load template data from the templates file
      _templateCollection = AppTemplates.getDefaultCollection();
      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        'Failed to initialize template service: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<String>> getResponse(TemplateContext context) async {
    if (!_isInitialized) {
      return Result.failure('Template service not initialized');
    }

    // Validate context
    final validationResult = validateContext(context);
    if (validationResult.isFailure) {
      return Result.failure(validationResult.error);
    }

    // Get templates for the response type
    final templates = _templateCollection.getTemplatesFor(context.responseType);
    if (templates.isEmpty) {
      return Result.failure(
        'No templates found for response type: ${context.responseType}',
      );
    }

    // Filter templates that can be used with the current context
    final usableTemplates =
        templates.where((template) => template.canBeUsedWith(context)).toList();

    if (usableTemplates.isEmpty) {
      return Result.failure(
        'No usable templates found for response type: ${context.responseType}. Check if all required variables are provided.',
      );
    }

    // Select template using weighted random selection
    final selectedTemplate = _selectWeightedRandom(usableTemplates);

    // Generate response with variable substitution
    try {
      final response = _substituteVariables(
        selectedTemplate.template,
        context.variables,
      );
      return Result.success(response);
    } catch (e) {
      return Result.failure('Failed to generate response: ${e.toString()}');
    }
  }

  @override
  Future<Result<String>> getRandomResponse(
    ResponseType responseType, {
    Map<String, dynamic>? variables,
  }) async {
    final context = TemplateContext.now(
      responseType: responseType,
      variables: variables ?? {},
    );

    return getResponse(context);
  }

  @override
  bool hasTemplatesFor(ResponseType responseType) {
    if (!_isInitialized) return false;
    return _templateCollection.hasTemplatesFor(responseType);
  }

  @override
  List<ResponseType> getAvailableResponseTypes() {
    if (!_isInitialized) return [];
    return _templateCollection.availableResponseTypes;
  }

  @override
  Result<void> validateContext(TemplateContext context) {
    if (!_isInitialized) {
      return Result.failure('Template service not initialized');
    }

    // Check if response type exists
    if (!hasTemplatesFor(context.responseType)) {
      return Result.failure(
        'No templates available for response type: ${context.responseType}',
      );
    }

    // Get templates for this response type
    final templates = _templateCollection.getTemplatesFor(context.responseType);

    // Check if at least one template can be used with the context
    final hasUsableTemplate = templates.any(
      (template) => template.canBeUsedWith(context),
    );

    if (!hasUsableTemplate) {
      return Result.failure(
        'No usable templates found for response type: ${context.responseType}. Missing required variables.',
      );
    }

    return Result.success(null);
  }

  @override
  Map<String, dynamic> getTemplateMetadata() {
    if (!_isInitialized) {
      return {'initialized': false};
    }

    final metadata = <String, dynamic>{
      'initialized': true,
      'collectionName': _templateCollection.name,
      'totalTemplates': _templateCollection.totalTemplateCount,
      'responseTypes':
          getAvailableResponseTypes().map((e) => e.toString()).toList(),
      'templatesByType': {},
    };

    // Add template count by type
    for (final responseType in getAvailableResponseTypes()) {
      final templates = _templateCollection.getTemplatesFor(responseType);
      metadata['templatesByType'][responseType.toString()] = {
        'count': templates.length,
        'templates':
            templates
                .map(
                  (t) => {
                    'id': t.id,
                    'weight': t.weight,
                    'requiredVariables': t.requiredVariables,
                    'optionalVariables': t.optionalVariables,
                  },
                )
                .toList(),
      };
    }

    return metadata;
  }

  /// Select a template using weighted random selection
  ResponseTemplate _selectWeightedRandom(List<ResponseTemplate> templates) {
    if (templates.length == 1) {
      return templates.first;
    }

    // Calculate total weight
    final totalWeight = templates.fold<int>(
      0,
      (sum, template) => sum + template.weight,
    );

    // Generate random number in range [0, totalWeight)
    final randomValue = _random.nextInt(totalWeight);

    // Find the template corresponding to the random value
    int currentWeight = 0;
    for (final template in templates) {
      currentWeight += template.weight;
      if (randomValue < currentWeight) {
        return template;
      }
    }

    // Fallback to last template (should not happen)
    return templates.last;
  }

  /// Substitute variables in template string
  String _substituteVariables(String template, Map<String, dynamic> variables) {
    String result = template;

    // Process variables in the format {{variableName}}
    final variablePattern = RegExp(r'\{\{(\w+)\}\}');

    result = result.replaceAllMapped(variablePattern, (match) {
      final variableName = match.group(1)!;
      final value = variables[variableName];

      if (value == null) {
        // Keep the placeholder if variable is not provided
        return match.group(0)!;
      }

      return _formatValue(value);
    });

    // Process conditional blocks in the format {{#if variableName}}content{{/if}}
    final conditionalPattern = RegExp(
      r'\{\{#if\s+(\w+)\}\}(.*?)\{\{/if\}\}',
      dotAll: true,
    );

    result = result.replaceAllMapped(conditionalPattern, (match) {
      final variableName = match.group(1)!;
      final content = match.group(2)!;
      final value = variables[variableName];

      // Include content if variable exists and is truthy
      if (value != null && _isTruthy(value)) {
        return content;
      }

      return '';
    });

    // Process negative conditional blocks {{#unless variableName}}content{{/unless}}
    final unlessPattern = RegExp(
      r'\{\{#unless\s+(\w+)\}\}(.*?)\{\{/unless\}\}',
      dotAll: true,
    );

    result = result.replaceAllMapped(unlessPattern, (match) {
      final variableName = match.group(1)!;
      final content = match.group(2)!;
      final value = variables[variableName];

      // Include content if variable doesn't exist or is falsy
      if (value == null || !_isTruthy(value)) {
        return content;
      }

      return '';
    });

    return result.trim();
  }

  /// Format a value for template substitution
  String _formatValue(dynamic value) {
    if (value is DateTime) {
      return _formatDateTime(value);
    } else if (value is Duration) {
      return _formatDuration(value);
    } else if (value is num) {
      return _formatNumber(value);
    } else {
      return value.toString();
    }
  }

  /// Format DateTime for template display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format Duration for template display
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
    }
  }

  /// Format numbers for template display
  String _formatNumber(num number) {
    if (number is int) {
      return number.toString();
    } else {
      // Round doubles to 1 decimal place if needed
      return number == number.roundToDouble()
          ? number.round().toString()
          : number.toStringAsFixed(1);
    }
  }

  /// Check if a value is considered truthy
  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    if (value is num) return value != 0;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}
