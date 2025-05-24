import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/models/template_models.dart';

void main() {
  group('ResponseType', () {
    test('should have all expected response types', () {
      // Verify that all expected response types exist
      expect(ResponseType.values, contains(ResponseType.confirmationPositive));
      expect(ResponseType.values, contains(ResponseType.habitCompleted));
      expect(ResponseType.values, contains(ResponseType.greeting));
      expect(ResponseType.values, contains(ResponseType.errorGeneric));
      expect(ResponseType.values, contains(ResponseType.systemReady));
      expect(ResponseType.values, contains(ResponseType.firstTimeUser));
    });

    test('should convert to string properly', () {
      expect(
        ResponseType.habitCompleted.toString(),
        equals('ResponseType.habitCompleted'),
      );
      expect(ResponseType.greeting.toString(), equals('ResponseType.greeting'));
    });
  });

  group('TemplateContext', () {
    late DateTime testTimestamp;

    setUp(() {
      testTimestamp = DateTime.parse('2024-01-15T10:30:00Z');
    });

    test('should create instance with required parameters', () {
      // Arrange & Act
      final context = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise'},
        timestamp: testTimestamp,
      );

      // Assert
      expect(context.responseType, equals(ResponseType.habitCompleted));
      expect(context.variables, equals({'habitName': 'Exercise'}));
      expect(context.timestamp, equals(testTimestamp));
      expect(context.userId, isNull);
      expect(context.metadata, isNull);
    });

    test('should create instance with all parameters', () {
      // Arrange & Act
      final context = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise', 'streakCount': 5},
        timestamp: testTimestamp,
        userId: 'user123',
        metadata: {'source': 'voice'},
      );

      // Assert
      expect(context.responseType, equals(ResponseType.habitCompleted));
      expect(context.variables['habitName'], equals('Exercise'));
      expect(context.variables['streakCount'], equals(5));
      expect(context.userId, equals('user123'));
      expect(context.metadata?['source'], equals('voice'));
    });

    test('should create instance using factory constructor', () {
      // Arrange & Act
      final context = TemplateContext.now(
        responseType: ResponseType.greeting,
        variables: {'userName': 'John'},
        userId: 'user456',
      );

      // Assert
      expect(context.responseType, equals(ResponseType.greeting));
      expect(context.variables['userName'], equals('John'));
      expect(context.userId, equals('user456'));
      expect(context.timestamp, isNotNull);
      // Timestamp should be recent (within last minute)
      expect(
        DateTime.now().difference(context.timestamp).inMinutes,
        lessThan(1),
      );
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalContext = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise'},
        timestamp: testTimestamp,
        userId: 'user123',
      );

      // Act
      final copiedContext = originalContext.copyWith(
        variables: {'habitName': 'Reading'},
        userId: 'user456',
      );

      // Assert
      expect(copiedContext.responseType, equals(ResponseType.habitCompleted));
      expect(copiedContext.variables['habitName'], equals('Reading'));
      expect(copiedContext.timestamp, equals(testTimestamp));
      expect(copiedContext.userId, equals('user456'));

      // Original should be unchanged
      expect(originalContext.variables['habitName'], equals('Exercise'));
      expect(originalContext.userId, equals('user123'));
    });

    test('should add variables to context', () {
      // Arrange
      final context = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise'},
      );

      // Act
      final updatedContext = context.withVariables({
        'streakCount': 7,
        'completionTime': '10:30 AM',
      });

      // Assert
      expect(updatedContext.variables['habitName'], equals('Exercise'));
      expect(updatedContext.variables['streakCount'], equals(7));
      expect(updatedContext.variables['completionTime'], equals('10:30 AM'));
      expect(updatedContext.variables.length, equals(3));

      // Original should be unchanged
      expect(context.variables.length, equals(1));
    });

    test('should override existing variables when adding', () {
      // Arrange
      final context = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise', 'streakCount': 5},
      );

      // Act
      final updatedContext = context.withVariables({
        'streakCount': 10, // Override existing
        'newField': 'newValue',
      });

      // Assert
      expect(updatedContext.variables['habitName'], equals('Exercise'));
      expect(updatedContext.variables['streakCount'], equals(10));
      expect(updatedContext.variables['newField'], equals('newValue'));
    });

    test('should serialize to and from JSON', () {
      // Arrange
      final originalContext = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise', 'streakCount': 5},
        timestamp: testTimestamp,
        userId: 'user123',
        metadata: {'source': 'voice', 'confidence': 0.95},
      );

      // Act
      final json = originalContext.toJson();
      final reconstructedContext = TemplateContext.fromJson(json);

      // Assert
      expect(
        reconstructedContext.responseType,
        equals(originalContext.responseType),
      );
      expect(reconstructedContext.variables, equals(originalContext.variables));
      expect(reconstructedContext.timestamp, equals(originalContext.timestamp));
      expect(reconstructedContext.userId, equals(originalContext.userId));
      expect(reconstructedContext.metadata, equals(originalContext.metadata));
    });

    test('should handle null values in JSON serialization', () {
      // Arrange
      final context = TemplateContext(
        responseType: ResponseType.greeting,
        variables: {},
        timestamp: testTimestamp,
      );

      // Act
      final json = context.toJson();
      final reconstructed = TemplateContext.fromJson(json);

      // Assert
      expect(reconstructed.responseType, equals(ResponseType.greeting));
      expect(reconstructed.variables, isEmpty);
      expect(reconstructed.userId, isNull);
      expect(reconstructed.metadata, isNull);
    });

    test('should implement equality correctly', () {
      // Arrange
      final context1 = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise'},
        timestamp: testTimestamp,
        userId: 'user123',
      );

      final context2 = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise'},
        timestamp: testTimestamp,
        userId: 'user123',
      );

      final context3 = TemplateContext(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Reading'},
        timestamp: testTimestamp,
        userId: 'user123',
      );

      // Act & Assert
      expect(context1, equals(context2));
      expect(context1.hashCode, equals(context2.hashCode));
      expect(context1, isNot(equals(context3)));
    });
  });

  group('ResponseTemplate', () {
    test('should create instance with required parameters', () {
      // Arrange & Act
      final template = ResponseTemplate(
        id: 'test_1',
        responseType: ResponseType.habitCompleted,
        template: 'Great job on {{habitName}}!',
        requiredVariables: ['habitName'],
      );

      // Assert
      expect(template.id, equals('test_1'));
      expect(template.responseType, equals(ResponseType.habitCompleted));
      expect(template.template, equals('Great job on {{habitName}}!'));
      expect(template.requiredVariables, equals(['habitName']));
      expect(template.optionalVariables, isEmpty);
      expect(template.weight, equals(1));
      expect(template.metadata, isNull);
      expect(template.tags, isNull);
    });

    test('should create instance with all parameters', () {
      // Arrange & Act
      final template = ResponseTemplate(
        id: 'test_2',
        responseType: ResponseType.habitCompleted,
        template: 'Awesome {{habitName}}! {{streakCount}} days!',
        requiredVariables: ['habitName'],
        optionalVariables: ['streakCount'],
        weight: 3,
        metadata: {'category': 'celebration'},
        tags: ['motivational', 'streak'],
      );

      // Assert
      expect(template.optionalVariables, equals(['streakCount']));
      expect(template.weight, equals(3));
      expect(template.metadata?['category'], equals('celebration'));
      expect(template.tags, equals(['motivational', 'streak']));
    });

    test('should check if template can be used with context', () {
      // Arrange
      final template = ResponseTemplate(
        id: 'test_3',
        responseType: ResponseType.habitCompleted,
        template:
            'Great {{habitName}}! {{#if streakCount}}{{streakCount}} days!{{/if}}',
        requiredVariables: ['habitName'],
        optionalVariables: ['streakCount'],
      );

      final validContext = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {'habitName': 'Exercise', 'streakCount': 5},
      );

      final invalidContext = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {'streakCount': 5}, // Missing required habitName
      );

      final partialContext = TemplateContext.now(
        responseType: ResponseType.habitCompleted,
        variables: {
          'habitName': 'Exercise',
        }, // Missing optional streakCount is OK
      );

      // Act & Assert
      expect(template.canBeUsedWith(validContext), isTrue);
      expect(template.canBeUsedWith(invalidContext), isFalse);
      expect(template.canBeUsedWith(partialContext), isTrue);
    });

    test('should return all variables (required + optional)', () {
      // Arrange
      final template = ResponseTemplate(
        id: 'test_4',
        responseType: ResponseType.habitCompleted,
        template: 'Template text',
        requiredVariables: ['habitName', 'date'],
        optionalVariables: ['streakCount', 'mood'],
      );

      // Act
      final allVariables = template.allVariables;

      // Assert
      expect(allVariables, hasLength(4));
      expect(
        allVariables,
        containsAll(['habitName', 'date', 'streakCount', 'mood']),
      );
    });

    test('should serialize to and from JSON', () {
      // Arrange
      final originalTemplate = ResponseTemplate(
        id: 'test_5',
        responseType: ResponseType.habitCompleted,
        template: 'Great {{habitName}}!',
        requiredVariables: ['habitName'],
        optionalVariables: ['streakCount'],
        weight: 2,
        metadata: {'category': 'positive'},
        tags: ['celebration'],
      );

      // Act
      final json = originalTemplate.toJson();
      final reconstructed = ResponseTemplate.fromJson(json);

      // Assert
      expect(reconstructed.id, equals(originalTemplate.id));
      expect(reconstructed.responseType, equals(originalTemplate.responseType));
      expect(reconstructed.template, equals(originalTemplate.template));
      expect(
        reconstructed.requiredVariables,
        equals(originalTemplate.requiredVariables),
      );
      expect(
        reconstructed.optionalVariables,
        equals(originalTemplate.optionalVariables),
      );
      expect(reconstructed.weight, equals(originalTemplate.weight));
      expect(reconstructed.metadata, equals(originalTemplate.metadata));
      expect(reconstructed.tags, equals(originalTemplate.tags));
    });

    test('should implement equality correctly', () {
      // Arrange
      final template1 = ResponseTemplate(
        id: 'test_6',
        responseType: ResponseType.greeting,
        template: 'Hello!',
        requiredVariables: [],
      );

      final template2 = ResponseTemplate(
        id: 'test_6',
        responseType: ResponseType.greeting,
        template: 'Hello!',
        requiredVariables: [],
      );

      final template3 = ResponseTemplate(
        id: 'test_7',
        responseType: ResponseType.greeting,
        template: 'Hello!',
        requiredVariables: [],
      );

      // Act & Assert
      expect(template1, equals(template2));
      expect(template1.hashCode, equals(template2.hashCode));
      expect(template1, isNot(equals(template3)));
    });
  });

  group('TemplateCollection', () {
    test('should create collection with templates', () {
      // Arrange
      final templates = {
        ResponseType.greeting: [
          ResponseTemplate(
            id: 'greeting_1',
            responseType: ResponseType.greeting,
            template: 'Hello!',
            requiredVariables: [],
          ),
        ],
        ResponseType.goodbye: [
          ResponseTemplate(
            id: 'goodbye_1',
            responseType: ResponseType.goodbye,
            template: 'Goodbye!',
            requiredVariables: [],
          ),
        ],
      };

      // Act
      final collection = TemplateCollection(
        name: 'Test Collection',
        description: 'Collection for testing',
        templates: templates,
      );

      // Assert
      expect(collection.name, equals('Test Collection'));
      expect(collection.description, equals('Collection for testing'));
      expect(collection.templates, equals(templates));
    });

    test('should get templates for specific response type', () {
      // Arrange
      final greetingTemplates = [
        ResponseTemplate(
          id: 'greeting_1',
          responseType: ResponseType.greeting,
          template: 'Hello!',
          requiredVariables: [],
        ),
        ResponseTemplate(
          id: 'greeting_2',
          responseType: ResponseType.greeting,
          template: 'Hi there!',
          requiredVariables: [],
        ),
      ];

      final collection = TemplateCollection(
        name: 'Test',
        description: 'Test',
        templates: {ResponseType.greeting: greetingTemplates},
      );

      // Act
      final result = collection.getTemplatesFor(ResponseType.greeting);
      final emptyResult = collection.getTemplatesFor(ResponseType.goodbye);

      // Assert
      expect(result, equals(greetingTemplates));
      expect(result, hasLength(2));
      expect(emptyResult, isEmpty);
    });

    test('should get available response types', () {
      // Arrange
      final collection = TemplateCollection(
        name: 'Test',
        description: 'Test',
        templates: {
          ResponseType.greeting: [
            ResponseTemplate(
              id: 'test',
              responseType: ResponseType.greeting,
              template: 'Hello',
              requiredVariables: [],
            ),
          ],
          ResponseType.goodbye: [
            ResponseTemplate(
              id: 'test2',
              responseType: ResponseType.goodbye,
              template: 'Bye',
              requiredVariables: [],
            ),
          ],
        },
      );

      // Act
      final availableTypes = collection.availableResponseTypes;

      // Assert
      expect(availableTypes, hasLength(2));
      expect(
        availableTypes,
        containsAll([ResponseType.greeting, ResponseType.goodbye]),
      );
    });

    test('should calculate total template count', () {
      // Arrange
      final collection = TemplateCollection(
        name: 'Test',
        description: 'Test',
        templates: {
          ResponseType.greeting: [
            ResponseTemplate(
              id: '1',
              responseType: ResponseType.greeting,
              template: 'Hi',
              requiredVariables: [],
            ),
            ResponseTemplate(
              id: '2',
              responseType: ResponseType.greeting,
              template: 'Hello',
              requiredVariables: [],
            ),
          ],
          ResponseType.goodbye: [
            ResponseTemplate(
              id: '3',
              responseType: ResponseType.goodbye,
              template: 'Bye',
              requiredVariables: [],
            ),
          ],
        },
      );

      // Act
      final totalCount = collection.totalTemplateCount;

      // Assert
      expect(totalCount, equals(3));
    });

    test('should check if has templates for response type', () {
      // Arrange
      final collection = TemplateCollection(
        name: 'Test',
        description: 'Test',
        templates: {
          ResponseType.greeting: [
            ResponseTemplate(
              id: '1',
              responseType: ResponseType.greeting,
              template: 'Hi',
              requiredVariables: [],
            ),
          ],
        },
      );

      // Act & Assert
      expect(collection.hasTemplatesFor(ResponseType.greeting), isTrue);
      expect(collection.hasTemplatesFor(ResponseType.goodbye), isFalse);
    });
  });

  group('TemplateVariable', () {
    test('should create template variable with all properties', () {
      // Arrange & Act
      final variable = TemplateVariable(
        name: 'habitName',
        description: 'Name of the habit',
        expectedType: String,
        isRequired: true,
        defaultValue: 'Unknown Habit',
        validationPattern: r'^[a-zA-Z\s]+$',
        allowedValues: ['Exercise', 'Reading', 'Meditation'],
      );

      // Assert
      expect(variable.name, equals('habitName'));
      expect(variable.description, equals('Name of the habit'));
      expect(variable.expectedType, equals(String));
      expect(variable.isRequired, isTrue);
      expect(variable.defaultValue, equals('Unknown Habit'));
      expect(variable.validationPattern, equals(r'^[a-zA-Z\s]+$'));
      expect(
        variable.allowedValues,
        equals(['Exercise', 'Reading', 'Meditation']),
      );
    });

    test('should validate string values correctly', () {
      // Arrange
      final variable = TemplateVariable(
        name: 'habitName',
        description: 'Name of the habit',
        expectedType: String,
        isRequired: true,
        validationPattern: r'^[a-zA-Z\s]+$',
        allowedValues: ['Exercise', 'Reading'],
      );

      // Act & Assert
      expect(variable.isValidValue('Exercise'), isTrue);
      expect(variable.isValidValue('Reading'), isTrue);
      expect(
        variable.isValidValue('Swimming'),
        isFalse,
      ); // Not in allowed values
      expect(
        variable.isValidValue('Exercise123'),
        isFalse,
      ); // Doesn't match pattern
      expect(variable.isValidValue(null), isFalse); // Required but null
    });

    test('should validate numeric values correctly', () {
      // Arrange
      final intVariable = TemplateVariable(
        name: 'streakCount',
        description: 'Streak count',
        expectedType: int,
        isRequired: true,
      );

      final doubleVariable = TemplateVariable(
        name: 'score',
        description: 'Score value',
        expectedType: double,
        isRequired: false,
      );

      // Act & Assert
      expect(intVariable.isValidValue(5), isTrue);
      expect(intVariable.isValidValue(0), isTrue);
      expect(intVariable.isValidValue('5'), isFalse); // Wrong type

      expect(doubleVariable.isValidValue(3.14), isTrue);
      expect(
        doubleVariable.isValidValue(5),
        isTrue,
      ); // int is acceptable for double
      expect(doubleVariable.isValidValue(null), isTrue); // Not required
    });

    test('should validate boolean values correctly', () {
      // Arrange
      final variable = TemplateVariable(
        name: 'isCompleted',
        description: 'Completion status',
        expectedType: bool,
        isRequired: true,
      );

      // Act & Assert
      expect(variable.isValidValue(true), isTrue);
      expect(variable.isValidValue(false), isTrue);
      expect(variable.isValidValue('true'), isFalse); // Wrong type
      expect(variable.isValidValue(1), isFalse); // Wrong type
    });

    test('should handle optional variables with null values', () {
      // Arrange
      final optionalVariable = TemplateVariable(
        name: 'mood',
        description: 'User mood',
        expectedType: String,
        isRequired: false,
      );

      final requiredVariable = TemplateVariable(
        name: 'habitName',
        description: 'Habit name',
        expectedType: String,
        isRequired: true,
      );

      // Act & Assert
      expect(optionalVariable.isValidValue(null), isTrue);
      expect(optionalVariable.isValidValue('happy'), isTrue);
      expect(requiredVariable.isValidValue(null), isFalse);
    });
  });
}
