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
      jsonString: _jsonInput,
      className: _mainClassName,
      nullabilityMode: _nullabilityMode,
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

    return div(classes: 'relative min-h-screen overflow-hidden bg-slate-50 font-sans', [
      // Decorative Background Elements (Shared with Home)
      const div(classes: 'absolute top-0 left-1/2 -translate-x-1/2 w-full h-full overflow-hidden pointer-events-none z-0', [
        div(classes: 'absolute -top-[10%] -left-[10%] w-[40%] h-[40%] bg-blue-400/10 rounded-full blur-[120px] animate-pulse', []),
        div(classes: 'absolute top-[20%] -right-[10%] w-[35%] h-[35%] bg-purple-400/10 rounded-full blur-[120px]', []),
        div(classes: 'absolute bottom-[10%] left-[20%] w-[30%] h-[30%] bg-indigo-400/5 rounded-full blur-[100px]', []),
      ]),

      div(classes: 'relative z-10 py-12 px-4 sm:px-6 lg:px-12', [
        div(classes: 'max-w-[1600px] mx-auto', [
          // Elegant Header Section
          div(classes: 'flex flex-col md:flex-row items-center justify-between mb-12 gap-8', [
            const div(classes: 'flex items-center gap-5', [
              div(classes: 'w-14 h-14 bg-gradient-to-br from-blue-600 to-indigo-700 rounded-2xl shadow-xl shadow-blue-500/20 flex items-center justify-center transform hover:rotate-6 transition-transform', [
                span(classes: 'text-2xl text-white font-black', [.text('{}')]),
              ]),
              div([
                h1(classes: 'text-3xl font-black text-slate-900 tracking-tight leading-none mb-2', [.text('JSON to Dart')]),
                p(classes: 'text-sm text-slate-500 font-medium flex items-center gap-2', [
                  .text('Production-ready models for'),
                  span(classes: 'px-2 py-0.5 bg-blue-50 text-blue-600 rounded-md text-[10px] font-bold uppercase tracking-wider border border-blue-100', [.text('dart_mappable')]),
                ]),
              ]),
            ]),
            div(classes: 'flex items-center gap-3 bg-white/50 backdrop-blur-sm p-1.5 rounded-2xl border border-slate-200/60 shadow-sm', [
              _featureBadge('Real-time', 'bg-emerald-50 text-emerald-600 border-emerald-100'),
              _featureBadge('Type-Safe', 'bg-blue-50 text-blue-600 border-blue-100'),
              _featureBadge('Null-Safe', 'bg-indigo-50 text-indigo-600 border-indigo-100'),
            ]),
          ]),

          // Main Converter Section
          div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-8 items-start', [
            // Left Column: Configuration & Input (5 cols)
            div(classes: 'lg:col-span-5 space-y-8', [
              // Configuration Bento-style Group
              div(classes: 'bg-white/70 backdrop-blur-md rounded-[2rem] shadow-sm border border-slate-200/60 p-8 space-y-8 hover:shadow-md transition-shadow', [
                div(classes: 'flex items-center justify-between', [
                  const h2(classes: 'text-xl font-bold text-slate-900 flex items-center gap-3', [div(classes: 'w-2 h-6 bg-blue-600 rounded-full', []), .text('Configuration')]),
                  div(classes: 'flex gap-2', [
                    button(classes: 'text-xs font-bold text-blue-600 hover:text-blue-700 transition-all flex items-center gap-2 px-4 py-2 bg-blue-50/50 hover:bg-blue-50 rounded-xl border border-blue-100', onClick: _loadExample, const [
                      .text('Simple'),
                    ]),
                    button(classes: 'text-xs font-bold text-orange-600 hover:text-orange-700 transition-all flex items-center gap-2 px-4 py-2 bg-orange-50/50 hover:bg-orange-50 rounded-xl border border-orange-100', onClick: _loadComplexExample, const [
                      .text('Complex'),
                    ]),
                  ]),
                ]),

                div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
                  div(classes: 'space-y-2', [
                    const label(classes: 'block text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]', [.text('Root Class Name')]),
                    input(
                      classes: 'w-full px-5 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 transition-all outline-none font-bold text-sm text-slate-800 shadow-inner-sm',
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
                  div(classes: 'space-y-2', [
                    const label(classes: 'block text-[10px] font-black text-slate-400 uppercase tracking-[0.1em]', [.text('Nullability Policy')]),
                    div(classes: 'relative', [
                      select(
                        classes: 'w-full px-5 py-3 bg-white border border-slate-200 rounded-2xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 transition-all outline-none font-bold text-sm text-slate-800 appearance-none cursor-pointer',
                        onChange: (value) {
                          final newMode = value.first;
                          setState(() {
                            _nullabilityMode = newMode;
                            _updateDartOutput();
                          });
                        },
                        [
                          option(value: 'none', selected: _nullabilityMode == 'none', const [.text('Static - No Nulls')]),
                          option(value: 'all', selected: _nullabilityMode == 'all', const [.text('Relaxed - All Nullable')]),
                          option(value: 'smart', selected: _nullabilityMode == 'smart', const [.text('Intelligent Sensing')]),
                        ],
                      ),
                      const div(classes: 'absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400', [.text('↓')]),
                    ]),
                  ]),
                ]),

                // Advanced Options Grid
                div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-y-6 gap-x-12 pt-4 border-t border-slate-100', [
                  _modernToggle(
                    'Explicit Mapping',
                    'Always include @MappableField annotations',
                    _alwaysIncludeMappableField,
                    (v) => setState(() {
                      _alwaysIncludeMappableField = v;
                      _updateDartOutput();
                    }),
                  ),
                  _modernToggle(
                    'Strict Types',
                    'Use Object instead of dynamic for unknown types',
                    _useObjectInsteadOfDynamic,
                    (v) => setState(() {
                      _useObjectInsteadOfDynamic = v;
                      _updateDartOutput();
                    }),
                  ),
                  _modernToggle(
                    'Standard Methods',
                    'Include fromMap, fromJson, etc.',
                    _includeDefaultMethods,
                    (v) => setState(() {
                      _includeDefaultMethods = v;
                      _updateDartOutput();
                    }),
                  ),
                  _modernToggle(
                    'Safety First',
                    'Use required constructor parameters',
                    _useRequiredConstructor,
                    (v) => setState(() {
                      _useRequiredConstructor = v;
                      _updateDartOutput();
                    }),
                  ),
                ]),
              ]),

              // Input Card
              div(classes: 'bg-white rounded-[2rem] shadow-sm border border-slate-200/60 overflow-hidden flex flex-col hover:shadow-md transition-shadow', [
                div(classes: 'px-8 py-5 border-b border-slate-100 flex items-center justify-between bg-slate-50/30', [
                  const h2(classes: 'text-[11px] font-black text-slate-400 uppercase tracking-[0.2em]', [.text('Source JSON')]),
                  div(classes: 'flex gap-2', [
                    _modernIconButton('✨', 'Format Code', _formatJson),
                    _modernIconButton('🔥', 'Compact', _minifyJson),
                    _modernIconButton('🗑️', 'Clear All', () => _onJsonInputChanged('')),
                  ]),
                ]),
                div(classes: 'relative bg-white group', [
                  textarea(
                    id: 'json-input-editor',
                    classes: 'w-full p-8 font-mono text-[13px] leading-relaxed bg-white text-slate-800 h-[400px] overflow-auto resize-none outline-none focus:ring-0 placeholder:text-slate-200 border-none transition-all',
                    attributes: {
                      'value': _jsonInput,
                      'spellcheck': 'false',
                      'aria-label': 'JSON Input',
                    },
                    onInput: _onJsonInputChanged,
                    events: {'paste': _handlePaste},
                    placeholder: 'Paste your JSON data here...',
                    const [],
                  ),
                  if (_errorMessage.isNotEmpty)
                    div(classes: 'absolute bottom-4 left-4 right-4 p-4 bg-red-50/90 backdrop-blur-sm border border-red-100 rounded-2xl flex items-center gap-3 text-red-700 text-xs font-bold animate-in fade-in slide-in-from-bottom-2', [
                      const span(classes: 'w-6 h-6 bg-red-100 rounded-full flex items-center justify-center text-red-600', [.text('!')]),
                      .text(_errorMessage),
                    ]),
                ]),
              ]),
            ]),

            // Right Column: Output (7 cols)
            div(classes: 'lg:col-span-7 flex flex-col h-full', [
              div(classes: 'bg-slate-900 rounded-[2.5rem] shadow-2xl border border-slate-800 overflow-hidden flex flex-col sticky top-12 max-h-[calc(100vh-6rem)]', [
                // Window Header
                div(classes: 'px-8 py-5 border-b border-slate-800 flex items-center justify-between bg-slate-900/80 backdrop-blur-md', [
                  div(classes: 'flex items-center gap-4', [
                    const div(classes: 'flex gap-2', [
                      div(classes: 'w-3 h-3 rounded-full bg-red-400/20 border border-red-400/40', []),
                      div(classes: 'w-3 h-3 rounded-full bg-amber-400/20 border border-amber-400/40', []),
                      div(classes: 'w-3 h-3 rounded-full bg-emerald-400/20 border border-emerald-400/40', []),
                    ]),
                    span(classes: 'ml-2 text-[10px] font-black text-slate-500 font-mono uppercase tracking-[0.2em]', [.text('${_mainClassName.toLowerCase()}.dart')]),
                  ]),
                  if (_dartOutput.isNotEmpty)
                    div(classes: 'flex gap-3', [
                      button(
                        classes: 'px-5 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-black rounded-xl transition-all border border-slate-700 flex items-center gap-2 active:scale-95 shadow-lg',
                        onClick: _downloadCode,
                        const [
                          span(classes: 'text-sm', [.text('📥')]),
                          .text('Download'),
                        ],
                      ),
                      button(
                        classes: 'group px-5 py-2 ${_isCopyingCode ? 'bg-emerald-500' : 'bg-blue-600 hover:bg-blue-500'} text-white text-xs font-black rounded-xl transition-all shadow-lg shadow-blue-900/40 flex items-center gap-2 active:scale-95',
                        onClick: () => _copyToClipboard(_dartOutput, 'code'),
                        [
                          span(classes: 'text-sm group-hover:scale-110 transition-transform', [.text(_isCopyingCode ? '✓' : '📋')]),
                          .text(_isCopyingCode ? 'Copied' : 'Copy'),
                        ],
                      ),
                    ]),
                ]),

                // Code Content
                div(classes: 'relative flex-1 group overflow-auto custom-scrollbar', [
                  pre(classes: 'm-0 p-8 bg-transparent font-mono text-[13px] leading-[1.7] whitespace-pre overflow-visible', [
                    code(
                      classes: 'hljs language-dart block !bg-transparent !p-0 !m-0 whitespace-pre text-slate-300',
                      key: ValueKey('dart-code-${_dartOutput.hashCode}'),
                      [
                        .text(_dartOutput.isEmpty ? '// Your generated Dart classes will appear here...\n// Paste some JSON to see the magic!' : _dartOutput),
                      ],
                    ),
                  ]),

                  // Float Button Bar
                  if (_dartOutput.isNotEmpty)
                    div(classes: 'absolute bottom-8 right-8 flex gap-2 translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-300', [
                      button(
                        onClick: _downloadCode,
                        classes: 'px-4 py-2 bg-slate-800/80 backdrop-blur-md border border-slate-700 text-slate-300 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-slate-700 transition-colors shadow-xl',
                        const [
                          .text('Download .dart'),
                        ],
                      ),
                    ]),
                ]),

                // Status Bar
                const div(classes: 'px-8 py-3 bg-slate-950/50 border-t border-slate-800 flex justify-between items-center', [
                  div(classes: 'flex items-center gap-2', [
                    div(classes: 'w-1.5 h-1.5 rounded-full bg-blue-500', []),
                    span(classes: 'text-[9px] font-black text-slate-600 uppercase tracking-widest', [.text('Output Ready')]),
                  ]),
                  span(classes: 'text-[9px] font-black text-slate-600 uppercase tracking-widest', [.text('Mappable v4.2.2')]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _modernToggle(String title, String description, bool value, void Function(bool) onChanged) {
    return div(classes: 'flex items-start gap-4 group cursor-pointer', [
      div(classes: 'flex-1', [
        h3(classes: 'text-sm font-bold text-slate-800 mb-0.5 group-hover:text-blue-600 transition-colors', [.text(title)]),
        p(classes: 'text-[11px] text-slate-500 leading-tight', [.text(description)]),
      ]),
      label(classes: 'relative inline-flex items-center cursor-pointer mt-1', [
        input(
          type: InputType.checkbox,
          checked: value,
          onChange: (v) => onChanged(v as bool? ?? false),
          classes: 'sr-only peer',
        ),
        const div(
          classes:
              'w-10 h-5 bg-slate-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[""] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-blue-600',
          [],
        ),
      ]),
    ]);
  }

  Component _modernIconButton(String icon, String label, void Function() onPressed) {
    return button(
      classes: 'w-9 h-9 flex items-center justify-center bg-white border border-slate-200 rounded-xl text-slate-600 hover:text-blue-600 hover:border-blue-200 hover:shadow-lg hover:shadow-blue-500/10 transition-all active:scale-90',
      onClick: onPressed,
      attributes: {'title': label},
      [
        span(classes: 'text-sm', [.text(icon)]),
      ],
    );
  }

  Component _featureBadge(String label, String colorClass) {
    return div(classes: 'px-2.5 py-1 rounded-lg text-[10px] font-bold border $colorClass uppercase tracking-wider', [.text(label)]);
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
        // Handled elsewhere if needed, or simply skipped
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
