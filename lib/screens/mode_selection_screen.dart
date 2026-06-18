import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/chw_preferences.dart';

// ── Colour tokens (matching app theme) ───────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

// ── Localized Strings ────────────────────────────────────────────────────────
class _LocalizedStrings {
  static const appSubtitleEn = 'ORAL SCREENING';
  static const appSubtitleUr = 'منہ کا معائنہ';

  static const heroLine1En = 'Early detection';
  static const heroLine1Ur = 'ابتدائی تشخیص';

  static const heroLine2En = 'saves lives.';
  static const heroLine2Ur = 'جان بچاتی ہے۔';

  static const bodyTextEn =
      'Oral cancer is highly treatable when caught early.\nChoose how you\'d like to begin.';
  static const bodyTextUr =
      'منہ کے کینسر کا جلد پتا چلنے پر اس کا علاج ممکن ہے۔\nبراہِ کرم آغاز کا طریقہ منتخب کریں۔';

  static const chwTitleEn = 'Community Health Worker';
  static const chwTitleUr = 'کمیونٹی ہیلتھ ورکر';

  static const chwSubtitleEn =
      'For trained screeners conducting field assessments';
  static const chwSubtitleUr = 'فیلڈ اسیسمنٹ کرنے والے تربیت یافتہ عملے کے لیے';

  static const selfTitleEn = 'Self Assessment';
  static const selfTitleUr = 'ذاتی معائنہ';

  static const selfSubtitleEn =
      'Check yourself privately — no hospital visit needed';
  static const selfSubtitleUr =
      'گھر بیٹھے نجی طور پر معائنہ کریں — ہسپتال جانے کی ضرورت نہیں';

  static const disclaimerEn =
      'Ziauddin University · Prototype · Not for Clinical Use';
  static const disclaimerUr =
      'ضیاء الدین یونیورسٹی · پروٹوٹائپ · کلینیکل استعمال کے لیے نہیں ہے';
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool _isUrdu = false;

  // Helper method to resolve font styling dynamically
  TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    bool isItalic = false,
  }) {
    if (_isUrdu) {
      // Noto Nastaliq Urdu usually requires a slightly adjusted line-height
      // and explicit family assignment. Italics are traditionally omitted in Nastaliq.
      return TextStyle(
        fontFamily: 'NotoNastaliqUrdu',
        fontSize: fontSize - 1, // Slight visual balancing for Nastaliq sizing
        fontWeight: fontWeight,
        color: color,
        height:
            height ??
            1.8, // Nastaliq looks best with room to breathe vertical flourishes
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Header Row (App Name + Language Toggle) ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LumenAI',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isUrdu
                              ? _LocalizedStrings.appSubtitleUr
                              : _LocalizedStrings.appSubtitleEn,
                          style: _getTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                          ).copyWith(letterSpacing: _isUrdu ? 0 : 1.6),
                        ),
                      ],
                    ),

                    // Language Toggle Button
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

                const Spacer(),

                // ── Hero text ─────────────────────────────────────────────────
                Text(
                  _isUrdu
                      ? _LocalizedStrings.heroLine1Ur
                      : _LocalizedStrings.heroLine1En,
                  style: _getTextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                    height: 1.15,
                  ),
                ),
                Text(
                  _isUrdu
                      ? _LocalizedStrings.heroLine2Ur
                      : _LocalizedStrings.heroLine2En,
                  style: _getTextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: kAccent,
                    height: 1.15,
                    isItalic: true,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  _isUrdu
                      ? _LocalizedStrings.bodyTextUr
                      : _LocalizedStrings.bodyTextEn,
                  style: _getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: kTextBody,
                    height: _isUrdu ? 1.8 : 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // ── CHW button ────────────────────────────────────────────────
                _ModeButton(
                  icon: Icons.medical_services_outlined,
                  title: _isUrdu
                      ? _LocalizedStrings.chwTitleUr
                      : _LocalizedStrings.chwTitleEn,
                  subtitle: _isUrdu
                      ? _LocalizedStrings.chwSubtitleUr
                      : _LocalizedStrings.chwSubtitleEn,
                  isPrimary: true,
                  isUrdu: _isUrdu,
                  onTap: () async {
                    final hasId = await ChwPreferences.hasIdentifier();
                    if (!context.mounted) return;
                    if (hasId) {
                      Navigator.pushNamed(context, '/home');
                    } else {
                      Navigator.pushNamed(context, '/chw-setup');
                    }
                  },
                ),

                const SizedBox(height: 14),

                // ── Self assessment button ────────────────────────────────────
                _ModeButton(
                  icon: Icons.person_search_outlined,
                  title: _isUrdu
                      ? _LocalizedStrings.selfTitleUr
                      : _LocalizedStrings.selfTitleEn,
                  subtitle: _isUrdu
                      ? _LocalizedStrings.selfSubtitleUr
                      : _LocalizedStrings.selfSubtitleEn,
                  isPrimary: false,
                  isUrdu: _isUrdu,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/self-assessment',
                    arguments: {'isUrdu': _isUrdu},
                  ),
                ),
                const Spacer(),

                // ── Disclaimer ────────────────────────────────────────────────
                Center(
                  child: Text(
                    _isUrdu
                        ? _LocalizedStrings.disclaimerUr
                        : _LocalizedStrings.disclaimerEn,
                    textAlign: TextAlign.center,
                    style: _getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: kTextMuted,
                    ).copyWith(letterSpacing: _isUrdu ? 0 : 0.3),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mode button ───────────────────────────────────────────────────────────────
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final bool isUrdu;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(18),
          border: isPrimary ? null : Border.all(color: kBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withOpacity(0.1)
                    : kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isPrimary ? Colors.white : kAccent,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : kPrimary,
                      height: isUrdu ? 1.8 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                      fontSize: isUrdu ? 11 : 12,
                      height: isUrdu ? 1.8 : 1.4,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.6)
                          : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Rotates the chevron indicator automatically if in RTL mode
            RotatedBox(
              quarterTurns: isUrdu ? 2 : 0,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isPrimary ? Colors.white.withOpacity(0.5) : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
