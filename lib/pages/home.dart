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

    return div(classes: 'relative min-h-screen overflow-hidden bg-slate-50', [
      // Decorative Background Elements
      const div(classes: 'absolute top-0 left-1/2 -translate-x-1/2 w-full h-full overflow-hidden pointer-events-none z-0', [
        div(classes: 'absolute -top-[10%] -left-[10%] w-[40%] h-[40%] bg-blue-400/20 rounded-full blur-[120px] animate-pulse', []),
        div(classes: 'absolute top-[20%] -right-[10%] w-[35%] h-[35%] bg-purple-400/20 rounded-full blur-[120px]', []),
        div(classes: 'absolute bottom-[10%] left-[20%] w-[30%] h-[30%] bg-indigo-400/10 rounded-full blur-[100px]', []),
      ]),

      // Main Content
      div(classes: 'relative z-10', [
        // Hero Section
        section(classes: 'pt-24 pb-20 px-4', [
          div(classes: 'max-w-[1400px] mx-auto', [
            const div(classes: 'flex flex-col items-center text-center mb-20', [
              // New Badge
              div(classes: 'inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-100 mb-8 animate-bounce', [
                span(classes: 'w-2 h-2 rounded-full bg-blue-600', []),
                span(classes: 'text-xs font-bold text-blue-700 uppercase tracking-wider', [.text('Powered by Dart Mappable')]),
              ]),

              h1(classes: 'text-5xl md:text-7xl font-black text-slate-900 mb-8 leading-[1.1] tracking-tight', [
                .text('Convert JSON to '),
                span(classes: 'bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent', [.text('Type-Safe')]),
                .text(' Dart'),
              ]),

              p(classes: 'text-lg md:text-xl text-slate-600 max-w-2xl mx-auto leading-relaxed mb-10 font-medium', [
                .text('The most advanced code generator for Dart. Instant conversion, smart nullability, and beautiful formatting for your production-ready models.'),
              ]),

              div(classes: 'flex flex-col sm:flex-row gap-4 items-center', [
                Link(
                  to: '/converter',
                  classes: 'group relative px-8 py-4 bg-slate-900 text-white rounded-2xl font-bold text-lg shadow-2xl hover:bg-slate-800 transition-all duration-300 flex items-center gap-3 overflow-hidden',
                  child: div(classes: 'flex items-center gap-3 relative z-10', [
                    span([.text('Get Started Free')]),
                    span(classes: 'group-hover:translate-x-1 transition-transform', [.text('→')]),
                  ]),
                ),
                a(
                  href: 'https://pub.dev/packages/dart_mappable',
                  classes: 'px-8 py-4 bg-white text-slate-700 border border-slate-200 rounded-2xl font-bold text-lg hover:bg-slate-50 transition-all duration-200',
                  [.text('View on Pub.dev')],
                ),
              ]),
            ]),

            // Bento Grid Features
            const div(classes: 'grid grid-cols-1 md:grid-cols-12 gap-6 mb-24', [
              // Large Card
              div(classes: 'md:col-span-8 bg-white rounded-3xl p-8 shadow-sm border border-slate-200/60 flex flex-col md:flex-row gap-8 items-center overflow-hidden group hover:shadow-xl hover:shadow-blue-500/5 transition-all duration-500', [
                div(classes: 'flex-1', [
                  div(classes: 'w-12 h-12 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 text-2xl', [.text('💎')]),
                  h3(classes: 'text-2xl font-bold text-slate-900 mb-4', [.text('Dart Mappable Power')]),
                  p(classes: 'text-slate-600 leading-relaxed mb-6', [
                    .text('Leverage the full power of dart_mappable with advanced features like polymorphic classes, custom mappers, and deep copies.'),
                  ]),
                  div(classes: 'flex gap-3', [
                    span(classes: 'px-3 py-1 bg-blue-50 text-blue-700 rounded-lg text-xs font-bold', [.text('V4.2.2')]),
                    span(classes: 'px-3 py-1 bg-indigo-50 text-indigo-700 rounded-lg text-xs font-bold', [.text('Polymorphism')]),
                  ]),
                ]),
                // Illustrative code snippet or visual
                div(classes: 'w-full md:w-1/2 bg-slate-50 rounded-2xl p-4 border border-slate-100 rotate-2 group-hover:rotate-0 transition-transform duration-500', [
                  div(classes: 'flex gap-1.5 mb-3', [
                    div(classes: 'w-2 h-2 rounded-full bg-slate-300', []),
                    div(classes: 'w-2 h-2 rounded-full bg-slate-300', []),
                  ]),
                  div(classes: 'space-y-2', [
                    div(classes: 'h-2 w-3/4 bg-slate-200 rounded', []),
                    div(classes: 'h-2 w-1/2 bg-slate-200 rounded', []),
                    div(classes: 'h-2 w-2/3 bg-blue-200 rounded', []),
                  ]),
                ]),
              ]),

              // Medium Card 1
              div(classes: 'md:col-span-4 bg-gradient-to-br from-indigo-600 to-blue-700 rounded-3xl p-8 shadow-lg text-white group hover:scale-[1.02] transition-transform duration-500', [
                div(classes: 'w-12 h-12 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center mb-6 text-2xl', [.text('⚡')]),
                h3(classes: 'text-2xl font-bold mb-4', [.text('Fast. Really Fast.')]),
                p(classes: 'text-indigo-100 leading-relaxed', [
                  .text('Real-time generation means you see the results as you type. No waiting, just instant output.'),
                ]),
              ]),

              // Feature cards row
              div(classes: 'md:col-span-4 bg-white rounded-3xl p-8 shadow-sm border border-slate-200/60 hover:shadow-lg transition-all', [
                div(classes: 'w-12 h-12 bg-emerald-100 rounded-2xl flex items-center justify-center mb-6 text-2xl', [.text('🛡️')]),
                h3(classes: 'text-xl font-bold text-slate-900 mb-3', [.text('Type-Safe')]),
                p(classes: 'text-slate-600 leading-relaxed', [.text('Say goodbye to dynamic types. Get full auto-completion and compile-time safety.')]),
              ]),

              div(classes: 'md:col-span-4 bg-white rounded-3xl p-8 shadow-sm border border-slate-200/60 hover:shadow-lg transition-all', [
                div(classes: 'w-12 h-12 bg-purple-100 rounded-2xl flex items-center justify-center mb-6 text-2xl', [.text('🎯')]),
                h3(classes: 'text-xl font-bold text-slate-900 mb-3', [.text('Smart Nulls')]),
                p(classes: 'text-slate-600 leading-relaxed', [.text('Automatically detects nullable fields by analyzing your JSON structure across multiple records.')]),
              ]),

              div(classes: 'md:col-span-4 bg-white rounded-3xl p-8 shadow-sm border border-slate-200/60 hover:shadow-lg transition-all', [
                div(classes: 'w-12 h-12 bg-amber-100 rounded-2xl flex items-center justify-center mb-6 text-2xl', [.text('🛠️')]),
                h3(classes: 'text-xl font-bold text-slate-900 mb-3', [.text('Format & Clean')]),
                p(classes: 'text-slate-600 leading-relaxed', [.text('Built-in JSON formatter and minifier helps you clean up messy data before conversion.')]),
              ]),
            ]),

            // Showcase Section (Interactive Preview)
            div(classes: 'relative mt-24', [
              const div(classes: 'absolute inset-0 bg-blue-600/5 blur-[100px] rounded-full', []),
              div(classes: 'relative bg-slate-900 rounded-[2.5rem] shadow-2xl border border-slate-800 overflow-hidden', [
                // Window Header
                const div(classes: 'flex items-center justify-between px-6 py-4 bg-slate-800/50 border-b border-slate-700/50', [
                  div(classes: 'flex gap-2', [
                    div(classes: 'w-3 h-3 rounded-full bg-red-400/80', []),
                    div(classes: 'w-3 h-3 rounded-full bg-amber-400/80', []),
                    div(classes: 'w-3 h-3 rounded-full bg-emerald-400/80', []),
                  ]),
                  div(classes: 'text-slate-400 text-xs font-mono tracking-widest', [.text('GENERATED_CODE.DART')]),
                  div(classes: 'w-12', []), // Spacer
                ]),

                // Code Content
                div(classes: 'p-8 md:p-12 grid grid-cols-1 lg:grid-cols-2 gap-12', [
                  div(classes: 'space-y-6', [
                    const h2(classes: 'text-3xl font-bold text-white', [.text('Clean Code,')]),
                    const h2(classes: 'text-3xl font-bold text-blue-400', [.text('Guaranteed.')]),
                    const p(classes: 'text-slate-400 leading-relaxed text-lg', [
                      .text('Our generator produces idiomatic Dart code that follows best practices. Fully compatible with Dart 3 and the latest mapping features.'),
                    ]),
                    ul(classes: 'space-y-4', [
                      _checkItem('Zero-boilerplate required'),
                      _checkItem('Customizable class names'),
                      _checkItem('Polymorphic support'),
                    ]),
                  ]),

                  const div(classes: 'bg-slate-800/40 rounded-2xl p-6 border border-slate-700/50 shadow-inner overflow-x-auto', [
                    pre(classes: 'text-slate-100 text-sm leading-relaxed font-mono', [
                      code(classes: 'language-dart', [
                        .text("""
@MappableClass()
class User with UserMappable {
  const User({
    required this.id,
    required this.name,
    this.email,
    @MappableField(key: 'user_meta')
    this.meta,
  });

  final String id;
  final String name;
  final String? email;
  final Map<String, dynamic>? meta;
}"""),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]),

            // CTA Bottom
            const div(classes: 'mt-32 text-center pb-20', [
              h2(classes: 'text-4xl font-bold text-slate-900 mb-6', [.text('Start generating today')]),
              p(classes: 'text-lg text-slate-600 mb-10 max-w-xl mx-auto', [
                .text('Join the growing community of Dart developers using modern tools to build faster.'),
              ]),
              Link(
                to: '/converter',
                classes: 'inline-flex items-center px-10 py-5 bg-blue-600 text-white rounded-2xl font-bold text-xl shadow-xl hover:bg-blue-700 hover:shadow-blue-500/20 transition-all duration-300 gap-3',
                child: div(classes: 'flex items-center gap-3', [
                  span([.text('Go to Converter')]),
                  span([.text('⚡')]),
                ]),
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _checkItem(String text) {
    return li(classes: 'flex items-center gap-3 text-slate-300', [
      const div(classes: 'flex-shrink-0 w-5 h-5 bg-blue-500/20 rounded-full flex items-center justify-center', [
        span(classes: 'text-blue-400 text-xs', [.text('✓')]),
      ]),
      span([.text(text)]),
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
