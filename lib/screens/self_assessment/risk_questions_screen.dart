import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/screening_model.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

// ── Localised strings ─────────────────────────────────────────────────────────
class _S {
  static const headingEn = 'A few quick\nquestions.';
  static const headingUr = 'چند سوالات۔';
  static const subheadingEn = 'This helps us understand your risk level.';
  static const subheadingUr =
      'یہ ہمیں آپ کے خطرے کی سطح سمجھنے میں مدد کرتا ہے۔';
  static const q1En = 'How old are you?';
  static const q1Ur = 'آپ کی عمر کتنی ہے؟';
  static const q1HintEn = 'e.g. 35';
  static const q1HintUr = 'مثلاً ۳۵';
  static const q1SuffixEn = 'yrs';
  static const q1SuffixUr = 'سال';
  static const q2En = 'Do you use tobacco?';
  static const q2Ur = 'کیا آپ تمباکو استعمال کرتے ہیں؟';
  static const yesEn = 'Yes';
  static const yesUr = 'ہاں';
  static const noEn = 'No';
  static const noUr = 'نہیں';
  static const q2bEn = 'Which type?';
  static const q2bUr = 'کون سی قسم؟';
  static const q3En = 'Have you noticed anything unusual?  ·  optional';
  static const q3Ur = 'کیا آپ نے کچھ غیر معمولی محسوس کیا؟  ·  اختیاری';
  static const continueEn = 'Continue';
  static const continueUr = 'آگے بڑھیں';

