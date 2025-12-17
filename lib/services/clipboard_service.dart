import '../pages/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// Service for clipboard operations
class ClipboardService {
  // Define kIsWeb locally to avoid dependency on flutter
  static const bool kIsWeb = bool.fromEnvironment('dart.library.js');

  /// Copies text to clipboard
  static Future<bool> copyToClipboard(String text) async {
    if (text.isEmpty || !kIsWeb) return false;

    try {
      web.window.navigator.clipboard.writeText(text);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Downloads text as a file
  static bool downloadAsFile(String text, String fileName) {
    if (text.isEmpty || !kIsWeb) return false;

    try {
      final blob = web.Blob([text.toJS].toJS, web.BlobPropertyBag(type: 'text/plain'));
      final url = web.URL.createObjectURL(blob);
      final a = web.document.createElement('a') as web.HTMLAnchorElement;
      a.href = url;
      a.download = fileName;
      web.document.body!.appendChild(a);
      a.click();
      web.URL.revokeObjectURL(url);
      web.document.body!.removeChild(a);
      return true;
    } catch (e) {
      return false;
    }
  }
}
