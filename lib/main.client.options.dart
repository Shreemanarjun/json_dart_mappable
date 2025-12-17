// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:json_dart_mappable/pages/converter.dart' deferred as _converter;
import 'package:json_dart_mappable/pages/home.dart' deferred as _home;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'converter': ClientLoader(
      (p) => _converter.Converter(),
      loader: _converter.loadLibrary,
    ),
    'home': ClientLoader((p) => _home.Home(), loader: _home.loadLibrary),
  },
);
