import 'dart:convert';
import 'dart:io'; // Added to allow the use of standard File types for picked images

enum ScreeningVerdict { normal, suspicious, highRisk }

// ── ScreeningImage ────────────────────────────────────────────────────────────
class ScreeningImage {
  final String label;
  final String imagePath;

  const ScreeningImage({required this.label, required this.imagePath});

  Map<String, dynamic> toMap() => {'label': label, 'image_path': imagePath};

  factory ScreeningImage.fromMap(Map<String, dynamic> map) {
    return ScreeningImage(
      label: map['label'] as String,
      imagePath: map['image_path'] as String,
    );
  }
}

// ── BoundingBox ───────────────────────────────────────────────────────────────
class BoundingBox {
  final double x;
  final double y;
  final double w;
  final double h;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'w': w, 'h': h};

  factory BoundingBox.fromMap(Map<String, dynamic> map) {
    return BoundingBox(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      w: (map['w'] as num).toDouble(),
      h: (map['h'] as num).toDouble(),
    );
  }
}

// ── ScreeningFinding ──────────────────────────────────────────────────────────
class ScreeningFinding {
  final String area;
  final String finding;
  final bool flagged;
  final String? imageLabel;
  final BoundingBox? bbox;

  const ScreeningFinding({
    required this.area,
    required this.finding,
    this.flagged = false,
    this.imageLabel,
    this.bbox,
  });

  Map<String, dynamic> toMap() => {
    'area': area,
    'finding': finding,
    'flagged': flagged,
    'image_label': imageLabel,
    'bbox': bbox != null ? jsonEncode(bbox!.toMap()) : null,
  };

  factory ScreeningFinding.fromMap(Map<String, dynamic> map) {
    return ScreeningFinding(
      area: map['area'] as String,
      finding: map['finding'] as String,
      flagged: map['flagged'] as bool,
      imageLabel: map['image_label'] as String?,
      bbox: map['bbox'] != null
          ? BoundingBox.fromMap(
              Map<String, dynamic>.from(jsonDecode(map['bbox'] as String)),
            )
          : null,
    );
  }
}

// ── SymmetryAnalysis ──────────────────────────────────────────────────────────
class SymmetryAnalysis {
  final bool isSymmetrical;
  final String observation;

  const SymmetryAnalysis({
    required this.isSymmetrical,
    required this.observation,
  });

  Map<String, dynamic> toMap() => {
    'is_symmetrical': isSymmetrical,
    'observation': observation,
  };

  factory SymmetryAnalysis.fromMap(Map<String, dynamic> map) {
    return SymmetryAnalysis(
      isSymmetrical: map['is_symmetrical'] as bool,
      observation: map['observation'] as String,
    );
  }
}

// ── Screening ─────────────────────────────────────────────────────────────────
class Screening {
  final String id;
  final String patientId;
  final String location;
  final DateTime screenedAt;
  final List<ScreeningImage> images;
  final ScreeningVerdict verdict;
  final List<ScreeningFinding> findings;
  final String summary;
  final List<String> keyPoints;
  final SymmetryAnalysis? symmetryAnalysis;

  const Screening({
    required this.id,
    required this.patientId,
    required this.location,
    required this.screenedAt,
    required this.images,
    required this.verdict,
    required this.findings,
    required this.summary,
    required this.keyPoints,
    this.symmetryAnalysis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'location': location,
      'screened_at': screenedAt.toIso8601String(),
      'images': jsonEncode(images.map((i) => i.toMap()).toList()),
      'verdict': verdict.name,
      'findings': jsonEncode(findings.map((f) => f.toMap()).toList()),
      'summary': summary,
      'key_points': jsonEncode(keyPoints),
      'symmetry_analysis': symmetryAnalysis != null
          ? jsonEncode(symmetryAnalysis!.toMap())
          : null,
    };
  }

  factory Screening.fromMap(Map<String, dynamic> map) {
    List<String> keyPoints = [];
    if (map['key_points'] != null) {
      keyPoints = (jsonDecode(map['key_points'] as String) as List)
          .map((k) => k as String)
          .toList();
    }

    SymmetryAnalysis? symmetryAnalysis;
    if (map['symmetry_analysis'] != null) {
      symmetryAnalysis = SymmetryAnalysis.fromMap(
        Map<String, dynamic>.from(
          jsonDecode(map['symmetry_analysis'] as String),
        ),
      );
    }

    return Screening(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      location: map['location'] as String,
      screenedAt: DateTime.parse(map['screened_at'] as String),
      images: (jsonDecode(map['images'] as String) as List)
          .map((i) => ScreeningImage.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      verdict: ScreeningVerdict.values.firstWhere(
        (v) => v.name == map['verdict'],
      ),
      findings: (jsonDecode(map['findings'] as String) as List)
          .map((f) => ScreeningFinding.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      summary: (map['summary'] as String?) ?? '',
      keyPoints: keyPoints,
      symmetryAnalysis: symmetryAnalysis,
    );
  }
}

// ── Self Assessment Specific Extensions ───────────────────────────────────────

class SelfAssessmentAnswers {
  final int age;
  final bool usesTobacco;
  final String? tobaccoType;
  final List<String> symptoms;

  const SelfAssessmentAnswers({
    required this.age,
    required this.usesTobacco,
    this.tobaccoType,
    required this.symptoms,
  });
}

class SelfAssessmentImage {
  final String label;
  final File file;

  const SelfAssessmentImage({required this.label, required this.file});
}
