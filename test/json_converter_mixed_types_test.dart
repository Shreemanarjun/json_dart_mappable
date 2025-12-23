import 'package:test/test.dart';
import 'package:json_dart_mappable/services/json_to_dart_converter.dart';

void main() {
  group('JsonToDartConverter Mixed Types', () {
    test('should handle mixed int and double as num', () {
      const json = '''
      {
        "data": [
          {"age": 12},
          {"name": "", "age": 12.5}
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
      expect(result.code, contains('final num age;'));
    });

    test('should handle mixed int and String as dynamic', () {
      const json = '''
      {
        "data": [
          {"age": 12},
          {"name": "", "age": "Unknown"}
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
      // Depending on default behavior, it might be dynamic or Object?
      // Our logic defaults to dynamic unless useObjectInsteadOfDynamic is true
      expect(result.code, contains('final dynamic age;'));
    });

    test('should handle mixed int and String as Object? when flag is set', () {
      const json = '''
      {
        "data": [
          {"age": 12},
          {"name": "", "age": "Unknown"}
        ]
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
      expect(result.code, contains('final Object? age;'));
    });
  });
}
