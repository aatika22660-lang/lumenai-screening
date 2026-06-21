import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/screening_model.dart';
import '../../database/database_helper.dart';
import '../../models/patient_model.dart';
import '../../utils/id_generator.dart';
import '../../services/pdf_service.dart';
import 'package:printing/printing.dart';
import '../../utils/chw_preferences.dart';
import '../communityhealthworker/image_capture_screen.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);
const kBlueLight = Color(0xFF3B5BDB);
const kAmber = Color(0xFFB8860B);

// ── Results Screen ────────────────────────────────────────────────────────────
class ResultsScreen extends StatefulWidget {
  final String patientId;
  final String location;
  final List<ScreeningImage> images;
  final ScreeningVerdict verdict;
  final List<ScreeningFinding> findings;
  final Patient patient;
  final String summary;
  final List<String> keyPoints;
  final SymmetryAnalysis? symmetryAnalysis;
  final List<OralLocation> selectedLocations;

  const ResultsScreen({
    super.key,
    this.patientId = 'OC-20250611-0000',
    this.location = 'Unknown',
    this.images = const [],
    this.verdict = ScreeningVerdict.suspicious,
    this.findings = const [],
    required this.patient,
    required this.summary,
    this.keyPoints = const [],
    this.symmetryAnalysis,
    this.selectedLocations = const [],
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _saved = false;
  ScreeningVerdict? _previousVerdict;

  @override
  void initState() {
    super.initState();
    _autoSave().then((_) => _loadPreviousVerdict());
  }

  Future<void> _loadPreviousVerdict() async {
    final history = await DatabaseHelper.instance
        .getScreeningsByPatientAndLocation(
          patientId: widget.patient.id,
          location: widget.location,
        );
    if (history.length >= 2) {
      setState(() {
        _previousVerdict = history[history.length - 2].verdict;
      });
    }
  }

  Future<void> _autoSave() async {
    if (_saved) return;
    _saved = true;

    // Skip if a record for this patient+location was saved in the last 60 seconds
    final existing = await DatabaseHelper.instance
        .getScreeningsByPatientAndLocation(
          patientId: widget.patient.id,
          location: widget.location,
        );
    final now = DateTime.now();
    if (existing.any((s) => now.difference(s.screenedAt).inSeconds < 60)) {
      return;
    }

    final screening = Screening(
      id: IdGenerator.newScreeningId(),
      patientId: widget.patient.id,
      location: widget.location,
      screenedAt: now,
      images: widget.images,
      verdict: widget.verdict,
      findings: widget.findings,
      summary: widget.summary,
      keyPoints: widget.keyPoints,
      symmetryAnalysis: widget.symmetryAnalysis,
    );
    await DatabaseHelper.instance.savePatientAndScreening(
      patient: widget.patient,
      screening: screening,
    );
  }

  // ── Verdict helpers ───────────────────────────────────────────────────────
  String get _verdictLabel {
    switch (widget.verdict) {
      case ScreeningVerdict.normal:
        return 'Normal';
      case ScreeningVerdict.suspicious:
        return 'Suspicious';
      case ScreeningVerdict.highRisk:
        return 'High Risk';
    }
  }

  String get _verdictEyebrow {
    switch (widget.verdict) {
      case ScreeningVerdict.normal:
        return 'AI RESULT · LOW RISK';
      case ScreeningVerdict.suspicious:
        return 'AI RESULT · NEEDS REVIEW';
      case ScreeningVerdict.highRisk:
        return 'AI RESULT · HIGH RISK';
    }
  }

  String get _verdictDescription {
    switch (widget.verdict) {
      case ScreeningVerdict.normal:
        return 'No significant abnormalities detected. Recommend routine rescreening in 6 months.';
      case ScreeningVerdict.suspicious:
        return 'Some areas require attention. Please refer this patient to a clinic within 2 weeks.';
      case ScreeningVerdict.highRisk:
        return 'Areas of concern detected. This patient needs urgent clinical assessment — refer within 48 hours.';
    }
  }

  Color get _verdictColor {
    switch (widget.verdict) {
      case ScreeningVerdict.normal:
        return const Color(0xFF4A7C59);
      case ScreeningVerdict.suspicious:
        return const Color(0xFFB8860B);
      case ScreeningVerdict.highRisk:
        return const Color(0xFF9B3A3A);
    }
  }

  IconData get _verdictIcon {
    switch (widget.verdict) {
      case ScreeningVerdict.normal:
        return Icons.check_circle_rounded;
      case ScreeningVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case ScreeningVerdict.highRisk:
        return Icons.error_rounded;
    }
  }

  String get _dateStr {
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
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month]} ${now.year}';
  }

