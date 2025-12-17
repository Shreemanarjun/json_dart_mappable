import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
@client
class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'relative min-h-screen overflow-hidden bg-slate-50', [
      // Decorative Background Elements
      const div(classes: 'absolute top-0 left-1/2 -translate-x-1/2 w-full h-full overflow-hidden pointer-events-none z-0', [
        div(classes: 'absolute -top-[10%] -left-[10%] w-[40%] h-[40%] bg-blue-400/10 rounded-full blur-[120px] animate-pulse', []),
        div(classes: 'absolute top-[20%] -right-[10%] w-[35%] h-[35%] bg-purple-400/10 rounded-full blur-[120px]', []),
      ]),

      section(classes: 'relative z-10 py-24 px-4', [
        div(classes: 'max-w-4xl mx-auto', [
          const div(classes: 'text-center mb-16', [
            h1(classes: 'text-4xl md:text-5xl font-black text-slate-900 mb-6 tracking-tight', [.text('About JSON Dart')]),
            p(classes: 'text-lg text-slate-600 font-medium max-w-2xl mx-auto', [
              .text('A powerful toolkit for Flutter and Dart developers, built to make data modeling effortless and type-safe.'),
            ]),
          ]),

          div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-8', [
            _aboutCard(
              '📖 Documentation',
              'Jaspr\'s official documentation provides you with all information you need to get started.',
              'https://docs.jaspr.site',
              'Read Docs',
              'bg-blue-50 text-blue-600',
            ),
            _aboutCard(
              '💬 Community',
              'Got stuck? Ask your question on the official Discord server for the Jaspr community.',
              'https://discord.gg/XGXrGEk4c6',
              'Join Discord',
              'bg-indigo-50 text-indigo-600',
            ),
            _aboutCard(
              '📦 Ecosystem',
              'Get official packages like jaspr_router, jaspr_tailwind or jaspr_riverpod on pub.dev.',
              'https://pub.dev/packages?q=topic%3Ajaspr',
              'Explore Packages',
              'bg-emerald-50 text-emerald-600',
            ),
            _aboutCard(
              '💙 Support Jaspr',
              'If you like Jaspr, consider starring us on GitHub and sharing with your friends.',
              'https://github.com/schultek/jaspr',
              'Star on GitHub',
              'bg-pink-50 text-pink-600',
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _aboutCard(String title, String description, String link, String linkText, String colorClasses) {
    return div(classes: 'bg-white p-8 rounded-3xl shadow-sm border border-slate-200/60 hover:shadow-xl transition-all group', [
      h3(classes: 'text-xl font-bold text-slate-900 mb-4', [.text(title)]),
      p(classes: 'text-slate-600 leading-relaxed mb-6 font-medium', [.text(description)]),
      a(
        href: link,
        classes: 'inline-flex items-center px-4 py-2 rounded-xl text-sm font-bold transition-all $colorClasses hover:shadow-md active:scale-95',
        [.text(linkText)],
      ),
    ]);
  }
}
