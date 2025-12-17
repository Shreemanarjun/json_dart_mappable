import 'dart:convert';

/// Service for converting JSON to Dart Mappable classes
class JsonToDartConverter {
  static const _reservedKeywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'native',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'patch',
    'priority',
    'private',
    'protected',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Converts JSON string to Dart Mappable class code
  static ConversionResult convertJsonToDart(
    String jsonString,
    String className,
    String nullabilityMode, {
    bool alwaysIncludeMappableField = false,
    bool useObjectInsteadOfDynamic = false,
    bool includeDefaultMethods = false,
    bool useRequiredConstructor = false,
  }) {
    if (jsonString.trim().isEmpty) {
      return ConversionResult.success('', '');
    }

    try {
      final jsonData = jsonDecode(jsonString);

      // Analyze nullability for smart mode
      final nullabilityAnalysis = nullabilityMode == 'smart' ? _analyzeNullability(jsonData) : null;

      final dartClass = _generateDartClass(
        jsonData,
        className,
        nullabilityAnalysis,
        nullabilityMode,
        alwaysIncludeMappableField: alwaysIncludeMappableField,
        useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
        includeDefaultMethods: includeDefaultMethods,
        useRequiredConstructor: useRequiredConstructor,
      );
      return ConversionResult.success(dartClass, '');
    } catch (e) {
      return ConversionResult.error('', 'Invalid JSON: ${e.toString()}');
    }
  }

  static Map<String, bool> _analyzeNullability(dynamic json, [String path = '']) {
    final analysis = <String, bool>{};

    if (json is Map<String, dynamic>) {
      json.forEach((key, value) {
        final fieldPath = path.isEmpty ? key : '$path.$key';

        // A field should be nullable if it's null (not if it's an empty string)
        bool shouldBeNullable = value == null;

        if (value is Map<String, dynamic>) {
          analysis.addAll(_analyzeNullability(value, fieldPath));
        } else if (value is List && value.isNotEmpty) {
          // For arrays, analyze all items to see field nullability within items
          final arrayAnalysis = _analyzeArrayNullability(value, key, fieldPath);
          analysis.addAll(arrayAnalysis);

          // The array field itself is only nullable if the value is null (not if items are nullable)
          // shouldBeNullable remains false for array fields
        }

        analysis[fieldPath] = shouldBeNullable;
      });
    } else if (json is List && json.isNotEmpty) {
      // For root level arrays, analyze the structure
      if (json.first is Map<String, dynamic>) {
        analysis.addAll(_analyzeArrayNullability(json, '', path));
      }
    }

    return analysis;
  }

  static Map<String, bool> _analyzeArrayNullability(List array, String fieldName, String path) {
    final analysis = <String, bool>{};
    final allKeys = <String>{};

    // Collect all possible keys from all objects in the array
    for (final item in array) {
      if (item is Map<String, dynamic>) {
        allKeys.addAll(item.keys);
      }
    }

    // For each key, check if it's ever missing, null, or empty across all items
    for (final key in allKeys) {
      final fieldPath = path.isEmpty ? key : '$path.$key';
      bool shouldBeNullable = false;

      for (final item in array) {
        if (item is Map<String, dynamic>) {
          if (!item.containsKey(key)) {
            // Field is missing - should be nullable
            shouldBeNullable = true;
          } else {
            final value = item[key];
            if (value == null) {
              // Field is null - should be nullable
              shouldBeNullable = true;
            }
          }
        }
      }

      analysis[fieldPath] = shouldBeNullable;

      // Also analyze nested structures if they exist
      final firstNonNullValue = array.firstWhere(
        (item) => item is Map<String, dynamic> && item.containsKey(key) && item[key] != null,
        orElse: () => null,
      );

      if (firstNonNullValue is Map<String, dynamic> && firstNonNullValue[key] is Map<String, dynamic>) {
        analysis.addAll(_analyzeNullability(firstNonNullValue[key], fieldPath));
      } else if (firstNonNullValue is Map<String, dynamic> && firstNonNullValue[key] is List && (firstNonNullValue[key] as List).isNotEmpty) {
        analysis.addAll(_analyzeArrayNullability(firstNonNullValue[key] as List, key, fieldPath));
      }
    }

    return analysis;
  }

