import 'base_dart_generator.dart';
import 'code_generator_interface.dart';

/// Dart Mappable code generator implementation
class DartMappableGenerator extends BaseDartGenerator {
  @override
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  }) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln("import 'package:dart_mappable/dart_mappable.dart';");
    buffer.writeln();
    buffer.writeln("part '${className.toLowerCase()}.mapper.dart';");
    buffer.writeln();

    // Analyze nullability if in smart mode
    final nullabilityAnalysis = options.nullabilityMode == 'smart' ? analyzeNullability(json) : null;

    // Generate classes
    if (json is Map<String, dynamic>) {
      _generateClassFromMap(
        buffer,
        json,
        className,
        nullabilityAnalysis,
        options,
        isRootClass: true,
      );
    } else if (json is List && json.isNotEmpty) {
      _generateClassFromList(buffer, json, className, nullabilityAnalysis, options);
    }

    return buffer.toString();
  }

  void _generateClassFromMap(
    StringBuffer buffer,
    Map<String, dynamic> map,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    CodeGeneratorOptions options, {
    bool isRootClass = false,
    Map<String, String>? extraFieldTypeOverrides,
  }) {
    final nestedClassBuffers = <StringBuffer>[];
    final nestedClasses = <String>[];
    final fieldTypeOverrides = <String, String>{};

    if (extraFieldTypeOverrides != null) {
      fieldTypeOverrides.addAll(extraFieldTypeOverrides);
    }

    // Process nested structures
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final defaultName = '${sanitizeFieldName(key)[0].toUpperCase()}${sanitizeFieldName(key).substring(1)}';
        final nestedClassName = options.classRenames[defaultName] ?? defaultName;

        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();
          // Filter nullability analysis for nested class
          final filteredAnalysis = <String, bool>{};
          final prefix = '$key.';
          nullabilityAnalysis?.forEach((path, isNullable) {
            if (path.startsWith(prefix)) {
              filteredAnalysis[path.substring(prefix.length)] = isNullable;
            }
          });

          _generateClassFromMap(
            nestedBuffer,
            value,
            nestedClassName,
            filteredAnalysis,
            options,
          );
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = nestedClassName;
      } else if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        final defaultName = '${sanitizeFieldName(key)[0].toUpperCase()}${sanitizeFieldName(key).substring(1)}Item';
        final nestedClassName = options.classRenames[defaultName] ?? defaultName;

        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();

          // Filter nullability analysis for nested class
          final filteredAnalysis = <String, bool>{};
          final prefix = '$key.';
          nullabilityAnalysis?.forEach((path, isNullable) {
            if (path.startsWith(prefix)) {
              filteredAnalysis[path.substring(prefix.length)] = isNullable;
            }
          });

          // Merge fields and detect type conflicts
          final mergeResult = mergeArrayFields(value, options.useObjectInsteadOfDynamic);

          _generateClassFromMap(
            nestedBuffer,
            mergeResult.mergedFields,
            nestedClassName,
            filteredAnalysis,
            options,
            extraFieldTypeOverrides: mergeResult.typeOverrides,
          );
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = 'List<$nestedClassName>';
      }
    });

    // Generate class header
    buffer.writeln('@MappableClass()');
    buffer.writeln('class $className with ${className}Mappable {');

    // Generate constructor
    final fields = <String>[];
    final constructorParams = <String>[];

    map.forEach((key, value) {
      final fieldName = sanitizeFieldName(key);
      var fieldType = fieldTypeOverrides[key] ?? getDartType(value, key, nullabilityAnalysis, options.nullabilityMode, options.useObjectInsteadOfDynamic);

      if (fieldTypeOverrides.containsKey(key)) {
        fieldType = applyNullability(fieldType, key, nullabilityAnalysis, options.nullabilityMode);
      }

      if (options.alwaysIncludeFieldAnnotations || fieldName != key) {
        fields.add("  @MappableField(key: '$key')");
      }
      fields.add('  final $fieldType $fieldName;');

      if (options.useRequiredConstructor) {
        constructorParams.add('    required this.$fieldName,');
      } else {
        constructorParams.add('    this.$fieldName,');
      }
    });

    if (options.useRequiredConstructor) {
      buffer.writeln('  const $className({');
      buffer.writeln(constructorParams.join('\n'));
      buffer.writeln('  });');
    } else {
      buffer.writeln('  const $className(');
      buffer.writeln(constructorParams.join('\n'));
      buffer.writeln('  );');
    }
    buffer.writeln();

    fields.forEach(buffer.writeln);

    // Add helper methods if requested
    if (options.includeHelperMethods) {
      buffer.writeln();
      buffer.writeln('  factory $className.fromMap(Map<String, dynamic> map) => ${className}Mapper.fromMap(map);');
      buffer.writeln();
      buffer.writeln('  factory $className.fromJson(String json) => ${className}Mapper.fromJson(json);');
      buffer.writeln();
      buffer.writeln('  static ${className}Mapper ensureInitialized() => ${className}Mapper.ensureInitialized();');
    }

    buffer.writeln('}');

    // Add nested classes
    for (final nestedBuffer in nestedClassBuffers) {
      buffer.writeln();
      buffer.write(nestedBuffer);
    }
  }

  void _generateClassFromList(
    StringBuffer buffer,
    List list,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    CodeGeneratorOptions options,
  ) {
    final itemClassName = '${className}Item';

    if (list.isNotEmpty && list.first is Map<String, dynamic>) {
      final mergeResult = mergeArrayFields(list, options.useObjectInsteadOfDynamic);

      if (mergeResult.mergedFields.isNotEmpty) {
        _generateClassFromMap(
          buffer,
          mergeResult.mergedFields,
          itemClassName,
          nullabilityAnalysis,
          options,
          extraFieldTypeOverrides: mergeResult.typeOverrides,
        );
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

  @override
  String get name => 'dart_mappable';
}

/// Plain Dart code generator implementation (no dependencies)
class PlainDartGenerator extends BaseDartGenerator {
  @override
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  }) {
    final buffer = StringBuffer();

    // Analyze nullability if in smart mode
    final nullabilityAnalysis = options.nullabilityMode == 'smart' ? analyzeNullability(json) : null;

    // Generate classes
    if (json is Map<String, dynamic>) {
      _generateClassFromMap(
        buffer,
        json,
        className,
        nullabilityAnalysis,
        options,
        isRootClass: true,
      );
    } else if (json is List && json.isNotEmpty) {
      _generateClassFromList(buffer, json, className, nullabilityAnalysis, options);
    }

    return buffer.toString();
  }

  void _generateClassFromMap(
    StringBuffer buffer,
    Map<String, dynamic> map,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    CodeGeneratorOptions options, {
    bool isRootClass = false,
    Map<String, String>? extraFieldTypeOverrides,
  }) {
    final nestedClassBuffers = <StringBuffer>[];
    final nestedClasses = <String>[];
    final fieldTypeOverrides = <String, String>{};

    if (extraFieldTypeOverrides != null) {
      fieldTypeOverrides.addAll(extraFieldTypeOverrides);
    }

    // Process nested structures (same as DartMappable)
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final defaultName = '${sanitizeFieldName(key)[0].toUpperCase()}${sanitizeFieldName(key).substring(1)}';
        final nestedClassName = options.classRenames[defaultName] ?? defaultName;

        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();
          // Filter nullability analysis for nested class
          final filteredAnalysis = <String, bool>{};
          final prefix = '$key.';
          nullabilityAnalysis?.forEach((path, isNullable) {
            if (path.startsWith(prefix)) {
              filteredAnalysis[path.substring(prefix.length)] = isNullable;
            }
          });

          _generateClassFromMap(
            nestedBuffer,
            value,
            nestedClassName,
            filteredAnalysis,
            options,
          );
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = nestedClassName;
      } else if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        final defaultName = '${sanitizeFieldName(key)[0].toUpperCase()}${sanitizeFieldName(key).substring(1)}Item';
        final nestedClassName = options.classRenames[defaultName] ?? defaultName;

        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();

          final filteredAnalysis = <String, bool>{};
          final prefix = '$key.';
          nullabilityAnalysis?.forEach((path, isNullable) {
            if (path.startsWith(prefix)) {
              filteredAnalysis[path.substring(prefix.length)] = isNullable;
            }
          });

          final mergeResult = mergeArrayFields(value, options.useObjectInsteadOfDynamic);

          _generateClassFromMap(
            nestedBuffer,
            mergeResult.mergedFields,
            nestedClassName,
            filteredAnalysis,
            options,
            extraFieldTypeOverrides: mergeResult.typeOverrides,
          );
          nestedClassBuffers.add(nestedBuffer);
        }
        fieldTypeOverrides[key] = 'List<$nestedClassName>';
      }
    });

    // Generate class header (no annotations)
    buffer.writeln('class $className {');

    // Generate constructor
    final fields = <String>[];
    final constructorParams = <String>[];

    map.forEach((key, value) {
      final fieldName = sanitizeFieldName(key);
      var fieldType = fieldTypeOverrides[key] ?? getDartType(value, key, nullabilityAnalysis, options.nullabilityMode, options.useObjectInsteadOfDynamic);

      if (fieldTypeOverrides.containsKey(key)) {
        fieldType = applyNullability(fieldType, key, nullabilityAnalysis, options.nullabilityMode);
      }

      fields.add('  final $fieldType $fieldName;');

      if (options.useRequiredConstructor) {
        constructorParams.add('    required this.$fieldName,');
      } else {
        constructorParams.add('    this.$fieldName,');
      }
    });

    if (options.useRequiredConstructor) {
      buffer.writeln('  const $className({');
      buffer.writeln(constructorParams.join('\n'));
      buffer.writeln('  });');
    } else {
      buffer.writeln('  const $className(');
      buffer.writeln(constructorParams.join('\n'));
      buffer.writeln('  );');
    }
    buffer.writeln();

    fields.forEach(buffer.writeln);

    // Generate fromJson factory
    buffer.writeln();
    buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $className(');

    map.forEach((key, value) {
      final fieldName = sanitizeFieldName(key);
      var fieldType = fieldTypeOverrides[key] ?? getDartType(value, key, nullabilityAnalysis, options.nullabilityMode, options.useObjectInsteadOfDynamic);

      if (fieldTypeOverrides.containsKey(key)) {
        fieldType = applyNullability(fieldType, key, nullabilityAnalysis, options.nullabilityMode);
      }

      buffer.write('      $fieldName: ');
      buffer.write(_generateFromJsonExpression(key, fieldType));
      buffer.writeln(',');
    });

    buffer.writeln('    );');
    buffer.writeln('  }');

    // Generate toJson method
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');

    map.forEach((key, value) {
      final fieldName = sanitizeFieldName(key);
      var fieldType = fieldTypeOverrides[key] ?? getDartType(value, key, nullabilityAnalysis, options.nullabilityMode, options.useObjectInsteadOfDynamic);

      if (fieldTypeOverrides.containsKey(key)) {
        fieldType = applyNullability(fieldType, key, nullabilityAnalysis, options.nullabilityMode);
      }

      buffer.write("      '$key': ");
      buffer.write(_generateToJsonExpression(fieldName, fieldType));
      buffer.writeln(',');
    });

    buffer.writeln('    };');
    buffer.writeln('  }');

    // Generate equality and hashCode methods if requested
    if (options.includeEqualityMethods) {
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  bool operator ==(Object other) {');
      buffer.writeln('    if (identical(this, other)) return true;');
      buffer.writeln('    if (other is! $className) return false;');
      buffer.writeln('    return ');

      final fieldComparisons = <String>[];
      map.forEach((key, value) {
        final fieldName = sanitizeFieldName(key);
        fieldComparisons.add('$fieldName == other.$fieldName');
      });

      buffer.writeln('      ${fieldComparisons.join(' &&\n      ')};');
      buffer.writeln('  }');

      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  int get hashCode {');

      final fieldNames = <String>[];
      map.forEach((key, value) {
        final fieldName = sanitizeFieldName(key);
        fieldNames.add(fieldName);
      });

      if (fieldNames.length == 1) {
        buffer.writeln('    return ${fieldNames[0]}.hashCode;');
      } else {
        buffer.writeln('    return Object.hash(${fieldNames.join(', ')});');
      }

      buffer.writeln('  }');
    }

    buffer.writeln('}');

    // Add nested classes
    for (final nestedBuffer in nestedClassBuffers) {
      buffer.writeln();
      buffer.write(nestedBuffer);
    }
  }

  String _generateFromJsonExpression(String key, String fieldType) {
    String cleanType = fieldType.replaceAll('?', '');
    bool isNullable = fieldType.endsWith('?');
    bool isList = cleanType.startsWith('List<');

    if (['int', 'double', 'String', 'bool', 'num', 'dynamic', 'Object'].contains(cleanType)) {
      return "json['$key'] as $fieldType";
    } else if (isList) {
      String inner = cleanType.substring(5, cleanType.length - 1);
      String innerClean = inner.replaceAll('?', '');
      bool innerPrimitive = ['int', 'double', 'String', 'bool', 'num', 'dynamic', 'Object'].contains(innerClean);

      String cast = isNullable ? "(json['$key'] as List?)" : "(json['$key'] as List)";

      if (innerPrimitive) {
        return "$cast${isNullable ? '?' : ''}.map((e) => e as $inner).toList()";
      } else {
        return "$cast${isNullable ? '?' : ''}.map((e) => $innerClean.fromJson(e as Map<String, dynamic>)).toList()";
      }
    } else {
      // Nested Object
      if (isNullable) {
        return "json['$key'] == null ? null : $cleanType.fromJson(json['$key'] as Map<String, dynamic>)";
      } else {
        return "$cleanType.fromJson(json['$key'] as Map<String, dynamic>)";
      }
    }
  }

  String _generateToJsonExpression(String fieldName, String fieldType) {
    String cleanType = fieldType.replaceAll('?', '');
    bool isNullable = fieldType.endsWith('?');
    bool isList = cleanType.startsWith('List<');

    if (isList) {
      String inner = cleanType.substring(5, cleanType.length - 1);
      String innerClean = inner.replaceAll('?', '');
      bool innerPrimitive = ['int', 'double', 'String', 'bool', 'num', 'dynamic', 'Object'].contains(innerClean);

      if (innerPrimitive) {
        return fieldName;
      } else {
        String safeAccess = isNullable ? '?' : '';
        return "$fieldName$safeAccess.map((e) => e.toJson()).toList()";
      }
    } else if (['int', 'double', 'String', 'bool', 'num', 'dynamic', 'Object'].contains(cleanType)) {
      return fieldName;
    } else {
      if (isNullable) {
        return "$fieldName?.toJson()";
      } else {
        return "$fieldName.toJson()";
      }
    }
  }

  void _generateClassFromList(
    StringBuffer buffer,
    List list,
    String className,
    Map<String, bool>? nullabilityAnalysis,
    CodeGeneratorOptions options,
  ) {
    final itemClassName = '${className}Item';

    if (list.isNotEmpty && list.first is Map<String, dynamic>) {
      final mergeResult = mergeArrayFields(list, options.useObjectInsteadOfDynamic);

      if (mergeResult.mergedFields.isNotEmpty) {
        _generateClassFromMap(
          buffer,
          mergeResult.mergedFields,
          itemClassName,
          nullabilityAnalysis,
          options,
          extraFieldTypeOverrides: mergeResult.typeOverrides,
        );
        buffer.writeln();
      }
    }

    buffer.writeln('class $className {');
    buffer.writeln('  const $className(');
    buffer.writeln('    this.items,');
    buffer.writeln('  );');
    buffer.writeln();
    buffer.writeln('  final List<${list.isNotEmpty && list.any((item) => item is Map) ? itemClassName : 'dynamic'}> items;');

    // Generate equality and hashCode methods for list classes
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    if (identical(this, other)) return true;');
    buffer.writeln('    if (other is! $className) return false;');
    buffer.writeln('    return items == other.items;');
    buffer.writeln('  }');

    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => items.hashCode;');

    buffer.writeln('}');
  }

  @override
  String get name => 'plain_dart';
}

/// Registry for managing code generators
class CodeGeneratorRegistry {
  static final Map<String, CodeGenerator> _generators = {};

  /// Register a new code generator
  static void register(CodeGenerator generator) {
    _generators[generator.name] = generator;
  }

  /// Get a generator by name
  static CodeGenerator? get(String name) {
    return _generators[name];
  }

  /// Get all registered generators
  static List<CodeGenerator> getAll() {
    return _generators.values.toList();
  }

  /// Initialize default generators
  static void initializeDefaults() {
    register(DartMappableGenerator());
    register(PlainDartGenerator());
  }
}
