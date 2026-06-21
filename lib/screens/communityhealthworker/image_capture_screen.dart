import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/patient_model.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);
const kBlueLight = Color(0xFF3B5BDB);

// ── OralLocation enum + extension ────────────────────────────────────────────
enum OralLocation {
  topOfTongue,
  undersideOfTongue,
  sideOfTongue,
  floorOfMouth,
  roofOfMouth,
  innerCheek,
  lips,
  gums,
}

extension OralLocationDetails on OralLocation {
  String get label {
    switch (this) {
      case OralLocation.topOfTongue:
        return 'Top of tongue';
      case OralLocation.undersideOfTongue:
        return 'Underside of tongue';
      case OralLocation.sideOfTongue:
        return 'Side of tongue';
      case OralLocation.floorOfMouth:
        return 'Floor of mouth';
      case OralLocation.roofOfMouth:
        return 'Roof of mouth';
      case OralLocation.innerCheek:
        return 'Inner cheek';
      case OralLocation.lips:
        return 'Lips';
      case OralLocation.gums:
        return 'Gums';
    }
  }

  Color get regionColor {
    switch (this) {
      case OralLocation.roofOfMouth:
        return const Color(0xFF9B8FC0);
      case OralLocation.floorOfMouth:
        return const Color(0xFF4A7B8C);
      case OralLocation.innerCheek:
        return const Color(0xFF7A9E6B);
      case OralLocation.topOfTongue:
        return const Color(0xFFD4728A);
      case OralLocation.sideOfTongue:
        return const Color(0xFFE8955A);
      case OralLocation.undersideOfTongue:
        return const Color(0xFF5B8CC4);
      case OralLocation.lips:
        return const Color(0xFFE05C8A);
      case OralLocation.gums:
        return const Color(0xFFB06090);
    }
  }

  MouthRegion get mouthRegion {
    switch (this) {
      case OralLocation.roofOfMouth:
        return MouthRegion.roof;
      case OralLocation.floorOfMouth:
        return MouthRegion.floor;
      case OralLocation.innerCheek:
        return MouthRegion.cheeks;
      case OralLocation.topOfTongue:
        return MouthRegion.tongueTop;
      case OralLocation.sideOfTongue:
        return MouthRegion.tongueSides;
      case OralLocation.undersideOfTongue:
        return MouthRegion.tongueUnder;
      case OralLocation.lips:
        return MouthRegion.lips;
      case OralLocation.gums:
        return MouthRegion.gums;
    }
  }

