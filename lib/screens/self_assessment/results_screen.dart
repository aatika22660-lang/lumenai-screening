import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/screening_model.dart';
import '../../services/self_assessment_analysis_service.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

// ── Verdict palettes ──────────────────────────────────────────────────────────
const _kNormalCard = Color(0xFF2E7D3A);
const _kSuspiciousCard = Color(0xFF8C5E00);
const _kHighRiskCard = Color(0xFF9B2020);

// ── Localized Strings ────────────────────────────────────────────────────────
class _LocalizedStrings {
  static const ctaEn = 'What should I do next?  →';
  static const ctaUr = 'مجھے آگے کیا کرنا چاہیے؟  ←';

  static const sectionFoundEn = 'What we found';
  static const sectionFoundUr = 'ہماری جانچ پڑتال';

  static const sectionPointsEn = 'Key points';
  static const sectionPointsUr = 'اہم نکات';

  static const sectionPhotosEn = 'Photos reviewed';
  static const sectionPhotosUr = 'تصاویر کا معائنہ';

  // Dynamic system labels translations lookup
  static const fallbackLabelsUr = {
    'Full Mouth': 'پورا منہ',
    'Tongue': 'زبان',
    'Cheek': 'گال',
  };

  static const content = {
    ScreeningVerdict.normal: {
      'eyebrowEn': 'YOUR RESULT · ALL CLEAR',
      'eyebrowUr': 'آپ کا رزلٹ · سب واضح ہے',
      'labelEn': 'Looking\nGood',
      'labelUr': 'سب ٹھیک\nہے',
      'descEn': 'Nothing concerning detected. Keep checking every 3 months.',
      'descUr': 'کوئی تشویشناک علامت نہیں ملی۔ ہر 3 ماہ بعد معائنہ کرتے رہیں۔',
    },
    ScreeningVerdict.highRisk: {
      'eyebrowEn': 'YOUR RESULT · NEEDS ATTENTION',
      'eyebrowUr': 'آپ کا رزلٹ · توجہ کی ضرورت ہے',
      'labelEn': 'See a\nDoctor',
      'labelUr': 'ڈاکٹر سے\nرجوع کریں',
      'descEn':
          'Please see a doctor as soon as possible. This does not mean you have cancer — but it needs professional attention.',
      'descUr':
          'براہ کرم جلد از جلد ڈاکٹر سے رابطہ کریں۔ اس کا مطلب یہ ہرگز نہیں کہ آپ کو کینسر ہے — لیکن اس پر ڈاکٹر کی توجہ ضروری ہے۔',
    },
    ScreeningVerdict.suspicious: {
      'eyebrowEn': 'YOUR RESULT · WORTH MONITORING',
      'eyebrowUr': 'آپ کا رزلٹ · نگرانی کی ضرورت ہے',
      'labelEn': 'Worth\nChecking',
      'labelUr': 'معائنہ\nضروری ہے',
      'descEn':
          'Some areas worth monitoring. We recommend visiting a clinic soon.',
      'descUr':
          'کچھ حصوں کی نگرانی ضروری ہے۔ ہم تجویز کرتے ہیں کہ جلد ہی کسی کلینک کا دورہ کریں۔',
    },
  };
}

class SelfAssessmentResultsScreen extends StatefulWidget {
  final SelfAssessmentResult result;
  final List<SelfAssessmentImage> images;
  final bool usesTobacco;
  final bool initialIsUrdu; // 1. Added field

  const SelfAssessmentResultsScreen({
    super.key,
    required this.result,
    required this.images,
    required this.usesTobacco,
    this.initialIsUrdu = false, // 2. Added to constructor parameters
  });

  @override
  State<SelfAssessmentResultsScreen> createState() =>
      _SelfAssessmentResultsScreenState();
}

