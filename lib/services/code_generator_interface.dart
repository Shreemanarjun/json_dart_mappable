/// Interface for custom code generators
///
/// This allows creating plugins that can generate different output formats
/// from the same JSON input (e.g., freezed, json_serializable, custom formats)
abstract class CodeGenerator {
  /// Generate code from parsed JSON data
  ///
  /// [json] - The parsed JSON data (Map, List, or primitive)
  /// [className] - The root class name to generate
  /// [options] - Configuration options for code generation
  ///
  /// Returns the generated code as a string
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  });

  /// Validate if this generator can handle the given JSON structure
  bool canHandle(dynamic json);

  /// Get the file extension for generated files (e.g., '.dart', '.g.dart')
  String get fileExtension;

  /// Get the generator name/identifier
  String get name;
}

/// Fallback type for unknown or mixed types
enum FallbackType {
  /// Use 'dynamic' (default)
  dynamic,

  /// Use 'Object'
  object,

  /// Use 'Object?'
  objectNullable,
}

/// Configuration options for code generation
class CodeGeneratorOptions {
  /// Nullability mode: 'none', 'all', or 'smart'
  final String nullabilityMode;

  /// Nullability analysis results (for smart mode)
  final Map<String, bool>? nullabilityAnalysis;

  /// Always include field annotations
  final bool alwaysIncludeFieldAnnotations;

  /// Deprecated: Use [fallbackType] instead
  /// Use Object instead of dynamic for unknown types
  final bool useObjectInsteadOfDynamic;

  /// Type to use when the actual type cannot be determined or is mixed
  final FallbackType fallbackType;

  /// Include helper methods (fromMap, fromJson, etc.)
  final bool includeHelperMethods;

  /// Use required constructor parameters
  final bool useRequiredConstructor;

  /// Include equality and hashCode methods (for plain Dart)
  final bool includeEqualityMethods;

  /// Map of class renames (original name -> new name)
  final Map<String, String> classRenames;

  /// Additional custom options for specific generators
  final Map<String, dynamic> customOptions;

  const CodeGeneratorOptions({
    this.nullabilityMode = 'smart',
    this.nullabilityAnalysis,
    this.alwaysIncludeFieldAnnotations = false,
    this.useObjectInsteadOfDynamic = false,
    this.fallbackType = FallbackType.dynamic,
    this.includeHelperMethods = false,
    this.useRequiredConstructor = false,
    this.includeEqualityMethods = false,
    this.classRenames = const {},
    this.customOptions = const {},
  });

  /// Create a copy with modified fields
  CodeGeneratorOptions copyWith({
    String? nullabilityMode,
    Map<String, bool>? nullabilityAnalysis,
    bool? alwaysIncludeFieldAnnotations,
    bool? useObjectInsteadOfDynamic,
    FallbackType? fallbackType,
    bool? includeHelperMethods,
    bool? useRequiredConstructor,
    Map<String, String>? classRenames,
    Map<String, dynamic>? customOptions,
  }) {
    return CodeGeneratorOptions(
      nullabilityMode: nullabilityMode ?? this.nullabilityMode,
      nullabilityAnalysis: nullabilityAnalysis ?? this.nullabilityAnalysis,
      alwaysIncludeFieldAnnotations: alwaysIncludeFieldAnnotations ?? this.alwaysIncludeFieldAnnotations,
      useObjectInsteadOfDynamic: useObjectInsteadOfDynamic ?? this.useObjectInsteadOfDynamic,
      fallbackType: fallbackType ?? this.fallbackType,
      includeHelperMethods: includeHelperMethods ?? this.includeHelperMethods,
      useRequiredConstructor: useRequiredConstructor ?? this.useRequiredConstructor,
      classRenames: classRenames ?? this.classRenames,
      customOptions: customOptions ?? this.customOptions,
    );
  }
}

/// Result of code generation
class GenerationResult {
  /// The generated code
  final String code;

  /// Any error message (empty if successful)
  final String error;

  /// Additional files that should be generated (e.g., .g.dart files)
  final Map<String, String> additionalFiles;

  const GenerationResult({
    required this.code,
    this.error = '',
    this.additionalFiles = const {},
  });

  factory GenerationResult.success(String code, {Map<String, String>? additionalFiles}) {
    return GenerationResult(
      code: code,
      additionalFiles: additionalFiles ?? {},
    );
  }

  factory GenerationResult.error(String error) {
    return GenerationResult(
      code: '',
      error: error,
    );
  }

  bool get isSuccess => error.isEmpty;
}
