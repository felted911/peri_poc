import '../models/template_models.dart';
import '../core/utils/result.dart';

/// Interface for template-based response generation service
///
/// This service provides template-based responses for voice interactions,
/// allowing for dynamic content generation based on user context and data.
abstract class ITemplateService {
  /// Initialize the template service with template data
  Future<Result<void>> initialize();

  /// Get a response template based on the given context
  ///
  /// [context] - The template context containing response type and variables
  /// Returns a [Result] containing either the generated response or an error
  Future<Result<String>> getResponse(TemplateContext context);

  /// Get a random response for the given response type
  ///
  /// [responseType] - The type of response needed
  /// [variables] - Optional variables for template substitution
  /// Returns a [Result] containing either the generated response or an error
  Future<Result<String>> getRandomResponse(
    ResponseType responseType, {
    Map<String, dynamic>? variables,
  });

  /// Check if a template exists for the given response type
  ///
  /// [responseType] - The response type to check
  /// Returns true if templates exist for this type
  bool hasTemplatesFor(ResponseType responseType);

  /// Get all available response types
  ///
  /// Returns a list of all response types that have templates
  List<ResponseType> getAvailableResponseTypes();

  /// Validate template variables against the context
  ///
  /// [context] - The template context to validate
  /// Returns a [Result] indicating validation success or failure
  Result<void> validateContext(TemplateContext context);

  /// Get metadata about available templates
  ///
  /// Returns template metadata for debugging and monitoring
  Map<String, dynamic> getTemplateMetadata();
}
