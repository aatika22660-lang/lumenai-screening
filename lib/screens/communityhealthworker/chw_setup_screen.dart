import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/chw_preferences.dart';

// ── Colour tokens (matching app theme) ───────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

class ChwSetupScreen extends StatefulWidget {
  // When non-null, this screen behaves as an "edit name" flow:
  // the field is pre-filled, the button says "Save", and it
  // pops back to the previous screen instead of resetting the stack.
  final String? initialName;

  const ChwSetupScreen({super.key, this.initialName});

  bool get isEditing => initialName != null;

  @override
  State<ChwSetupScreen> createState() => _ChwSetupScreenState();
}

class _ChwSetupScreenState extends State<ChwSetupScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  Future<void> _continue() async {
    if (!_canContinue || _saving) return;
    setState(() => _saving = true);

    await ChwPreferences.saveIdentifier(_nameController.text.trim());

    if (!context.mounted) return;

    if (widget.isEditing) {
      // Editing from Home — pop back with the updated name.
      Navigator.pop(context, _nameController.text.trim());
    } else {
      // First-time setup — clear the stack so setup can't be revisited via back.
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── App name ──────────────────────────────────────────────────
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
                'ORAL SCREENING',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                ),
              ),

              const Spacer(),

              // ── Heading ───────────────────────────────────────────────────
              Text(
                widget.isEditing
                    ? 'Update your\nname.'
                    : 'Before we begin,\nwho are you?',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your name will appear on all screenings you perform.',
                style: TextStyle(fontSize: 14, height: 1.6, color: kTextBody),
              ),

              const SizedBox(height: 28),

              // ── Name field ────────────────────────────────────────────────
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
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your name or ID',
                    hintStyle: TextStyle(color: kTextMuted, fontSize: 15),
                  ),
                  style: const TextStyle(fontSize: 15, color: kPrimary),
                ),
              ),

              const Spacer(),

              // ── Continue / Save button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _canContinue && !_saving ? _continue : null,
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
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Save' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Disclaimer ────────────────────────────────────────────────
              Center(
                child: Text(
                  'Prototype — Not for Clinical Use',
                  style: TextStyle(
                    fontSize: 11,
                    color: kTextMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
