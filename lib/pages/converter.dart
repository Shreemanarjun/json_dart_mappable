import 'dart:convert';
import 'package:json_dart_mappable/services/clipboard_service.dart';
import 'package:universal_web/web.dart' as web;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../services/json_to_dart_converter.dart';
import '../services/json_formatter.dart';

// Define kIsWeb locally to avoid dependency on flutter
const bool kIsWeb = bool.fromEnvironment('dart.library.js');

@client
class Converter extends StatefulComponent {
  const Converter({super.key});

  @override
  State<Converter> createState() => ConverterState();
}

class ConverterState extends State<Converter> {
  String _jsonInput = '';
  String _dartOutput = '';
  String _errorMessage = '';
  String _nullabilityMode = 'smart'; // 'none', 'all', 'smart'
  String _mainClassName = 'MyModel';
  bool _isCopyingJson = false;
  bool _isCopyingCode = false;
  bool _alwaysIncludeMappableField = true; // New option for explicit field mapping
  bool _useObjectInsteadOfDynamic = false; // Use Object instead of dynamic for unknown types
  bool _includeDefaultMethods = true; // Include fromMap, fromJson, ensureInitialized methods
  bool _useRequiredConstructor = true; // Use required constructor parameters instead of defaults

  void _onJsonInputChanged(String value) {
    setState(() {
      _jsonInput = value;
      _updateDartOutput();
    });
  }

  void _handlePaste(dynamic event) {
    if (!kIsWeb) return;

    final clipboardEvent = event as web.ClipboardEvent;
    final pastedText = clipboardEvent.clipboardData?.getData('text').trim();

    if (pastedText == null || pastedText.isEmpty) return;

    // Check if the pasted text is valid JSON
    try {
      final jsonData = jsonDecode(pastedText);
      final formatted = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Valid JSON detected - prevent default paste and handle ourselves
      clipboardEvent.preventDefault();

      print('📋 PASTE: Valid JSON detected, formatted length: ${formatted.length}');

      setState(() {
        _jsonInput = formatted;
        _errorMessage = ''; // Clear any previous errors
        _updateDartOutput();
      });

      // Sync the DOM element value
      final element = web.document.getElementById('json-input-editor') as web.HTMLTextAreaElement?;
      if (element != null) {
        element.value = formatted;
        // Set cursor to end of text
        element.setSelectionRange(formatted.length, formatted.length);
      }

      print('📋 PASTE: JSON input updated successfully');
    } catch (e) {
      // Not valid JSON - let default paste behavior happen
      print('📋 PASTE: Not valid JSON, letting default paste behavior');
      // Don't prevent default - let the browser paste normally
    }
  }

  void _updateDartOutput() {
    print('🎨 UI: _updateDartOutput called with className="$_mainClassName", nullabilityMode="$_nullabilityMode"');

    final result = JsonToDartConverter.convertJsonToDart(
      _jsonInput,
      _mainClassName,
      _nullabilityMode,
      alwaysIncludeMappableField: _alwaysIncludeMappableField,
      useObjectInsteadOfDynamic: _useObjectInsteadOfDynamic,
      includeDefaultMethods: _includeDefaultMethods,
      useRequiredConstructor: _useRequiredConstructor,
    );

    print('🎨 UI: Converter returned ${result.code.length} chars of code, error: "${result.error}"');

    setState(() {
      _dartOutput = result.code;
      _errorMessage = result.error;
    });

    print('🎨 UI: State updated. _dartOutput length: ${_dartOutput.length}, _errorMessage: "$_errorMessage"');
  }

  void _runHighlight() {
    if (!kIsWeb) return;
    try {
      print('🎨 UI: Running highlight.js on code blocks');
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
      print('🎨 UI: Highlight error: $e');
    }
  }

