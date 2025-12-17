import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    final activePath = context.url;

    return header(classes: 'bg-white/70 backdrop-blur-xl border-b border-slate-200/50 sticky top-0 z-50 transition-all', [
      div(classes: 'max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'flex justify-between items-center h-20', [
          // Logo/Brand
          const Link(
            to: '/',
            classes: 'flex items-center space-x-3 group',
            child: div(classes: 'flex items-center space-x-4', [
              div(classes: 'w-10 h-10 bg-slate-900 rounded-2xl flex items-center justify-center transform group-hover:rotate-6 transition-transform duration-300 shadow-lg shadow-slate-200', [
                span(classes: 'text-white font-black text-xl', [.text('{}')]),
              ]),
              div([
                h1(classes: 'text-xl font-black text-slate-900 leading-none mb-1 tracking-tight', [.text('JSON DART')]),
                p(classes: 'text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] leading-none', [.text('Mappable v4')]),
              ]),
            ]),
          ),

          // Navigation
          nav(classes: 'hidden md:flex items-center gap-2', [
            for (final route in [
              (label: 'Home', path: '/'),
              (label: 'Converter', path: '/converter'),
            ])
              Link(
                to: route.path,
                classes: 'px-5 py-2 rounded-xl font-bold text-sm transition-all duration-200 ${activePath == route.path ? 'bg-slate-900 text-white shadow-lg shadow-slate-200' : 'text-slate-500 hover:text-slate-900 hover:bg-slate-50'}',
                child: .text(route.label),
              ),

            // Github link
            const a(href: 'https://github.com/schultek/dart_mappable', classes: 'ml-4 px-5 py-2 bg-blue-50 text-blue-600 rounded-xl font-bold text-sm hover:bg-blue-100 transition-all', [.text('GitHub')]),
          ]),

          const div(classes: 'md:hidden', [
            button(
              classes: 'p-2 rounded-xl text-slate-600 hover:bg-slate-50 transition-colors',
              [.text('☰')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
