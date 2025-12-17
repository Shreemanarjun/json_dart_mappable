import 'package:test/test.dart';
import 'package:json_dart_mappable/services/json_to_dart_converter.dart';

void main() {
  group('JsonToDartConverter', () {
    test('converts simple JSON object', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'User', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('class User with UserMappable'));
      expect(result.code, contains('final String name;'));
      expect(result.code, contains('final int age;'));
    });

    test('handles nullability modes - none', () {
      const jsonString = '{"name": "John", "age": null}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'User', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('final String name;'));
      expect(result.code, contains('final dynamic age;'));
    });

    test('handles nullability modes - all', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'User', 'all');

      expect(result.isSuccess, true);
      expect(result.code, contains('final String? name;'));
      expect(result.code, contains('final int? age;'));
    });

    test('handles nullability modes - smart', () {
      const jsonString = '{"name": "John", "nickname": null, "age": 30}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'User', 'smart');

      expect(result.isSuccess, true);
      expect(result.code, contains('final String name;')); // Not null
      expect(result.code, contains('final dynamic nickname;')); // Null value
      expect(result.code, contains('final int age;')); // Not null
    });

    test('handles arrays', () {
      const jsonString = '{"items": [1, 2, 3]}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Container', 'none');

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
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Response', 'smart');

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
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'ApiResponse', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('class ApiResponse with ApiResponseMappable'));
      expect(result.code, contains('final User user;'));
      expect(result.code, contains('class User with UserMappable'));
      expect(result.code, contains('final Profile profile;'));
      expect(result.code, contains('class Profile with ProfileMappable'));
    });

    test('handles empty arrays', () {
      const jsonString = '{"items": []}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Container', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<dynamic> items;'));
    });

    test('handles mixed types in arrays', () {
      const jsonString = '{"data": [1, "hello", true, null]}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Mixed', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('final List<int> data;')); // Uses first item type
    });

    test('handles field name sanitization', () {
      const jsonString = '{"user_name": "John", "user-age": 30, "123invalid": "test"}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'User', 'none');

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
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Test', 'none');

      expect(result.isSuccess, true);
      expect(result.code, contains('final String classValue;'));
      expect(result.code, contains('final String voidValue;'));
      expect(result.code, contains('final String ifValue;'));
    });

    test('handles empty JSON', () {
      const jsonString = '';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Empty', 'none');

      expect(result.isSuccess, true);
      expect(result.code, isEmpty);
    });

    test('handles invalid JSON', () {
      const jsonString = '{"invalid": json}';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Invalid', 'none');

      expect(result.isSuccess, false);
      expect(result.error, contains('Invalid JSON'));
    });

    test('handles root level arrays', () {
      const jsonString = '[{"name": "John"}, {"name": "Jane"}]';
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Users', 'none');

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
      final result = JsonToDartConverter.convertJsonToDart(jsonString, 'Blog', 'smart');

      expect(result.isSuccess, true);
      expect(result.code, contains('class Blog with BlogMappable'));
      expect(result.code, contains('final List<UsersItem> users;'));
      expect(result.code, contains('class UsersItem with UsersItemMappable'));
      expect(result.code, contains('final List<PostsItem> posts;'));
      expect(result.code, contains('class PostsItem with PostsItemMappable'));
      expect(result.code, contains('final String title;'));
      expect(result.code, contains('final int? likes;')); // Nullable due to null value
    });
  });
}
