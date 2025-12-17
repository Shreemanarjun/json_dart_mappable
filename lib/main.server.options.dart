// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:json_dart_mappable/components/header.dart' as _header;
import 'package:json_dart_mappable/pages/converter.dart' as _converter;
import 'package:json_dart_mappable/pages/home.dart' as _home;
import 'package:json_dart_mappable/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _converter.Converter: ClientTarget<_converter.Converter>('converter'),
    _home.Home: ClientTarget<_home.Home>('home'),
  },
  styles: () => [..._header.Header.styles, ..._app.App.styles],
);
