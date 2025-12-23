import 'package:test/test.dart';
import 'package:json_dart_mappable/services/json_to_dart_converter.dart';

void main() {
  group('JsonToDartConverter Complex Types', () {
    test('should handle nested objects with mixed types', () {
      const json = '''
      {
        "users": [
          {"id": 1, "name": "Alice", "score": 95.5},
          {"id": "2", "name": "Bob", "score": 88}
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      // id has mixed int/String -> dynamic
      expect(result.code, contains('final dynamic id;'));
      // score has mixed double/int -> num
      expect(result.code, contains('final num score;'));
    });

    test('should handle deeply nested structures', () {
      const json = '''
      {
        "data": {
          "nested": {
            "items": [
              {"value": 1},
              {"value": 2.5}
            ]
          }
        }
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final num value;'));
    });

    test('should handle missing fields in array items', () {
      const json = '''
      {
        "items": [
          {"id": 1, "name": "First"},
          {"id": 2},
          {"name": "Third"}
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      // Both fields should be nullable due to missing values
      expect(result.code, contains('final int? id;'));
      expect(result.code, contains('final String? name;'));
    });

    test('should handle null values in smart mode', () {
      const json = '''
      {
        "data": [
          {"value": null, "count": 5},
          {"value": "text", "count": null}
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final String? value;'));
      expect(result.code, contains('final int? count;'));
    });

    test('should handle empty arrays', () {
      const json = '''
      {
        "items": [],
        "name": "test"
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final List<dynamic> items;'));
    });

    test('should handle primitive arrays with mixed types', () {
      const json = '''
      {
        "values": [1, 2.5, 3]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final List<num> values;'));
    });

    test('should handle completely incompatible types in arrays', () {
      const json = '''
      {
        "mixed": [1, "text", true, 2.5]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final List<dynamic> mixed;'));
    });

    test('should use Object? when flag is set for incompatible types', () {
      const json = '''
      {
        "mixed": [1, "text", true]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useObjectInsteadOfDynamic: true,
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final List<Object> mixed;'));
    });

    test('should handle class renaming with mixed types', () {
      const json = '''
      {
        "users": [
          {"age": 25},
          {"age": 30.5}
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        classRenames: {'UsersItem': 'Person'},
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class Person'));
      expect(result.code, contains('final num age;'));
    });

    test('should generate plain Dart with mixed types', () {
      const json = '''
      {
        "data": [
          {"value": 1},
          {"value": 2.5}
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'TestModel',
        nullabilityMode: 'smart',
        useDartMappable: false,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final num value;'));
      expect(result.code, contains('factory'));
      expect(result.code, contains('fromJson'));
      expect(result.code, contains('toJson'));
      expect(result.code, isNot(contains('dart_mappable')));
    });
  });
}
