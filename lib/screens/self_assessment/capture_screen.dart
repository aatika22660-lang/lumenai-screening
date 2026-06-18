import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/screening_model.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

// ── Localized Strings ─────────────────────────────────────────────────────────
class _L {
  static const titleEn = 'Capture Photos';
  static const titleUr = 'تصاویر لیں';

  static const subtitleEn =
      'Take or upload 3 clear photos of your mouth under good lighting.';
  static const subtitleUr =
      'اچھی روشنی میں اپنے منہ کی ۳ واضح تصاویر لیں یا اپلوڈ کریں۔';

  static const ctaEn = 'Analyze Photos  →';
  static const ctaUr = 'تصاویر کا تجزیہ کریں  ←';

  static const missingEn = 'Please capture all 3 photos before proceeding.';
  static const missingUr = 'براہ کرم آگے بڑھنے سے پہلے تمام ۳ تصاویر لیں۔';

  static const addPhotoEn = 'Add photo';
  static const addPhotoUr = 'تصویر شامل کریں';

  static const cameraEn = 'Camera';
  static const cameraUr = 'کیمرہ';

  static const galleryEn = 'Gallery';
  static const galleryUr = 'گیلری';

  static const retakeEn = 'Retake';
  static const retakeUr = 'دوبارہ لیں';

  static const capturedEn = 'Photo added';
  static const capturedUr = 'تصویر شامل ہو گئی';
}

// ── Slot model ────────────────────────────────────────────────────────────────
class _Slot {
  final String key;
  final String labelEn;
  final String labelUr;
  final String hintEn;
  final String hintUr;
  final _SlotType type;
  final List<String> instructions;

  const _Slot({
    required this.key,
    required this.labelEn,
    required this.labelUr,
    required this.hintEn,
    required this.hintUr,
    required this.type,
    required this.instructions,
  });
}

enum _SlotType { fullMouth, tongue, cheek }

