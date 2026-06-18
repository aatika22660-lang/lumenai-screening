import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure these paths point directly to your actual local file structures
import '../../models/screening_model.dart';
import '../../services/self_assessment_analysis_service.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextBody = Color(0xFF3D3D38);

// ── Localized Strings ────────────────────────────────────────────────────────
class _LocalizedStrings {
  static const headingEn = 'Analyzing your photos...';
  static const headingUr = 'آپ کی تصاویر کا تجزیہ کیا جا رہا ہے...';

  static const subEn =
      'This can take up to 10-15 seconds. Please do not close the app or go back.';
  static const subUr =
      'اس میں ۱۰ سے ۱۵ سیکنڈ لگ سکتے ہیں۔ براہ کرم ایپ بند نہ کریں اور نہ ہی پیچھے جائیں۔';
}

class SelfAssessmentAnalysingScreen extends StatefulWidget {
  final SelfAssessmentAnswers answers;
  final List<SelfAssessmentImage> images;
  final bool isUrdu; // 1. Local language configuration variable added

  const SelfAssessmentAnalysingScreen({
    super.key,
    required this.answers,
    required this.images,
    this.isUrdu =
        false, // 2. Exposed parameter cleanly inside the constructor layout
  });

  @override
  State<SelfAssessmentAnalysingScreen> createState() =>
      _SelfAssessmentAnalysingScreenState();
}

class _SelfAssessmentAnalysingScreenState
    extends State<SelfAssessmentAnalysingScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically trigger processing pipeline when the interface boots up
    _startAnalysis();
  }

  TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    if (widget.isUrdu) {
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

  Future<void> _startAnalysis() async {
    try {
      // 3. Injecting the targetLanguage request rule flag dynamically
      final result = await SelfAssessmentAnalysisService.analyse(
        age: widget.answers.age,
        usesTobacco: widget.answers.usesTobacco,
        symptoms: widget.answers.symptoms,
        imageData: widget.images
            .map((img) => {'file': img.file, 'label': img.label})
            .toList(),
        targetLanguage: widget.isUrdu ? 'urdu' : 'english',
      );

      // 4. Pass the verified language parameter mapping downstream to the Results card panel
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/self-assessment/results',
          arguments: {
            'result': result,
            'images': widget.images,
            'usesTobacco': widget.answers.usesTobacco,
            'isUrdu': widget.isUrdu,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isUrdu
                  ? 'تجزیہ کرنے میں خرابی پیش آئی۔ براہ کرم دوبارہ کوشش کریں۔'
                  : 'An error occurred during analysis. Please try again.',
              style: _getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red[800],
          ),
        );
        // Fallback option pushing the user safely back out to try camera snaps again
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Loader Animation Hub ──────────────────────────────────
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: kAccent,
                      strokeWidth: 4.5,
                      backgroundColor: kPrimary.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Processing State Context Message Labels ───────────────
                  Text(
                    widget.isUrdu
                        ? _LocalizedStrings.headingUr
                        : _LocalizedStrings.headingEn,
                    textAlign: TextAlign.center,
                    style: _getTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isUrdu
                        ? _LocalizedStrings.subUr
                        : _LocalizedStrings.subEn,
                    textAlign: TextAlign.center,
                    style: _getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: kTextBody,
                      height: widget.isUrdu ? 1.85 : 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
