import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/screening_model.dart';
import '../database/database_helper.dart';
import '../models/patient_model.dart';

class AnalysisService {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';

  static const String _systemPrompt = '''
You are an AI-assisted oral cancer screening tool deployed in a community health worker (CHW) app in Pakistan. You analyse intraoral images taken with a fluorescence device (VELscope-type, 400–460 nm blue light excitation) alongside white-light images, and return a structured clinical assessment.

FLUORESCENCE INTERPRETATION:
- Healthy tissue fluoresces a uniform pale green under blue light.
- Suspicious or dysplastic tissue shows fluorescence visualisation loss (FVL): dark, brown, or black patches against the green background.
- Precancerous lesions appear dark green to black; cancerous tissue appears deep purple to dark brown.
- Artefacts to discount: shadows from tongue or cheek folds, pooled saliva, dental restorations, and hair can all cause dark patches that are not FVL. Assess shape, border regularity, and whether the dark area corresponds to a lesion visible in the white-light image.
- A dark patch with sharp, irregular borders that persists across the white-light and fluorescence pair is more significant than a diffuse shadow.

RISK STRATIFICATION BY PATIENT PROFILE:
Weight your verdict according to the intake data provided. A dark area in a non-tobacco-user with no symptoms and no visible white-light lesion is low priority. The same finding in a long-term gutka user with dysphagia is urgent.

Tobacco type and site-specific risk for this population (Pakistan):
- Gutka / Paan: held in the gingivobuccal sulcus → highest risk at buccal mucosa, gingivobuccal sulcus, lateral tongue, floor of mouth.
- Naswar: placed in the buccal sulcus and lower lip → highest risk at buccal mucosa, floor of mouth, lower gingiva.
- Cigarettes: combustion carcinogens → tongue (lateral border, ventral surface), floor of mouth, soft palate.
- Multiple / combination use: all of the above; escalate threshold for suspicion.
- Duration amplifies risk: 10+ years is significantly higher risk than < 1 year.
- Frequency amplifies risk: 5+ times/day is significantly higher risk.

High-risk anatomical sites regardless of habit: lateral border of tongue, ventral tongue, floor of mouth (horseshoe-shaped zone under the tongue), soft palate.

SYMPTOMS:
If the patient has reported pain, difficulty swallowing, white or red patches, or numbness — escalate your suspicion. These are red flags especially when co-occurring with tobacco use.

LOCATION-SPECIFIC ANALYSIS:
The images are from a specific oral site. Tailor your findings to that anatomy:
- Top of tongue: assess dorsal surface, papillae irregularity, midline vs lateral asymmetry.
- Underside of tongue (ventral): high-risk zone — scrutinise for FVL, leukoplakia, erythroplakia.
- Side of tongue: lateral border is the highest-risk site in the oral cavity globally — compare left and right; note any asymmetric FVL.
- Floor of mouth: horseshoe zone under the tongue — high-risk, particularly for naswar and cigarette users; note any FVL near the lingual frenum or lateral margins.
- Roof of mouth (hard and soft palate): hard palate lesions rare but assess; soft palate is higher risk — note FVL near the junction of hard and soft palate.

SYMMETRY ANALYSIS:
Only perform symmetry analysis when the screening location is "Side of tongue" (i.e. both left and right images are present). Compare the fluorescence pattern and any white-light findings between the left and right lateral borders. Note whether FVL, colour changes, or lesion morphology differs between sides. Asymmetric FVL is a significant finding and should escalate the verdict. Set symmetryAnalysis to null for all other locations.

OUTPUT FORMAT:
Respond only with a valid JSON object. No preamble, no explanation outside the JSON. Use exactly this structure:

{
  "verdict": "normal" | "suspicious" | "high_risk",
  "summary": "2-3 sentence plain-English summary written for a community health worker with no clinical training. State what was seen, what it means, and what to do next.",
  "findings": [
    {
      "area": "anatomical sub-area name",
      "finding": "clinical description of what was observed in this area",
      "flagged": true | false,
      "imageLabel": "exact label of the image this finding comes from, or null if overall",
      "bbox": {"x": 0.3, "y": 0.5, "w": 0.2, "h": 0.15} | null
    }
  ],
  "keyPoints": [
    "string",
    "string",
    "string",
    "string"
  ],
  "symmetryAnalysis": {
    "isSymmetrical": true | false,
    "observation": "one sentence describing the comparison between left and right"
  } | null
}

FINDINGS RULES:
- Include one finding per distinct anatomical area observed. 3-5 findings is typical.
- flagged: true means the area warrants clinical attention.
- area should be specific: "Ventral tongue — left margin" not just "Tongue".
- bbox: normalized bounding box of the finding within the image it comes from. x and y are the top-left corner, w and h are width and height, all as decimal fractions between 0.0 and 1.0 relative to the image dimensions. Only provide bbox when the finding is locatable to a specific visible region in the image — for example a dark patch, a lesion, or a colour change. Set bbox to null for diffuse findings, overall assessments, or any finding where imageLabel is null. Be conservative — only box areas you are confident about.

KEY POINTS RULES:
- 4-6 bullet points. Mix of accessible and clinical.
- Examples of accessible: "No suspicious dark patches detected under fluorescence light", "Patient has used gutka for 10+ years — this increases cancer risk significantly."
- Examples of clinical: "FVL observed at left lateral border of tongue with irregular margins — correlates with white-light image", "Erythroplakia-type changes visible on white-light image at floor of mouth."
- Do not repeat the verdict verbatim. Each point should add new information.
- Order from most to least significant.

VERDICT RULES:
- normal: no FVL, no white-light lesion, no symptoms, low-risk profile.
- suspicious: FVL present but ambiguous (could be artefact), OR white-light lesion present without FVL, OR high-risk profile with borderline findings.
- high_risk: clear FVL with irregular borders that correlates with white-light, OR any finding in a long-term heavy tobacco user with symptoms.

LONGITUDINAL ANALYSIS:
If previous screening history is provided for this patient at this location, factor the trend into your verdict and summary.
- A stable normal pattern over multiple visits is reassuring — reflect this in the summary.
- A progression from normal to suspicious to high risk is a significant escalating pattern — escalate your verdict accordingly and flag the trend explicitly in the summary and key points.
- A suspicious finding that has resolved to normal on follow up is meaningful — note the improvement.
- Always mention the trend in the summary if history is present.

Never output anything outside the JSON object.
''';

