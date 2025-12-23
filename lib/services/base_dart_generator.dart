import 'code_generator_interface.dart';

/// Base class for Dart code generators with shared utilities
abstract class BaseDartGenerator implements CodeGenerator {
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

  @override
  bool canHandle(dynamic json) {
    return json is Map || json is List;
  }

  @override
  String get fileExtension => '.dart';

  /// Analyze nullability patterns in JSON data
  Map<String, bool> analyzeNullability(dynamic json, [String path = '']) {
    final analysis = <String, bool>{};

    if (json is Map<String, dynamic>) {
      json.forEach((key, value) {
        final fieldPath = path.isEmpty ? key : '$path.$key';
        bool shouldBeNullable = value == null;

        if (value is Map<String, dynamic>) {
          analysis.addAll(analyzeNullability(value, fieldPath));
        } else if (value is List && value.isNotEmpty) {
          final arrayAnalysis = analyzeArrayNullability(value, key, fieldPath);
          analysis.addAll(arrayAnalysis);
        }

        analysis[fieldPath] = shouldBeNullable;
      });
    } else if (json is List && json.isNotEmpty) {
      if (json.first is Map<String, dynamic>) {
        analysis.addAll(analyzeArrayNullability(json, '', path));
      }
    }

    return analysis;
  }

  /// Analyze nullability in array items
  Map<String, bool> analyzeArrayNullability(List array, String fieldName, String path) {
    final analysis = <String, bool>{};
    final allKeys = <String>{};

    for (final item in array) {
      if (item is Map<String, dynamic>) {
        allKeys.addAll(item.keys);
      }
    }

    for (final key in allKeys) {
      final fieldPath = path.isEmpty ? key : '$path.$key';
      bool shouldBeNullable = false;

      for (final item in array) {
        if (item is Map<String, dynamic>) {
          if (!item.containsKey(key) || item[key] == null) {
            shouldBeNullable = true;
            break;
          }
        }
      }

      analysis[fieldPath] = shouldBeNullable;

      // Collect all non-null values for this key to analyze nested structure
      final values = array.where((item) => item is Map<String, dynamic> && item[key] != null).map((item) => item[key]).toList();

      if (values.isNotEmpty) {
        if (values.first is Map<String, dynamic>) {
          // Recursively analyze the list of maps
          analysis.addAll(analyzeArrayNullability(values, key, fieldPath));
        } else if (values.first is List && values.first.isNotEmpty) {
          // Flatten list of lists and analyze
          final flattened = values.expand((l) => l as List).toList();
          analysis.addAll(analyzeArrayNullability(flattened, key, fieldPath));
        }
      }
    }

    return analysis;
  }

  /// Sanitize field names to valid Dart identifiers
  String sanitizeFieldName(String fieldName) {
    var sanitized = fieldName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      sanitized = 'n$sanitized';
    }

    if (sanitized.isEmpty) return 'field';

    final parts = sanitized.split('_').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'field';

    var result = parts.first.toLowerCase();
    for (var i = 1; i < parts.length; i++) {
      result += parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase();
    }

    if (_reservedKeywords.contains(result)) {
      result = '${result}Value';
    }

    return result;
  }

  /// Get Dart type for a JSON value
  String getDartType(
    dynamic value,
    String originalKey,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
    bool useObjectInsteadOfDynamic,
  ) {
    final fieldName = sanitizeFieldName(originalKey);
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
      baseType = _getListType(value, originalKey, nullabilityAnalysis, nullabilityMode, useObjectInsteadOfDynamic);
    } else if (value is Map<String, dynamic>) {
      final className = '${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
      baseType = className;
    } else {
      baseType = useObjectInsteadOfDynamic ? 'Object' : 'dynamic';
    }

    return applyNullability(baseType, originalKey, nullabilityAnalysis, nullabilityMode);
  }

  String _getListType(
    List value,
    String originalKey,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
    bool useObjectInsteadOfDynamic,
  ) {
    if (value.isEmpty) {
      return 'List<${useObjectInsteadOfDynamic ? 'Object' : 'dynamic'}>';
    }

    String? commonType;
    bool hasNull = false;

    for (final item in value) {
      if (item == null) {
        hasNull = true;
        continue;
      }

      final itemType = getDartType(item, originalKey, nullabilityAnalysis, 'none', useObjectInsteadOfDynamic);

      if (commonType == null) {
        commonType = itemType;
      } else if (commonType != itemType) {
        if ((commonType == 'int' && itemType == 'double') || (commonType == 'double' && itemType == 'int')) {
          commonType = 'num';
        } else if (commonType == 'num' && (itemType == 'int' || itemType == 'double')) {
          // Stay num
        } else if (itemType == 'num' && (commonType == 'int' || commonType == 'double')) {
          commonType = 'num';
        } else {
          commonType = useObjectInsteadOfDynamic ? 'Object' : 'dynamic';
          break;
        }
      }
    }

    commonType ??= useObjectInsteadOfDynamic ? 'Object' : 'dynamic';

    if (nullabilityMode == 'all' || (nullabilityMode == 'smart' && hasNull)) {
      if (commonType != 'dynamic' && commonType != 'Object' && !commonType.endsWith('?')) {
        commonType = '$commonType?';
      }
    }

    return 'List<$commonType>';
  }

  /// Apply nullability to a base type
  String applyNullability(
    String baseType,
    String originalKey,
    Map<String, bool>? nullabilityAnalysis,
    String nullabilityMode,
  ) {
    if (baseType == 'dynamic' || baseType == 'Object' || baseType.endsWith('?')) {
      return baseType;
    }

    switch (nullabilityMode) {
      case 'all':
        return '$baseType?';
      case 'smart':
        if (nullabilityAnalysis != null && nullabilityAnalysis[originalKey] == true) {
          return '$baseType?';
        }
        return baseType;
      case 'none':
      default:
        return baseType;
    }
  }

  /// Merge fields from array items and detect type conflicts
  MapMergeResult mergeArrayFields(
    List array,
    bool useObjectInsteadOfDynamic,
  ) {
    final mergedFields = <String, dynamic>{};
    final typeOverrides = <String, String>{};

    for (final item in array) {
      if (item is Map<String, dynamic>) {
        item.forEach((key, itemValue) {
          if (!mergedFields.containsKey(key)) {
            mergedFields[key] = itemValue;
          } else {
            final existing = mergedFields[key];

            if (existing != null && itemValue != null) {
              if (existing.runtimeType != itemValue.runtimeType) {
                bool isNum = (existing is int && itemValue is double) || (existing is double && itemValue is int);

                if (isNum) {
                  final currentOverride = typeOverrides[key];
                  if (currentOverride != 'dynamic' && currentOverride != 'Object?' && !(currentOverride?.startsWith('Object') ?? false)) {
                    typeOverrides[key] = 'num';
                  }
                } else {
                  typeOverrides[key] = useObjectInsteadOfDynamic ? 'Object?' : 'dynamic';
                }
              }
            } else if (existing == null && itemValue != null) {
              mergedFields[key] = itemValue;
            }
          }
        });
      }
    }

    return MapMergeResult(mergedFields, typeOverrides);
  }
}

/// Result of merging map fields from array items
class MapMergeResult {
  final Map<String, dynamic> mergedFields;
  final Map<String, String> typeOverrides;

  MapMergeResult(this.mergedFields, this.typeOverrides);
}
