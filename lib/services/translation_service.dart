import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Simple wrapper calling Anthropic's text-completion endpoint.
  // This implementation sends a translation instruction and expects
  // a JSON object in the assistant's reply containing an array
  // `translations` corresponding to the input texts.

  static const _endpoint = 'https://api.anthropic.com/v1/complete';

  /// Translate [texts] to Urdu using Anthropic. Returns list of translations
  /// in the same order. Throws on network or parsing errors.
  static Future<List<String>> translateToUrdu({
    required String apiKey,
    required List<String> texts,
    String model = 'claude-2',
  }) async {
    if (apiKey.isEmpty || apiKey.contains('REPLACE')) {
      throw StateError('Anthropic API key not configured');
    }

    final promptBuffer = StringBuffer();
    promptBuffer.writeln('Translate the following English texts into Urdu.');
    promptBuffer.writeln(
      'Return ONLY a JSON object with a single key `translations`',
    );
    promptBuffer.writeln(
      'whose value is an array of translated strings in the same order.',
    );
    promptBuffer.writeln('Do not add any commentary or extra text.');
    promptBuffer.writeln('\nTexts:');
    for (var i = 0; i < texts.length; i++) {
      promptBuffer.writeln('${i + 1}. ${texts[i]}');
    }

    final body = {
      'model': model,
      'prompt': promptBuffer.toString(),
      'max_tokens': 2000,
      'temperature': 0.0,
      'stop': null,
    };

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json', 'X-Api-Key': apiKey},
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Anthropic API error: ${res.statusCode} ${res.body}');
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    // Anthropic responses place the assistant text under `completion` or
    // `completion`/`text` depending on API shape; be tolerant.
    final text =
        (json['completion'] ?? json['response'] ?? json['text'])?.toString() ??
        '';

    // Attempt to extract JSON object from the assistant text.
    final decoded = _extractJsonFromString(text);
    if (decoded == null || decoded['translations'] == null) {
      throw Exception('Failed to parse Anthropic response: $text');
    }

    final translations = (decoded['translations'] as List)
        .map((e) => e.toString())
        .toList();
    return translations;
  }

  static Map<String, dynamic>? _extractJsonFromString(String s) {
    // Find first '{' and last '}' and try to decode.
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    try {
      return jsonDecode(s.substring(start, end + 1)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
