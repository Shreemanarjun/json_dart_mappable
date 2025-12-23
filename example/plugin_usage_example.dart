import 'package:json_dart_mappable/services/code_generator_interface.dart';
import 'package:json_dart_mappable/services/code_generators.dart';
import 'dart:convert';

void main() {
  // Example 1: Using the registry directly (composable approach)
  print('=== Example 1: Using Code Generator Registry ===\n');

  // Initialize the default generators
  CodeGeneratorRegistry.initializeDefaults();

  const jsonString = '''
  {
    "users": [
      {"id": 1, "name": "Alice", "score": 95.5},
      {"id": 2, "name": "Bob", "score": 88}
    ]
  }
  ''';

  final jsonData = jsonDecode(jsonString);

  // Get the Dart Mappable generator
  final dartMappableGen = CodeGeneratorRegistry.get('dart_mappable')!;

  const options = CodeGeneratorOptions(
    nullabilityMode: 'smart',
    useObjectInsteadOfDynamic: false,
    includeHelperMethods: true,
    useRequiredConstructor: true,
    classRenames: {
      'UsersItem': 'User',
    },
  );

  final code = dartMappableGen.generate(
    json: jsonData,
    className: 'UserList',
    options: options,
  );

  print(code);
  print('\n${'=' * 60}\n');

  // Example 2: Using Plain Dart generator
  print('=== Example 2: Using Plain Dart Generator ===\n');

  final plainDartGen = CodeGeneratorRegistry.get('plain_dart')!;

  final plainCode = plainDartGen.generate(
    json: jsonData,
    className: 'UserList',
    options: options,
  );

  print(plainCode);
  print('\n${'=' * 60}\n');

  // Example 3: Handling mixed types
  print('=== Example 3: Mixed Type Handling ===\n');

  const mixedJson = '''
  {
    "data": [
      {"age": 12, "value": 100},
      {"age": 12.5, "value": "text"}
    ]
  }
  ''';

  final mixedData = jsonDecode(mixedJson);

  const mixedOptions = CodeGeneratorOptions(
    nullabilityMode: 'smart',
    useObjectInsteadOfDynamic: true, // Use Object? instead of dynamic
  );

  final mixedCode = dartMappableGen.generate(
    json: mixedData,
    className: 'MixedData',
    options: mixedOptions,
  );

  print(mixedCode);
  print('\nNote: age is num (int + double), value is Object? (int + String)\n');
  print('=' * 60 + '\n');

  // Example 4: Creating a custom generator
  print('=== Example 4: Custom Generator ===\n');

  // Register a custom generator
  CodeGeneratorRegistry.register(SimpleJsonGenerator());

  final customGen = CodeGeneratorRegistry.get('simple_json')!;
  final customCode = customGen.generate(
    json: jsonData,
    className: 'UserList',
    options: options,
  );

  print(customCode);
  print('\n${'=' * 60}\n');

  // Example 5: List all available generators
  print('=== Example 5: Available Generators ===\n');

  final allGenerators = CodeGeneratorRegistry.getAll();
  print('Available generators:');
  for (final gen in allGenerators) {
    print('  - ${gen.name} (${gen.fileExtension})');
  }
}

/// Example custom generator that creates a simple JSON structure representation
class SimpleJsonGenerator implements CodeGenerator {
  @override
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('// Simple JSON structure for $className');
    buffer.writeln('// Generated with custom SimpleJsonGenerator');
    buffer.writeln();
    buffer.writeln('class $className {');
    buffer.writeln('  // This is a simplified representation');
    buffer.writeln('  // In a real implementation, you would parse the JSON');
    buffer.writeln('  // and generate appropriate fields');
    buffer.writeln('  final Map<String, dynamic> data;');
    buffer.writeln();
    buffer.writeln('  const $className(this.data);');
    buffer.writeln();
    buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $className(json);');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  @override
  bool canHandle(dynamic json) => true;

  @override
  String get fileExtension => '.dart';

  @override
  String get name => 'simple_json';
}
