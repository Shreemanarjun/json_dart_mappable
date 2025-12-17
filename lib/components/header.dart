import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    final activePath = context.url;

    return header(classes: 'bg-white/80 backdrop-blur-md border-b border-slate-200/60 shadow-sm sticky top-0 z-50', [
      div(classes: 'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8', [
        div(classes: 'flex justify-between items-center h-16', [
          // Logo/Brand
          const Link(
            to: '/',
            classes: 'flex items-center space-x-3 group transition-all duration-200',
            child: div(classes: 'flex items-center space-x-3', [
              div(classes: 'w-9 h-9 bg-gradient-to-br from-blue-600 via-purple-600 to-indigo-700 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/25 group-hover:shadow-blue-500/40 transition-all duration-200', [
                span(classes: 'text-white font-black text-lg transform group-hover:scale-110 transition-transform duration-200', [.text('{')]),
                span(classes: 'text-white font-black text-lg transform group-hover:scale-110 transition-transform duration-200 delay-75', [
                  .text('}'),
                ]),
              ]),
              div([
                h1(classes: 'text-xl font-black bg-gradient-to-r from-slate-900 via-blue-800 to-purple-800 bg-clip-text text-transparent', [.text('JSON')]),
                p(classes: 'text-xs font-semibold text-slate-500 uppercase tracking-widest leading-tight', [.text('Dart Converter')]),
              ]),
            ]),
          ),

          // Navigation
          nav(classes: 'hidden md:flex items-center space-x-1', [
            for (final route in [
              (label: 'Home', path: '/', icon: '🏠'),
              (label: 'Converter', path: '/converter', icon: '⚡'),
            ])
              Link(
                to: route.path,
                classes:
                    'relative px-4 py-2.5 rounded-xl font-semibold text-sm transition-all duration-200 group ${activePath == route.path ? 'bg-gradient-to-r from-blue-50 to-purple-50 text-blue-700 shadow-sm border border-blue-200/50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'}',
                child: div(classes: 'flex items-center space-x-2', [
                  span(classes: 'text-base', [.text(route.icon)]),
                  span(classes: 'transition-colors duration-200', [.text(route.label)]),
                  ...(activePath == route.path ? [const div(classes: 'absolute -bottom-px left-1/2 transform -translate-x-1/2 w-6 h-0.5 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full', [])] : []),
                ]),
              ),
          ]),

          // Mobile menu button (placeholder for future mobile menu)
          div(classes: 'md:hidden', [
            button(
              classes: 'p-2 rounded-lg text-slate-600 hover:text-slate-900 hover:bg-slate-50 transition-colors',
              attributes: const {'aria-label': 'Menu'},
              onClick: () {
                // TODO: Implement mobile menu
              },
              const [
                span(classes: 'text-lg', [.text('☰')]),
              ],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