  List<ImageSlot> get imageSlots {
    switch (this) {
      case OralLocation.topOfTongue:
        return [
          ImageSlot(label: 'White light · top of tongue', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · top of tongue', isBlueLight: true),
        ];
      case OralLocation.undersideOfTongue:
        return [
          ImageSlot(
            label: 'White light · underside of tongue',
            isBlueLight: false,
          ),
          ImageSlot(
            label: 'Fluorescence · underside of tongue',
            isBlueLight: true,
          ),
        ];
      case OralLocation.floorOfMouth:
        return [
          ImageSlot(label: 'White light · floor of mouth', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · floor of mouth', isBlueLight: true),
        ];
      case OralLocation.sideOfTongue:
        return [
          ImageSlot(
            label: 'White light · right side of tongue',
            isBlueLight: false,
          ),
          ImageSlot(
            label: 'White light · left side of tongue',
            isBlueLight: false,
          ),
          ImageSlot(
            label: 'Fluorescence · right side of tongue',
            isBlueLight: true,
          ),
          ImageSlot(
            label: 'Fluorescence · left side of tongue',
            isBlueLight: true,
          ),
        ];
      case OralLocation.roofOfMouth:
        return [
          ImageSlot(label: 'White light · Hard palate', isBlueLight: false),
          ImageSlot(label: 'White light · Soft palate', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · Hard palate', isBlueLight: true),
          ImageSlot(label: 'Fluorescence · Soft palate', isBlueLight: true),
        ];
      case OralLocation.innerCheek:
        return [
          ImageSlot(label: 'White light · Right cheek', isBlueLight: false),
          ImageSlot(label: 'White light · Left cheek', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · Right cheek', isBlueLight: true),
          ImageSlot(label: 'Fluorescence · Left cheek', isBlueLight: true),
        ];
      case OralLocation.lips:
        return [
          ImageSlot(label: 'White light · Upper lip', isBlueLight: false),
          ImageSlot(label: 'White light · Lower lip', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · Upper lip', isBlueLight: true),
          ImageSlot(label: 'Fluorescence · Lower lip', isBlueLight: true),
        ];
      case OralLocation.gums:
        return [
          ImageSlot(label: 'White light · Upper gums', isBlueLight: false),
          ImageSlot(label: 'White light · Lower gums', isBlueLight: false),
          ImageSlot(label: 'Fluorescence · Upper gums', isBlueLight: true),
          ImageSlot(label: 'Fluorescence · Lower gums', isBlueLight: true),
        ];
    }
  }
}

// ── Image slot ────────────────────────────────────────────────────────────────
class ImageSlot {
  final String label;
  final bool isBlueLight;
  const ImageSlot({required this.label, required this.isBlueLight});
}

class _TaggedSlot {
  final ImageSlot slot;
  final OralLocation location;
  const _TaggedSlot({required this.slot, required this.location});
}

// ── Mouth region enum ─────────────────────────────────────────────────────────
enum MouthRegion {
  lips,
  gums,
  roof,
  floor,
  cheeks,
  tongueTop,
  tongueSides,
  tongueUnder,
}

// ── Mini mouth silhouette icon ────────────────────────────────────────────────
class _MouthIcon extends StatelessWidget {
  final MouthRegion region;
  final Color color;
  final bool isSelected;

  const _MouthIcon({
    required this.region,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _MouthIconPainter(
          region: region,
          color: color,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class _MouthIconPainter extends CustomPainter {
  final MouthRegion region;
  final Color color;
  final bool isSelected;

  const _MouthIconPainter({
    required this.region,
    required this.color,
    required this.isSelected,
  });

  static const double S = 48;
  static const double cx = S / 2;
  static const double cy = S / 2;

  static Path _lipsPath() {
    final p = Path();
    p.moveTo(cx - 16, cy - 2);
    p.quadraticBezierTo(cx - 10, cy - 12, cx - 4, cy - 11);
    p.quadraticBezierTo(cx, cy - 12, cx + 4, cy - 11);
    p.quadraticBezierTo(cx + 10, cy - 12, cx + 16, cy - 2);
    p.quadraticBezierTo(cx + 12, cy + 10, cx, cy + 12);
    p.quadraticBezierTo(cx - 12, cy + 10, cx - 16, cy - 2);
    p.close();
    return p;
  }

  static Path _openCavityPath() {
    final p = Path();
    p.addOval(
      Rect.fromCenter(center: const Offset(cx, cy + 1), width: 26, height: 20),
    );
    return p;
  }

  static Path _roofPath() {
    final p = Path();
    p.moveTo(cx - 10, cy - 6);
    p.quadraticBezierTo(cx, cy - 12, cx + 10, cy - 6);
    p.quadraticBezierTo(cx + 5, cy - 8, cx, cy - 8);
    p.quadraticBezierTo(cx - 5, cy - 8, cx - 10, cy - 6);
    p.close();
    return p;
  }

  static Path _floorPath() {
    final p = Path();
    p.moveTo(cx - 10, cy + 8);
    p.quadraticBezierTo(cx, cy + 13, cx + 10, cy + 8);
    p.quadraticBezierTo(cx + 5, cy + 11, cx, cy + 11);
    p.quadraticBezierTo(cx - 5, cy + 11, cx - 10, cy + 8);
    p.close();
    return p;
  }

  static Path _cheeksPath() {
    final p = Path();
    p.addOval(
      Rect.fromCenter(
        center: const Offset(cx - 10, cy + 1),
        width: 4,
        height: 14,
      ),
    );
    p.addOval(
      Rect.fromCenter(
        center: const Offset(cx + 10, cy + 1),
        width: 4,
        height: 14,
      ),
    );
    return p;
  }

  static Path _tongueTopPath() {
    final p = Path();
    p.addOval(
      Rect.fromCenter(center: const Offset(cx, cy + 3), width: 16, height: 10),
    );
    return p;
  }

  static Path _tongueSidesPath() {
    final p = Path();
    p.addOval(
      Rect.fromCenter(
        center: const Offset(cx - 8, cy + 3),
        width: 4,
        height: 8,
      ),
    );
    p.addOval(
      Rect.fromCenter(
        center: const Offset(cx + 8, cy + 3),
        width: 4,
        height: 8,
      ),
    );
    return p;
  }

  static Path _tongueUnderPath() {
    final p = Path();
    p.moveTo(cx - 6, cy + 7);
    p.quadraticBezierTo(cx, cy + 11, cx + 6, cy + 7);
    p.quadraticBezierTo(cx + 3, cy + 10, cx, cy + 10);
    p.quadraticBezierTo(cx - 3, cy + 10, cx - 6, cy + 7);
    p.close();
    return p;
  }

  static Path _gumsPath() {
    final p = Path();
    p.moveTo(cx - 11, cy - 4);
    p.quadraticBezierTo(cx, cy - 9, cx + 11, cy - 4);
    p.quadraticBezierTo(cx + 6, cy - 6, cx, cy - 6);
    p.quadraticBezierTo(cx - 6, cy - 6, cx - 11, cy - 4);
    p.close();
    p.moveTo(cx - 11, cy + 6);
    p.quadraticBezierTo(cx, cy + 10, cx + 11, cy + 6);
    p.quadraticBezierTo(cx + 6, cy + 8, cx, cy + 8);
    p.quadraticBezierTo(cx - 6, cy + 8, cx - 11, cy + 6);
    p.close();
    return p;
  }

  Path _regionPath() {
    switch (region) {
      case MouthRegion.lips:
        return _lipsPath();
      case MouthRegion.roof:
        return _roofPath();
      case MouthRegion.floor:
        return _floorPath();
      case MouthRegion.cheeks:
        return _cheeksPath();
      case MouthRegion.tongueTop:
        return _tongueTopPath();
      case MouthRegion.tongueSides:
        return _tongueSidesPath();
      case MouthRegion.tongueUnder:
        return _tongueUnderPath();
      case MouthRegion.gums:
        return _gumsPath();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isSelected
          ? kPrimary.withValues(alpha: 0.7)
          : kPrimary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: isSelected ? 0.9 : 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(_lipsPath(), linePaint);
    canvas.drawPath(
      _openCavityPath(),
      Paint()
        ..color = isSelected
            ? kPrimary.withValues(alpha: 0.12)
            : kPrimary.withValues(alpha: 0.07)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(_openCavityPath(), linePaint);

    final upperTeeth = Path()
      ..moveTo(cx - 11, cy - 4)
      ..quadraticBezierTo(cx, cy - 8, cx + 11, cy - 4);
    canvas.drawPath(upperTeeth, linePaint);

    final lowerTeeth = Path()
      ..moveTo(cx - 11, cy + 6)
      ..quadraticBezierTo(cx, cy + 10, cx + 11, cy + 6);
    canvas.drawPath(lowerTeeth, linePaint);

    canvas.drawPath(_tongueTopPath(), linePaint);
    canvas.drawPath(_regionPath(), fillPaint);
    canvas.drawPath(_lipsPath(), linePaint);
    canvas.drawPath(_tongueTopPath(), linePaint);
  }

  @override
  bool shouldRepaint(_MouthIconPainter old) =>
      old.region != region ||
      old.color != color ||
      old.isSelected != isSelected;
}

// ── Screen states ─────────────────────────────────────────────────────────────
enum _ScreenState { locationSelect, capturing, blueLightTransition, reviewing }

// ── Main screen ───────────────────────────────────────────────────────────────
class ImageCaptureScreen extends StatefulWidget {
  final Patient patient;

  const ImageCaptureScreen({super.key, required this.patient});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen>
    with TickerProviderStateMixin {
  _ScreenState _screenState = _ScreenState.locationSelect;

  // ── Use List to preserve selection order ──────────────────────────────────
  List<OralLocation> _selectedLocations = [];

  List<_TaggedSlot> _taggedSlots = [];
  List<File?> _images = [];
  int _currentStep = 0;
  bool _blueLightShown = false;

  final ImagePicker _picker = ImagePicker();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  ImageSlot get _currentSlot => _taggedSlots[_currentStep].slot;
  void _onToggleLocation(OralLocation loc) {
    setState(() {
      if (_selectedLocations.contains(loc)) {
        _selectedLocations.remove(loc);
      } else {
        _selectedLocations.add(loc);
      }
    });
  }

  // ── All white-light slots first, then all blue-light slots ────────────────
  void _beginCapture() {
    final whiteSlots = _selectedLocations
        .expand(
          (loc) => loc.imageSlots
              .where((s) => !s.isBlueLight)
              .map((s) => _TaggedSlot(slot: s, location: loc)),
        )
        .toList();

    final blueSlots = _selectedLocations
        .expand(
          (loc) => loc.imageSlots
              .where((s) => s.isBlueLight)
              .map((s) => _TaggedSlot(slot: s, location: loc)),
        )
        .toList();

    setState(() {
      _taggedSlots = [...whiteSlots, ...blueSlots];
      _images = List.filled(_taggedSlots.length, null);
      _currentStep = 0;
      _blueLightShown = false;
      _screenState = _ScreenState.capturing;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _images[_currentStep] = File(picked.path));
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _advance();
  }

  void _advance() {
    final nextStep = _currentStep + 1;
    if (nextStep >= _taggedSlots.length) {
      setState(() => _screenState = _ScreenState.reviewing);
      return;
    }
    final nextIsBlue = _taggedSlots[nextStep].slot.isBlueLight;
    final currIsBlue = _taggedSlots[_currentStep].slot.isBlueLight;

    // Show blue-light transition screen exactly once, when we cross from white → blue
    if (nextIsBlue && !currIsBlue && !_blueLightShown) {
      setState(() {
        _currentStep = nextStep;
        _screenState = _ScreenState.blueLightTransition;
        _blueLightShown = true;
      });
      return;
    }
    setState(() {
      _currentStep = nextStep;
      _screenState = _ScreenState.capturing;
    });
  }

  void _onBlueLightReady() =>
      setState(() => _screenState = _ScreenState.capturing);

  void _onRetake(int index) {
    setState(() {
      _images[index] = null;
      _currentStep = index;
      _screenState = _ScreenState.capturing;
    });
  }

  void _onAnalyse() {
    Navigator.pushNamed(
      context,
      '/analysing',
      arguments: {
        'patient': widget.patient,
        'location': _selectedLocations.map((l) => l.label).join(', '),
        'selectedLocations': _selectedLocations,
        'imageData': List.generate(
          _taggedSlots.length,
          (i) => {
            'label': _taggedSlots[i].slot.label,
            'location': _taggedSlots[i].location.label,
            'isBlueLight': _taggedSlots[i].slot.isBlueLight,
            'file': _images[i],
          },
        ),
      },
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  Widget _patientIdStrip() {
    return Row(
      children: [
        const Icon(Icons.person_outline_rounded, size: 12, color: kTextMuted),
        const SizedBox(width: 5),
        Text(
          'Patient  ${widget.patient.id}',
          style: const TextStyle(
            fontSize: 11,
            color: kTextMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _backButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: const Icon(Icons.arrow_back, size: 18, color: kPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: switch (_screenState) {
            _ScreenState.locationSelect => KeyedSubtree(
              key: const ValueKey('location'),
              child: _buildLocationSelect(),
            ),
            _ScreenState.capturing => KeyedSubtree(
              key: ValueKey('capture-$_currentStep'),
              child: _buildCaptureView(),
            ),
            _ScreenState.blueLightTransition => KeyedSubtree(
              key: const ValueKey('blue-transition'),
              child: _BlueLightTransitionScreen(onReady: _onBlueLightReady),
            ),
            _ScreenState.reviewing => KeyedSubtree(
              key: const ValueKey('review'),
              child: _buildReviewView(),
            ),
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCREEN 1 — Location selection
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLocationSelect() {
    final locations = OralLocation.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              _backButton(onTap: () => Navigator.pop(context)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMAGE CAPTURE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                      color: kAccent,
                    ),
                  ),
                  _patientIdStrip(),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select areas to\nexamine.',
            style: GoogleFonts.inter(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select one or more areas to begin.',
            style: TextStyle(fontSize: 13, color: kTextMuted),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            itemCount: locations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final loc = locations[i];
              final isSelected = _selectedLocations.contains(loc);
              return GestureDetector(
                onTap: () => _onToggleLocation(loc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? loc.regionColor.withValues(alpha: 0.07)
                        : kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? loc.regionColor : kBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _MouthIcon(
                        region: loc.mouthRegion,
                        color: loc.regionColor,
                        isSelected: isSelected,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? kPrimary : kTextBody,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${loc.imageSlots.length} images',
                              style: TextStyle(fontSize: 12, color: kTextMuted),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? loc.regionColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? loc.regionColor : kBorder,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selectedLocations.isNotEmpty
              ? Padding(
                  key: const ValueKey('begin-btn'),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phase summary strip
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PhaseSummaryStrip(
                          selectedLocations: _selectedLocations,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _beginCapture,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Begin Capture  ·  '
                            '${_selectedLocations.length} '
                            'area${_selectedLocations.length > 1 ? 's' : ''}  →',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(key: ValueKey('begin-empty'), height: 32),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCREEN 2 — Capture view
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCaptureView() {
    final slot = _currentSlot;
    final imageFile = _images[_currentStep];
    final isPicked = imageFile != null;
    final total = _taggedSlots.length;

    // Count how many white vs blue total, and which phase we're in
    final whiteCount = _taggedSlots.where((s) => !s.slot.isBlueLight).length;
    final phaseLabel = slot.isBlueLight
        ? 'FLUORESCENCE PHASE'
        : 'WHITE LIGHT PHASE';
    final phaseStep = slot.isBlueLight
        ? (_currentStep - whiteCount + 1)
        : (_currentStep + 1);
    final phaseTotal = slot.isBlueLight
        ? (_taggedSlots.length - whiteCount)
        : whiteCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              _backButton(
                onTap: () => setState(() {
                  _screenState = _ScreenState.locationSelect;
                  _taggedSlots = [];
                  _images = [];
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          phaseLabel,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w600,
                            color: slot.isBlueLight ? kBlueLight : kAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$phaseStep of $phaseTotal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: slot.isBlueLight
                                ? kBlueLight.withValues(alpha: 0.6)
                                : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _buildStepDots(total),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentStep + 1} / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _patientIdStrip(),
        ),
        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.label,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    slot.isBlueLight
                        ? Icons.flashlight_on_rounded
                        : Icons.wb_sunny_rounded,
                    size: 14,
                    color: slot.isBlueLight ? kBlueLight : kTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    slot.isBlueLight
                        ? 'Blue light attachment must be on'
                        : 'Normal white light ‣ no attachment needed',
                    style: TextStyle(
                      fontSize: 13,
                      color: slot.isBlueLight ? kBlueLight : kTextMuted,
                      fontWeight: slot.isBlueLight
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _Viewfinder(
              isBlueLight: slot.isBlueLight,
              isPicked: isPicked,
              imageFile: imageFile,
              pulseAnimation: _pulseAnimation,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: isPicked
              ? const _PickedConfirmationBar()
              : Row(
                  children: [
                    Expanded(
                      child: _CaptureActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        isPrimary: true,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CaptureActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        isPrimary: false,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStepDots(int total) {
    final whiteCount = _taggedSlots.where((s) => !s.slot.isBlueLight).length;
    return Row(
      children: List.generate(total, (i) {
        final done = _images[i] != null;
        final current = i == _currentStep;
        final isBlue = _taggedSlots[i].slot.isBlueLight;

        // Add a small gap between white and blue phases
        final addGap = i == whiteCount && i != 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (addGap) const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 4),
              width: current ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: done
                    ? (isBlue ? kBlueLight : kAccent)
                    : current
                    ? kPrimary
                    : kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCREEN 3 — Review
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReviewView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ALL IMAGES CAPTURED',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: kAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review before\nanalysing.',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap "Retake" on any image that looks wrong.',
                style: TextStyle(fontSize: 13, color: kTextMuted, height: 1.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_selectedLocations.length} area'
                      '${_selectedLocations.length > 1 ? 's' : ''} selected',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _patientIdStrip(),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: _selectedLocations.map((loc) {
              final indices = <int>[];
              for (var i = 0; i < _taggedSlots.length; i++) {
                if (_taggedSlots[i].location == loc) indices.add(i);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 4),
                    child: Text(
                      loc.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: kAccent,
                      ),
                    ),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: indices
                        .map(
                          (i) => _ThumbnailCard(
                            label: _taggedSlots[i].slot.label,
                            imageFile: _images[i],
                            isBlueLight: _taggedSlots[i].slot.isBlueLight,
                            onRetake: () => _onRetake(i),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _screenState = _ScreenState.locationSelect;
                  _selectedLocations = [];
                  _taggedSlots = [];
                  _images = [];
                }),
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'Start over',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextBody,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _images.every((f) => f != null)
                        ? _onAnalyse
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Analyse →',
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
      ],
    );
  }
}

// ── Phase summary strip ───────────────────────────────────────────────────────
class _PhaseSummaryStrip extends StatelessWidget {
  final List<OralLocation> selectedLocations;
  const _PhaseSummaryStrip({required this.selectedLocations});

  @override
  Widget build(BuildContext context) {
    final whiteCount = selectedLocations
        .expand((loc) => loc.imageSlots.where((s) => !s.isBlueLight))
        .length;
    final blueCount = selectedLocations
        .expand((loc) => loc.imageSlots.where((s) => s.isBlueLight))
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          _PhaseChip(
            icon: Icons.wb_sunny_rounded,
            label: '$whiteCount white light',
            color: kAccent,
          ),
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: kTextMuted)),
          const SizedBox(width: 6),
          _PhaseChip(
            icon: Icons.flashlight_on_rounded,
            label: '$blueCount fluorescence',
            color: kBlueLight,
          ),
          const Spacer(),
          Text(
            'in order',
            style: TextStyle(
              fontSize: 10,
              color: kTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PhaseChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Blue light transition ─────────────────────────────────────────────────────
class _BlueLightTransitionScreen extends StatelessWidget {
  final VoidCallback onReady;
  const _BlueLightTransitionScreen({required this.onReady});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: kBlueLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flashlight_on_rounded,
              size: 48,
              color: kBlueLight,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Switch on the\nblue light now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Attach the fluorescence clip to the phone camera\n'
            'before taking the next image.\n\n'
            'The remaining images all need the blue light on.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: kTextBody),
          ),
          const SizedBox(height: 40),
          _CheckRow(text: 'Clip is attached to the camera'),
          const SizedBox(height: 10),
          _CheckRow(text: 'Blue light is switched on'),
          const SizedBox(height: 10),
          _CheckRow(text: 'Room is as dark as possible'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onReady,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'I am ready →',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Do not skip — images without the blue light cannot be analysed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: kTextMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: kAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: kAccent),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextBody,
          ),
        ),
      ],
    );
  }
}

// ── Viewfinder ────────────────────────────────────────────────────────────────
class _Viewfinder extends StatelessWidget {
  final bool isBlueLight;
  final bool isPicked;
  final File? imageFile;
  final Animation<double> pulseAnimation;

  const _Viewfinder({
    required this.isBlueLight,
    required this.isPicked,
    required this.imageFile,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: isPicked
            ? Colors.transparent
            : isBlueLight
            ? const Color(0xFF0D1B4B)
            : const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPicked
              ? kAccent
              : isBlueLight
              ? kBlueLight.withValues(alpha: 0.6)
              : kPrimary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            if (isPicked && imageFile != null)
              Positioned.fill(child: Image.file(imageFile!, fit: BoxFit.cover)),
            ..._buildCornerMarkers(isBlueLight, isPicked),
            if (!isPicked)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: pulseAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (isBlueLight ? kBlueLight : Colors.white)
                              .withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBlueLight
                              ? Icons.flashlight_on_rounded
                              : Icons.wb_sunny_rounded,
                          size: 40,
                          color: isBlueLight
                              ? kBlueLight.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Use Camera or Gallery below',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (isPicked)
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Image selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isBlueLight && !isPicked)
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kBlueLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kBlueLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kBlueLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Fluorescence',
                        style: TextStyle(
                          color: kBlueLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers(bool blue, bool picked) {
    final color = picked
        ? kAccent
        : blue
        ? kBlueLight.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.4);
    const size = 20.0;
    const thickness = 2.5;
    const inset = 16.0;

    Widget corner(
      double? top,
      double? bottom,
      double? left,
      double? right,
      bool flipH,
      bool flipV,
    ) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Transform.scale(
          scaleX: flipH ? -1 : 1,
          scaleY: flipV ? -1 : 1,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _CornerPainter(color, thickness)),
          ),
        ),
      );
    }

    return [
      corner(inset, null, inset, null, false, false),
      corner(inset, null, null, inset, true, false),
      corner(null, inset, inset, null, false, true),
      corner(null, inset, null, inset, true, true),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  const _CornerPainter(this.color, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.thickness != thickness;
}

// ── Capture action buttons ────────────────────────────────────────────────────
class _CaptureActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CaptureActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isPrimary ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: kBorder, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : kTextBody, size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : kTextBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picked confirmation bar ───────────────────────────────────────────────────
class _PickedConfirmationBar extends StatelessWidget {
  const _PickedConfirmationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: kAccent, size: 26),
          SizedBox(width: 12),
          Text(
            'Uploaded — moving on…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// SourceTile removed: unused declaration cleaned up.

// ── Thumbnail card ────────────────────────────────────────────────────────────
class _ThumbnailCard extends StatelessWidget {
  final String label;
  final bool isBlueLight;
  final File? imageFile;
  final VoidCallback onRetake;

  const _ThumbnailCard({
    required this.label,
    required this.isBlueLight,
    required this.imageFile,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isBlueLight ? const Color(0xFF0D1B4B) : const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: imageFile != null
                  ? Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Center(
                      child: Icon(
                        isBlueLight
                            ? Icons.fluorescent_rounded
                            : Icons.wb_sunny_rounded,
                        size: 32,
                        color: isBlueLight
                            ? kBlueLight.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kTextBody,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onRetake,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kBorder),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kTextBody,
                      ),
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
