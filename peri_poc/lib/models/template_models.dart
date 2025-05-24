/// Enum representing different types of responses the template service can generate
enum ResponseType {
  // Acknowledgment responses
  confirmationPositive,
  confirmationNegative,
  acknowledged,

  // Habit-related responses
  habitCompleted,
  habitReminder,
  habitStreak,
  habitMotivation,
  habitProgress,

  // Status responses
  streakUpdate,
  progressReport,
  dailySummary,
  weeklyReport,

  // Error and help responses
  commandNotUnderstood,
  helpGeneral,
  helpVoiceCommands,
  errorGeneric,
  errorPermission,
  errorNetwork,

  // Greeting and conversation
  greeting,
  goodbye,
  conversationStarter,
  encouragement,

  // System responses
  systemReady,
  systemBusy,
  systemError,
  permissionRequest,

  // Context-specific responses
  firstTimeUser,
  returningUser,
  achievementUnlocked,
  milestone,
}

/// Template context containing all information needed for response generation
class TemplateContext {
  final ResponseType responseType;
  final Map<String, dynamic> variables;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  const TemplateContext({
    required this.responseType,
    required this.variables,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  /// Factory constructor for creating context with current timestamp
  factory TemplateContext.now({
    required ResponseType responseType,
    Map<String, dynamic>? variables,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return TemplateContext(
      responseType: responseType,
      variables: variables ?? {},
      timestamp: DateTime.now(),
      userId: userId,
      metadata: metadata,
    );
  }

  /// Create a copy of this context with updated variables
  TemplateContext copyWith({
    ResponseType? responseType,
    Map<String, dynamic>? variables,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return TemplateContext(
      responseType: responseType ?? this.responseType,
      variables: variables ?? this.variables,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Add variables to the current context
  TemplateContext withVariables(Map<String, dynamic> additionalVariables) {
    final mergedVariables = Map<String, dynamic>.from(variables)
      ..addAll(additionalVariables);
    return copyWith(variables: mergedVariables);
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'responseType': responseType.toString(),
      'variables': variables,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
  }

  /// Create from JSON representation
  factory TemplateContext.fromJson(Map<String, dynamic> json) {
    return TemplateContext(
      responseType: ResponseType.values.firstWhere(
        (e) => e.toString() == json['responseType'],
      ),
      variables: Map<String, dynamic>.from(json['variables'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'])
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateContext &&
        other.responseType == responseType &&
        _mapEquals(other.variables, variables) &&
        other.timestamp == timestamp &&
        other.userId == userId &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    final varHash = variables.entries.fold(0, (int hash, entry) => 
      hash ^ entry.key.hashCode ^ (entry.value?.hashCode ?? 0));
    final metaHash = metadata?.entries.fold(0, (int hash, entry) => 
      hash ^ entry.key.hashCode ^ (entry.value?.hashCode ?? 0)) ?? 0;
    
    return responseType.hashCode ^ 
           varHash ^ 
           timestamp.hashCode ^ 
           (userId?.hashCode ?? 0) ^ 
           metaHash;
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Template data structure containing template content and metadata
class ResponseTemplate {
  final String id;
  final ResponseType responseType;
  final String template;
  final List<String> requiredVariables;
  final List<String> optionalVariables;
  final Map<String, dynamic>? metadata;
  final int weight; // For weighted random selection
  final List<String>? tags; // For categorization and filtering

  const ResponseTemplate({
    required this.id,
    required this.responseType,
    required this.template,
    required this.requiredVariables,
    this.optionalVariables = const [],
    this.metadata,
    this.weight = 1,
    this.tags,
  });

  /// Check if this template has all required variables in the given context
  bool canBeUsedWith(TemplateContext context) {
    return requiredVariables.every(
      (variable) => context.variables.containsKey(variable),
    );
  }

  /// Get all variables (required + optional) referenced in this template
  List<String> get allVariables => [...requiredVariables, ...optionalVariables];

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'responseType': responseType.toString(),
      'template': template,
      'requiredVariables': requiredVariables,
      'optionalVariables': optionalVariables,
      'metadata': metadata,
      'weight': weight,
      'tags': tags,
    };
  }

  /// Create from JSON representation
  factory ResponseTemplate.fromJson(Map<String, dynamic> json) {
    return ResponseTemplate(
      id: json['id'],
      responseType: ResponseType.values.firstWhere(
        (e) => e.toString() == json['responseType'],
      ),
      template: json['template'],
      requiredVariables: List<String>.from(json['requiredVariables'] ?? []),
      optionalVariables: List<String>.from(json['optionalVariables'] ?? []),
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'])
              : null,
      weight: json['weight'] ?? 1,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResponseTemplate &&
        other.id == id &&
        other.responseType == responseType &&
        other.template == template &&
        _listEquals(other.requiredVariables, requiredVariables) &&
        _listEquals(other.optionalVariables, optionalVariables) &&
        _mapEquals(other.metadata, metadata) &&
        other.weight == weight &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    final reqVarHash = requiredVariables.fold(0, (int hash, String item) => hash ^ item.hashCode);
    final optVarHash = optionalVariables.fold(0, (int hash, String item) => hash ^ item.hashCode);
    final metaHash = metadata?.entries.fold(0, (int hash, entry) => 
      hash ^ entry.key.hashCode ^ (entry.value?.hashCode ?? 0)) ?? 0;
    final tagsHash = tags?.fold(0, (int hash, String tag) => hash ^ tag.hashCode) ?? 0;
    
    return id.hashCode ^ 
           responseType.hashCode ^ 
           template.hashCode ^ 
           reqVarHash ^ 
           optVarHash ^
           weight.hashCode ^ 
           metaHash ^ 
           tagsHash;
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Template collection for organizing related templates
class TemplateCollection {
  final String name;
  final String description;
  final Map<ResponseType, List<ResponseTemplate>> templates;
  final Map<String, dynamic>? metadata;

  const TemplateCollection({
    required this.name,
    required this.description,
    required this.templates,
    this.metadata,
  });

  /// Get all templates for a specific response type
  List<ResponseTemplate> getTemplatesFor(ResponseType responseType) {
    return templates[responseType] ?? [];
  }

  /// Get all available response types in this collection
  List<ResponseType> get availableResponseTypes => templates.keys.toList();

  /// Get total number of templates in this collection
  int get totalTemplateCount =>
      templates.values.fold(0, (sum, list) => sum + list.length);

  /// Check if collection has templates for the given response type
  bool hasTemplatesFor(ResponseType responseType) {
    return templates.containsKey(responseType) &&
        templates[responseType]!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateCollection &&
        other.name == name &&
        other.description == description &&
        _mapEquals(other.templates, templates) &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(name, description, templates, metadata);
  }

  bool _mapEquals(Map? a, Map? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Template variable definition for documentation and validation
class TemplateVariable {
  final String name;
  final String description;
  final Type expectedType;
  final bool isRequired;
  final dynamic defaultValue;
  final String? validationPattern;
  final List<String>? allowedValues;

  const TemplateVariable({
    required this.name,
    required this.description,
    required this.expectedType,
    required this.isRequired,
    this.defaultValue,
    this.validationPattern,
    this.allowedValues,
  });

  /// Validate a value against this variable definition
  bool isValidValue(dynamic value) {
    if (value == null && isRequired) return false;
    if (value == null && !isRequired) return true;

    // Type check
    if (!_isOfExpectedType(value)) return false;

    // Pattern validation for strings
    if (validationPattern != null && value is String) {
      final regex = RegExp(validationPattern!);
      if (!regex.hasMatch(value)) return false;
    }

    // Allowed values check
    if (allowedValues != null && !allowedValues!.contains(value.toString())) {
      return false;
    }

    return true;
  }

  bool _isOfExpectedType(dynamic value) {
    if (expectedType == String) {
      return value is String;
    } else if (expectedType == int) {
      return value is int;
    } else if (expectedType == double) {
      return value is double || value is int;
    } else if (expectedType == bool) {
      return value is bool;
    } else if (expectedType == DateTime) {
      return value is DateTime || value is String;
    } else {
      return true; // Allow any type for unknown types
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateVariable &&
        other.name == name &&
        other.description == description &&
        other.expectedType == expectedType &&
        other.isRequired == isRequired &&
        other.defaultValue == defaultValue &&
        other.validationPattern == validationPattern &&
        _listEquals(other.allowedValues, allowedValues);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      description,
      expectedType,
      isRequired,
      defaultValue,
      validationPattern,
      allowedValues,
    );
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
