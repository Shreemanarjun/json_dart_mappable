import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'bg-white border-t border-slate-200 pt-16 pb-8', [
      div(classes: 'max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'grid grid-cols-1 md:grid-cols-4 gap-12 mb-12', [
          // Brand Column
          div(classes: 'col-span-1 md:col-span-1', [
            const div(classes: 'flex items-center space-x-3 mb-6', [
              div(classes: 'w-8 h-8 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center shadow-md', [
                span(classes: 'text-white font-bold text-sm', [.text('{}')]),
              ]),
              span(classes: 'text-xl font-black text-slate-900', [.text('JSON Dart')]),
            ]),
            const p(classes: 'text-slate-500 text-sm leading-relaxed mb-4', [
              .text('The most powerful and user-friendly JSON to Dart converter built with Jaspr and Dart Mappable.'),
            ]),
            div(classes: 'flex space-x-4', [
              // Social icons placeholders
              _socialLink('GitHub', 'https://github.com'),
              _socialLink('Twitter', 'https://twitter.com'),
            ]),
          ]),

          // Links Columns
          _linkColumn('Product', [
            (label: 'Converter', href: '/converter'),
            (label: 'Features', href: '/#features'),
            (label: 'Documentation', href: 'https://pub.dev/packages/dart_mappable'),
          ]),
          _linkColumn('Resources', [
            (label: 'Jaspr Framework', href: 'https://jaspr.site'),
            (label: 'Dart Language', href: 'https://dart.dev'),
            (label: 'Flutter', href: 'https://flutter.dev'),
          ]),
          _linkColumn('About', [
            (label: 'Our Story', href: '/about'),
            (label: 'Privacy Policy', href: '#'),
            (label: 'Terms of Service', href: '#'),
          ]),
        ]),

        const div(classes: 'border-t border-slate-100 pt-8 flex flex-col md:flex-row justify-between items-center', [
          p(classes: 'text-slate-400 text-sm mb-4 md:mb-0', [
            .text('© 2024 JSON Dart Mappable. Built with ❤️ using Jaspr.'),
          ]),
          div(classes: 'flex space-x-6 text-sm text-slate-400', [
            a(href: '#', classes: 'hover:text-blue-600 transition-colors', [.text('Privacy')]),
            a(href: '#', classes: 'hover:text-blue-600 transition-colors', [.text('Terms')]),
            a(href: '#', classes: 'hover:text-blue-600 transition-colors', [.text('Contact')]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _socialLink(String label, String url) {
    return a(href: url, classes: 'text-slate-400 hover:text-blue-600 transition-colors', [
      span(classes: 'sr-only', [.text(label)]),
      // Simple text icons for now
      span(classes: 'font-bold', [.text(label[0])]),
    ]);
  }

  Component _linkColumn(String title, List<({String label, String href})> links) {
    return div([
      h3(classes: 'text-slate-900 font-bold mb-6', [.text(title)]),
      ul(classes: 'space-y-4', [
        for (final link in links)
          li([
            a(href: link.href, classes: 'text-slate-500 hover:text-blue-600 transition-colors text-sm', [.text(link.label)]),
          ]),
      ]),
    ]);
  }
}