  static String _generateDartClass(
    dynamic json,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode, {
    bool alwaysIncludeMappableField = false,
    bool useObjectInsteadOfDynamic = false,
    bool includeDefaultMethods = false,
    bool useRequiredConstructor = false,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:dart_mappable/dart_mappable.dart';");
    buffer.writeln();
    buffer.writeln('part \'${className.toLowerCase()}.mapper.dart\';');
    buffer.writeln();

    if (json is Map<String, dynamic>) {
      _generateClassFromMap(buffer, json, className, nullabilityAnalysis, nullabilityMode, alwaysIncludeMappableField,
        useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
        includeDefaultMethods: includeDefaultMethods,
        useRequiredConstructor: useRequiredConstructor,
        isRootClass: true);
    } else if (json is List) {
      if (json.isNotEmpty) {
        _generateClassFromList(buffer, json, className, nullabilityAnalysis, nullabilityMode, alwaysIncludeMappableField,
          useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
          includeDefaultMethods: includeDefaultMethods,
          useRequiredConstructor: useRequiredConstructor,
          isRootClass: true);
      } else {
        buffer.writeln('@MappableClass()');
        buffer.writeln('class $className with ${className}Mappable {');
        buffer.writeln('  const $className();');
        buffer.writeln('}');
      }
    } else {
      buffer.writeln('@MappableClass()');
      buffer.writeln('class $className with ${className}Mappable {');
      buffer.writeln('  final dynamic value;');
      buffer.writeln('  const $className(this.value);');
      buffer.writeln('}');
    }

    return buffer.toString();
  }

  static void _generateClassFromMap(
    StringBuffer buffer,
    Map<String, dynamic> map,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
    bool alwaysIncludeMappableField, {
    bool useObjectInsteadOfDynamic = false,
    bool includeDefaultMethods = false,
    bool useRequiredConstructor = false,
    bool isRootClass = false,
  }) {
    // Collect all nested classes first
    final nestedClassBuffers = <StringBuffer>[];
    final nestedClasses = <String>[];
    final fieldTypeOverrides = <String, String>{}; // fieldName -> actualType

    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final nestedClassName = '${_sanitizeFieldName(key)[0].toUpperCase()}${_sanitizeFieldName(key).substring(1)}';
        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();
          _generateClassFromMap(nestedBuffer, value, nestedClassName, nullabilityAnalysis, nullabilityMode, alwaysIncludeMappableField,
            useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
            includeDefaultMethods: includeDefaultMethods,
            useRequiredConstructor: useRequiredConstructor,
            isRootClass: false);
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = nestedClassName;
      } else if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        final nestedClassName = '${_sanitizeFieldName(key)[0].toUpperCase()}${_sanitizeFieldName(key).substring(1)}Item';
        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();

          // Filter nullability analysis for this nested class
          final filteredAnalysis = <String, bool>{};
          final prefix = '$key.';
          nullabilityAnalysis?.forEach((path, isNullable) {
            if (path.startsWith(prefix)) {
              filteredAnalysis[path.substring(prefix.length)] = isNullable;
            }
          });

          // Create merged fields from all array items
          final mergedFields = <String, dynamic>{};
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              // For merged fields, we want to preserve the types but handle nulls specially
              item.forEach((key, itemValue) {
                if (!mergedFields.containsKey(key)) {
                  // First time seeing this field
                  mergedFields[key] = itemValue;
                } else if (mergedFields[key] == null && itemValue != null) {
                  // Replace null with actual value to get better type inference
                  mergedFields[key] = itemValue;
                }
                // If both are non-null or both are null, keep the existing value
              });
            }
          }

          _generateClassFromMap(nestedBuffer, mergedFields, nestedClassName, filteredAnalysis, nullabilityMode, alwaysIncludeMappableField,
            useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
            includeDefaultMethods: includeDefaultMethods,
            useRequiredConstructor: useRequiredConstructor,
            isRootClass: false);
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = 'List<$nestedClassName>';
      }
    });

    // Generate the main class first
    buffer.writeln('@MappableClass()');
    buffer.writeln('class $className with ${className}Mappable {');

    final fields = <String>[];
    final constructorParams = <String>[];

    map.forEach((key, value) {
      final fieldName = _sanitizeFieldName(key);
      final fieldType = fieldTypeOverrides[key] ?? _getDartType(value, fieldName, nullabilityAnalysis, nullabilityMode, useObjectInsteadOfDynamic);

      if (alwaysIncludeMappableField || fieldName != key) {
        fields.add('  @MappableField(key: \'$key\')');
      }
      fields.add('  final $fieldType $fieldName;');

      if (useRequiredConstructor) {
        constructorParams.add('    required this.$fieldName,');
      } else {
        constructorParams.add('    this.$fieldName,');
      }
    });

    if (useRequiredConstructor) {
      buffer.writeln('  const $className({');
    } else {
      buffer.writeln('  const $className(');
    }

    buffer.writeln(constructorParams.join('\n'));
    buffer.writeln('  );');
    buffer.writeln();

    fields.forEach(buffer.writeln);

    // Add default methods if requested
    if (includeDefaultMethods) {
      buffer.writeln();
      buffer.writeln('  factory $className.fromMap(Map<String, dynamic> map) => ${className}Mapper.fromMap(map);');
      buffer.writeln();
      buffer.writeln('  factory $className.fromJson(String json) => ${className}Mapper.fromJson(json);');
      buffer.writeln();
      buffer.writeln('  static ${className}Mapper ensureInitialized() => ${className}Mapper.ensureInitialized();');
    }

    buffer.writeln('}');

    // Add all nested classes after the main class
    for (final nestedBuffer in nestedClassBuffers) {
      buffer.writeln();
      buffer.write(nestedBuffer);
    }
  }

  static void _generateClassFromList(
    StringBuffer buffer,
    List list,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
    bool alwaysIncludeMappableField, {
    bool useObjectInsteadOfDynamic = false,
    bool includeDefaultMethods = false,
    bool useRequiredConstructor = false,
    bool isRootClass = false,
  }) {
    final itemClassName = '${className}Item';

    // Generate the item class based on all items in the array, not just the first one
    if (list.isNotEmpty) {
      // Create a merged map of all fields from all items
      final mergedFields = <String, dynamic>{};

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          mergedFields.addAll(item);
        }
      }



      if (mergedFields.isNotEmpty) {
        // For array item classes, we need to filter the nullability analysis
        // The className here is like "ResponseItem", but we need to find the field name
        // that this array belongs to. Since this is called from _generateClassFromList,
        // and the className is like "Response", we need to find the field that contains this array.

        // Actually, since this is for root-level arrays, the path prefix would be empty
        // But for nested arrays, we need the field name. For now, let's assume the
        // nullability analysis already has the correct paths for the array items.

        _generateClassFromMap(buffer, mergedFields, itemClassName, nullabilityAnalysis, nullabilityMode, alwaysIncludeMappableField,
          useObjectInsteadOfDynamic: useObjectInsteadOfDynamic,
          includeDefaultMethods: includeDefaultMethods,
          useRequiredConstructor: useRequiredConstructor,
          isRootClass: false);
        buffer.writeln();
      }
    }

    buffer.writeln('@MappableClass()');
    buffer.writeln('class $className with ${className}Mappable {');
    buffer.writeln('  const $className(');
    buffer.writeln('    this.items,');
    buffer.writeln('  );');
    buffer.writeln();
    buffer.writeln('  final List<${list.isNotEmpty && list.any((item) => item is Map) ? itemClassName : 'dynamic'}> items;');
    buffer.writeln('}');
  }

  static String _sanitizeFieldName(String fieldName) {
    // Convert to camelCase and ensure it's a valid Dart identifier
    var sanitized = fieldName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it doesn't start with a number
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      sanitized = 'n$sanitized';
    }

    if (sanitized.isEmpty) return 'field';

    // Convert to camelCase
    final parts = sanitized.split('_').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'field';

    var result = parts.first.toLowerCase();
    for (var i = 1; i < parts.length; i++) {
      result += parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase();
    }

    // Check for reserved keywords
    if (_reservedKeywords.contains(result)) {
      result = '${result}Value';
    }

    return result;
  }

  static String _getDartType(
    dynamic value,
    String fieldName,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
    bool useObjectInsteadOfDynamic,
  ) {
    String baseType;
    if (value == null) {
      baseType = useObjectInsteadOfDynamic ? 'Object' : 'dynamic';
    } else if (value is String) {
      baseType = 'String';
    } else if (value is int) {
      baseType = 'int';
    } else if (value is double) {
      baseType = 'double';
    } else if (value is bool) {
      baseType = 'bool';
    } else if (value is List) {
      if (value.isEmpty) {
        baseType = 'List<${useObjectInsteadOfDynamic ? 'Object' : 'dynamic'}>';
      } else {
        final itemType = _getDartType(value.first, fieldName, nullabilityAnalysis, nullabilityMode, useObjectInsteadOfDynamic);
        baseType = 'List<$itemType>';
      }
    } else if (value is Map<String, dynamic>) {
      final className = '${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
      baseType = className;
    } else {
      baseType = useObjectInsteadOfDynamic ? 'Object' : 'dynamic';
    }

    // Apply nullability based on mode
    switch (nullabilityMode) {
      case 'all':
        return baseType == 'dynamic' || baseType == 'Object' ? baseType : '$baseType?';
      case 'smart':
        // For smart mode, check if this field should be nullable based on analysis
        if (nullabilityAnalysis != null && nullabilityAnalysis[fieldName] == true) {
          return baseType == 'dynamic' || baseType == 'Object' ? baseType : '$baseType?';
        }
        return baseType;
      case 'none':
      default:
        return baseType;
    }
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
