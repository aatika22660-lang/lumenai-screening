import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/communityhealthworker/home_screen.dart';
import 'screens/communityhealthworker/patient_intake_screen.dart';
import 'screens/communityhealthworker/image_capture_screen.dart';
import 'screens/communityhealthworker/results_screen.dart';
import 'screens/communityhealthworker/patient_history_screen.dart';
import 'database/database_helper.dart';
import 'models/patient_model.dart';
import 'screens/communityhealthworker/analysing_screen.dart';
import 'models/screening_model.dart';
import 'screens/communityhealthworker/chw_setup_screen.dart';
import 'screens/communityhealthworker/screening_info_screen.dart';
import 'screens/self_assessment/welcome_screen.dart';
import 'screens/self_assessment/capture_screen.dart';
import 'screens/self_assessment/analysing_screen.dart';
import 'screens/self_assessment/results_screen.dart';
import 'services/self_assessment_analysis_service.dart';
import 'screens/self_assessment/next_steps_screen.dart';
import 'screens/self_assessment/risk_questions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OC Screening',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8F71)),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const ModeSelectionScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chw-setup': (context) => const ChwSetupScreen(),
        '/info': (context) => const ScreeningInfoScreen(),

        // ── 1. Welcome Screen ────────────────────────────────────────────────
        '/self-assessment': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final bool isUrdu = args?['isUrdu'] as bool? ?? false;
          return WelcomeScreen(initialIsUrdu: isUrdu);
        },

        // ── 2. Risk Questions Screen ──────────────────────────────────────────
        '/self-assessment/questions': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final bool isUrdu = args?['isUrdu'] as bool? ?? false;
          return RiskQuestionsScreen(initialIsUrdu: isUrdu);
        },

        // ── 3. Capture Screen ──────────────────────────────────────────────────
        '/self-assessment/capture': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CaptureScreen(
            answers: args['answers'] as SelfAssessmentAnswers,
            initialIsUrdu: args['isUrdu'] as bool? ?? false,
          );
        },

        // ── 4. Analysing / Loading Screen ─────────────────────────────────────
        '/self-assessment/analysing': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SelfAssessmentAnalysingScreen(
            answers: args['answers'] as SelfAssessmentAnswers,
            images: args['images'] as List<SelfAssessmentImage>,
            isUrdu: args['isUrdu'] as bool? ?? false,
          );
        },

        // ── 5. Results Screen ──────────────────────────────────────────────────
        '/self-assessment/results': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SelfAssessmentResultsScreen(
            result: args['result'] as SelfAssessmentResult,
            images: args['images'] as List<SelfAssessmentImage>,
            usesTobacco: args['usesTobacco'] as bool,
            initialIsUrdu:
                args['isUrdu'] as bool? ??
                false, // Matches changes made inside results screen code
          );
        },

        // ── 6. Next Steps Screen ───────────────────────────────────────────────
        '/self-assessment/next-steps': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return NextStepsScreen(
            verdict: args['verdict'] as ScreeningVerdict,
            usesTobacco: args['usesTobacco'] as bool,
            recommendation: args['recommendation'] as String,
            initialIsUrdu:
                args['isUrdu'] as bool? ??
                false, // Matches updates to next steps constructor
          );
        },

        // ── Community Health Worker workflow routes ───────────────────────────
        '/patient-intake': (context) => const PatientIntakeScreen(),
        '/image-capture': (context) {
          final patient = ModalRoute.of(context)!.settings.arguments as Patient;
          return ImageCaptureScreen(patient: patient);
        },
        '/analysing': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return AnalysingScreen(
            patient: args['patient'] as Patient,
            location: args['location'] as String,
            imageData: args['imageData'] as List<Map<String, dynamic>>,
          );
        },
        '/results': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ResultsScreen(
            patient: args['patient'] as Patient,
            patientId: args['patientId'] as String,
            location: args['location'] as String,
            images: args['images'] as List<ScreeningImage>,
            verdict: args['verdict'] as ScreeningVerdict,
            findings: args['findings'] as List<ScreeningFinding>,
            summary: args['summary'] as String,
            keyPoints: args['keyPoints'] as List<String>,
            symmetryAnalysis: args['symmetryAnalysis'],
          );
        },
        '/patient-history': (context) => const PatientHistoryScreen(),
      },
    );
  }
}
