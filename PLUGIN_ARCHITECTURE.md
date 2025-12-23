# Plugin System Architecture - Summary

## Overview

The JSON to Dart converter has been refactored to use a **composable plugin architecture** that separates concerns and makes the system extensible.

## Architecture Components

### 1. **Code Generator Interface** (`code_generator_interface.dart`)

The foundation of the plugin system:

```dart
abstract class CodeGenerator {
  String generate({
    required dynamic json,
    required String className,
    required CodeGeneratorOptions options,
  });

  bool canHandle(dynamic json);
  String get fileExtension;
  String get name;
}
```

**Benefits:**
- Clear contract for all generators
- Easy to implement custom generators
- Type-safe configuration via `CodeGeneratorOptions`

### 2. **Base Dart Generator** (`base_dart_generator.dart`)

Shared utilities for Dart code generation:

```dart
abstract class BaseDartGenerator implements CodeGenerator {
  // Shared utilities:
  - analyzeNullability()
  - sanitizeFieldName()
  - getDartType()
  - applyNullability()
  - mergeArrayFields()
}
```

**Benefits:**
- DRY principle - no code duplication
- Consistent behavior across generators
- Easy to extend with new utilities

### 3. **Concrete Generators** (`code_generators.dart`)

Two built-in implementations:

#### DartMappableGenerator
- Extends `BaseDartGenerator`
- Generates `dart_mappable` classes
- Includes `@MappableClass()` annotations
- Auto-generates `fromMap`, `fromJson`, `toJson`

#### PlainDartGenerator
- Extends `BaseDartGenerator`
- Generates plain Dart classes
- No external dependencies
- Manual `fromJson`/`toJson` implementations

**Benefits:**
- Code reuse through inheritance
- Consistent type handling
- Easy to maintain

### 4. **Generator Registry** (`code_generators.dart`)

Central registry for managing generators:

```dart
class CodeGeneratorRegistry {
  static void register(CodeGenerator generator);
  static CodeGenerator? get(String name);
  static List<CodeGenerator> getAll();
  static void initializeDefaults();
}
```

**Benefits:**
- Plugin discovery
- Runtime generator selection
- Easy to add new generators

### 5. **Legacy Adapter** (`json_to_dart_converter.dart`)

Maintains backward compatibility:

```dart
class JsonToDartConverter {
  static ConversionResult convertJsonToDart({...}) {
    // Now uses the plugin system internally
    final generator = useDartMappable
        ? _getDartMappableGenerator()
        : _getPlainDartGenerator();

    return generator.generate(...);
  }
}
```

**Benefits:**
- No breaking changes to existing API
- Gradual migration path
- Existing code continues to work

## Composability Features

### 1. **Separation of Concerns**

Each component has a single responsibility:
- **Interface**: Defines the contract
- **Base**: Provides shared utilities
- **Generators**: Implement specific output formats
- **Registry**: Manages generator lifecycle
- **Adapter**: Maintains compatibility

### 2. **Easy Extension**

Create a custom generator in 3 steps:

```dart
// 1. Implement the interface
class MyGenerator extends BaseDartGenerator {
  @override
  String generate({...}) {
    // Your custom logic
  }

  @override
  String get name => 'my_generator';
}

// 2. Register it
CodeGeneratorRegistry.register(MyGenerator());

// 3. Use it
final gen = CodeGeneratorRegistry.get('my_generator');
final code = gen.generate(...);
```

### 3. **Flexible Configuration**

`CodeGeneratorOptions` provides a unified configuration:

```dart
final options = CodeGeneratorOptions(
  nullabilityMode: 'smart',
  useObjectInsteadOfDynamic: true,
  includeHelperMethods: true,
  useRequiredConstructor: true,
  classRenames: {'UserItem': 'Person'},
  customOptions: {'myFeature': true}, // Generator-specific
);
```

### 4. **Type Safety**

All components are strongly typed:
- No string-based configuration (except mode names)
- Compile-time type checking
- Clear error messages

## Complex Type Handling

The system intelligently handles:

### Mixed Numeric Types
```json
[{"age": 12}, {"age": 12.5}]
```
→ `final num age;`

### Incompatible Types
```json
[{"value": 12}, {"value": "text"}]
```
→ `final dynamic value;` or `final Object? value;`

### Missing Fields
```json
[{"id": 1, "name": "Alice"}, {"id": 2}]
```
→ `final String? name;` (nullable)

### Null Values
```json
[{"value": null}, {"value": "text"}]
```
→ `final String? value;` (nullable)

## Testing

Comprehensive test coverage:

- **`json_converter_mixed_types_test.dart`**: Tests mixed type scenarios
- **`json_converter_complex_types_test.dart`**: Tests complex nested structures
- All tests pass ✅

## Migration Path

### For Users

**Option 1: Keep using the existing API (recommended for now)**
```dart
final result = JsonToDartConverter.convertJsonToDart(
  jsonString: json,
  className: 'MyClass',
  nullabilityMode: 'smart',
  useDartMappable: true,
);
```

**Option 2: Use the plugin system directly**
```dart
CodeGeneratorRegistry.initializeDefaults();
final generator = CodeGeneratorRegistry.get('dart_mappable')!;
final code = generator.generate(
  json: jsonDecode(jsonString),
  className: 'MyClass',
  options: CodeGeneratorOptions(nullabilityMode: 'smart'),
);
```

### For Plugin Developers

1. Extend `BaseDartGenerator` for Dart-based generators
2. Implement `CodeGenerator` directly for other languages
3. Register your generator with the registry
4. Distribute as a package

## Future Enhancements

Potential generators to add:

1. **FreezedGenerator** - `freezed` classes with unions
2. **JsonSerializableGenerator** - `json_serializable` annotations
3. **EquatableGenerator** - Add `Equatable` support
4. **BuildValueGenerator** - `built_value` classes
5. **ProtoGenerator** - Protocol Buffer definitions
6. **TypeScriptGenerator** - TypeScript interfaces
7. **GraphQLGenerator** - GraphQL schema

## Benefits Summary

✅ **Composable**: Mix and match components
✅ **Extensible**: Easy to add new generators
✅ **Maintainable**: Clear separation of concerns
✅ **Type-safe**: Compile-time checking
✅ **Backward compatible**: Existing code works
✅ **Well-tested**: Comprehensive test coverage
✅ **Documented**: Clear examples and guides

## Files Created/Modified

### New Files
- `lib/services/code_generator_interface.dart` - Plugin interface
- `lib/services/base_dart_generator.dart` - Shared utilities
- `lib/services/code_generators.dart` - Concrete implementations (refactored)
- `lib/services/README.md` - Plugin documentation
- `example/plugin_usage_example.dart` - Usage examples
- `test/json_converter_mixed_types_test.dart` - Mixed type tests
- `test/json_converter_complex_types_test.dart` - Complex type tests

### Modified Files
- `lib/services/json_to_dart_converter.dart` - Now uses plugin system
- `lib/pages/converter.dart` - UI for new features

## Conclusion

The refactored architecture provides a solid foundation for future enhancements while maintaining backward compatibility. The plugin system makes it easy to add new output formats and customize behavior without modifying core code.
