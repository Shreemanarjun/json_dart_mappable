import 'package:json_dart_mappable/services/json_to_dart_converter.dart';
import 'package:json_dart_mappable/services/code_generators.dart';

void main() {
  const jsonString = '{"name": null}';
  final jsonData = {'name': null};

  // Test the nullability analysis
  final generator = DartMappableGenerator();
  final analysis = generator.analyzeNullability(jsonData);
  print('Nullability analysis: $analysis');

  final result = JsonToDartConverter.convertJsonToDart(
    jsonString: jsonString,
    className: 'MyModel',
    nullabilityMode: 'smart',
    alwaysIncludeMappableField: true,
    useObjectInsteadOfDynamic: true,
    includeDefaultMethods: true,
    useRequiredConstructor: true,
  );

  print('JSON: $jsonString');
  print('Result:');
  print(result.code);
  if (result.error.isNotEmpty) {
    print('Error: ${result.error}');
  }
}
