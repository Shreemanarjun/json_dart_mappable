import 'package:test/test.dart';
import 'package:json_dart_mappable/services/json_to_dart_converter.dart';

void main() {
  group('Production Real-World Scenarios', () {
    test('should handle GitHub API user response', () {
      const json = '''
      {
        "login": "octocat",
        "id": 1,
        "node_id": "MDQ6VXNlcjE=",
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "",
        "url": "https://api.github.com/users/octocat",
        "html_url": "https://github.com/octocat",
        "followers_url": "https://api.github.com/users/octocat/followers",
        "following_url": "https://api.github.com/users/octocat/following{/other_user}",
        "type": "User",
        "site_admin": false,
        "name": "monalisa octocat",
        "company": "GitHub",
        "blog": "https://github.com/blog",
        "location": "San Francisco",
        "email": "octocat@github.com",
        "hireable": false,
        "bio": "There once was...",
        "public_repos": 2,
        "public_gists": 1,
        "followers": 20,
        "following": 0,
        "created_at": "2008-01-14T04:33:35Z",
        "updated_at": "2008-01-14T04:33:35Z"
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'GitHubUser',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class GitHubUser'));
      expect(result.code, contains('final String login;'));
      expect(result.code, contains('final int id;'));
      expect(result.code, contains('final bool siteAdmin;'));
    });

    test('should handle REST API pagination response', () {
      const json = '''
      {
        "page": 1,
        "per_page": 10,
        "total": 100,
        "total_pages": 10,
        "data": [
          {
            "id": 1,
            "title": "First Post",
            "author": {
              "id": 1,
              "name": "John Doe",
              "email": "john@example.com"
            },
            "tags": ["tech", "programming"],
            "published": true,
            "views": 1500,
            "created_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "title": "Second Post",
            "author": {
              "id": 2,
              "name": "Jane Smith",
              "email": null
            },
            "tags": [],
            "published": false,
            "views": 0,
            "created_at": "2024-01-02T00:00:00Z"
          }
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'PaginatedResponse',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class PaginatedResponse'));
      expect(result.code, contains('class DataItem'));
      expect(result.code, contains('class Author'));
      expect(result.code, contains('final String? email;')); // Nullable due to null value
      expect(result.code, contains('final List<String> tags;'));
    });

    test('should handle e-commerce product catalog', () {
      const json = '''
      {
        "products": [
          {
            "id": "prod_123",
            "name": "Laptop",
            "price": 999.99,
            "currency": "USD",
            "in_stock": true,
            "quantity": 50,
            "categories": ["electronics", "computers"],
            "specifications": {
              "cpu": "Intel i7",
              "ram": "16GB",
              "storage": "512GB SSD"
            },
            "reviews": [
              {
                "user": "Alice",
                "rating": 5,
                "comment": "Great laptop!"
              },
              {
                "user": "Bob",
                "rating": 4.5,
                "comment": "Good value"
              }
            ]
          }
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'ProductCatalog',
        nullabilityMode: 'smart',
        useDartMappable: true,
        classRenames: {
          'ProductsItem': 'Product',
          'ReviewsItem': 'Review',
        },
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class Product'));
      expect(result.code, contains('class Review'));
      expect(result.code, contains('class Specifications'));
      expect(result.code, contains('final num rating;')); // Mixed int/double
    });

    test('should handle weather API response with optional fields', () {
      const json = '''
      {
        "location": {
          "name": "London",
          "region": "City of London, Greater London",
          "country": "United Kingdom",
          "lat": 51.52,
          "lon": -0.11
        },
        "current": {
          "temp_c": 15.0,
          "temp_f": 59.0,
          "is_day": 1,
          "condition": {
            "text": "Partly cloudy",
            "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
            "code": 1003
          },
          "wind_mph": 6.9,
          "wind_kph": 11.2,
          "wind_degree": 230,
          "wind_dir": "SW",
          "pressure_mb": 1012.0,
          "precip_mm": 0.0,
          "humidity": 82,
          "cloud": 75,
          "feelslike_c": 14.5,
          "feelslike_f": 58.1,
          "uv": 4.0
        }
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'WeatherResponse',
        nullabilityMode: 'smart',
        useDartMappable: false, // Test plain Dart
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('factory WeatherResponse.fromJson'));
      expect(result.code, contains('Map<String, dynamic> toJson()'));
      expect(result.code, isNot(contains('dart_mappable')));
      expect(result.code, contains('final double tempC;'));
    });

    test('should handle social media post with nested comments', () {
      const json = '''
      {
        "post": {
          "id": "post_123",
          "content": "Hello World!",
          "author": {
            "id": "user_1",
            "username": "johndoe",
            "display_name": "John Doe",
            "verified": true
          },
          "likes": 42,
          "shares": 5,
          "comments": [
            {
              "id": "comment_1",
              "text": "Great post!",
              "author": {
                "id": "user_2",
                "username": "janedoe",
                "display_name": "Jane Doe",
                "verified": false
              },
              "likes": 3,
              "replies": [
                {
                  "id": "reply_1",
                  "text": "Thanks!",
                  "author": {
                    "id": "user_1",
                    "username": "johndoe",
                    "display_name": "John Doe",
                    "verified": true
                  },
                  "likes": 1
                }
              ]
            }
          ],
          "timestamp": "2024-01-15T10:30:00Z"
        }
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'SocialPost',
        nullabilityMode: 'smart',
        useDartMappable: true,
        classRenames: {
          'CommentsItem': 'Comment',
          'RepliesItem': 'Reply',
        },
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class Comment'));
      expect(result.code, contains('class Reply'));
      expect(result.code, contains('class Author'));
      expect(result.code, contains('final List<Comment> comments;'));
      expect(result.code, contains('final List<Reply> replies;'));
    });

    test('should handle analytics dashboard data', () {
      const json = '''
      {
        "dashboard": {
          "period": "last_30_days",
          "metrics": {
            "total_users": 15420,
            "active_users": 8932,
            "new_users": 1245,
            "revenue": 45678.90,
            "conversion_rate": 3.45
          },
          "chart_data": [
            {"date": "2024-01-01", "users": 450, "revenue": 1234.56},
            {"date": "2024-01-02", "users": 523, "revenue": 1456.78},
            {"date": "2024-01-03", "users": 498, "revenue": 1389.12}
          ],
          "top_products": [
            {"id": 1, "name": "Product A", "sales": 234, "revenue": 5678.90},
            {"id": 2, "name": "Product B", "sales": 189, "revenue": 4567.80}
          ]
        }
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'AnalyticsDashboard',
        nullabilityMode: 'smart',
        useDartMappable: true,
        useObjectInsteadOfDynamic: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class AnalyticsDashboard'));
      expect(result.code, contains('class Metrics'));
      expect(result.code, contains('final double conversionRate;'));
    });

    test('should handle empty and null edge cases in production data', () {
      const json = '''
      {
        "users": [
          {
            "id": 1,
            "name": "Alice",
            "email": "alice@example.com",
            "phone": "+1234567890",
            "address": {
              "street": "123 Main St",
              "city": "New York",
              "country": "USA"
            }
          },
          {
            "id": 2,
            "name": "Bob",
            "email": null,
            "phone": "",
            "address": null
          },
          {
            "id": 3,
            "name": "",
            "email": "charlie@example.com"
          }
        ]
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'UserList',
        nullabilityMode: 'smart',
        useDartMappable: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('final String? email;'));
      expect(result.code, contains('final String? phone;'));
      expect(result.code, contains('final Address? address;'));
    });

    test('should handle large nested configuration object', () {
      const json = '''
      {
        "app_config": {
          "version": "1.0.0",
          "environment": "production",
          "features": {
            "authentication": {
              "enabled": true,
              "providers": ["google", "github", "email"],
              "session_timeout": 3600
            },
            "notifications": {
              "enabled": true,
              "channels": {
                "email": {"enabled": true, "smtp_host": "smtp.example.com"},
                "push": {"enabled": false, "api_key": null},
                "sms": {"enabled": true, "provider": "twilio"}
              }
            },
            "analytics": {
              "enabled": true,
              "tracking_id": "UA-12345678-1",
              "sample_rate": 0.1
            }
          },
          "limits": {
            "max_upload_size": 10485760,
            "rate_limit": 100,
            "concurrent_connections": 50
          }
        }
      }
      ''';

      final result = JsonToDartConverter.convertJsonToDart(
        jsonString: json,
        className: 'AppConfig',
        nullabilityMode: 'smart',
        useDartMappable: false,
      );

      expect(result.isSuccess, isTrue);
      expect(result.code, contains('class AppConfig'));
      expect(result.code, contains('class Features'));
      expect(result.code, contains('class Authentication'));
      expect(result.code, contains('class Notifications'));
      expect(result.code, contains('class Channels'));
      expect(result.code, contains('final double sampleRate;'));
    });
  });
}
