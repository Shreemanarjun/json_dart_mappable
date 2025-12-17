import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class Converter extends StatefulComponent {
  const Converter({super.key});

  @override
  State<Converter> createState() => ConverterState();
}

class ConverterState extends State<Converter> {
  String _jsonInput = '';
  String _dartOutput = '';
  String _errorMessage = '';
  String _nullabilityMode = 'none'; // 'none', 'all', 'smart'
  String _mainClassName = 'MyModel';

  void _onJsonInputChanged(String value) {
    setState(() {
      _jsonInput = value;
      _convertJsonToDart();
    });
  }

  void _onNullabilityModeChanged(String mode) {
    setState(() {
      _nullabilityMode = mode;
      _convertJsonToDart();
    });
  }

  void _convertJsonToDart() {
    if (_jsonInput.trim().isEmpty) {
      setState(() {
        _dartOutput = '';
        _errorMessage = '';
      });
      return;
    }

    try {
      final jsonData = jsonDecode(_jsonInput);
      // Analyze nullability for smart mode
      final nullabilityAnalysis = _nullabilityMode == 'smart' ? _analyzeNullability(jsonData) : null;
      final dartClass = _generateDartClass(jsonData, _mainClassName, nullabilityAnalysis);
      setState(() {
        _dartOutput = dartClass;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
        _dartOutput = '';
      });
    }
  }

  Map<String, bool> _analyzeNullability(dynamic json, [String path = '']) {
    final analysis = <String, bool>{};

    if (json is Map<String, dynamic>) {
      json.forEach((key, value) {
        final fieldPath = path.isEmpty ? key : '$path.$key';
        analysis[fieldPath] = value == null;

        if (value is Map<String, dynamic>) {
          analysis.addAll(_analyzeNullability(value, fieldPath));
        } else if (value is List && value.isNotEmpty) {
          // For arrays, check if any item has this field as null or missing
          final hasNulls = value.any((item) => item is Map && (item[key] == null || !item.containsKey(key)));
          analysis[fieldPath] = hasNulls;

          // Analyze nested structures in arrays
          if (value.first is Map<String, dynamic>) {
            analysis.addAll(_analyzeNullability(value.first, fieldPath));
          }
        }
      });
    } else if (json is List && json.isNotEmpty && json.first is Map<String, dynamic>) {
      // Analyze all items in the array to see which fields are sometimes missing
      final allKeys = <String>{};
      final missingCounts = <String, int>{};

      for (final item in json) {
        if (item is Map<String, dynamic>) {
          allKeys.addAll(item.keys);
          for (final key in allKeys) {
            if (!item.containsKey(key) || item[key] == null) {
              missingCounts[key] = (missingCounts[key] ?? 0) + 1;
            }
          }
        }
      }

      for (final key in allKeys) {
        final fieldPath = path.isEmpty ? key : '$path.$key';
        analysis[fieldPath] = (missingCounts[key] ?? 0) > 0;
      }

      // Analyze nested structures
      if (json.first is Map<String, dynamic>) {
        analysis.addAll(_analyzeNullability(json.first, path));
      }
    }

    return analysis;
  }

  String _generateDartClass(dynamic json, String className, [Map<String, bool>? nullabilityAnalysis]) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:dart_mappable/dart_mappable.dart';");
    buffer.writeln();
    buffer.writeln('part \'${className.toLowerCase()}.mapper.dart\';');
    buffer.writeln();