  static const tobaccoEn = {
    'Gutka': 'Gutka',
    'Paan': 'Paan',
    'Naswar': 'Naswar',
    'Cigarettes': 'Cigarettes',
    'Multiple': 'Multiple',
  };
  static const tobaccoUr = {
    'Gutka': 'گٹکا / چھالیہ / پان',
    'Paan': 'پان',
    'Naswar': 'نسوار',
    'Cigarettes': 'سگریٹ / شیشہ',
    'Multiple': 'ایک سے زیادہ',
  };
  static const symptomsEn = {
    'Pain or soreness': 'Pain or soreness',
    'White or red patches': 'White or red patches',
    'Difficulty swallowing': 'Difficulty swallowing',
    'Numbness': 'Numbness',
  };
  static const symptomsUr = {
    'Pain or soreness': 'درد یا تکلیف',
    'White or red patches': 'سفید یا سرخ دھبے',
    'Difficulty swallowing': 'نگلنے میں دشواری',
    'Numbness': 'سن ہونا',
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────
class RiskQuestionsScreen extends StatefulWidget {
  final bool initialIsUrdu;
  const RiskQuestionsScreen({super.key, this.initialIsUrdu = false});

  @override
  State<RiskQuestionsScreen> createState() => _RiskQuestionsScreenState();
}

class _RiskQuestionsScreenState extends State<RiskQuestionsScreen> {
  late bool _isUrdu;
  final TextEditingController _ageController = TextEditingController();
  bool? _usesTobacco;
  String? _tobaccoType;
  final Set<String> _symptoms = {};

  @override
  void initState() {
    super.initState();
    _isUrdu = widget.initialIsUrdu;
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_ageController.text.isEmpty) return false;
    if (_usesTobacco == null) return false;
    if (_usesTobacco == true && _tobaccoType == null) return false;
    return true;
  }

  void _continue() {
    final answers = SelfAssessmentAnswers(
      age: int.parse(_ageController.text),
      usesTobacco: _usesTobacco ?? false,
      tobaccoType: _usesTobacco == true ? _tobaccoType : null,
      symptoms: _symptoms.toList(),
    );
    Navigator.pushNamed(
      context,
      '/self-assessment/capture',
      arguments: {'answers': answers, 'isUrdu': _isUrdu},
    );
  }

  TextStyle _urduStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = kTextBody,
    double height = 1.9,
  }) {
    return TextStyle(
      fontFamily: 'NotoNastaliqUrdu',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tobacco = _isUrdu ? _S.tobaccoUr : _S.tobaccoEn;
    final symptoms = _isUrdu ? _S.symptomsUr : _S.symptomsEn;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
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
                    GestureDetector(
                      onTap: () => setState(() => _isUrdu = !_isUrdu),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(
                          _isUrdu ? 'English' : 'اردو',
                          style: TextStyle(
                            fontFamily: _isUrdu ? null : 'NotoNastaliqUrdu',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isUrdu
                          ? Text(
                              _S.headingUr,
                              style: _urduStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: kPrimary,
                                height: 1.6,
                              ),
                            )
                          : Text(
                              _S.headingEn,
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),

                      const SizedBox(height: 8),

                      _isUrdu
                          ? Text(
                              _S.subheadingUr,
                              style: _urduStyle(color: kTextBody),
                            )
                          : Text(
                              _S.subheadingEn,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: kTextBody,
                              ),
                            ),

                      const SizedBox(height: 32),

                      // Q1: Age
                      _SectionLabel(
                        _isUrdu ? _S.q1Ur : _S.q1En,
                        isUrdu: _isUrdu,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => setState(() {}),
                          textAlign: _isUrdu ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _isUrdu ? _S.q1HintUr : _S.q1HintEn,
                            hintStyle: const TextStyle(
                              color: kTextMuted,
                              fontSize: 15,
                            ),
                            suffixText: _ageController.text.isNotEmpty
                                ? (_isUrdu ? _S.q1SuffixUr : _S.q1SuffixEn)
                                : '',
                            suffixStyle: const TextStyle(
                              fontSize: 15,
                              color: kTextMuted,
                            ),
                          ),
                          style: const TextStyle(fontSize: 15, color: kPrimary),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Q2: Tobacco
                      _SectionLabel(
                        _isUrdu ? _S.q2Ur : _S.q2En,
                        isUrdu: _isUrdu,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _BigChoiceButton(
                              label: _isUrdu ? _S.yesUr : _S.yesEn,
                              selected: _usesTobacco == true,
                              isUrdu: _isUrdu,
                              onTap: () => setState(() => _usesTobacco = true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BigChoiceButton(
                              label: _isUrdu ? _S.noUr : _S.noEn,
                              selected: _usesTobacco == false,
                              isUrdu: _isUrdu,
                              onTap: () => setState(() {
                                _usesTobacco = false;
                                _tobaccoType = null;
                              }),
                            ),
                          ),
                        ],
                      ),

                      if (_usesTobacco == true) ...[
                        const SizedBox(height: 20),
                        _SectionLabel(
                          _isUrdu ? _S.q2bUr : _S.q2bEn,
                          isUrdu: _isUrdu,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: tobacco.entries
                              .map(
                                (e) => _ChipButton(
                                  label: e.value,
                                  selected: _tobaccoType == e.key,
                                  isUrdu: _isUrdu,
                                  onTap: () =>
                                      setState(() => _tobaccoType = e.key),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Q3: Symptoms
                      _SectionLabel(
                        _isUrdu ? _S.q3Ur : _S.q3En,
                        isUrdu: _isUrdu,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: symptoms.entries
                            .map(
                              (e) => _ChipButton(
                                label: e.value,
                                selected: _symptoms.contains(e.key),
                                isUrdu: _isUrdu,
                                onTap: () => setState(() {
                                  _symptoms.contains(e.key)
                                      ? _symptoms.remove(e.key)
                                      : _symptoms.add(e.key);
                                }),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Continue button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kBorder,
                      disabledForegroundColor: kTextMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isUrdu
                        ? Text(
                            _S.continueUr,
                            style: _urduStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _canContinue ? Colors.white : kTextMuted,
                              height: 1.0,
                            ),
                          )
                        : const Text(
                            _S.continueEn,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isUrdu;
  const _SectionLabel(this.text, {required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: isUrdu
          ? const TextStyle(
              fontFamily: 'NotoNastaliqUrdu',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
              height: 1.9,
            )
          : const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
              letterSpacing: 0.2,
            ),
    );
  }
}

class _BigChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isUrdu;
  final VoidCallback onTap;

  const _BigChoiceButton({
    required this.label,
    required this.selected,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 64,
        decoration: BoxDecoration(
          color: selected ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 0 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: isUrdu
                ? TextStyle(
                    fontFamily: 'NotoNastaliqUrdu',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kTextBody,
                    height: 1.0,
                  )
                : TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kTextBody,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isUrdu;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.selected,
    required this.isUrdu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 0 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: isUrdu
              ? TextStyle(
                  fontFamily: 'NotoNastaliqUrdu',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : kTextBody,
                  height: 1.5,
                )
              : TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : kTextBody,
                ),
        ),
      ),
    );
  }
}