  // ── Trend indicator ───────────────────────────────────────────────────────
  Widget _buildTrendIndicator() {
    if (_previousVerdict == null) return const SizedBox.shrink();

    final prev = _previousVerdict!;
    final curr = widget.verdict;
    final prevIndex = ScreeningVerdict.values.indexOf(prev);
    final currIndex = ScreeningVerdict.values.indexOf(curr);

    if (currIndex > prevIndex) {
      return _trendBanner(
        icon: Icons.arrow_upward_rounded,
        color: const Color(0xFF9B3A3A),
        label: 'Risk has increased since last visit — refer to a doctor',
      );
    } else if (currIndex < prevIndex) {
      return _trendBanner(
        icon: Icons.arrow_downward_rounded,
        color: const Color(0xFF4A7C59),
        label: 'Improving since last visit',
      );
    } else {
      final count = ScreeningVerdict.values.indexOf(curr) == 0
          ? 'stable'
          : 'unchanged';
      return _trendBanner(
        icon: Icons.remove_rounded,
        color: kTextMuted,
        label: 'Result $count compared to last visit',
      );
    }
  }

  Widget _trendBanner({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grouped findings + images ─────────────────────────────────────────────
  Widget _buildGroupedFindingsAndImages() {
    final areas = widget.location
        .split(', ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Single area — flat layout, no section headers
    if (widget.selectedLocations.length <= 1) {
      return _buildAreaSection(
        areaLabel: widget.selectedLocations.isNotEmpty
            ? widget.selectedLocations.first.label
            : null,
        areaFindings: widget.findings,
        areaImages: widget.images,
        showHeader: false,
      );
    }

    // Multiple areas — sectioned
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: areas.map((area) {
        final areaFindings = widget.findings.where((f) {
          final areaLower = area.toLowerCase();
          return f.area.toLowerCase().contains(areaLower) ||
              (f.imageLabel?.toLowerCase().contains(areaLower) ?? false);
        }).toList();

        final areaImages = widget.images
            .where(
              (img) => img.label.toLowerCase().contains(area.toLowerCase()),
            )
            .toList();

        if (areaFindings.isEmpty && areaImages.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildAreaSection(
          areaLabel: area,
          areaFindings: areaFindings,
          areaImages: areaImages,
          showHeader: true,
        );
      }).toList(),
    );
  }

  Widget _buildAreaSection({
    required String? areaLabel,
    required List<ScreeningFinding> areaFindings,
    required List<ScreeningImage> areaImages,
    required bool showHeader,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header with divider ──────────────────────────────────
        if (showHeader && areaLabel != null) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Divider(color: kBorder, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  areaLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: kAccent,
                  ),
                ),
              ),
              Expanded(child: Divider(color: kBorder, thickness: 1)),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // ── Images ───────────────────────────────────────────────────────
        if (areaImages.isNotEmpty) ...[
          if (!showHeader) ...[
            const SizedBox(height: 24),
            const Text(
              'CAPTURED IMAGES',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 10),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: areaImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, i) => _buildImageTile(areaImages[i]),
          ),
          const SizedBox(height: 14),
        ],

        // ── Findings ─────────────────────────────────────────────────────
        if (areaFindings.isNotEmpty) ...[
          if (!showHeader) ...[
            const SizedBox(height: 10),
            const Text(
              'FINDINGS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 10),
          ],
          _buildFindingsList(areaFindings),
        ],
      ],
    );
  }

