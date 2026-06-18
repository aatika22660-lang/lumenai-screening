import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour tokens (matching app theme) ───────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);
const kBlueLight = Color(0xFF3B5BDB);
const kAmber = Color(0xFFB8860B);

// Verdict colours, matching results_screen.dart exactly
const kNormalColor = Color(0xFF4A7C59);
const kSuspiciousColor = Color(0xFFB8860B);
const kHighRiskColor = Color(0xFF9B3A3A);

class ScreeningInfoScreen extends StatelessWidget {
  const ScreeningInfoScreen({super.key});

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
                  Text(
                    'SCREENING INFORMATION',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A quick reference\nfor using LumenAI.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Section 1: What this tool does ──────────────────────
                    _SectionLabel('WHAT THIS TOOL DOES'),
                    const SizedBox(height: 10),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LumenAI is an AI-assisted visual screening aid for early signs of oral cancer. It analyses white light and fluorescence images of the mouth to flag areas that may need closer attention.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.6,
                              color: kTextBody,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kAmber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kAmber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: kAmber,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This is a screening aid, not a diagnosis. Every flagged patient still needs clinical referral and assessment.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: kTextBody,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Section 2: How to use the attachment ────────────────
                    _SectionLabel('HOW TO USE THE ATTACHMENT'),
                    const SizedBox(height: 10),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StepRow(
                            number: '1',
                            icon: Icons.wb_sunny_rounded,
                            iconColor: kAccent,
                            text:
                                'Capture all white light images first — no attachment needed.',
                          ),
                          const SizedBox(height: 14),
                          _StepRow(
                            number: '2',
                            icon: Icons.flashlight_on_rounded,
                            iconColor: kBlueLight,
                            text:
                                'Clip the fluorescence attachment onto the phone camera before continuing.',
                          ),
                          const SizedBox(height: 14),
                          _StepRow(
                            number: '3',
                            icon: Icons.dark_mode_outlined,
                            iconColor: kTextBody,
                            text:
                                'Dim the room as much as possible — fluorescence images need low ambient light to be clear.',
                          ),
                          const SizedBox(height: 14),
                          _StepRow(
                            number: '4',
                            icon: Icons.center_focus_strong_rounded,
                            iconColor: kTextBody,
                            text:
                                'Hold the phone steady and keep the target area fully in frame before capturing.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Section 3: Colour codes ─────────────────────────────
                    _SectionLabel('WHAT THE COLOUR CODES MEAN'),
                    const SizedBox(height: 10),
                    _InfoCard(
                      child: Column(
                        children: [
                          _VerdictRow(
                            color: kNormalColor,
                            label: 'Normal',
                            description:
                                'No significant abnormalities detected. Routine rescreening recommended in 6 months.',
                          ),
                          const Divider(height: 24, color: kBorder),
                          _VerdictRow(
                            color: kSuspiciousColor,
                            label: 'Suspicious',
                            description:
                                'Some areas require attention. Refer to a clinic within 2 weeks.',
                          ),
                          const Divider(height: 24, color: kBorder),
                          _VerdictRow(
                            color: kHighRiskColor,
                            label: 'High Risk',
                            description:
                                'Areas of concern detected. Refer for urgent clinical assessment within 48 hours.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Disclaimer ───────────────────────────────────────────
                    Center(
                      child: Text(
                        'Ziauddin University · Prototype · Not for Clinical Use',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: kTextMuted,
                          letterSpacing: 0.3,
                        ),
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
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
        color: kTextMuted,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: child,
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final IconData icon;
  final Color iconColor;
  final String text;

  const _StepRow({
    required this.number,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: kTextBody,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerdictRow extends StatelessWidget {
  final Color color;
  final String label;
  final String description;

  const _VerdictRow({
    required this.color,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: kTextBody,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
