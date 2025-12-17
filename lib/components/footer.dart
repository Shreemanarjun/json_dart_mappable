import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'bg-white border-t border-slate-200 pt-16 pb-12', [
      div(classes: 'max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'flex flex-col md:flex-row justify-between items-start md:items-center gap-12 mb-12', [
          // Brand Column
          div(classes: 'max-w-md', [
            const div(classes: 'flex items-center space-x-3 mb-6', [
              div(classes: 'w-8 h-8 bg-slate-900 rounded-lg flex items-center justify-center shadow-md', [
                span(classes: 'text-white font-bold text-sm', [.text('{}')]),
              ]),
              span(classes: 'text-xl font-black text-slate-900', [.text('JSON DART')]),
            ]),
            const p(classes: 'text-slate-500 text-sm font-medium leading-relaxed mb-6', [
              .text('The most powerful and user-friendly JSON to Dart converter built with Jaspr and Dart Mappable.'),
            ]),
            div(classes: 'flex space-x-6', [
              _socialLink('GitHub', 'https://github.com/schultek/dart_mappable'),
              _socialLink('Documentation', 'https://pub.dev/packages/dart_mappable'),
            ]),
          ]),
        ]),

        const div(classes: 'border-t border-slate-100 pt-8 flex flex-col md:flex-row justify-between items-center', [
          p(classes: 'text-slate-400 text-sm font-medium mb-4 md:mb-0', [
            .text('MIT License © 2025 Shreeman Arjun Sahu'),
          ]),
          p(classes: 'text-slate-400 text-sm font-medium', [
            .text('Made with ❤️ and Jaspr'),
          ]),
        ]),
      ]),
    ]);
  }

  Component _socialLink(String label, String url) {
    return a(href: url, classes: 'text-sm font-bold text-slate-500 hover:text-blue-600 transition-colors flex items-center gap-2', [
      .text(label),
      span(classes: 'text-[10px]', [.text('↗')]),
    ]);
  }
}
