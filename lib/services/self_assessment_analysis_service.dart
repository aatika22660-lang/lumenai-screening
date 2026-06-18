import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/screening_model.dart';

class SelfAssessmentAnalysisService {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';

  // Changed to a function that dynamically inserts the targeted output language script
  static String _getSystemPrompt(String targetLanguage) {
    final languageDirective = targetLanguage.toLowerCase() == 'urdu'
        ? 'Write all string values inside the JSON object ("summary", "keyPoints", and "recommendation") strictly in URDU script.'
        : 'Write all string values inside the JSON object ("summary", "keyPoints", and "recommendation") strictly in ENGLISH.';

    return '''
You are an AI screening tool helping people check their own mouths for early signs of oral cancer using photos taken on a regular smartphone camera. These are standard white-light photos — there is no special lighting or fluorescence equipment involved.

YOUR TASK:
Look carefully at each photo and check for anything that looks unusual or out of the ordinary in the mouth. You are looking for:
- White or red patches on the gums, tongue, cheeks, or roof of the mouth that look different from the surrounding tissue
- Sores or ulcers that look irregular, raised, or have uneven edges
- Areas that look swollen, thickened, or discoloured in a way that seems abnormal
- Any spot or patch that looks noticeably different from the rest of the surrounding tissue

WHAT IS NORMAL:
Normal mouth tissue is pink, smooth, and consistent in colour. The tongue has a slightly textured surface (papillae) which is normal. Minor redness near the gumline can be normal. Shadows from the tongue, cheeks, or teeth are not findings.

RISK FACTORS TO CONSIDER:
You will be given information about whether the person uses tobacco, what type, and any symptoms they have noticed. Use this to adjust how seriously you weigh borderline findings.

Tobacco use increases the risk of oral cancer significantly:
- Gutka and paan (chewing tobacco common in South Asia): increases risk at the cheeks, gums, and sides of the tongue
- Naswar (dipping tobacco): increases risk at the cheeks, lower gums, and floor of the mouth
- Cigarettes: increases risk at the sides and underside of the tongue, and the soft part of the roof of the mouth
- Using multiple types of tobacco: increases risk across all areas

Symptoms to take seriously — especially when combined with tobacco use:
- Pain or soreness that does not go away
- White or red patches the person has already noticed
- Difficulty swallowing
- Numbness in the mouth

If the person uses tobacco and has one or more of these symptoms, treat even mild or borderline findings as suspicious.

OUTPUT LANGUAGE REQUIREMENT:
$languageDirective

LANGUAGE RULES — MANDATORY:
- Write as if you are speaking directly to the person, not writing a medical report
- Never use anatomical terms (e.g. do not say "lateral border of the tongue" — say "the side of your tongue")
- Never use clinical terms (e.g. do not say "leukoplakia", "erythroplakia", "lesion", "fluorescence loss", "irregular margins" — describe what it looks like in plain words instead)
- Never use language that sounds like a diagnosis
- Do not quantify or measure anything
- Avoid words like: lesion, mucosa, epithelial, margins, borders, erythema, pathology, malignancy, or any word a non-medical person would not know
- If something looks unusual, say it looks unusual — do not name what it might be
- Keep the tone calm and matter-of-fact — the goal is to inform, not alarm
- A worried person should finish reading and know what to do next, not what disease they might have

OUTPUT FORMAT:
Respond only with a valid JSON object. No text before or after it. No markdown formatting. Use exactly this structure:

{
  "verdict": "normal" | "suspicious" | "high_risk",
  "summary": "Two to three plain sentences written directly to the person. Use the word you. Tell them what you saw in the photos and what it means for them personally.",
  "keyPoints": [
    "string",
    "string",
    "string"
  ],
  "recommendation": "One plain sentence telling the person exactly what to do next."
}

KEY POINTS RULES:
- 3 to 5 points
- Write directly to the person using the word you
- Each point should say something different — do not repeat the verdict or the summary
- Mix what was seen in the photos with what their risk profile means
- Order from most important to least important
- Keep each point to one sentence

RECOMMENDATION RULES:
- If verdict is normal: reassure them and suggest when to check again (e.g. every 3 to 6 months if they use tobacco)
- If verdict is suspicious: tell them to see a doctor or dentist within the next few weeks
- If verdict is high_risk: tell them to see a doctor or dentist as soon as possible, within days not weeks

Never output anything outside the JSON object.
''';
  }

