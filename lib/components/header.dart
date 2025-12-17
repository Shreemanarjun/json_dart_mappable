import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../constants/theme.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = context.url;

    return header(classes: 'bg-white border-b border-gray-200 shadow-sm', [
      div(classes: 'max-w-7xl mx-auto px-4', [
        div(classes: 'flex justify-between items-center h-16', [
          // Logo/Brand
          const Link(to: '/', classes: 'flex items-center space-x-2', child: div(classes: 'flex items-center space-x-2', [
            div(classes: 'w-8 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center', [
              span(classes: 'text-white font-bold text-sm', [.text('{}')]),
            ]),
            span(classes: 'text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent', [.text('JSON Converter')]),
          ])),

          // Navigation
          nav(classes: 'flex space-x-1', [
            for (var route in [
              (label: 'Home', path: '/'),
              (label: 'Converter', path: '/converter'),
            ])
              Link(
                to: route.path,
                classes: 'px-4 py-2 rounded-lg font-medium transition-all duration-200 ${
                  activePath == route.path
                    ? 'bg-blue-100 text-blue-700 shadow-sm'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                }',
                child: .text(route.label),
              ),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('header', [
      css('&').styles(
        display: .flex,
        padding: .all(1.em),
        justifyContent: .center,
      ),
      css('nav', [
        css('&').styles(
          display: .flex,
          height: 3.em,
          radius: .all(.circular(10.px)),
          overflow: .clip,
          justifyContent: .spaceBetween,
          backgroundColor: primaryColor,
        ),
        css('a', [
          css('&').styles(
            display: .flex,
            height: 100.percent,
            padding: .symmetric(horizontal: 2.em),
            alignItems: .center,
            color: Colors.white,
            fontWeight: .w700,
            textDecoration: const TextDecoration(line: .none),
          ),
          css('&:hover').styles(
            backgroundColor: const Color('#0005'),
          ),
        ]),
        css('div.active', [
          css('&').styles(position: const .relative()),
          css('&::before').styles(
            content: '',
            display: .block,
            position: .absolute(bottom: 0.5.em, left: 20.px, right: 20.px),
            height: 2.px,
            radius: .circular(1.px),
            backgroundColor: Colors.white,
          ),
        ])
      ]),
    ]),
  ];
}
