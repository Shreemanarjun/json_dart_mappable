# Code Generator Plugin System

This directory contains the plugin interface and implementations for generating Dart code from JSON.

## Architecture

The plugin system is designed to be extensible, allowing developers to create custom code generators for different output formats.

### Core Components

1. **`code_generator_interface.dart`** - Defines the base interface and options
2. **`code_generators.dart`** - Built-in generator implementations and registry
3. **`json_to_dart_converter.dart`** - Legacy converter (being refactored to use plugins)

## Built-in Generators

### DartMappableGenerator
Generates code using the `dart_mappable` package with full serialization support.

**Features:**
- `@MappableClass()` annotations
- Automatic `fromMap`, `fromJson`, and `toJson` methods
- Type-safe serialization
- Null-safety support

**Example Output:**
```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

@MappableClass()
class User with UserMappable {
  const User({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
```

### PlainDartGenerator
Generates plain Dart classes with manual `fromJson`/`toJson` implementations (no external dependencies).

**Features:**
- No external dependencies
- Manual serialization methods
- Lightweight and portable
- Full null-safety support

**Example Output:**
```dart
class User {
  const User({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

## Creating Custom Generators

To create a custom generator, implement the `CodeGenerator` interface:

```dart
import 'package:json_dart_mappable/services/code_generator_interface.dart';

class MyCustomGenerator implements CodeGenerator {
  @override
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  }) {
    // Your custom generation logic here
    return generatedCode;
  }

  @override
  bool canHandle(dynamic json) {
    // Return true if this generator can handle the JSON structure
    return json is Map || json is List;
  }

  @override
  String get fileExtension => '.dart';

  @override
  String get name => 'my_custom_generator';
}
```

### Register Your Generator

```dart
import 'package:json_dart_mappable/services/code_generators.dart';

void main() {
  // Initialize default generators
  CodeGeneratorRegistry.initializeDefaults();

  // Register your custom generator
  CodeGeneratorRegistry.register(MyCustomGenerator());

  // Use it
  final generator = CodeGeneratorRegistry.get('my_custom_generator');
  final code = generator?.generate(
    json: myJsonData,
    className: 'MyClass',
    options: CodeGeneratorOptions(),
  );
}
```

## Configuration Options

The `CodeGeneratorOptions` class provides extensive configuration:

```dart
final options = CodeGeneratorOptions(
  nullabilityMode: 'smart',           // 'none', 'all', or 'smart'
  useObjectInsteadOfDynamic: true,    // Use Object? instead of dynamic
  includeHelperMethods: true,          // Include fromMap, fromJson, etc.
  useRequiredConstructor: true,        // Use required parameters
  classRenames: {                      // Rename generated classes
    'UserItem': 'Person',
    'PostItem': 'Article',
  },
  customOptions: {                     // Generator-specific options
    'myOption': 'myValue',
  },
);
```

## Type Handling

The converter intelligently handles complex type scenarios:

### Mixed Numeric Types
```json
[{"age": 12}, {"age": 12.5}]
```
→ `final num age;`

### Incompatible Types
```json
[{"value": 12}, {"value": "text"}]
```
→ `final dynamic value;` (or `Object?` if flag is set)

### Missing Fields
```json
[{"id": 1, "name": "Alice"}, {"id": 2}]
```
→ `final String? name;` (nullable due to missing in second item)

### Null Values
```json
[{"value": null}, {"value": "text"}]
```
→ `final String? value;` (nullable due to null in first item)

## Future Generator Ideas

Here are some ideas for custom generators you could create:

1. **FreezedGenerator** - Generate `freezed` classes with unions and copyWith
2. **JsonSerializableGenerator** - Generate `json_serializable` annotations
3. **EquatableGenerator** - Add `Equatable` support for value equality
4. **BuildValueGenerator** - Generate `built_value` immutable classes
5. **ProtoGenerator** - Generate Protocol Buffer definitions
6. **TypeScriptGenerator** - Generate TypeScript interfaces
7. **GraphQLGenerator** - Generate GraphQL schema definitions

## Testing

All generators should be thoroughly tested. See `test/json_converter_complex_types_test.dart` for examples of comprehensive test coverage.

## Contributing

When adding a new generator:

1. Implement the `CodeGenerator` interface
2. Add comprehensive tests
3. Update this README with examples
4. Register it in the default registry if it's a built-in generator
