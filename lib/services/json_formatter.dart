import 'dart:convert';

/// Utility class for JSON formatting operations
class JsonFormatter {
  /// Formats JSON string with proper indentation
  static FormatResult formatJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return FormatResult.success('');
    }

    try {
      final jsonData = jsonDecode(jsonString);
      final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);
      return FormatResult.success(formattedJson);
    } catch (e) {
      return FormatResult.error('Invalid JSON: ${e.toString()}');
    }
  }

  /// Minifies JSON string by removing whitespace
  static FormatResult minifyJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return FormatResult.success('');
    }

    try {
      final jsonData = jsonDecode(jsonString);
      final minifiedJson = jsonEncode(jsonData);
      return FormatResult.success(minifiedJson);
    } catch (e) {
      return FormatResult.error('Invalid JSON: ${e.toString()}');
    }
  }

  /// Validates if a string is valid JSON
  static bool isValidJson(String jsonString) {
    if (jsonString.trim().isEmpty) return false;

    try {
      jsonDecode(jsonString);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Result of a JSON formatting operation
class FormatResult {
  final String result;
  final String error;

  const FormatResult._(this.result, this.error);

  factory FormatResult.success(String result) => FormatResult._(result, '');

  factory FormatResult.error(String error) => FormatResult._('', error);

  bool get isSuccess => error.isEmpty;
}
