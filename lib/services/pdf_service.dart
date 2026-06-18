import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/screening_model.dart';
import '../models/patient_model.dart';

// ── Colour tokens (mirrored from results_screen) ──────────────────────────────
const _kPrimary = PdfColor.fromInt(0xFF1C1C1A);
const _kAccent = PdfColor.fromInt(0xFF6B8F71);
const _kTextMuted = PdfColor.fromInt(0xFF9A9A8E);
const _kTextBody = PdfColor.fromInt(0xFF3D3D38);
const _kBorder = PdfColor.fromInt(0xFFE2DFD8);
const _kBg = PdfColor.fromInt(0xFFF5F3EE);
const _kSurface = PdfColors.white;
const _kAmber = PdfColor.fromInt(0xFFB8860B);
const _kAmberBg = PdfColor.fromInt(0xFFFFF8E1);
const _kGreen = PdfColor.fromInt(0xFF4A7C59);
const _kGreenBg = PdfColor.fromInt(0xFFEEF3EF);
const _kRed = PdfColor.fromInt(0xFF9B3A3A);
const _kRedBg = PdfColor.fromInt(0xFFFDF0F0);

class PdfService {
  PdfService._();

  // ── Public entry point ────────────────────────────────────────────────────
  static Future<Uint8List> generateReferralPdf({
    required String patientId,
    required String location,
    required Patient patient,
    required ScreeningVerdict verdict,
    required String summary,
    required List<String> keyPoints,
    required List<ScreeningFinding> findings,
    required List<ScreeningImage> images,
    SymmetryAnalysis? symmetryAnalysis,
    String? chwName,
  }) async {
    final pdf = pw.Document();

    // Pre-load images (graceful fallback if file missing)
    final imageWidgets = <String, pw.MemoryImage>{};
    for (final img in images) {
      try {
        final file = File(img.imagePath);
        if (await file.exists()) {
          imageWidgets[img.imagePath] = pw.MemoryImage(
            await file.readAsBytes(),
          );
        }
      } catch (_) {
        // File unreadable — placeholder used instead
      }
    }

    // Verdict palette
    final vColor = _verdictColor(verdict);
    final vBgColor = _verdictBgColor(verdict);
    final vLabel = _verdictLabel(verdict);

    // Date/time strings
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${now.day.toString().padLeft(2, '0')} ${months[now.month]} ${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 48),
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.interRegular(),
          bold: await PdfGoogleFonts.interSemiBold(),
        ),
        header: (_) => _buildHeader(dateStr, chwName),
        footer: (_) => _buildFooter(dateStr, timeStr),
        build: (context) => [
          pw.SizedBox(height: 20),

          // ── Section 1 — Patient details ───────────────────────────────
          _sectionHeading('Patient Details'),
          pw.SizedBox(height: 8),
          _buildPatientTable(
            patientId: patientId,
            patient: patient,
            location: location,
            dateStr: dateStr,
          ),

          pw.SizedBox(height: 24),

          // ── Section 2 — AI Result ─────────────────────────────────────
          _sectionHeading('AI Result'),
          pw.SizedBox(height: 8),
          _buildAiResult(
            verdict: verdict,
            vLabel: vLabel,
            vColor: vColor,
            vBgColor: vBgColor,
            summary: summary,
            keyPoints: keyPoints,
          ),

          pw.SizedBox(height: 24),

          // ── Section 3 — Findings ──────────────────────────────────────
          if (findings.isNotEmpty) ...[
            _sectionHeading('Findings'),
            pw.SizedBox(height: 8),
            _buildFindings(findings),
            pw.SizedBox(height: 24),
          ],

          // ── Section 4 — Symmetry analysis ────────────────────────────
          if (symmetryAnalysis != null) ...[
            _sectionHeading('Symmetry Analysis'),
            pw.SizedBox(height: 8),
            _buildSymmetry(symmetryAnalysis),
            pw.SizedBox(height: 24),
          ],

          // ── Section 5 — Captured images ───────────────────────────────
          if (images.isNotEmpty) ...[
            _sectionHeading('Captured Images'),
            pw.SizedBox(height: 8),
            _buildImageGrid(images, imageWidgets),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // ── Header ────────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(String dateStr, String? chwName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            // Wordmark
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LumenAI',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Text(
                      'ORAL SCREENING',
                      style: pw.TextStyle(
                        fontSize: 9,
                        letterSpacing: 2.0,
                        color: _kTextMuted,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                // Accent underbar
                pw.Container(
                  width: 32,
                  height: 2,
                  decoration: const pw.BoxDecoration(color: _kAccent),
                ),
              ],
            ),
            // "REFERRAL REPORT" label
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'REFERRAL REPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(fontSize: 10, color: _kTextMuted),
                ),
                if (chwName != null && chwName.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Screened by: $chwName',
                    style: pw.TextStyle(fontSize: 9, color: _kTextMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Divider(thickness: 0.5, color: _kBorder),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(String dateStr, String timeStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Divider(thickness: 0.5, color: _kBorder),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by LumenAI — Prototype. Not for clinical use.',
              style: pw.TextStyle(fontSize: 8, color: _kTextMuted),
            ),
            pw.Text(
              'Generated $dateStr at $timeStr',
              style: pw.TextStyle(fontSize: 8, color: _kTextMuted),
            ),
          ],
        ),
      ],
    );
  }

  // ── Patient details table ─────────────────────────────────────────────────
  static pw.Widget _buildPatientTable({
    required String patientId,
    required Patient patient,
    required String location,
    required String dateStr,
  }) {
    final rows = <_TableRow>[
      _TableRow('Patient ID', patientId),
      _TableRow('Date of Screening', dateStr),
      _TableRow('Age', patient.age.toString()),
      _TableRow('Gender', patient.gender),
      if ((patient.phone ?? '').isNotEmpty) _TableRow('Phone', patient.phone!),
      _TableRow('Screened Location', location),
      _TableRow('Tobacco Use', patient.usesTobacco ? 'Yes' : 'No'),
      if (patient.usesTobacco) ...[
        _TableRow('Tobacco Type', patient.tobaccoType ?? '—'),
        _TableRow('Duration', patient.duration ?? '—'),
        _TableRow('Frequency', patient.frequency ?? '—'),
      ],
      _TableRow(
        'Symptoms',
        patient.symptoms.isEmpty
            ? 'None reported'
            : patient.symptoms.join(', '),
      ),
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kBorder, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1.2),
          1: const pw.FlexColumnWidth(2),
        },
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          final isLast = i == rows.length - 1;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? _kBg : _kSurface,
              borderRadius: isLast
                  ? const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(10),
                      bottomRight: pw.Radius.circular(10),
                    )
                  : i == 0
                  ? const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(10),
                      topRight: pw.Radius.circular(10),
                    )
                  : null,
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: pw.Text(
                  row.label,
                  style: pw.TextStyle(fontSize: 10, color: _kTextMuted),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: pw.Text(
                  row.value,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  static pw.Widget _buildAiResult({
    required ScreeningVerdict verdict,
    required String vLabel,
    required PdfColor vColor,
    required PdfColor vBgColor,
    required String summary,
    required List<String> keyPoints,
  }) {
    final vDesc = _verdictDescription(verdict);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Simple bullet verdict line ──────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 8,
              height: 8,
              decoration: pw.BoxDecoration(
                color: vColor,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '$vLabel: ',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: vColor,
                    ),
                  ),
                  pw.TextSpan(
                    text: vDesc,
                    style: pw.TextStyle(fontSize: 11, color: _kTextBody),
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 16),

        // ── Summary ────────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _kSurface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            border: pw.Border.all(color: _kBorder, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SUMMARY',
                style: pw.TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.4,
                  color: _kTextMuted,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                summary,
                style: pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 4,
                  color: _kTextBody,
                ),
              ),
            ],
          ),
        ),

        // ── Key points ─────────────────────────────────────────────────
        if (keyPoints.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _kSurface,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              border: pw.Border.all(color: _kBorder, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'KEY POINTS',
                  style: pw.TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.4,
                    color: _kTextMuted,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...keyPoints.map(
                  (point) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 4),
                          width: 5,
                          height: 5,
                          decoration: pw.BoxDecoration(
                            color: _kAccent,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            point,
                            style: pw.TextStyle(
                              fontSize: 10,
                              lineSpacing: 3,
                              color: _kTextBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Findings ──────────────────────────────────────────────────────────────
  static pw.Widget _buildFindings(List<ScreeningFinding> findings) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kBorder, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: List.generate(findings.length, (i) {
          final f = findings[i];
          final isLast = i == findings.length - 1;
          return pw.Column(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        f.area.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _kTextMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            f.finding,
                            style: pw.TextStyle(fontSize: 10, color: _kPrimary),
                          ),
                          if (f.imageLabel != null) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              f.imageLabel!,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: _kTextMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: f.flagged ? _kAmber : _kAccent,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                pw.Divider(
                  thickness: 0.5,
                  color: _kBorder,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Symmetry analysis ─────────────────────────────────────────────────────
  static pw.Widget _buildSymmetry(SymmetryAnalysis symmetry) {
    final color = symmetry.isSymmetrical ? _kAccent : _kAmber;
    final bgColor = symmetry.isSymmetrical ? _kGreenBg : _kAmberBg;
    final label = symmetry.isSymmetrical ? 'Symmetrical' : 'Asymmetry detected';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _kBorder, width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 10,
            height: 10,
            margin: const pw.EdgeInsets.only(top: 2),
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  symmetry.observation,
                  style: pw.TextStyle(
                    fontSize: 10,
                    lineSpacing: 3,
                    color: _kTextBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image grid ────────────────────────────────────────────────────────────
  static pw.Widget _buildImageGrid(
    List<ScreeningImage> images,
    Map<String, pw.MemoryImage> imageWidgets,
  ) {
    // Pair images into rows of 2
    final rows = <List<ScreeningImage>>[];
    for (var i = 0; i < images.length; i += 2) {
      rows.add([images[i], if (i + 1 < images.length) images[i + 1]]);
    }

    return pw.Column(
      children: rows.map((pair) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Row(
            children: pair.map((img) {
              final memImg = imageWidgets[img.imagePath];
              return pw.Expanded(
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(
                    right: pair.indexOf(img) == 0 ? 6 : 0,
                  ),
                  child: pw.Container(
                    height: 160,
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFF1A1A18),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(10),
                      ),
                      border: pw.Border.all(color: _kBorder, width: 0.5),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 10,
                      verticalRadius: 10,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Expanded(
                            child: memImg != null
                                ? pw.Image(memImg, fit: pw.BoxFit.cover)
                                : pw.Center(
                                    child: pw.Text(
                                      'Image unavailable',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: _kTextMuted,
                                      ),
                                    ),
                                  ),
                          ),
                          pw.Container(
                            color: PdfColors.white,
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: pw.Text(
                              img.label,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: _kTextBody,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // ── Section heading ───────────────────────────────────────────────────────
  static pw.Widget _sectionHeading(String title) {
    return pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 9,
        letterSpacing: 1.4,
        fontWeight: pw.FontWeight.bold,
        color: _kTextMuted,
      ),
    );
  }

  // ── Verdict helpers ───────────────────────────────────────────────────────
  static String _verdictLabel(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return 'Normal';
      case ScreeningVerdict.suspicious:
        return 'Suspicious';
      case ScreeningVerdict.highRisk:
        return 'High Risk';
    }
  }

  static String _verdictDescription(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return 'No significant abnormalities detected. '
            'Recommend routine rescreening in 6 months.';
      case ScreeningVerdict.suspicious:
        return 'Some areas require attention. '
            'Please refer this patient to a clinic within 2 weeks.';
      case ScreeningVerdict.highRisk:
        return 'Areas of concern detected. '
            'This patient needs urgent clinical assessment — refer within 48 hours.';
    }
  }

  static PdfColor _verdictColor(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return _kGreen;
      case ScreeningVerdict.suspicious:
        return _kAmber;
      case ScreeningVerdict.highRisk:
        return _kRed;
    }
  }

  static PdfColor _verdictBgColor(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return _kGreenBg;
      case ScreeningVerdict.suspicious:
        return _kAmberBg;
      case ScreeningVerdict.highRisk:
        return _kRedBg;
    }
  }
}

// ── Small helper ─────────────────────────────────────────────────────────────
class _TableRow {
  final String label;
  final String value;
  const _TableRow(this.label, this.value);
}
