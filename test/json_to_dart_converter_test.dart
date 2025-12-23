import 'package:test/test.dart';
import 'package:json_dart_mappable/services/json_to_dart_converter.dart';

void main() {
  group('JsonToDartConverter', () {
    test('converts simple JSON object', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class User with UserMappable'));
      expect(result.code, contains('final String name;'));
      expect(result.code, contains('final int age;'));
    });

    test('handles nullability modes - none', () {
      const jsonString = '{"name": "John", "age": null}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String name;'));
      expect(result.code, contains('final dynamic age;'));
    });

    test('handles nullability modes - all', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'all',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String? name;'));
      expect(result.code, contains('final int? age;'));
    });

    test('handles nullability modes - smart', () {
      const jsonString = '{"name": "John", "nickname": null, "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'smart',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String name;')); // Not null
      expect(result.code, contains('final dynamic nickname;')); // Null value
      expect(result.code, contains('final int age;')); // Not null
    });

    test('handles arrays', () {
      const jsonString = '{"items": [1, 2, 3]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Container',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<int> items;'));
    });

    test('handles complex arrays with varying fields', () {
      const jsonString = '''
      {
        "data": [
          {"age": "12"},
          {"name": "", "age": ""},
          {"name": null, "age": ""}
        ]
      }
      ''';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Response',
        nullabilityMode: 'smart',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class Response with ResponseMappable'));
      expect(result.code, contains('final List<DataItem> data;'));
      expect(result.code, contains('class DataItem with DataItemMappable'));
      expect(result.code, contains('final String? name;')); // Nullable - can be missing/null
      expect(result.code, contains('final String age;')); // Not nullable - always present, never null
    });

    test('handles nested objects', () {
      const jsonString = '''
      {
        "user": {
          "name": "John",
          "profile": {
            "age": 30,
            "city": "NYC"
          }
        }
      }
      ''';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'ApiResponse',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class ApiResponse with ApiResponseMappable'));
      expect(result.code, contains('final User user;'));
      expect(result.code, contains('class User with UserMappable'));
      expect(result.code, contains('final Profile profile;'));
      expect(result.code, contains('class Profile with ProfileMappable'));
    });

    test('handles empty arrays', () {
      const jsonString = '{"items": []}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Container',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<dynamic> items;'));
    });

    test('handles mixed types in arrays', () {
      const jsonString = '{"data": [1, "hello", true, null]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Mixed',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<dynamic> data;')); // Correctly identifies mixed types
    });

    test('handles field name sanitization', () {
      const jsonString = '{"user_name": "John", "user-age": 30, "123invalid": "test"}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String userName;'));
      expect(result.code, contains('final int userAge;'));
      expect(result.code, contains('final String n123invalid;'));
      expect(result.code, contains('@MappableField(key: \'user_name\')'));
      expect(result.code, contains('@MappableField(key: \'user-age\')'));
      expect(result.code, contains('@MappableField(key: \'123invalid\')'));
    });

    test('handles reserved keywords', () {
      const jsonString = '{"class": "A", "void": "B", "if": "C"}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Test',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String classValue;'));
      expect(result.code, contains('final String voidValue;'));
      expect(result.code, contains('final String ifValue;'));
    });

    test('handles empty JSON', () {
      const jsonString = '';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Empty',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, isEmpty);
    });

    test('handles invalid JSON', () {
      const jsonString = '{"invalid": json}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Invalid',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, false);
      expect(result.error, contains('Invalid JSON'));
    });

    test('handles root level arrays', () {
      const jsonString = '[{"name": "John"}, {"name": "Jane"}]';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Users',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class Users with UsersMappable'));
      expect(result.code, contains('final List<UsersItem> items;'));
      expect(result.code, contains('class UsersItem with UsersItemMappable'));
      expect(result.code, contains('final String name;'));
    });

    test('handles complex nested arrays', () {
      const jsonString = '''
      {
        "users": [
          {
            "name": "John",
            "posts": [
              {"title": "Post 1", "likes": 10},
              {"title": "Post 2", "likes": null}
            ]
          }
        ]
      }
      ''';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Blog',
        nullabilityMode: 'smart',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class Blog with BlogMappable'));
      expect(result.code, contains('final List<UsersItem> users;'));
      expect(result.code, contains('class UsersItem with UsersItemMappable'));
      expect(result.code, contains('final List<PostsItem> posts;'));
      expect(result.code, contains('class PostsItem with PostsItemMappable'));
      expect(result.code, contains('final String title;'));
      expect(result.code, contains('final int? likes;')); // Nullable due to null value
    });

    test('handles user reported scenario - inconsistent array items', () {
      const jsonString = '{"Data":[{"age":""},{"name":""}]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'MyModel',
        nullabilityMode: 'smart',
        alwaysIncludeMappableField: true,
        includeDefaultMethods: true,
        useRequiredConstructor: true,
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class MyModel with MyModelMappable'));
      expect(result.code, contains('final List<DataItem> data;'));
      expect(result.code, contains('class DataItem with DataItemMappable'));
      expect(result.code, contains('final String? age;')); // Reverted: nullable
      expect(result.code, contains('final String? name;')); // Reverted: nullable
      expect(result.code, contains('factory MyModel.fromMap'));
      expect(result.code, contains('});')); // Check for fixed constructor syntax
    });

    test('smart nullability works with sanitized keys', () {
      const jsonString = '{"user_data": [{"user_id": "1"}, {"other": "2"}]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'MyModel',
        nullabilityMode: 'smart',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String? userId;')); // Fixed: used to be non-nullable
    });

    test('smart nullability triggers on explicit null', () {
      const jsonString = '{"user_data": [{"user_id": "1"}, {"user_id": null}]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'MyModel',
        nullabilityMode: 'smart',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final String? userId;')); // Nullable because of explicit null
    });

    test('detects double type', () {
      const jsonString = '{"price": 10.5}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Product',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final double price;'));
    });

    test('detects num type for mixed int and double in array', () {
      const jsonString = '{"prices": [10, 10.5]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Product',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<num> prices;'));
    });

    test('detects num type for mixed int and double in objects array', () {
      const jsonString = '{"data": [{"val": 10}, {"val": 10.5}]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Response',
        nullabilityMode: 'none',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final num val;'));
    });

    test('handles nullability modes - all - nested objects', () {
      const jsonString = '{"user": {"name": "John"}}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'Response',
        nullabilityMode: 'all',
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final User? user;'));
    });

    test('handles smart nullability with null value and Object type', () {
      const jsonString = '{"name": null}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'MyModel',
        nullabilityMode: 'smart',
        alwaysIncludeMappableField: true,
        useObjectInsteadOfDynamic: true,
        includeDefaultMethods: true,
        useRequiredConstructor: true,
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('final Object? name;'));
      expect(result.code, contains('@MappableField(key: \'name\')'));
      expect(result.code, contains('factory MyModel.fromMap'));
    });

    test('plain Dart generator includes equality and hashCode methods when enabled', () {
      const jsonString = '{"name": "John", "age": 30, "active": true}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'none',
        useDartMappable: false, // Use plain Dart generator
        includeEqualityMethods: true, // Enable equality methods
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class User {'));
      expect(result.code, contains('@override'));
      expect(result.code, contains('bool operator ==(Object other)'));
      expect(result.code, contains('int get hashCode'));
      expect(result.code, contains('name == other.name'));
      expect(result.code, contains('age == other.age'));
      expect(result.code, contains('active == other.active'));
      expect(result.code, contains('Object.hash(name, age, active)'));
    });

    test('plain Dart generator excludes equality methods by default', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'User',
        nullabilityMode: 'none',
        useDartMappable: false, // Use plain Dart generator
        includeEqualityMethods: false, // Explicitly disable equality methods
      );

      expect(result.isSuccess, true);
      expect(result.code, contains('class User {'));
      expect(result.code, isNot(contains('operator ==')));
      expect(result.code, isNot(contains('hashCode')));
    });
    test('handles smart nullability with null value and Object type with recursive types', () {
      const jsonString = '{"data":[{"age": 12},{"age": null,"name":null}]}';
      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: jsonString,
        className: 'MyModel',
        nullabilityMode: 'smart',
        alwaysIncludeMappableField: true,
        useObjectInsteadOfDynamic: true,
        includeDefaultMethods: true,
        useRequiredConstructor: true,
      );

      expect(result.isSuccess, true);
      print(result.code);
      expect(result.code, contains('final Object? name;'));
      expect(result.code, contains('@MappableField(key: \'name\')'));
      expect(result.code, contains('factory MyModel.fromMap'));
    });
  });
}
