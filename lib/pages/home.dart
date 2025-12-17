import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:universal_web/web.dart' as web;

// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.

// Define kIsWeb locally to avoid dependency on flutter
const bool kIsWeb = bool.fromEnvironment('dart.library.js');

// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
@client
class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    // Initialize highlight.js when component mounts
    if (kIsWeb) {
      Future.delayed(const Duration(milliseconds: 10), _runHighlight);
    }

    return const div(classes: 'flex-1 bg-gradient-to-br from-blue-50 via-white to-purple-50', [
      // Hero Section
      section(classes: 'py-20 px-4', [
        div(classes: 'max-w-6xl mx-auto text-center', [
          // Main Hero Content
          div(classes: 'mb-16', [
            div(classes: 'inline-flex items-center justify-center w-20 h-20 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full mb-8 shadow-xl', [
              span(classes: 'text-3xl text-white font-bold', [.text('{}')]),
            ]),
            h1(classes: 'text-6xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-blue-800 bg-clip-text text-transparent mb-6 leading-tight', [
              .text('Transform JSON into\nType-Safe Dart Classes'),
            ]),
            p(classes: 'text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed mb-8', [
              .text('Generate production-ready Dart models with Dart Mappable. Format, validate, and convert your JSON data into beautiful, type-safe code instantly with our powerful online converter.'),
            ]),
            div(classes: 'flex flex-col sm:flex-row gap-4 justify-center items-center', [
              Link(
                to: '/converter',
                classes: 'px-8 py-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-semibold text-lg shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-200 flex items-center gap-3',
                child: div(classes: 'flex items-center gap-3', [
                  span([.text('🚀 Start Converting')]),
                  span(classes: 'text-sm opacity-90', [.text('Free')]),
                ]),
              ),
              div(classes: 'text-sm text-gray-500 flex items-center gap-2', [
                span(classes: 'w-2 h-2 bg-green-500 rounded-full animate-pulse', []),
                span([.text('No signup required • Works offline')]),
              ]),
            ]),
          ]),

          // Feature Grid
          div(classes: 'grid grid-cols-1 md:grid-cols-3 gap-8 mb-16', [
            // Feature 1
            div(classes: 'bg-white p-8 rounded-2xl shadow-lg border border-gray-100 hover:shadow-xl transition-shadow duration-300', [
              div(classes: 'w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center mb-4', [
                span(classes: 'text-2xl', [.text('✨')]),
              ]),
              h3(classes: 'text-xl font-bold text-gray-800 mb-3', [.text('JSON Formatting')]),
              p(classes: 'text-gray-600 leading-relaxed', [.text('Format and minify your JSON with one click. Clean, readable output with proper indentation and syntax highlighting.')]),
            ]),

            // Feature 2
            div(classes: 'bg-white p-8 rounded-2xl shadow-lg border border-gray-100 hover:shadow-xl transition-shadow duration-300', [
              div(classes: 'w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center mb-4', [
                span(classes: 'text-2xl', [.text('🎯')]),
              ]),
              h3(classes: 'text-xl font-bold text-gray-800 mb-3', [.text('Smart Nullability')]),
              p(classes: 'text-gray-600 leading-relaxed', [.text('Intelligent nullability detection. Choose between none, all nullable, or smart detection based on your JSON structure.')]),
            ]),

            // Feature 3
            div(classes: 'bg-white p-8 rounded-2xl shadow-lg border border-gray-100 hover:shadow-xl transition-shadow duration-300', [
              div(classes: 'w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center mb-4', [
                span(classes: 'text-2xl', [.text('⚡')]),
              ]),
              h3(classes: 'text-xl font-bold text-gray-800 mb-3', [.text('Real-time Generation')]),
              p(classes: 'text-gray-600 leading-relaxed', [.text('See your Dart classes generated instantly as you type. Syntax highlighting and error detection in real-time.')]),
            ]),
          ]),

          // Code Example
          div(classes: 'bg-slate-900 rounded-2xl p-8 shadow-2xl border border-slate-700 overflow-hidden', [
            div(classes: 'flex items-center justify-between mb-6', [
              div(classes: 'flex items-center gap-3', [
                div(classes: 'flex gap-1.5', [
                  div(classes: 'w-3 h-3 rounded-full bg-red-500', []),
                  div(classes: 'w-3 h-3 rounded-full bg-yellow-500', []),
                  div(classes: 'w-3 h-3 rounded-full bg-green-500', []),
                ]),
                span(classes: 'text-slate-300 text-sm font-medium ml-2', [.text('Generated Dart Class')]),
              ]),
              div(classes: 'flex items-center gap-2', [
                span(classes: 'text-xs text-slate-400 bg-slate-800 px-2 py-1 rounded-md font-medium', [.text('Dart Mappable v4.2.2')]),
                span(classes: 'text-xs text-emerald-400 flex items-center gap-1', [
                  span(classes: 'w-1.5 h-1.5 bg-emerald-400 rounded-full', []),
                  .text('Ready'),
                ]),
              ]),
            ]),
            div(classes: 'bg-slate-800/50 rounded-lg p-4 border border-slate-700', [
              div(classes: 'flex items-center gap-2 mb-3 text-slate-400 text-xs font-medium', [
                span(classes: 'text-blue-400', [.text('//')]),
                .text('🎯 Smart nullability detection'),
              ]),
              pre(classes: 'text-slate-100 text-sm leading-relaxed  font-mono', [
                code(classes: 'language-dart', [
                  .text("""
@MappableClass()
class User with UserMappable {
  const User({
    required this.name,
    required this.email,
    this.age,        // Nullable (detected from JSON)
    this.profile,    // Nullable (missing in some records)
  });

  final String name;
  final String email;
  final int? age;
  final Profile? profile;
}


"""),
                ]),
              ]),
            ]),
          ]),

          // CTA Section
          div(classes: 'mt-16 pt-16 border-t border-gray-200', [
            div(classes: 'bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl p-8 text-white', [
              h2(classes: 'text-3xl font-bold mb-4', [.text('Ready to Convert Your JSON?')]),
              p(classes: 'text-blue-100 mb-6 text-lg', [.text('Join thousands of developers who trust our converter for their Dart projects.')]),
              Link(
                to: '/converter',
                classes: 'inline-flex items-center px-6 py-3 bg-white text-blue-600 rounded-lg font-semibold hover:bg-gray-50 transition-colors duration-200',
                child: div(classes: 'flex items-center gap-2', [
                  span([.text('Get Started')]),
                  span([.text('→')]),
                ]),
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  void _runHighlight() {
    if (!kIsWeb) return;
    try {
      print('🏠 HOME: Running highlight.js on code blocks');
      final script = web.document.createElement('script') as web.HTMLScriptElement;
      script.text = '''
        (function() {
          if (typeof hljs === 'undefined') {
            console.log('highlight.js not loaded');
            return;
          }
          const codeBlocks = document.querySelectorAll('pre code');
          console.log('Found', codeBlocks.length, 'code blocks to highlight');
          codeBlocks.forEach((block, index) => {
            console.log('Highlighting block', index, 'with content length:', block.textContent.length);
            block.removeAttribute('data-highlighted');
            // Configure hljs to not warn about HTML-like content in code blocks
            hljs.configure({ignoreUnescapedHTML: true});
            hljs.highlightElement(block);
            console.log('Block', index, 'highlighted');
          });
        })();
      ''';
      web.document.head!.appendChild(script);
      script.remove();
    } catch (e) {
      print('🏠 HOME: Highlight error: $e');
    }
  }
}