const _slots = [
  _Slot(
    key: 'Full Mouth',
    labelEn: 'Full Mouth',
    labelUr: 'پورا منہ',
    hintEn: 'Open wide',
    hintUr: 'منہ کھولیں',
    type: _SlotType.fullMouth,
    instructions: [
      'Open mouth as wide as possible',
      'Include all teeth and gum line',
      'Hold camera 15–20 cm away',
    ],
  ),
  _Slot(
    key: 'Tongue',
    labelEn: 'Tongue',
    labelUr: 'زبان',
    hintEn: 'Stick it out',
    hintUr: 'زبان باہر نکالیں',
    type: _SlotType.tongue,
    instructions: [
      'Extend tongue fully out of mouth',
      'Capture the top surface clearly',
      'Tilt tongue to show both sides',
    ],
  ),
  _Slot(
    key: 'Inner Cheek',
    labelEn: 'Inner Cheek',
    labelUr: 'اندرونی گال',
    hintEn: 'Pull cheek aside',
    hintUr: 'گال کھینچیں',
    type: _SlotType.cheek,
    instructions: [],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class CaptureScreen extends StatefulWidget {
  final SelfAssessmentAnswers answers;
  final bool initialIsUrdu;

  const CaptureScreen({
    super.key,
    required this.answers,
    this.initialIsUrdu = false,
  });

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late bool _isUrdu;
  final Map<String, File?> _files = {
    'Full Mouth': null,
    'Tongue': null,
    'Inner Cheek': null,
  };
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isUrdu = widget.initialIsUrdu;
  }

  TextStyle _ts({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  }) {
    if (_isUrdu) {
      return TextStyle(
        fontFamily: 'NotoNastaliqUrdu',
        fontSize: size - 1,
        fontWeight: weight,
        color: color,
        height: height ?? 1.9,
      );
    }
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  Future<void> _pick(String key, ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _files[key] = File(picked.path));
  }

  void _showSourceSheet(String key) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  _isUrdu ? _L.addPhotoUr : _L.addPhotoEn,
                  style: _ts(
                    size: 18,
                    weight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _SheetTile(
                  icon: Icons.camera_alt_rounded,
                  label: _isUrdu ? _L.cameraUr : _L.cameraEn,
                  sub: _isUrdu ? 'ابھی تصویر لیں' : 'Take a photo now',
                  iconBg: kPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    _pick(key, ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                _SheetTile(
                  icon: Icons.photo_library_rounded,
                  label: _isUrdu ? _L.galleryUr : _L.galleryEn,
                  sub: _isUrdu
                      ? 'موجودہ تصویر منتخب کریں'
                      : 'Choose an existing photo',
                  iconBg: kAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _pick(key, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _proceed() {
    if (_files.values.any((f) => f == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isUrdu ? _L.missingUr : _L.missingEn),
          backgroundColor: const Color(0xFF9B3A3A),
        ),
      );
      return;
    }

    final images = _files.entries
        .map((e) => SelfAssessmentImage(label: e.key, file: e.value!))
        .toList();

    Navigator.pushNamed(
      context,
      '/self-assessment/analysing',
      arguments: {
        'answers': widget.answers,
        'images': images,
        'isUrdu': _isUrdu,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDone = _files.values.every((f) => f != null);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: _isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
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

              // ── Title ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Text(
                  _isUrdu ? _L.titleUr : _L.titleEn,
                  style: _ts(
                    size: 28,
                    weight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text(
                  _isUrdu ? _L.subtitleUr : _L.subtitleEn,
                  style: _ts(
                    size: 14,
                    weight: FontWeight.w400,
                    color: kTextMuted,
                    height: 1.5,
                  ),
                ),
              ),

              // ── Slot cards ───────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  itemCount: _slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final slot = _slots[i];
                    final file = _files[slot.key];
                    final label = _isUrdu ? slot.labelUr : slot.labelEn;
                    final hint = _isUrdu ? slot.hintUr : slot.hintEn;
                    return _SlotCard(
                      slot: slot,
                      file: file,
                      label: label,
                      hint: hint,
                      isUrdu: _isUrdu,
                      ts: _ts,
                      onTap: () => file == null
                          ? _showSourceSheet(slot.key)
                          : _showSourceSheet(slot.key),
                      retakeLabel: _isUrdu ? _L.retakeUr : _L.retakeEn,
                      capturedLabel: _isUrdu ? _L.capturedUr : _L.capturedEn,
                      addLabel: _isUrdu ? _L.addPhotoUr : _L.addPhotoEn,
                    );
                  },
                ),
              ),

              // ── CTA ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: allDone ? _proceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      disabledBackgroundColor: kBorder,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: kTextMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isUrdu ? _L.ctaUr : _L.ctaEn,
                      style: _ts(
                        size: 16,
                        weight: FontWeight.w600,
                        color: allDone ? Colors.white : kTextMuted,
                        height: 1.0,
                      ).copyWith(letterSpacing: _isUrdu ? 0 : 0.2),
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

// ── Slot card ─────────────────────────────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final _Slot slot;
  final File? file;
  final String label;
  final String hint;
  final bool isUrdu;
  final String retakeLabel;
  final String capturedLabel;
  final String addLabel;
  final VoidCallback onTap;
  final TextStyle Function({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  })
  ts;

  const _SlotCard({
    required this.slot,
    required this.file,
    required this.label,
    required this.hint,
    required this.isUrdu,
    required this.ts,
    required this.onTap,
    required this.retakeLabel,
    required this.capturedLabel,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    final captured = file != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: captured ? kAccent : kBorder,
          width: captured ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Illustration + preview row ──────────────────────────────────
          SizedBox(
            height: 148,
            child: Row(
              children: [
                // Illustration panel
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left: isUrdu ? Radius.zero : const Radius.circular(17),
                    right: isUrdu ? const Radius.circular(17) : Radius.zero,
                  ),
                  child: SizedBox(
                    width: 130,
                    height: 148,
                    child: captured
                        ? Image.file(file!, fit: BoxFit.cover)
                        : _MedicalIllustration(type: slot.type),
                  ),
                ),

                // Text + action
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: ts(
                                size: 15,
                                weight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (!captured) ...[
                              // Instruction lines — always English, clinical
                              ...slot.instructions.map(
                                (line) => Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '— ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: kTextMuted,
                                          height: 1.6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          line,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: kTextBody,
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              Text(
                                capturedLabel,
                                style: ts(
                                  size: 13,
                                  weight: FontWeight.w400,
                                  color: kAccent,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: captured
                                  ? kAccent.withOpacity(0.1)
                                  : kPrimary,
                              borderRadius: BorderRadius.circular(10),
                              border: captured
                                  ? Border.all(color: kAccent, width: 1)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  captured
                                      ? Icons.refresh_rounded
                                      : Icons.add_a_photo_rounded,
                                  size: 14,
                                  color: captured ? kAccent : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  captured ? retakeLabel : addLabel,
                                  style: ts(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: captured ? kAccent : Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Check badge
                if (captured)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medical line illustration ─────────────────────────────────────────────────
// Clean single-weight outlines, no fills, no colour — health pamphlet style.
class _MedicalIllustration extends StatelessWidget {
  final _SlotType type;
  const _MedicalIllustration({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: CustomPaint(painter: _MedicalPainter(type)),
    );
  }
}

class _MedicalPainter extends CustomPainter {
  final _SlotType type;
  const _MedicalPainter(this.type);

  // Single shared stroke paint — thin, precise, dark
  Paint get _p => Paint()
    ..color = const Color(0xFF1C1C1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _thin => Paint()
    ..color = const Color(0xFF1C1C1A).withOpacity(0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size s) {
    switch (type) {
      case _SlotType.fullMouth:
        _fullMouth(canvas, s);
        break;
      case _SlotType.tongue:
        _tongue(canvas, s);
        break;
      case _SlotType.cheek:
        _cheek(canvas, s);
        break;
    }
  }

  // ── Full mouth open — frontal view ───────────────────────────────────────
  void _fullMouth(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 + 4;

    // Outer lip boundary
    final lips = Path()
      ..moveTo(cx - s.width * 0.30, cy)
      ..cubicTo(
        cx - s.width * 0.28,
        cy - s.height * 0.22,
        cx - s.width * 0.08,
        cy - s.height * 0.26,
        cx,
        cy - s.height * 0.24,
      )
      ..cubicTo(
        cx + s.width * 0.08,
        cy - s.height * 0.26,
        cx + s.width * 0.28,
        cy - s.height * 0.22,
        cx + s.width * 0.30,
        cy,
      )
      ..cubicTo(
        cx + s.width * 0.26,
        cy + s.height * 0.22,
        cx + s.width * 0.08,
        cy + s.height * 0.26,
        cx,
        cy + s.height * 0.24,
      )
      ..cubicTo(
        cx - s.width * 0.08,
        cy + s.height * 0.26,
        cx - s.width * 0.26,
        cy + s.height * 0.22,
        cx - s.width * 0.30,
        cy,
      )
      ..close();
    canvas.drawPath(lips, _p);

    // Cupid's bow on upper lip
    final bow = Path()
      ..moveTo(cx - s.width * 0.30, cy)
      ..cubicTo(
        cx - s.width * 0.16,
        cy - s.height * 0.04,
        cx - s.width * 0.06,
        cy - s.height * 0.10,
        cx,
        cy - s.height * 0.07,
      )
      ..cubicTo(
        cx + s.width * 0.06,
        cy - s.height * 0.10,
        cx + s.width * 0.16,
        cy - s.height * 0.04,
        cx + s.width * 0.30,
        cy,
      );
    canvas.drawPath(bow, _p);

    // Lower lip curve
    final lower = Path()
      ..moveTo(cx - s.width * 0.30, cy)
      ..cubicTo(
        cx - s.width * 0.14,
        cy + s.height * 0.06,
        cx + s.width * 0.14,
        cy + s.height * 0.06,
        cx + s.width * 0.30,
        cy,
      );
    canvas.drawPath(lower, _thin);

    // Oral opening (open mouth cavity outline)
    final opening = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: s.width * 0.46,
          height: s.height * 0.32,
        ),
      );
    canvas.drawPath(opening, _p);

    // Upper teeth — 6 visible teeth
    final toothW = s.width * 0.065;
    final toothH = s.height * 0.10;
    final teethTop = cy - s.height * 0.16;
    final startX = cx - toothW * 3;
    for (int i = 0; i < 6; i++) {
      final tx = startX + i * toothW;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx + 1, teethTop, toothW - 2, toothH),
          const Radius.circular(2),
        ),
        _p,
      );
    }

    // Lower teeth — 6 visible teeth
    final lowerTeethTop = cy + s.height * 0.06;
    for (int i = 0; i < 6; i++) {
      final tx = startX + i * toothW;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx + 1, lowerTeethTop, toothW - 2, toothH * 0.85),
          const Radius.circular(2),
        ),
        _p,
      );
    }

    // Tongue just visible at bottom of cavity
    final tongue = Path()
      ..moveTo(cx - s.width * 0.12, cy + s.height * 0.08)
      ..cubicTo(
        cx - s.width * 0.14,
        cy + s.height * 0.16,
        cx + s.width * 0.14,
        cy + s.height * 0.16,
        cx + s.width * 0.12,
        cy + s.height * 0.08,
      )
      ..cubicTo(
        cx + s.width * 0.06,
        cy + s.height * 0.04,
        cx - s.width * 0.06,
        cy + s.height * 0.04,
        cx - s.width * 0.12,
        cy + s.height * 0.08,
      )
      ..close();
    canvas.drawPath(tongue, _thin);

    // Midline on tongue
    canvas.drawLine(
      Offset(cx, cy + s.height * 0.05),
      Offset(cx, cy + s.height * 0.15),
      _thin,
    );
  }

  // ── Tongue extended — frontal view ───────────────────────────────────────
  void _tongue(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    // Closed lips at top (tongue sticking out below)
    final upperLip = Path()
      ..moveTo(cx - s.width * 0.28, cy - s.height * 0.24)
      ..cubicTo(
        cx - s.width * 0.24,
        cy - s.height * 0.36,
        cx - s.width * 0.06,
        cy - s.height * 0.38,
        cx,
        cy - s.height * 0.36,
      )
      ..cubicTo(
        cx + s.width * 0.06,
        cy - s.height * 0.38,
        cx + s.width * 0.24,
        cy - s.height * 0.36,
        cx + s.width * 0.28,
        cy - s.height * 0.24,
      );
    canvas.drawPath(upperLip, _p);

    // Cupid's bow
    final bow = Path()
      ..moveTo(cx - s.width * 0.28, cy - s.height * 0.24)
      ..cubicTo(
        cx - s.width * 0.12,
        cy - s.height * 0.28,
        cx - s.width * 0.04,
        cy - s.height * 0.22,
        cx,
        cy - s.height * 0.20,
      )
      ..cubicTo(
        cx + s.width * 0.04,
        cy - s.height * 0.22,
        cx + s.width * 0.12,
        cy - s.height * 0.28,
        cx + s.width * 0.28,
        cy - s.height * 0.24,
      );
    canvas.drawPath(bow, _thin);

    // Lower lip parted
    final lowerLip = Path()
      ..moveTo(cx - s.width * 0.28, cy - s.height * 0.24)
      ..cubicTo(
        cx - s.width * 0.22,
        cy - s.height * 0.14,
        cx - s.width * 0.20,
        cy - s.height * 0.10,
        cx - s.width * 0.18,
        cy - s.height * 0.08,
      );
    canvas.drawPath(lowerLip, _p);

    final lowerLipR = Path()
      ..moveTo(cx + s.width * 0.28, cy - s.height * 0.24)
      ..cubicTo(
        cx + s.width * 0.22,
        cy - s.height * 0.14,
        cx + s.width * 0.20,
        cy - s.height * 0.10,
        cx + s.width * 0.18,
        cy - s.height * 0.08,
      );
    canvas.drawPath(lowerLipR, _p);

    // Tongue body — rounded rectangle extending down
    final tongue = Path()
      ..moveTo(cx - s.width * 0.18, cy - s.height * 0.08)
      ..cubicTo(
        cx - s.width * 0.20,
        cy + s.height * 0.12,
        cx - s.width * 0.18,
        cy + s.height * 0.30,
        cx,
        cy + s.height * 0.36,
      )
      ..cubicTo(
        cx + s.width * 0.18,
        cy + s.height * 0.30,
        cx + s.width * 0.20,
        cy + s.height * 0.12,
        cx + s.width * 0.18,
        cy - s.height * 0.08,
      )
      ..cubicTo(
        cx + s.width * 0.10,
        cy - s.height * 0.12,
        cx - s.width * 0.10,
        cy - s.height * 0.12,
        cx - s.width * 0.18,
        cy - s.height * 0.08,
      )
      ..close();
    canvas.drawPath(tongue, _p);

    // Midline groove
    canvas.drawLine(
      Offset(cx, cy - s.height * 0.06),
      Offset(cx, cy + s.height * 0.28),
      _thin,
    );

    // Papillae suggestion — small tick marks along midline
    for (int i = 0; i < 5; i++) {
      final y = cy + s.height * (0.00 + i * 0.06);
      canvas.drawLine(
        Offset(cx - s.width * 0.04, y),
        Offset(cx + s.width * 0.04, y),
        _thin,
      );
    }

    // Tip curve
    final tip = Path()
      ..moveTo(cx - s.width * 0.10, cy + s.height * 0.28)
      ..cubicTo(
        cx - s.width * 0.05,
        cy + s.height * 0.38,
        cx + s.width * 0.05,
        cy + s.height * 0.38,
        cx + s.width * 0.10,
        cy + s.height * 0.28,
      );
    canvas.drawPath(tip, _p);
  }

  // ── Inner cheek — cross-section / pulled view ────────────────────────────
  void _cheek(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    // Outer face contour — just the lower half (chin to cheek)
    final face = Path()
      ..moveTo(cx - s.width * 0.36, cy - s.height * 0.30)
      ..cubicTo(
        cx - s.width * 0.40,
        cy,
        cx - s.width * 0.32,
        cy + s.height * 0.32,
        cx,
        cy + s.height * 0.40,
      )
      ..cubicTo(
        cx + s.width * 0.32,
        cy + s.height * 0.32,
        cx + s.width * 0.40,
        cy,
        cx + s.width * 0.36,
        cy - s.height * 0.30,
      );
    canvas.drawPath(face, _thin);

    // Wide-open mouth outline
    final mouth = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, cy + s.height * 0.04),
          width: s.width * 0.54,
          height: s.height * 0.38,
        ),
      );
    canvas.drawPath(mouth, _p);

    // Inner cheek wall — right side pulled, shown as arc
    final cheekWall = Path()
      ..moveTo(cx + s.width * 0.18, cy - s.height * 0.14)
      ..cubicTo(
        cx + s.width * 0.30,
        cy - s.height * 0.08,
        cx + s.width * 0.32,
        cy + s.height * 0.16,
        cx + s.width * 0.18,
        cy + s.height * 0.22,
      );
    canvas.drawPath(cheekWall, _p);

    // Mucosal texture lines on cheek wall (horizontal hatch, faint)
    for (int i = 0; i < 4; i++) {
      final y = cy - s.height * 0.08 + i * s.height * 0.08;
      canvas.drawLine(
        Offset(cx + s.width * 0.18, y),
        Offset(cx + s.width * 0.28, y),
        _thin,
      );
    }

    // Upper teeth — 5 visible
    final toothW = s.width * 0.07;
    final toothH = s.height * 0.10;
    final teethTop = cy - s.height * 0.16;
    final startX = cx - toothW * 2.5;
    for (int i = 0; i < 5; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + i * toothW + 1, teethTop, toothW - 2, toothH),
          const Radius.circular(2),
        ),
        _p,
      );
    }

    // Finger pulling right cheek — simple elongated rounded rect
    final finger = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cx + s.width * 0.32,
            cy - s.height * 0.12,
            s.width * 0.14,
            s.height * 0.28,
          ),
          Radius.circular(s.width * 0.07),
        ),
      );
    canvas.drawPath(finger, _p);

    // Fingernail detail
    canvas.drawArc(
      Rect.fromLTWH(
        cx + s.width * 0.34,
        cy - s.height * 0.12,
        s.width * 0.10,
        s.height * 0.06,
      ),
      3.14,
      3.14,
      false,
      _thin,
    );

    // Knuckle lines
    for (int i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + s.width * 0.33, cy - s.height * 0.12 + i * s.height * 0.09),
        Offset(cx + s.width * 0.45, cy - s.height * 0.12 + i * s.height * 0.09),
        _thin,
      );
    }

    // Arrow indicating the area of interest
    final arrowX = cx + s.width * 0.22;
    final arrowY = cy + s.height * 0.06;
    canvas.drawLine(
      Offset(cx + s.width * 0.04, arrowY),
      Offset(arrowX, arrowY),
      _thin,
    );
    // Arrowhead
    canvas.drawLine(
      Offset(arrowX, arrowY),
      Offset(arrowX - 5, arrowY - 4),
      _thin,
    );
    canvas.drawLine(
      Offset(arrowX, arrowY),
      Offset(arrowX - 5, arrowY + 4),
      _thin,
    );
  }

  @override
  bool shouldRepaint(_MedicalPainter old) => old.type != type;
}

// ── Bottom sheet tile ─────────────────────────────────────────────────────────
class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color iconBg;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
