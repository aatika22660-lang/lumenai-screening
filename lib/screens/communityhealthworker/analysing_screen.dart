import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/patient_model.dart';
import '../../models/screening_model.dart';
import '../../services/analysis_service.dart';
import '../communityhealthworker/image_capture_screen.dart';

const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

class AnalysingScreen extends StatefulWidget {
  final Patient patient;
  final String location;
  final List<Map<String, dynamic>> imageData;
  final List<OralLocation> selectedLocations;

  const AnalysingScreen({
    super.key,
    required this.patient,
    required this.location,
    required this.imageData,
    this.selectedLocations = const [],
  });

  @override
  State<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Cycling status messages so the CHW knows something is happening
  final List<String> _messages = [
    'Reading fluorescence patterns…',
    'Comparing white light and blue light images…',
    'Assessing patient risk profile…',
    'Checking for fluorescence loss…',
    'Generating findings…',
  ];
  int _messageIndex = 0;
  late AnimationController _messageController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _messageController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (mounted) {
                setState(() {
                  _messageIndex = (_messageIndex + 1) % _messages.length;
                });
                _messageController.forward(from: 0);
              }
            }
          });
    _messageController.forward();

    // Kick off the actual API call
    _runAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    try {
      final result = await AnalysisService.analyse(
        patient: widget.patient,
        location: widget.location,
        imageData: widget.imageData,
      );

      if (!mounted) return;

      // Convert imageData files → ScreeningImage list
      final screeningImages = widget.imageData
          .where((m) => m['file'] != null)
          .map(
            (m) => ScreeningImage(
              label: m['label'] as String,
              imagePath: (m['file'] as File).path,
            ),
          )
          .toList();

      Navigator.pushReplacementNamed(
        context,
        '/results',
        arguments: {
          'patient': widget.patient,
          'patientId': widget.patient.id,
          'location': widget.location,
          'images': screeningImages,
          'verdict': result.verdict,
          'findings': result.findings,
          'keyPoints': result.keyPoints,
          'summary': result.summary,
          'symmetryAnalysis': result.symmetryAnalysis,
          'selectedLocations': widget.selectedLocations,
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Analysis failed',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: kPrimary,
          ),
        ),
        content: Text(
          'Something went wrong. Please check your connection and try again.\n\n$message',
          style: TextStyle(fontSize: 13, color: kTextBody, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to review screen
            },
            child: Text(
              'Go back',
              style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _runAnalysis(); // retry
            },
            child: Text(
              'Retry',
              style: TextStyle(color: kAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Pulsing icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.biotech_rounded, size: 48, color: kAccent),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Analysing…',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),

              const SizedBox(height: 12),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextMuted,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      final delay = i * 0.3;
                      final value = (_pulseController.value - delay).clamp(
                        0.0,
                        1.0,
                      );
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent.withOpacity(0.3 + value * 0.7),
                        ),
                      );
                    },
                  );
                }),
              ),

              const Spacer(),

              Text(
                'Do not close the app.',
                style: TextStyle(
                  fontSize: 12,
                  color: kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'This usually takes 15–30 seconds.',
                style: TextStyle(fontSize: 12, color: kTextMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