class _SelfAssessmentResultsScreenState
    extends State<SelfAssessmentResultsScreen> {
  late bool _isUrdu; // 3. Changed to a 'late' variable

  @override
  void initState() {
    super.initState();
    _isUrdu = widget
        .initialIsUrdu; // 4. Set the initial state from the widget parameter
  }

  // ── Verdict helpers context match variants ─────────────────────────────────
  Color get _cardColor => switch (widget.result.verdict) {
    ScreeningVerdict.normal => _kNormalCard,
    ScreeningVerdict.highRisk => _kHighRiskCard,
    _ => _kSuspiciousCard,
  };

  String get _eyebrow {
    final block =
        _LocalizedStrings.content[widget.result.verdict] ??
        _LocalizedStrings.content[ScreeningVerdict.suspicious]!;
    return _isUrdu ? block['eyebrowUr']! : block['eyebrowEn']!;
  }

  String get _verdictLabel {
    final block =
        _LocalizedStrings.content[widget.result.verdict] ??
        _LocalizedStrings.content[ScreeningVerdict.suspicious]!;
    return _isUrdu ? block['labelUr']! : block['labelEn']!;
  }

  IconData get _verdictIcon => switch (widget.result.verdict) {
    ScreeningVerdict.normal => Icons.check_circle_rounded,
    ScreeningVerdict.highRisk => Icons.error_rounded,
    _ => Icons.info_rounded,
  };

  String get _verdictDescription {
    final block =
        _LocalizedStrings.content[widget.result.verdict] ??
        _LocalizedStrings.content[ScreeningVerdict.suspicious]!;
    return _isUrdu ? block['descUr']! : block['descEn']!;
  }

  TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    if (_isUrdu) {
      return TextStyle(
        fontFamily: 'NotoNastaliqUrdu',
        fontSize: fontSize - 1,
        fontWeight: fontWeight,
        color: color,
        height: height ?? 1.9,
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Directionality(
        textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            // ── Full-bleed verdict card (extends behind status bar) ────────
            _FullBleedVerdictCard(
              color: _cardColor,
              eyebrow: _eyebrow,
              label: _verdictLabel,
              icon: _verdictIcon,
              description: _verdictDescription,
              isUrdu: _isUrdu,
              onLangToggle: () => setState(() => _isUrdu = !_isUrdu),
              onBack: () => Navigator.pop(context),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary ──────────────────────────────────────────
                    _SectionLabel(
                      _isUrdu
                          ? _LocalizedStrings.sectionFoundUr
                          : _LocalizedStrings.sectionFoundEn,
                      isUrdu: _isUrdu,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Builder(
                        builder: (context) {
                          // Detects whether the dynamically generated string is English or Urdu
                          final isTextEnglish = RegExp(
                            r'[a-zA-Z]',
                          ).hasMatch(widget.result.summary);

                          return Directionality(
                            textDirection: isTextEnglish
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: Text(
                              widget.result.summary,
                              textAlign: isTextEnglish
                                  ? TextAlign.left
                                  : TextAlign.right,
                              style:
                                  _getTextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: kTextBody,
                                    height: (_isUrdu && !isTextEnglish)
                                        ? 1.85
                                        : 1.65,
                                  ).copyWith(
                                    fontFamily: isTextEnglish
                                        ? null
                                        : 'NotoNastaliqUrdu',
                                  ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Key points ────────────────────────────────────────
                    _SectionLabel(
                      _isUrdu
                          ? _LocalizedStrings.sectionPointsUr
                          : _LocalizedStrings.sectionPointsEn,
                      isUrdu: _isUrdu,
                    ),
                    const SizedBox(height: 10),
                    ...widget.result.keyPoints.map(
                      (point) => _KeyPointRow(
                        text: point,
                        isUrdu: _isUrdu,
                        textStyle: _getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: kTextBody,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Photo thumbnails ──────────────────────────────────
                    _SectionLabel(
                      _isUrdu
                          ? _LocalizedStrings.sectionPhotosUr
                          : _LocalizedStrings.sectionPhotosEn,
                      isUrdu: _isUrdu,
                    ),
                    const SizedBox(height: 10),
                    _ThumbnailGrid(images: widget.images, isUrdu: _isUrdu),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── CTA ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/self-assessment/next-steps',
                    arguments: {
                      'verdict': widget.result.verdict,
                      'usesTobacco': widget.usesTobacco,
                      'recommendation': widget.result.recommendation,
                      'isUrdu': _isUrdu,
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isUrdu ? _LocalizedStrings.ctaUr : _LocalizedStrings.ctaEn,
                    style: _getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ).copyWith(letterSpacing: _isUrdu ? 0 : 0.2, height: 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-bleed verdict card ───────────────────────────────────────────────────
class _FullBleedVerdictCard extends StatelessWidget {
  final Color color;
  final String eyebrow;
  final String label;
  final IconData icon;
  final String description;
  final bool isUrdu;
  final VoidCallback onLangToggle;
  final VoidCallback onBack;

  const _FullBleedVerdictCard({
    required this.color,
    required this.eyebrow,
    required this.label,
    required this.icon,
    required this.description,
    required this.isUrdu,
    required this.onLangToggle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Action Bar Top Control Row ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RotatedBox(
                    quarterTurns: isUrdu ? 2 : 0,
                    child: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: onLangToggle,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isUrdu ? 'English' : 'اردو',
                  style: TextStyle(
                    fontFamily: isUrdu ? null : 'NotoNastaliqUrdu',
                    fontSize: isUrdu ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Eyebrow ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              eyebrow,
              style: TextStyle(
                fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                fontSize: 10,
                letterSpacing: isUrdu ? 0 : 1.2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: isUrdu ? 1.8 : null,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Icon + headline ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 14),
              Text(
                label,
                style: isUrdu
                    ? const TextStyle(
                        fontFamily: 'NotoNastaliqUrdu',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.6,
                      )
                    : GoogleFonts.inter(
                        fontSize: 40,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Divider ───────────────────────────────────────────────────
          Container(height: 1, color: Colors.white.withOpacity(0.2)),

          const SizedBox(height: 16),

          // ── Description ───────────────────────────────────────────────
          Text(
            description,
            style: isUrdu
                ? const TextStyle(
                    fontFamily: 'NotoNastaliqUrdu',
                    fontSize: 14,
                    height: 1.9,
                    color: Colors.white,
                  )
                : GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.9),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Key point row ─────────────────────────────────────────────────────────────
class _KeyPointRow extends StatelessWidget {
  final String text;
  final bool isUrdu;
  final TextStyle textStyle;

  const _KeyPointRow({
    required this.text,
    required this.isUrdu,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic text script language detection
    final isTextEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Directionality(
        textDirection: isTextEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: (isUrdu && !isTextEnglish) ? 12 : 8,
              ),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                textAlign: isTextEnglish ? TextAlign.left : TextAlign.right,
                style: textStyle.copyWith(
                  fontFamily: isTextEnglish ? null : 'NotoNastaliqUrdu',
                  height: isTextEnglish ? 1.5 : 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 2×2 thumbnail grid ────────────────────────────────────────────────────────
class _ThumbnailGrid extends StatelessWidget {
  final List<SelfAssessmentImage> images;
  final bool isUrdu;
  const _ThumbnailGrid({required this.images, required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, i) {
        final img = images[i];

        // Maps dynamic workflow keys safely to fallback labels
        final localizedLabel = isUrdu
            ? (_LocalizedStrings.fallbackLabelsUr[img.label] ?? img.label)
            : img.label;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.file(
                    img.file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Text(
                  localizedLabel,
                  style: TextStyle(
                    fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                    fontSize: isUrdu ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: kTextBody,
                    height: isUrdu ? 1.8 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isUrdu;
  const _SectionLabel(this.text, {required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
        fontSize: isUrdu ? 12 : 13,
        fontWeight: FontWeight.w600,
        color: kTextMuted,
        letterSpacing: isUrdu ? 0 : 0.2,
        height: isUrdu ? 1.8 : null,
      ),
    );
  }
}