  Widget _buildImageTile(ScreeningImage img) {
    final isBlue = img.label.toLowerCase().contains('fluorescence');
    final imageFile = File(img.imagePath);
    final annotated = widget.findings
        .where((f) => f.imageLabel == img.label && f.bbox != null)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: isBlue ? const Color(0xFF0D1B4B) : const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          isBlue
                              ? Icons.fluorescent_rounded
                              : Icons.wb_sunny_rounded,
                          size: 32,
                          color: isBlue
                              ? kBlueLight.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    if (annotated.isNotEmpty)
                      CustomPaint(
                        painter: _BBoxPainter(
                          findings: annotated,
                          flaggedColor: const Color(0xFFB8860B),
                          unflaggedColor: kAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              img.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kTextBody,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingsList(List<ScreeningFinding> findings) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(findings.length, (i) {
          final f = findings[i];
          final isLast = i == findings.length - 1;
          final isFluorescence =
              f.imageLabel?.toLowerCase().contains('fluorescence') ?? false;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isFluorescence
                            ? const Color(0xFF0D1B4B)
                            : kAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isFluorescence
                            ? Icons.fluorescent_rounded
                            : Icons.wb_sunny_rounded,
                        size: 20,
                        color: isFluorescence
                            ? kBlueLight.withValues(alpha: 0.7)
                            : kAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.area.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kTextMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            f.finding,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kPrimary,
                              height: 1.4,
                            ),
                          ),
                          if (f.imageLabel != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              f.imageLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kTextMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: f.flagged ? kAmber : kAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: kBorder,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: kPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SCREENING RESULTS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: kAccent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.patientId,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: kTextMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Screened',
                        style: TextStyle(fontSize: 10, color: kTextMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTextBody,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Verdict card ───────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: _verdictColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _verdictEyebrow,
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(_verdictIcon, size: 32, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                _verdictLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  height: 1.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _verdictDescription,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildTrendIndicator(),
                    const SizedBox(height: 8),

                    // ── AI Summary ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUMMARY',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: kTextMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.summary,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.6,
                              color: kTextBody,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Key points ─────────────────────────────────────────
                    if (widget.keyPoints.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'KEY POINTS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: widget.keyPoints
                              .map(
                                (point) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: kAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: kTextBody,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],

                    // ── Symmetry analysis ──────────────────────────────────
                    if (widget.symmetryAnalysis != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'SYMMETRY ANALYSIS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: widget.symmetryAnalysis!.isSymmetrical
                                    ? kAccent.withValues(alpha: 0.1)
                                    : kAmber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                widget.symmetryAnalysis!.isSymmetrical
                                    ? Icons.balance_rounded
                                    : Icons.warning_amber_rounded,
                                size: 22,
                                color: widget.symmetryAnalysis!.isSymmetrical
                                    ? kAccent
                                    : kAmber,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.symmetryAnalysis!.isSymmetrical
                                        ? 'Symmetrical'
                                        : 'Asymmetry detected',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: kPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.symmetryAnalysis!.observation,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: kTextBody,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Findings + Images grouped by area ──────────────────
                    if (widget.findings.isNotEmpty || widget.images.isNotEmpty)
                      _buildGroupedFindingsAndImages(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () async {
                        final chwName = await ChwPreferences.getIdentifier();
                        final bytes = await PdfService.generateReferralPdf(
                          patientId: widget.patientId,
                          location: widget.location,
                          patient: widget.patient,
                          verdict: widget.verdict,
                          summary: widget.summary,
                          keyPoints: widget.keyPoints,
                          findings: widget.findings,
                          images: widget.images,
                          symmetryAnalysis: widget.symmetryAnalysis,
                          chwName: chwName,
                        );
                        await Printing.sharePdf(
                          bytes: bytes,
                          filename: '${widget.patientId}-referral.pdf',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Generate Referral PDF',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSurface,
                        foregroundColor: kPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: kBorder, width: 1.5),
                        ),
                      ),
                      child: Text(
                        'Save and Exit',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── BBox Painter ──────────────────────────────────────────────────────────────
class _BBoxPainter extends CustomPainter {
  final List<ScreeningFinding> findings;
  final Color flaggedColor;
  final Color unflaggedColor;

  const _BBoxPainter({
    required this.findings,
    required this.flaggedColor,
    required this.unflaggedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in findings) {
      final b = f.bbox!;
      final color = f.flagged ? flaggedColor : unflaggedColor;
      final rect = Rect.fromLTWH(
        b.x * size.width,
        b.y * size.height,
        b.w * size.width,
        b.h * size.height,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: f.area,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            background: Paint()..color = Colors.black.withValues(alpha: 0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      final labelY = (rect.top - 14).clamp(0.0, size.height - 14);
      tp.paint(canvas, Offset(rect.left, labelY));
    }
  }

  @override
  bool shouldRepaint(_BBoxPainter old) => old.findings != findings;
}
