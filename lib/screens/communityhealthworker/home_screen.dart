import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/chw_preferences.dart';
import 'chw_setup_screen.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF0EDE6); // warm linen
const kSurface = Color(0xFFF0EDE6); // same as background for secondary btn
const kPrimary = Color(0xFF1C1C1A); // near-black
const kAccent = Color(0xFF4A7A52); // deeper sage (italic headline)
const kAccentIcon = Color(0xFF6B8F71); // lighter sage (logo / icon strokes)
const kTextMuted = Color(0xFF9A9A8E); // labels, disclaimers
const kTextBody = Color(0xFF5A5A52); // body copy
const kBorder = Color(0xFFD8D4CC); // secondary button border
const kSurfaceCard = Color(0xFFFFFFFF); // white card surface

// ── Home Screen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _chwName;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await ChwPreferences.getIdentifier();
    setState(() => _chwName = name);
  }

  Future<void> _editName() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ChwSetupScreen(initialName: _chwName)),
    );
    if (updated != null && updated.isNotEmpty) {
      setState(() => _chwName = updated);
    }
  }

  String get _todayStr {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ── CHW identity bar ──────────────────────────────────────────
              _IdentityBar(name: _chwName, onEdit: _editName),

              const Spacer(),

              // ── Wordmark, centred above the main action ──────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'LumenAI',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ORAL SCREENING',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Primary action card ───────────────────────────────────────
              _StartScreeningCard(
                onTap: () => Navigator.pushNamed(context, '/patient-intake'),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  _todayStr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: kTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // ── Secondary actions ─────────────────────────────────────────
              _SecondaryButton(
                icon: Icons.history_rounded,
                label: 'Patient History',
                onTap: () => Navigator.pushNamed(context, '/patient-history'),
              ),
              const SizedBox(height: 10),
              _SecondaryButton(
                icon: Icons.info_outline_rounded,
                label: 'Screening Information',
                onTap: () => Navigator.pushNamed(context, '/info'),
              ),

              // ── Disclaimer ─────────────────────────────────────────────────
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Ziauddin University · Prototype · Not for Clinical Use',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: kTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CHW identity bar ────────────────────────────────────────────────────────
class _IdentityBar extends StatelessWidget {
  final String? name;
  final VoidCallback onEdit;

  const _IdentityBar({required this.name, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final displayName = name != null && name!.isNotEmpty ? name! : 'CHW';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kAccentIcon.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.person_rounded, size: 18, color: kAccentIcon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kSurfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Icon(Icons.settings_outlined, size: 17, color: kTextBody),
          ),
        ),
      ],
    );
  }
}

// ── Primary action card ─────────────────────────────────────────────────────
class _StartScreeningCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StartScreeningCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Start New Screening',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to begin patient intake',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Secondary button (icon + label, full width) ──────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSurfaceCard,
          foregroundColor: kPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: kBorder, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: kTextBody),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
