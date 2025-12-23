import 'dart:convert';

import 'code_generator_interface.dart';
import 'code_generators.dart';

/// Service for converting JSON to Dart Mappable classes
///
/// This class now acts as an adapter to the plugin system while maintaining
/// backward compatibility with the existing API.
class JsonToDartConverter {
  /// Converts JSON string to Dart Mappable class code
  ///
  /// This is now an adapter that uses the plugin system internally
  static ConversionResult convertJsonToDart({
    required String jsonString,
    required String className,
    required String nullabilityMode,
    bool alwaysIncludeMappableField = false,
    bool useObjectInsteadOfDynamic = false,
    bool includeDefaultMethods = false,
    bool useRequiredConstructor = false,
    bool includeEqualityMethods = false,
    Map<String, String>? classRenames,
    bool useDartMappable = true,
  }) {
    if (jsonString.trim().isEmpty) {
      return ConversionResult.success('', '');
    }

    try {
      final jsonData = jsonDecode(jsonString);

      // Use the plugin system
      final generator = useDartMappable ? _getDartMappableGenerator() : _getPlainDartGenerator();

      final options = _createOptions(
        nullabilityMode: nullabilityMode,
        alwaysIncludeMappableField: alwaysIncludeMappableField,
        useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
        includeDefaultMethods: includeDefaultMethods,
        useRequiredConstructor: useRequiredConstructor,
        includeEqualityMethods: includeEqualityMethods,
        classRenames: classRenames,
      );

      final code = generator.generate(
        json: jsonData,
        className: className,
        options: options,
      );

      return ConversionResult.success(code, '');
    } catch (e) {
      return ConversionResult.error('', 'Invalid JSON: ${e.toString()}');
    }
  }

  static CodeGenerator _getDartMappableGenerator() {
    CodeGeneratorRegistry.initializeDefaults();
    return CodeGeneratorRegistry.get('dart_mappable')!;
  }

  static CodeGenerator _getPlainDartGenerator() {
    CodeGeneratorRegistry.initializeDefaults();
    return CodeGeneratorRegistry.get('plain_dart')!;
  }

  static CodeGeneratorOptions _createOptions({
    required String nullabilityMode,
    required bool alwaysIncludeMappableField,
    required bool useObjectInsteadOfDynamic,
    required bool includeDefaultMethods,
    required bool useRequiredConstructor,
    required bool includeEqualityMethods,
    Map<String, String>? classRenames,
  }) {
    return CodeGeneratorOptions(
      nullabilityMode: nullabilityMode,
      alwaysIncludeFieldAnnotations: alwaysIncludeMappableField,
      useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
      includeHelperMethods: includeDefaultMethods,
      useRequiredConstructor: useRequiredConstructor,
      includeEqualityMethods: includeEqualityMethods,
      classRenames: classRenames ?? {},
    );
  }
}

/// Result of a JSON to Dart conversion
class ConversionResult {
  final String code;
  final String error;

  const ConversionResult._(this.code, this.error);

  factory ConversionResult.success(String code, String error) => ConversionResult._(code, error);

  factory ConversionResult.error(String code, String error) => ConversionResult._(code, error);

  bool get isSuccess => error.isEmpty;
}