  @override
  Component build(BuildContext context) {
    // Initialize highlight.js when component mounts or content changes
    if (kIsWeb && (_dartOutput.isNotEmpty || _jsonInput.isNotEmpty)) {
      Future.delayed(const Duration(milliseconds: 10), _runHighlight);
    }

    return section(classes: 'min-h-screen bg-[#f8fafc] py-8 px-4 sm:px-6 lg:px-8 font-sans', [
      div(classes: 'max-w-7xl mx-auto', [
        // Compact Header Section
        div(classes: 'flex flex-col md:flex-row items-center justify-between mb-8 gap-4', [
          const div(classes: 'flex items-center gap-4', [
            div(classes: 'p-2.5 bg-blue-600 rounded-xl shadow-lg shadow-blue-200', [
              span(classes: 'text-xl text-white font-bold', [.text('{}')]),
            ]),
            div([
              h1(classes: 'text-2xl font-black text-slate-900 tracking-tight', [.text('JSON to Dart')]),
              p(classes: 'text-xs text-slate-500 font-medium', [
                .text('Convert your JSON to type-safe '),
                span(classes: 'text-blue-600 font-bold', [.text('dart_mappable')]),
                .text(' classes.'),
              ]),
            ]),
          ]),
          div(classes: 'flex gap-2', [
            _featureBadge('Real-time', 'bg-emerald-500/5 text-emerald-500 border-emerald-500/10'),
            _featureBadge('Type-Safe', 'bg-blue-500/5 text-blue-500 border-blue-500/10'),
            _featureBadge('Null-Safe', 'bg-indigo-500/5 text-indigo-500 border-indigo-500/10'),
          ]),
        ]),

        // Main Converter Section
        div(classes: 'grid grid-cols-1 lg:grid-cols-2 gap-8 items-start', [
          // Left Column: Input & Config
          div(classes: 'space-y-6', [
            // Config Card
            div(classes: 'bg-white rounded-3xl shadow-sm border border-slate-200 p-6 space-y-6', [
              div(classes: 'flex items-center justify-between', [
                const h2(classes: 'text-lg font-bold text-slate-800 flex items-center gap-2', [span(classes: 'w-1.5 h-5 bg-blue-600 rounded-full', []), .text('Configuration')]),
                div(classes: 'flex gap-2', [
                  button(classes: 'text-xs font-bold text-blue-600 hover:text-blue-700 transition-colors flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 rounded-lg', onClick: _loadExample, const [
                    span(classes: 'text-sm', [.text('💡')]),
                    .text('Simple'),
                  ]),
                  button(classes: 'text-xs font-bold text-orange-600 hover:text-orange-700 transition-colors flex items-center gap-1.5 px-3 py-1.5 bg-orange-50 rounded-lg', onClick: _loadComplexExample, const [
                    span(classes: 'text-sm', [.text('🔄')]),
                    .text('Complex'),
                  ]),
                ]),
              ]),

              div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
                div(classes: 'space-y-1.5', [
                  const label(classes: 'block text-[11px] font-bold text-slate-500 uppercase tracking-wider', [.text('Root Class Name')]),
                  input(
                    classes: 'w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 transition-all outline-none font-semibold text-sm',
                    type: InputType.text,
                    attributes: {'value': _mainClassName},
                    onInput: (value) {
                      setState(() {
                        _mainClassName = value as String? ?? 'MyModel';
                        _updateDartOutput();
                      });
                    },
                  ),
                ]),
                div(classes: 'space-y-1.5', [
                  const label(classes: 'block text-[11px] font-bold text-slate-500 uppercase tracking-wider', [.text('Nullability')]),
                  select(
                    classes: 'w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 transition-all outline-none font-semibold text-sm appearance-none',
                    onChange: (value) {
                      print('🎛️ SELECT: Nullability mode changed, raw value: $value, type: ${value.runtimeType}');
                      final newMode = value.first;
                      print('🎛️ SELECT: Setting nullability mode to: "$newMode"');
                      setState(() {
                        _nullabilityMode = newMode;
                        _updateDartOutput();
                      });
                    },
                    [
                      option(value: 'none', selected: _nullabilityMode == 'none', const [.text('None')]),
                      option(value: 'all', selected: _nullabilityMode == 'all', const [.text('All Nullable')]),
                      option(value: 'smart', selected: _nullabilityMode == 'smart', const [.text('Smart Detection')]),
                    ],
                  ),
                ]),
              ]),
              // Additional Options
              div(classes: 'grid grid-cols-1 gap-4', [
                // MappableField Option
                div(classes: 'space-y-2', [
                  const label(classes: 'block text-[11px] font-bold text-slate-500 uppercase tracking-wider', [.text('Field Mapping')]),
                  div(classes: 'flex items-center gap-3', [
                    input(
                      id: 'mappable-field-checkbox',
                      type: InputType.checkbox,
                      checked: _alwaysIncludeMappableField,
                      onChange: (value) {
                        print('📋 CHECKBOX: Always include MappableField changed to: $value');
                        setState(() {
                          _alwaysIncludeMappableField = value as bool? ?? false;
                          _updateDartOutput();
                        });
                      },
                      classes: 'w-4 h-4 text-blue-600 bg-slate-50 border-slate-200 rounded focus:ring-blue-100 focus:ring-2',
                    ),
                    const label(
                      attributes: {'for': 'mappable-field-checkbox'},
                      classes: 'text-sm font-semibold text-slate-700 cursor-pointer',
                      [.text('Always include @MappableField annotations')],
                    ),
                  ]),
                  const p(classes: 'text-[10px] text-slate-500 leading-tight', [
                    .text('When enabled, all fields will have explicit @MappableField(key: \'...\') annotations for consistency.'),
                  ]),
                ]),

                // Object instead of Dynamic
                div(classes: 'space-y-2', [
                  const label(classes: 'block text-[11px] font-bold text-slate-500 uppercase tracking-wider', [.text('Type Handling')]),
                  div(classes: 'flex items-center gap-3', [
                    input(
                      id: 'object-dynamic-checkbox',
                      type: InputType.checkbox,
                      checked: _useObjectInsteadOfDynamic,
                      onChange: (value) {
                        print('📋 CHECKBOX: Use Object instead of dynamic changed to: $value');
                        setState(() {
                          _useObjectInsteadOfDynamic = value as bool? ?? false;
                          _updateDartOutput();
                        });
                      },
                      classes: 'w-4 h-4 text-blue-600 bg-slate-50 border-slate-200 rounded focus:ring-blue-100 focus:ring-2',
                    ),
                    const label(
                      attributes: {'for': 'object-dynamic-checkbox'},
                      classes: 'text-sm font-semibold text-slate-700 cursor-pointer',
                      [.text('Use Object instead of dynamic')],
                    ),
                  ]),
                  const p(classes: 'text-[10px] text-slate-500 leading-tight', [
                    .text('When enabled, unknown types will use Object instead of dynamic for better type safety.'),
                  ]),
                ]),

                // Include Default Methods
                div(classes: 'flex items-center gap-3', [
                  input(
                    id: 'default-methods-checkbox',
                    type: InputType.checkbox,
                    checked: _includeDefaultMethods,
                    onChange: (value) {
                      print('📋 CHECKBOX: Include default methods changed to: $value');
                      setState(() {
                        _includeDefaultMethods = value as bool? ?? false;
                        _updateDartOutput();
                      });
                    },
                    classes: 'w-4 h-4 text-blue-600 bg-slate-50 border-slate-200 rounded focus:ring-blue-100 focus:ring-2',
                  ),
                  const label(
                    attributes: {'for': 'default-methods-checkbox'},
                    classes: 'text-sm font-semibold text-slate-700 cursor-pointer',
                    [.text('Include default methods (fromMap, fromJson, ensureInitialized)')],
                  ),
                ]),

                // Required Constructor
                div(classes: 'flex items-center gap-3', [
                  input(
                    id: 'required-constructor-checkbox',
                    type: InputType.checkbox,
                    checked: _useRequiredConstructor,
                    onChange: (value) {
                      print('📋 CHECKBOX: Use required constructor changed to: $value');
                      setState(() {
                        _useRequiredConstructor = value as bool? ?? false;
                        _updateDartOutput();
                      });
                    },
                    classes: 'w-4 h-4 text-blue-600 bg-slate-50 border-slate-200 rounded focus:ring-blue-100 focus:ring-2',
                  ),
                  const label(
                    attributes: {'for': 'required-constructor-checkbox'},
                    classes: 'text-sm font-semibold text-slate-700 cursor-pointer',
                    [.text('Use required constructor parameters')],
                  ),
                ]),
              ]),
              // Force Refresh Button
              div(classes: 'flex justify-center pt-2', [
                button(
                  classes: 'px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white text-sm font-bold rounded-lg transition-all shadow-lg shadow-blue-900/20 flex items-center gap-2 active:scale-95',
                  onClick: () {
                    print('🔄 MANUAL: Force refresh triggered');
                    _updateDartOutput();
                  },
                  const [
                    span(classes: 'text-base', [.text('🔄')]),
                    .text('Force Refresh'),
                  ],
                ),
              ]),
            ]),

            // Input Card
            div(classes: 'bg-white rounded-3xl shadow-sm border border-slate-200 overflow-hidden flex flex-col ring-1 ring-slate-200/50', [
              div(classes: 'px-5 py-3 border-b border-slate-100 flex items-center justify-between bg-slate-50/50', [
                const div(classes: 'flex items-center gap-3', [
                  div(classes: 'flex gap-1.5', [
                    div(classes: 'w-2.5 h-2.5 rounded-full bg-slate-200', []),
                    div(classes: 'w-2.5 h-2.5 rounded-full bg-slate-200', []),
                    div(classes: 'w-2.5 h-2.5 rounded-full bg-slate-200', []),
                  ]),
                  h2(classes: 'text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em]', [.text('JSON Input')]),
                ]),
                div(classes: 'flex gap-1', [
                  _iconButtonDark('✨', 'Format', _formatJson),
                  _iconButtonDark('🔥', 'Minify', _minifyJson),
                  _iconButtonDark('🗑️', 'Clear', () => _onJsonInputChanged('')),
                ]),
              ]),
              div(classes: 'relative bg-white', [
                textarea(
                  id: 'json-input-editor',
                  classes: 'w-full p-6 font-mono text-sm bg-white text-slate-800 h-[300px] overflow-auto resize-none outline-none focus:ring-0 placeholder:text-slate-300 border-none',
                  attributes: {
                    'value': _jsonInput,
                    'spellcheck': 'false',
                    'aria-label': 'JSON Input',
                  },
                  onInput: _onJsonInputChanged,
                  events: {'paste': _handlePaste},
                  placeholder: 'Paste your JSON here...',
                  const [],
                ),
                if (_errorMessage.isNotEmpty)
                  div(classes: 'absolute bottom-0 left-0 right-0 p-3 bg-red-50 border-t border-red-100 flex items-center gap-2 text-red-700 text-[11px] font-bold z-20', [
                    const span(classes: 'text-sm', [.text('⚠️')]),
                    .text(_errorMessage),
                  ]),
              ]),
            ]),

            const hr(classes: 'border-slate-100'),

            // Preview Card
            if (_jsonInput.isNotEmpty && _errorMessage.isEmpty)
              div(classes: 'bg-[#0f172a] rounded-3xl shadow-xl border border-slate-800 overflow-hidden flex flex-col ring-1 ring-slate-700/50 min-h-[200px]', [
                div(classes: 'px-5 py-3 border-b border-slate-800/50 flex items-center justify-between bg-slate-900/90 backdrop-blur-md', [
                  const div(classes: 'flex items-center gap-4', [
                    div(classes: 'flex gap-1.5', [
                      div(classes: 'w-2.5 h-2.5 rounded-full bg-[#ff5f56] shadow-sm shadow-red-900/20', []),
                      div(classes: 'w-2.5 h-2.5 rounded-full bg-[#ffbd2e] shadow-sm shadow-amber-900/20', []),
                      div(classes: 'w-2.5 h-2.5 rounded-full bg-[#27c93f] shadow-sm shadow-emerald-900/20', []),
                    ]),
                    div(classes: 'h-3 w-[1px] bg-slate-800 mx-1', []),
                    h2(classes: 'text-[10px] font-bold text-slate-500 font-mono uppercase tracking-[0.2em]', [.text('preview.json')]),
                    div(classes: 'flex items-center gap-1.5 px-2 py-0.5 bg-blue-500/10 border border-blue-500/20 rounded-md', [
                      span(classes: 'w-1 h-1 rounded-full bg-blue-500 animate-pulse', []),
                      span(classes: 'text-[9px] text-blue-400 uppercase tracking-tighter font-bold', [.text('Live')]),
                    ]),
                  ]),
                  button(
                    classes: 'text-[10px] font-bold ${_isCopyingJson ? 'text-emerald-400' : 'text-slate-500 hover:text-blue-400'} transition-all uppercase tracking-widest flex items-center gap-1.5 px-3 py-1.5 hover:bg-slate-800 rounded-lg active:scale-95',
                    onClick: () => _copyToClipboard(_jsonInput, 'json'),
                    [
                      if (_isCopyingJson) const span(classes: 'text-xs', [.text('✅')]),
                      .text(_isCopyingJson ? 'Copied' : 'Copy JSON'),
                    ],
                  ),
                ]),
                div(classes: 'relative flex-1 overflow-auto max-h-[400px] bg-[#0f172a]', [
                  pre(classes: 'm-0 p-6 border-none bg-transparent font-mono text-[13px] leading-[1.6] whitespace-pre-wrap break-all overflow-x-hidden', [
                    code(classes: 'hljs language-json block !bg-transparent !p-0 !m-0 font-mono text-[13px] leading-[1.6] text-slate-300', [.text(_jsonInput)]),
                  ]),
                ]),
              ]),
          ]),

          // Right Column: Output
          div(classes: 'bg-[#0f172a] rounded-3xl shadow-2xl border border-slate-800 overflow-hidden flex flex-col sticky top-8', [
            div(classes: 'px-6 py-4 border-b border-slate-800 flex items-center justify-between bg-slate-900/50', [
              div(classes: 'flex items-center gap-3', [
                const div(classes: 'flex gap-1.5', [
                  div(classes: 'w-2.5 h-2.5 rounded-full bg-[#ff5f56]', []),
                  div(classes: 'w-2.5 h-2.5 rounded-full bg-[#ffbd2e]', []),
                  div(classes: 'w-2.5 h-2.5 rounded-full bg-[#27c93f]', []),
                ]),
                span(classes: 'ml-2 text-[11px] font-bold text-slate-500 font-mono uppercase tracking-widest', [.text('${_mainClassName.toLowerCase()}.dart')]),
              ]),
              if (_dartOutput.isNotEmpty)
                div(classes: 'flex gap-2', [
                  button(classes: 'px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-bold rounded-lg transition-all border border-slate-700 flex items-center gap-1.5 active:scale-95', onClick: _downloadCode, const [
                    span(classes: 'text-sm', [.text('📥')]),
                    .text('Save'),
                  ]),
                  button(
                    classes: 'px-4 py-1.5 ${_isCopyingCode ? 'bg-emerald-600' : 'bg-blue-600 hover:bg-blue-500'} text-white text-[11px] font-bold rounded-lg transition-all shadow-lg shadow-blue-900/20 flex items-center gap-1.5 active:scale-95',
                    onClick: () => _copyToClipboard(_dartOutput, 'code'),
                    [
                      span(classes: 'text-sm', [.text(_isCopyingCode ? '✅' : '📋')]),
                      .text(_isCopyingCode ? 'Copied!' : 'Copy Code'),
                    ],
                  ),
                ]),
            ]),
            div(classes: 'relative flex-1 group overflow-auto max-h-[700px]', [
              pre(classes: 'm-0 p-8 bg-transparent font-mono text-[13px] leading-relaxed whitespace-pre overflow-visible', [
                code(
                  classes: 'hljs language-dart block !bg-transparent !p-0 !m-0 whitespace-pre text-slate-300',
                  key: ValueKey('dart-code-${_dartOutput.hashCode}'), // Force re-render on content change
                  [
                    .text(_dartOutput.isEmpty ? '// Your generated Dart classes will appear here...\n// Try pasting some JSON on the left!' : _dartOutput),
                  ],
                ),
              ]),
              if (_dartOutput.isNotEmpty)
                const div(classes: 'absolute bottom-6 right-6 opacity-0 group-hover:opacity-100 transition-opacity', [
                  div(classes: 'px-3 py-1.5 bg-slate-800/80 backdrop-blur text-slate-400 rounded-lg text-[10px] font-bold border border-slate-700', [.text('Dart Mappable v4.2.2')]),
                ]),
            ]),
          ]),
        ]),

        // Footer
        const div(classes: 'text-center mt-16 space-y-3', [
          p(classes: 'text-slate-400 text-[11px] font-bold uppercase tracking-[0.2em]', [.text('Powered by Jaspr & Tailwind')]),
          div(classes: 'flex justify-center gap-6', [
            a(classes: 'text-slate-400 hover:text-blue-600 transition-colors text-[11px] font-bold', href: 'https://pub.dev/packages/dart_mappable', [.text('Docs')]),
            a(classes: 'text-slate-400 hover:text-blue-600 transition-colors text-[11px] font-bold', href: 'https://github.com/schultek/dart_mappable', [.text('GitHub')]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _featureBadge(String label, String colorClass) {
    return div(classes: 'px-2.5 py-1 rounded-lg text-[10px] font-bold border $colorClass uppercase tracking-wider', [.text(label)]);
  }

  Component _iconButtonDark(String icon, String label, void Function() onPressed) {
    return button(
      classes: 'p-1.5 hover:bg-slate-100 rounded-lg transition-colors group relative outline-none',
      onClick: onPressed,
      attributes: {
        'title': label,
        'aria-label': label,
      },
      [
        span(classes: 'text-base', [.text(icon)]),
        // Tooltip
        span(classes: 'absolute top-full left-1/2 -translate-x-1/2 mt-2 px-2 py-1 bg-slate-900 text-white text-[9px] rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none z-50 shadow-xl border border-slate-700', [
          .text(label),
        ]),
      ],
    );
  }

  void _loadExample() {
    const example = {
      "id": 1,
      "name": "Leanne Graham",
      "username": "Bret",
      "email": "Sincere@april.biz",
      "address": {
        "street": "Kulas Light",
        "suite": "Apt. 556",
        "city": "Gwenborough",
        "zipcode": "92998-3874",
        "geo": {"lat": "-37.3159", "lng": "81.1496"},
      },
      "phone": "1-770-736-8031 x56442",
      "website": "hildegard.org",
      "company": {"name": "Romaguera-Crona", "catchPhrase": "Multi-layered client-server neural-net", "bs": "harness real-time e-markets"},
      "tags": ["developer", "premium", "fast"],
      "is_active": true,
      "metadata": null,
    };
    _onJsonInputChanged(const JsonEncoder.withIndent('  ').convert(example));
  }

  void _loadComplexExample() {
    const complexExample = {
      "data": [
        {"age": "12"},
        {"name": "", "age": ""},
        {"name": null, "age": ""},
      ],
    };
    _onJsonInputChanged(const JsonEncoder.withIndent('  ').convert(complexExample));
  }

  Future<void> _copyToClipboard(String text, String type) async {
    if (text.isEmpty || !kIsWeb) return;

    final success = await ClipboardService.copyToClipboard(text);

    if (success) {
      if (type == 'json') {
        setState(() => _isCopyingJson = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isCopyingJson = false);
        });
      } else {
        setState(() => _isCopyingCode = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isCopyingCode = false);
        });
      }
    }
  }

  void _downloadCode() {
    if (_dartOutput.isEmpty || !kIsWeb) return;

    final fileName = '${_mainClassName.toLowerCase()}.dart';
    ClipboardService.downloadAsFile(_dartOutput, fileName);
  }

  void _formatJson() {
    if (_jsonInput.trim().isEmpty) return;

    final result = JsonFormatter.formatJson(_jsonInput);
    if (result.isSuccess) {
      setState(() {
        _jsonInput = result.result;
        _updateDartOutput();
      });
    } else {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  void _minifyJson() {
    if (_jsonInput.trim().isEmpty) return;

    final result = JsonFormatter.minifyJson(_jsonInput);
    if (result.isSuccess) {
      setState(() {
        _jsonInput = result.result;
        _updateDartOutput();
      });
    } else {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }
}