  // ── Main analysis function ────────────────────────────────────────────────
  static Future<AnalysisResult> analyse({
    required Patient patient,
    required String location,
    required List<Map<String, dynamic>> imageData,
  }) async {
    // Encode all images to base64 and sniff out their true media types
    final List<Map<String, dynamic>> encodedImages = [];
    for (final item in imageData) {
      final file = item['file'] as File?;
      if (file == null) continue;
      final bytes = await file.readAsBytes();

      // Magic bytes checking
      String mediaType = 'image/jpeg'; // Fallback default
      if (bytes.length >= 4 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        mediaType = 'image/png';
      } else if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 && // RIFF
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        // WEBP
        mediaType = 'image/webp';
      }

      encodedImages.add({
        'label': item['label'] as String,
        'mediaType': mediaType,
        'base64': base64Encode(bytes),
      });
    }
    // Fetch previous screenings for this patient at this location
    final history = await DatabaseHelper.instance
        .getScreeningsByPatientAndLocation(
          patientId: patient.id,
          location: location,
        );
    // Build user message content blocks
    final List<Map<String, dynamic>> contentBlocks = [];

    // Patient profile text
    contentBlocks.add({
      'type': 'text',
      'text': _buildPatientProfile(patient, location, encodedImages, history),
    });

    // One label + image block per captured image
    for (final img in encodedImages) {
      contentBlocks.add({'type': 'text', 'text': 'Image: ${img['label']}'});
      contentBlocks.add({
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': img['mediaType'], // Injected dynamic media type here
          'data': img['base64'],
        },
      });
    }

    contentBlocks.add({
      'type': 'text',
      'text':
          'Analyse all images together. Cross-reference the white-light '
          'and fluorescence pairs. Return only the JSON object.',
    });

    // Build and send request
    final body = jsonEncode({
      'model': ApiConfig.model,
      'max_tokens': ApiConfig.maxTokens,
      'system': _systemPrompt,
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
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }

    return _parseResponse(response.body);
  }

  // ── Build patient profile string ──────────────────────────────────────────
  static String _buildPatientProfile(
    Patient patient,
    String location,
    List<Map<String, dynamic>> images,
    List<Screening> history,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Patient profile:');
    buffer.writeln('- Age: ${patient.age} | Gender: ${patient.gender}');

    if (patient.usesTobacco) {
      buffer.write('- Tobacco: ${patient.tobaccoType ?? 'Unknown type'}');
      if (patient.duration != null) buffer.write(', ${patient.duration}');
      if (patient.frequency != null) buffer.write(', ${patient.frequency}');
      buffer.writeln();
    } else {
      buffer.writeln('- Tobacco: None');
    }

    if (patient.symptoms.isNotEmpty) {
      buffer.writeln('- Symptoms: ${patient.symptoms.join(', ')}');
    } else {
      buffer.writeln('- Symptoms: None reported');
    }

    buffer.writeln('- Visit type: ${patient.visitType}');
    buffer.writeln('- Screening location: $location');
    buffer.writeln();
    buffer.writeln('Images provided (in order):');
    for (int i = 0; i < images.length; i++) {
      buffer.writeln('${i + 1}. ${images[i]['label']}');
    }
    buffer.writeln();
    buffer.writeln(_buildHistoryContext(history));
    return buffer.toString();
  }

  static String _buildHistoryContext(List<Screening> history) {
    if (history.isEmpty)
      return 'No previous screenings for this patient at this location.';

    final buffer = StringBuffer();
    buffer.writeln('Previous screenings for this patient at this location:');
    for (final s in history) {
      final date = s.screenedAt.toLocal().toString().split(' ').first;
      final verdict = s.verdict.name.replaceAll('_', ' ');
      buffer.writeln('- $date: $verdict');
    }
    return buffer.toString();
  }

  // ── Parse API response → AnalysisResult ──────────────────────────────────
  static AnalysisResult _parseResponse(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

    // Extract text from first content block
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

    // Findings
    final findings = (result['findings'] as List<dynamic>).map((f) {
      final map = f as Map<String, dynamic>;
      BoundingBox? bbox;
      if (map['bbox'] != null) {
        final b = map['bbox'] as Map<String, dynamic>;
        bbox = BoundingBox(
          x: (b['x'] as num).toDouble(),
          y: (b['y'] as num).toDouble(),
          w: (b['w'] as num).toDouble(),
          h: (b['h'] as num).toDouble(),
        );
      }
      return ScreeningFinding(
        area: map['area'] as String,
        finding: map['finding'] as String,
        flagged: map['flagged'] as bool,
        imageLabel: map['imageLabel'] as String?,
        bbox: bbox,
      );
    }).toList();

    // Key points
    final keyPoints = (result['keyPoints'] as List<dynamic>)
        .map((k) => k as String)
        .toList();

    // Symmetry analysis (nullable — only present for side of tongue)
    SymmetryAnalysis? symmetryAnalysis;
    if (result['symmetryAnalysis'] != null) {
      final sym = result['symmetryAnalysis'] as Map<String, dynamic>;
      symmetryAnalysis = SymmetryAnalysis(
        isSymmetrical: sym['isSymmetrical'] as bool,
        observation: sym['observation'] as String,
      );
    }

    return AnalysisResult(
      verdict: verdict,
      summary: result['summary'] as String,
      findings: findings,
      keyPoints: keyPoints,
      symmetryAnalysis: symmetryAnalysis,
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class AnalysisResult {
  final ScreeningVerdict verdict;
  final String summary;
  final List<ScreeningFinding> findings;
  final List<String> keyPoints;
  final SymmetryAnalysis? symmetryAnalysis;

  const AnalysisResult({
    required this.verdict,
    required this.summary,
    required this.findings,
    required this.keyPoints,
    this.symmetryAnalysis,
  });
}
