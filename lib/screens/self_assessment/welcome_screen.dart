import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

// ── Localized Strings ────────────────────────────────────────────────────────
class _LocalizedStrings {
  static const titleEn = 'Oral Cancer\nSelf-Screening';
  static const titleUr = 'منہ کے کینسر کی\nخود جانچ پڑتال';

  static const introEn =
      'This prototype helps you check your mouth for unusual patches or sores using your smartphone camera. It is a screening tool, not a medical diagnosis.';
  static const introUr =
      'یہ پروٹوٹائپ آپ کے اسمارٹ فون کیمرہ کی مدد سے منہ میں غیر معمولی دھبوں یا چھالوں کی نشاندہی کرنے میں مدد کرتا ہے۔ یہ ایک اسکریننگ ٹول ہے، طبی تشخیص نہیں ہے۔';

  static const step1TitleEn = '1. Risk Assessment';
  static const step1TitleUr = '۱. خطرات کا جائزہ';
  static const step1DescEn =
      'Answer 3 quick questions about tobacco use and symptoms.';
  static const step1DescUr =
      'تمباکو کے استعمال اور علامات کے بارے میں ۳ فوری سوالات کے جواب دیں۔';

  static const step2TitleEn = '2. Photo Capture';
  static const step2TitleUr = '۲. تصاویر لینا';
  static const step2DescEn = 'Take 3 clear photos of the inside of your mouth.';
  static const step2DescUr = 'اپنے منہ کے اندرونی حصے کی ۳ واضح تصاویر لیں۔';

  static const step3TitleEn = '3. Instant Analysis';
  static const step3TitleUr = '۳. فوری تجزیہ';
  static const step3DescEn =
      'Our system screens the photos for anything unusual.';
  static const step3DescUr =
      'ہمارا سسٹم کسی بھی غیر معمولی علامت کے لیے تصاویر کا جائزہ لیتا ہے۔';

  static const ctaEn = 'Get Started  →';
  static const ctaUr = 'شروع کریں  ←';
}

class WelcomeScreen extends StatefulWidget {
  final bool
  initialIsUrdu; // 1. Added to catch the choice from Mode Selection Screen

  const WelcomeScreen({
    super.key,
    this.initialIsUrdu = false, // Defaults to English if not provided
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late bool _isUrdu; // 2. Changed to late state variable

  @override
  void initState() {
    super.initState();
    _isUrdu =
        widget.initialIsUrdu; // 3. Synchronize initial language state selection
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

  void _handleGetStarted() {
    // 4. Pass the verified language state down to the risk questions route parameters
    Navigator.pushNamed(
      context,
      '/self-assessment/questions',
      arguments: {'isUrdu': _isUrdu},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header Bar Control Strip ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: RotatedBox(
                          quarterTurns: _isUrdu ? 2 : 0,
                          child: const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isUrdu = !_isUrdu),
                      style: TextButton.styleFrom(
                        backgroundColor: kSurface,
                        foregroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: kBorder, width: 1),
                        ),
                      ),
                      child: Text(
                        _isUrdu ? 'English' : 'اردو',
                        style: TextStyle(
                          fontFamily: _isUrdu ? null : 'NotoNastaliqUrdu',
                          fontSize: _isUrdu ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Welcome Banner / Intro Content ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        _isUrdu
                            ? _LocalizedStrings.titleUr
                            : _LocalizedStrings.titleEn,
                        style: _getTextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: kPrimary,
                          height: _isUrdu ? 1.6 : 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isUrdu
                            ? _LocalizedStrings.introUr
                            : _LocalizedStrings.introEn,
                        style: _getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: kTextBody,
                          height: _isUrdu ? 1.85 : 1.55,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Workflow Step Rows ──────────────────────────────────
                      _StepRow(
                        title: _isUrdu
                            ? _LocalizedStrings.step1TitleUr
                            : _LocalizedStrings.step1TitleEn,
                        description: _isUrdu
                            ? _LocalizedStrings.step1DescUr
                            : _LocalizedStrings.step1DescEn,
                        icon: Icons.assignment_outlined,
                        isUrdu: _isUrdu,
                      ),
                      const SizedBox(height: 24),
                      _StepRow(
                        title: _isUrdu
                            ? _LocalizedStrings.step2TitleUr
                            : _LocalizedStrings.step2TitleEn,
                        description: _isUrdu
                            ? _LocalizedStrings.step2DescUr
                            : _LocalizedStrings.step2DescEn,
                        icon: Icons.camera_alt_outlined,
                        isUrdu: _isUrdu,
                      ),
                      const SizedBox(height: 24),
                      _StepRow(
                        title: _isUrdu
                            ? _LocalizedStrings.step3TitleUr
                            : _LocalizedStrings.step3TitleEn,
                        description: _isUrdu
                            ? _LocalizedStrings.step3DescUr
                            : _LocalizedStrings.step3DescEn,
                        icon: Icons.analytics_outlined,
                        isUrdu: _isUrdu,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action Buttons Sticky Footer ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isUrdu
                          ? _LocalizedStrings.ctaUr
                          : _LocalizedStrings.ctaEn,
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
      ),
    );
  }
}

// ── Shared Workflow Step Row Helper Component ───────────────────────────────
class _StepRow extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUrdu;

  const _StepRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUrdu,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Icon(icon, size: 20, color: kAccent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                  fontSize: isUrdu ? 14 : 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  height: isUrdu ? 1.8 : 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                  fontSize: isUrdu ? 12 : 13,
                  fontWeight: FontWeight.w400,
                  color: kTextMuted,
                  height: isUrdu ? 1.85 : 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