    if (json is Map<String, dynamic>) {
      _generateClassFromMap(buffer, json, className, nullabilityAnalysis);
    } else if (json is List) {
      if (json.isNotEmpty) {
        _generateClassFromList(buffer, json, className, nullabilityAnalysis);
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

  void _generateClassFromMap(StringBuffer buffer, Map<String, dynamic> map, String className, [Map<String, bool>? nullabilityAnalysis]) {
    // Collect all nested classes first
    final nestedClassBuffers = <StringBuffer>[];
    final nestedClasses = <String>[];

    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final nestedClassName = '${_sanitizeFieldName(key)[0].toUpperCase()}${_sanitizeFieldName(key).substring(1)}';
        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();
          _generateClassFromMap(nestedBuffer, value, nestedClassName, nullabilityAnalysis);
          nestedClassBuffers.add(nestedBuffer);
        }
      } else if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        final nestedClassName = '${_sanitizeFieldName(key)[0].toUpperCase()}${_sanitizeFieldName(key).substring(1)}Item';
        if (!nestedClasses.contains(nestedClassName)) {
          nestedClasses.add(nestedClassName);
          final nestedBuffer = StringBuffer();
          _generateClassFromMap(nestedBuffer, value.first as Map<String, dynamic>, nestedClassName, nullabilityAnalysis);
          nestedClassBuffers.add(nestedBuffer);
        }
      }
    });

    // Generate the main class first
    buffer.writeln('@MappableClass()');
    buffer.writeln('class $className with ${className}Mappable {');
    buffer.writeln('  const $className(');

    final fields = <String>[];
    final constructors = <String>[];

    map.forEach((key, value) {
      final fieldName = _sanitizeFieldName(key);
      final fieldType = _getDartType(value, fieldName, nullabilityAnalysis);
      fields.add('  final $fieldType $fieldName;');
      constructors.add('    this.$fieldName,');
    });

    buffer.writeln(constructors.join('\n'));
    buffer.writeln('  );');
    buffer.writeln();

    fields.forEach(buffer.writeln);
    buffer.writeln('}');

    // Add all nested classes after the main class
    for (final nestedBuffer in nestedClassBuffers) {
      buffer.writeln();
      buffer.write(nestedBuffer);
    }
  }

  void _generateClassFromList(StringBuffer buffer, List list, String className, [Map<String, bool>? nullabilityAnalysis]) {
    final itemClassName = '${className}Item';

    if (list.isNotEmpty) {
      final firstItem = list.first;
      if (firstItem is Map<String, dynamic>) {
        _generateClassFromMap(buffer, firstItem, itemClassName, nullabilityAnalysis);
        buffer.writeln();
      }
    }

    buffer.writeln('@MappableClass()');
    buffer.writeln('class $className with ${className}Mappable {');
    buffer.writeln('  const $className(');
    buffer.writeln('    this.items,');
    buffer.writeln('  );');
    buffer.writeln();
    buffer.writeln('  final List<${list.isNotEmpty && list.first is Map ? itemClassName : 'dynamic'}> items;');
    buffer.writeln('}');
  }

  String _sanitizeFieldName(String fieldName) {
    // Convert to camelCase and ensure it's a valid Dart identifier
    final sanitized = fieldName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').replaceAll(RegExp(r'^[0-9]'), '_');

    if (sanitized.isEmpty) return 'field';

    // Convert to camelCase
    final parts = sanitized.split('_');
    if (parts.length == 1) return sanitized;

    return parts.first + parts.skip(1).map((part) => part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '').join('');
  }

  String _getDartType(dynamic value, String fieldName, [Map<String, bool>? nullabilityAnalysis]) {
    String baseType;
    if (value == null) {
      baseType = 'dynamic';
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
        baseType = 'List<dynamic>';
      } else {
        final itemType = _getDartType(value.first, fieldName, nullabilityAnalysis);
        baseType = 'List<$itemType>';
      }
    } else if (value is Map<String, dynamic>) {
      final className = '${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
      baseType = className;
    } else {
      baseType = 'dynamic';
    }

    // Apply nullability based on mode
    switch (_nullabilityMode) {
      case 'all':
        return baseType == 'dynamic' ? 'dynamic' : '$baseType?';
      case 'smart':
        // For smart mode, check if this field should be nullable based on analysis
        if (nullabilityAnalysis != null && nullabilityAnalysis[fieldName] == true) {
          return baseType == 'dynamic' ? 'dynamic' : '$baseType?';
        }
        return baseType;
      case 'none':
      default:
        return baseType;
    }
  }

  @override
  Component build(BuildContext context) {
    // Initialize highlight.js when component mounts or content changes
    // This will be called on the client side
    if (_dartOutput.isNotEmpty || (_jsonInput.isNotEmpty && _errorMessage.isEmpty)) {
      // Use a timeout to ensure DOM is updated
      // ignore: undefined_prefixed_name
      // dart.library.html
      if (identical(0, 0.0)) {
        // Client-side only code
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            // ignore: avoid_dynamic_calls
            (context as dynamic).callMethod('eval', ['''
              if (typeof hljs !== 'undefined') {
                hljs.highlightAll();
              }
            ''']);
          } catch (e) {
            // Ignore errors if highlight.js is not loaded
          }
        });
      }
    }

    return section(classes: 'min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 py-8 px-4', [
      div(classes: 'max-w-7xl mx-auto', [
        // Header Section
        const div(classes: 'text-center mb-12', [
          div(classes: 'inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full mb-6 shadow-lg', [
            span(classes: 'text-2xl text-white font-bold', [.text('{}')]),
          ]),
          h1(classes: 'text-5xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-blue-800 bg-clip-text text-transparent mb-4', [.text('JSON to Dart Converter')]),
          p(classes: 'text-xl text-gray-600 max-w-2xl mx-auto leading-relaxed', [.text('Transform your JSON data into type-safe Dart classes with Dart Mappable. Format, validate, and generate clean, production-ready code instantly.')]),
          div(classes: 'flex justify-center gap-4 mt-6', [
            div(classes: 'flex items-center gap-2 px-4 py-2 bg-white rounded-full shadow-sm border border-gray-200', [
              div(classes: 'w-3 h-3 bg-green-500 rounded-full animate-pulse', []),
              span(classes: 'text-sm text-gray-600 font-medium', [.text('Real-time Conversion')]),
            ]),
            div(classes: 'flex items-center gap-2 px-4 py-2 bg-white rounded-full shadow-sm border border-gray-200', [
              div(classes: 'w-3 h-3 bg-blue-500 rounded-full', []),
              span(classes: 'text-sm text-gray-600 font-medium', [.text('Type-Safe Output')]),
            ]),
            div(classes: 'flex items-center gap-2 px-4 py-2 bg-white rounded-full shadow-sm border border-gray-200', [
              div(classes: 'w-3 h-3 bg-purple-500 rounded-full', []),
              span(classes: 'text-sm text-gray-600 font-medium', [.text('Null Safety')]),
            ]),
          ]),
        ]),

        // Main Converter Section
        div(classes: 'bg-white rounded-2xl shadow-2xl border border-gray-100 overflow-hidden', [
          div(classes: 'flex flex-col lg:flex-row', [
            // JSON Input Section
            div(classes: 'flex-1 flex flex-col p-8 border-r border-gray-100', [
              div(classes: 'flex justify-between items-center mb-6', [
                const div(classes: 'flex items-center gap-3', [
                  div(classes: 'w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center', [
                    span(classes: 'text-blue-600 font-bold text-sm', [.text('{')]),
                  ]),
                  h2(classes: 'text-2xl font-bold text-gray-800', [.text('JSON Input')]),
                ]),
                div(classes: 'flex gap-3', [
                  button(classes: 'px-4 py-2 text-sm bg-gradient-to-r from-purple-600 to-purple-700 text-white rounded-lg hover:from-purple-700 hover:to-purple-800 transition-all duration-200 cursor-pointer shadow-md hover:shadow-lg transform hover:-translate-y-0.5', onClick: _formatJson, const [
                    span(classes: 'font-medium', [.text('✨ Format')]),
                  ]),
                  button(classes: 'px-4 py-2 text-sm bg-gradient-to-r from-orange-500 to-orange-600 text-white rounded-lg hover:from-orange-600 hover:to-orange-700 transition-all duration-200 cursor-pointer shadow-md hover:shadow-lg transform hover:-translate-y-0.5', onClick: _minifyJson, const [
                    span(classes: 'font-medium', [.text('🔥 Minify')]),
                  ]),
                  button(classes: 'px-4 py-2 text-sm border-2 border-gray-300 text-gray-600 bg-white rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 cursor-pointer', onClick: () => _onJsonInputChanged(''), const [
                    span(classes: 'font-medium', [.text('🗑️ Clear')]),
                  ]),
                ]),
              ]),

              // Configuration Section
              div(classes: 'bg-gradient-to-r from-gray-50 to-blue-50 rounded-xl p-6 mb-6 border border-gray-200', [
                div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
                  div(classes: 'space-y-2', [
                    const label(classes: 'block text-sm font-semibold text-gray-700 mb-2', [.text('📝 Class Name')]),
                    input(classes: 'w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-all duration-200 bg-white', type: InputType.text, value: _mainClassName, onInput: (value) => setState(() => _mainClassName = value as String? ?? 'MyModel')),
                  ]),
                  div(classes: 'space-y-3', [
                    const label(classes: 'block text-sm font-semibold text-gray-700 mb-2', [.text('🎯 Nullability Mode')]),
                    div(classes: 'flex flex-wrap gap-3', [
                      label(classes: 'flex items-center gap-2 cursor-pointer', [
                        input(type: InputType.radio, name: 'nullability', value: 'none', checked: _nullabilityMode == 'none', onChange: (e) => _onNullabilityModeChanged('none')),
                        const span(classes: 'px-3 py-1.5 bg-gray-100 text-gray-700 rounded-full text-sm font-medium hover:bg-gray-200 transition-colors', [.text('None')]),
                      ]),
                      label(classes: 'flex items-center gap-2 cursor-pointer', [
                        input(type: InputType.radio, name: 'nullability', value: 'all', checked: _nullabilityMode == 'all', onChange: (e) => _onNullabilityModeChanged('all')),
                        const span(classes: 'px-3 py-1.5 bg-blue-100 text-blue-700 rounded-full text-sm font-medium hover:bg-blue-200 transition-colors', [.text('All Nullable')]),
                      ]),
                      label(classes: 'flex items-center gap-2 cursor-pointer', [
                        input(type: InputType.radio, name: 'nullability', value: 'smart', checked: _nullabilityMode == 'smart', onChange: (e) => _onNullabilityModeChanged('smart')),
                        const span(classes: 'px-3 py-1.5 bg-purple-100 text-purple-700 rounded-full text-sm font-medium hover:bg-purple-200 transition-colors', [.text('Smart Detection')]),
                      ]),
                    ]),
                  ]),
                ]),
              ]),

              // JSON Input Area - Compact and Seamless
              div(classes: 'space-y-4', [
                // Main JSON Input
                div(classes: 'relative', [
                  textarea(
                    classes: 'w-full p-6 border-2 border-gray-200 rounded-xl font-mono text-sm bg-gradient-to-br from-gray-50 to-blue-50 text-gray-800 min-h-48 resize-vertical focus:border-blue-500 focus:ring-4 focus:ring-blue-100 transition-all duration-300 shadow-sm',
                    attributes: {'value': _jsonInput},
                    onInput: _onJsonInputChanged,
                    placeholder: '{"name": "John", "age": 30, "active": true}',
                    rows: 12,
                    const [],
                  ),

                  // Status indicators in top-right
                  if (_jsonInput.isNotEmpty) div(classes: 'absolute top-4 right-4 flex gap-2 z-10', [
                    if (_errorMessage.isEmpty) const div(classes: 'px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium flex items-center gap-1', [
                      span(classes: 'w-2 h-2 bg-green-500 rounded-full', []),
                      .text('Valid'),
                    ]) else const div(classes: 'px-2 py-1 bg-red-100 text-red-700 rounded-full text-xs font-medium flex items-center gap-1', [
                      span(classes: 'w-2 h-2 bg-red-500 rounded-full', []),
                      .text('Invalid'),
                    ]),
                  ]),

                  // Quick actions at bottom
                  if (_jsonInput.isNotEmpty && _errorMessage.isEmpty) div(classes: 'absolute bottom-4 left-4 right-4 flex justify-between items-center bg-white/90 backdrop-blur-sm rounded-lg p-2 border border-gray-200', [
                    const div(classes: 'text-xs text-gray-600 font-medium', [.text('JSON ready for conversion')]),
                    div(classes: 'flex gap-2', [
                      button(classes: 'px-3 py-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 rounded-md transition-colors font-medium', onClick: _formatJson, const [.text('Format')]),
                      button(classes: 'px-3 py-1 text-xs bg-orange-100 hover:bg-orange-200 text-orange-700 rounded-md transition-colors font-medium', onClick: _minifyJson, const [.text('Minify')]),
                    ]),
                  ]),
                ]),

                // JSON Syntax Highlighted Preview (only show if valid JSON)
                if (_jsonInput.isNotEmpty && _errorMessage.isEmpty) div(classes: 'relative', [
                  const div(classes: 'text-sm font-semibold text-gray-700 mb-2 flex items-center gap-2', [
                    span(classes: 'text-blue-600', [.text('🎨')]),
                    .text('Syntax Highlighted Preview'),
                  ]),
                  pre(classes: 'w-full p-4 bg-gradient-to-br from-slate-50 to-blue-50 border-2 border-blue-200 rounded-xl overflow-x-auto font-mono text-sm shadow-sm max-h-40', [
                    code(classes: 'language-json block', [.text(_getFormattedJson())]),
                  ]),
                ]),
              ]),

              if (_errorMessage.isNotEmpty) div(classes: 'mt-4 p-4 bg-gradient-to-r from-red-50 to-red-100 border border-red-200 text-red-700 rounded-lg flex items-center gap-3', [
                const span(classes: 'text-red-500 text-lg', [.text('⚠️')]),
                span(classes: 'font-medium', [.text(_errorMessage)]),
              ]),
            ]),

            // Dart Output Section
            div(classes: 'flex-1 flex flex-col p-8', [
              div(classes: 'flex justify-between items-center mb-6', [
                const div(classes: 'flex items-center gap-3', [
                  div(classes: 'w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center', [
                    span(classes: 'text-green-600 font-bold text-sm', [.text('</>')]),
                  ]),
                  h2(classes: 'text-2xl font-bold text-gray-800', [.text('Dart Output')]),
                ]),
                if (_dartOutput.isNotEmpty) button(classes: 'px-6 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-lg hover:from-green-700 hover:to-green-800 transition-all duration-200 cursor-pointer shadow-md hover:shadow-lg transform hover:-translate-y-0.5 flex items-center gap-2', onClick: () => _copyToClipboard(_dartOutput), const [
                  span(classes: 'font-medium', [.text('📋 Copy Code')]),
                ]),
              ]),

              div(classes: 'relative flex-1', [
                pre(classes: 'w-full min-h-80 max-h-[60vh] p-6 bg-gradient-to-br from-gray-900 to-blue-900 border-2 border-gray-200 rounded-xl overflow-y-auto overflow-x-auto font-mono text-sm text-gray-100 whitespace-pre shadow-lg scrollbar-thin scrollbar-thumb-gray-600 scrollbar-track-gray-800', [
                  code(classes: 'language-dart block', [.text(_dartOutput.isEmpty ? '// Your generated Dart classes will appear here...\n// Try pasting some JSON on the left!' : _dartOutput)]),
                ]),
                if (_dartOutput.isNotEmpty) const div(classes: 'absolute top-4 right-4 flex gap-2 z-10', [
                  div(classes: 'px-3 py-1 bg-green-500 text-white rounded-full text-xs font-medium animate-pulse', [.text('Generated')]),
                ]),
              ]),
            ]),
          ]),
        ]),

        // Footer
        const div(classes: 'text-center mt-12 text-gray-500', [
          p(classes: 'text-sm', [.text('Built with ❤️ using Jaspr, Tailwind CSS, and Dart Mappable')]),
        ]),
      ]),
    ]);
  }

  void _copyToClipboard(String text) {
    // For web, we can use the clipboard API
    // This is a simple implementation - in a real app you'd handle this better
  }

  void _formatJson() {
    if (_jsonInput.trim().isEmpty) return;

    try {
      final jsonData = jsonDecode(_jsonInput);
      final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);
      setState(() {
        _jsonInput = formattedJson;
        _convertJsonToDart();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
      });
    }
  }

  void _minifyJson() {
    if (_jsonInput.trim().isEmpty) return;

    try {
      final jsonData = jsonDecode(_jsonInput);
      final minifiedJson = jsonEncode(jsonData);
      setState(() {
        _jsonInput = minifiedJson;
        _convertJsonToDart();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON: ${e.toString()}';
      });
    }
  }

  String _getFormattedJson() {
    if (_jsonInput.trim().isEmpty) return '';

    try {
      final jsonData = jsonDecode(_jsonInput);
      return const JsonEncoder.withIndent('  ').convert(jsonData);
    } catch (e) {
      return _jsonInput; // Return original input if parsing fails
    }
  }
}