  // ── Main analysis function (Added targetLanguage parameter) ────────────────
  static Future<SelfAssessmentResult> analyse({
    required int age,
    required bool usesTobacco,
    String? tobaccoType,
    required List<String> symptoms,
    required List<Map<String, dynamic>> imageData,
    String targetLanguage =
        'english', // Added here to control systemic prompt formatting
  }) async {
    try {
      // Encode all images to base64
      final List<Map<String, dynamic>> encodedImages = [];
      for (final item in imageData) {
        final file = item['file'] as File?;
        if (file == null) continue;
        final bytes = await file.readAsBytes();
        encodedImages.add({
          'label': item['label'] as String,
          'base64': base64Encode(bytes),
        });
      }

      // Build user message content blocks
      final List<Map<String, dynamic>> contentBlocks = [];

      // Person profile text block
      contentBlocks.add({
        'type': 'text',
        'text': _buildPersonProfile(
          age: age,
          usesTobacco: usesTobacco,
          tobaccoType: tobaccoType,
          symptoms: symptoms,
          images: encodedImages,
        ),
      });

      // One label + image block per photo
      for (final img in encodedImages) {
        contentBlocks.add({'type': 'text', 'text': 'Photo: ${img['label']}'});
        contentBlocks.add({
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': _getMediaType(img['base64'] as String),
            'data': img['base64'],
          },
        });
      }

      contentBlocks.add({
        'type': 'text',
        'text':
            'Look at all the photos above. Return only the JSON object with your assessment.',
      });

      // Build and send request
      final body = jsonEncode({
        'model': ApiConfig.model,
        'max_tokens': ApiConfig.maxTokens,
        'system': _getSystemPrompt(
          targetLanguage,
        ), // Passes language variant down
        'messages': [
          {'role': 'user', 'content': contentBlocks},
        ],
      });

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': ApiConfig.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API request failed with status ${response.statusCode}. '
          'Please check your connection and try again.',
        );
      }
      return _parseResponse(response.body);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'Something went wrong while analysing your photos. Please try again.',
      );
    }
  }

  // ── Build person profile string ───────────────────────────────────────────
  static String _buildPersonProfile({
    required int age,
    required bool usesTobacco,
    String? tobaccoType,
    required List<String> symptoms,
    required List<Map<String, dynamic>> images,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Person details:');
    buffer.writeln('- Age: $age');

    if (usesTobacco) {
      buffer.writeln(
        '- Tobacco use: Yes — ${tobaccoType ?? 'type not specified'}',
      );
    } else {
      buffer.writeln('- Tobacco use: No');
    }

    if (symptoms.isNotEmpty) {
      buffer.writeln('- Symptoms reported: ${symptoms.join(', ')}');
    } else {
      buffer.writeln('- Symptoms reported: None');
    }

    buffer.writeln();
    buffer.writeln('Photos provided (in order):');
    for (int i = 0; i < images.length; i++) {
      buffer.writeln('${i + 1}. ${images[i]['label']}');
    }

    return buffer.toString();
  }

  // ── Parse API response → SelfAssessmentResult ────────────────────────────
  static SelfAssessmentResult _parseResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

      final content = decoded['content'] as List<dynamic>;
      final rawText = (content.first as Map<String, dynamic>)['text'] as String;

      // Strip accidental markdown fences
      final cleaned = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final result = jsonDecode(cleaned) as Map<String, dynamic>;

      // Verdict
      final verdict = switch (result['verdict'] as String) {
        'normal' => ScreeningVerdict.normal,
        'high_risk' => ScreeningVerdict.highRisk,
        _ => ScreeningVerdict.suspicious,
      };

      // Key points
      final keyPoints = (result['keyPoints'] as List<dynamic>)
          .map((k) => k as String)
          .toList();

      return SelfAssessmentResult(
        verdict: verdict,
        summary: result['summary'] as String,
        keyPoints: keyPoints,
        recommendation: result['recommendation'] as String,
      );
    } catch (e) {
      throw Exception(
        'We received a response but could not read it correctly. '
        'Please try again.',
      );
    }
  }

  static String _getMediaType(String base64Data) {
    final bytes = base64Decode(base64Data.substring(0, 16));
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
    return 'image/jpeg'; // fallback
  }
}

class SelfAssessmentResult {
  final ScreeningVerdict verdict;
  final String summary;
  final List<String> keyPoints;
  final String recommendation;

  const SelfAssessmentResult({
    required this.verdict,
    required this.summary,
    required this.keyPoints,
    required this.recommendation,
  });
}
