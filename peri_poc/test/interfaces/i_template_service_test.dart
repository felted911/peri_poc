import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/interfaces/i_template_service.dart';
import 'package:peri_poc/models/template_models.dart';
import 'package:peri_poc/services/template_service_impl.dart';

void main() {
  group('ITemplateService Contract', () {
    late ITemplateService templateService;

    setUp(() {
      templateService = TemplateServiceImpl();
    });

    group('initialize', () {
      test('should return success when initialization succeeds', () async {
        // Act
        final result = await templateService.initialize();

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should be able to initialize multiple times', () async {
        // Act
        final result1 = await templateService.initialize();
        final result2 = await templateService.initialize();

        // Assert
        expect(result1.isSuccess, isTrue);
        expect(result2.isSuccess, isTrue);
      });
    });

    group('getResponse', () {
      setUp(() async {
        await templateService.initialize();
      });

      test('should return success with valid template context', () async {
        // Arrange
        final context = TemplateContext.now(
          responseType: ResponseType.habitCompleted,
          variables: {'habitName': 'Morning Exercise'},
        );

        // Act
        final result = await templateService.getResponse(context);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, isNotEmpty);
        expect(result.value, contains('Morning Exercise'));
      });

      test(
        'should return failure when required variables are missing',
        () async {
          // Arrange
          final context = TemplateContext.now(
            responseType: ResponseType.habitCompleted,
            variables: {}, // Missing required variables
          );

          // Act
          final result = await templateService.getResponse(context);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error, isNotEmpty);
        },
      );

      test('should handle optional variables correctly', () async {
        // Arrange
        final context = TemplateContext.now(
          responseType: ResponseType.greeting,
          variables: {'userName': 'Alice'},
        );

        // Act
        final result = await templateService.getResponse(context);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, isNotEmpty);
      });
    });

    group('getRandomResponse', () {
      setUp(() async {
        await templateService.initialize();
      });

      test(
        'should return success with valid response type and variables',
        () async {
          // Act
          final result = await templateService.getRandomResponse(
            ResponseType.habitCompleted,
            variables: {'habitName': 'Daily Reading'},
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.value, isNotEmpty);
          expect(result.value, contains('Daily Reading'));
        },
      );

      test('should return success with just response type', () async {
        // Act
        final result = await templateService.getRandomResponse(
          ResponseType.greeting,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.value, isNotEmpty);
      });

      test(
        'should return failure when required variables are missing',
        () async {
          // Act
          final result = await templateService.getRandomResponse(
            ResponseType.habitCompleted,
            variables: {}, // Missing required variables
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error, isNotEmpty);
        },
      );
    });

    group('hasTemplatesFor', () {
      test('should return false before initialization', () {
        // Act
        final result = templateService.hasTemplatesFor(ResponseType.greeting);

        // Assert
        expect(result, isFalse);
      });

      test(
        'should return true for supported response types after initialization',
        () async {
          // Arrange
          await templateService.initialize();

          // Act & Assert
          expect(
            templateService.hasTemplatesFor(ResponseType.greeting),
            isTrue,
          );
          expect(
            templateService.hasTemplatesFor(ResponseType.habitCompleted),
            isTrue,
          );
          expect(templateService.hasTemplatesFor(ResponseType.goodbye), isTrue);
        },
      );
    });

    group('getAvailableResponseTypes', () {
      test('should return empty list before initialization', () {
        // Act
        final result = templateService.getAvailableResponseTypes();

        // Assert
        expect(result, isEmpty);
      });

      test('should return non-empty list after initialization', () async {
        // Arrange
        await templateService.initialize();

        // Act
        final result = templateService.getAvailableResponseTypes();

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains(ResponseType.greeting));
        expect(result, contains(ResponseType.habitCompleted));
      });
    });

    group('validateContext', () {
      test('should return failure before initialization', () {
        // Arrange
        final context = TemplateContext.now(
          responseType: ResponseType.greeting,
        );

        // Act
        final result = templateService.validateContext(context);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error, contains('not initialized'));
      });

      test('should validate context correctly after initialization', () async {
        // Arrange
        await templateService.initialize();
        final validContext = TemplateContext.now(
          responseType: ResponseType.habitCompleted,
          variables: {'habitName': 'Exercise'},
        );
        final invalidContext = TemplateContext.now(
          responseType: ResponseType.habitCompleted,
          variables: {}, // Missing required variables
        );

        // Act
        final validResult = templateService.validateContext(validContext);
        final invalidResult = templateService.validateContext(invalidContext);

        // Assert
        expect(validResult.isSuccess, isTrue);
        expect(invalidResult.isFailure, isTrue);
      });
    });

    group('getTemplateMetadata', () {
      test('should indicate not initialized when not initialized', () {
        // Act
        final metadata = templateService.getTemplateMetadata();

        // Assert
        expect(metadata['initialized'], isFalse);
      });

      test('should provide comprehensive metadata when initialized', () async {
        // Arrange
        await templateService.initialize();

        // Act
        final metadata = templateService.getTemplateMetadata();

        // Assert
        expect(metadata['initialized'], isTrue);
        expect(metadata['collectionName'], isNotNull);
        expect(metadata['totalTemplates'], isA<int>());
        expect(metadata['totalTemplates'], greaterThan(0));
        expect(metadata['responseTypes'], isA<List>());
        expect(metadata['templatesByType'], isA<Map>());
      });
    });

    group('interface consistency', () {
      test('should maintain consistent state across method calls', () async {
        // Arrange
        await templateService.initialize();

        // Act
        final hasTemplates1 = templateService.hasTemplatesFor(
          ResponseType.greeting,
        );
        final availableTypes1 = templateService.getAvailableResponseTypes();
        final metadata1 = templateService.getTemplateMetadata();

        // Wait a bit and call again
        await Future.delayed(Duration(milliseconds: 10));

        final hasTemplates2 = templateService.hasTemplatesFor(
          ResponseType.greeting,
        );
        final availableTypes2 = templateService.getAvailableResponseTypes();
        final metadata2 = templateService.getTemplateMetadata();

        // Assert
        expect(hasTemplates1, equals(hasTemplates2));
        expect(availableTypes1.length, equals(availableTypes2.length));
        expect(
          metadata1['totalTemplates'],
          equals(metadata2['totalTemplates']),
        );
      });

      test('should handle rapid sequential calls correctly', () async {
        // Arrange
        await templateService.initialize();
        final context = TemplateContext.now(
          responseType: ResponseType.greeting,
        );

        // Act - Make multiple rapid calls
        final futures = List.generate(
          5,
          (_) => templateService.getResponse(context),
        );
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result.isSuccess, isTrue);
          expect(result.value, isNotEmpty);
        }
      });
    });
  });
}
