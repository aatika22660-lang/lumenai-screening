import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/patient_model.dart';
import '../../utils/id_generator.dart';
import '../../database/database_helper.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);

class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  // ── Field state ───────────────────────────────────────────────────────────
  int _currentPage = 0;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _gender;
  bool? _usesTobacco;
  String? _tobaccoType;
  String? _duration;
  String? _frequency;
  final Set<String> _symptoms = {};
  String? _visitType;
  final TextEditingController _patientIdController = TextEditingController();
  Patient? _foundPatient;

  @override
  void dispose() {
    _ageController.dispose();
    _phoneController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  // ── Page list — page 2 (tobacco details) skipped if no tobacco ───────────
  List<int> get _pages {
    // 0 = page1, 1 = page2, 2 = page3(tobacco details), 3 = page4
    if (_usesTobacco == true) return [0, 1, 2, 3];
    return [0, 1, 3];
  }

  int get _totalPages => _pages.length;
  int get _pageIndex => _pages[_currentPage];

  // ── Can advance? ──────────────────────────────────────────────────────────
  bool get _canAdvance {
    switch (_pageIndex) {
      case 0: // age + gender required; phone optional
        return _ageController.text.isNotEmpty && _gender != null;
      case 1: // tobacco yes/no required; type required only if yes
        if (_usesTobacco == null) return false;
        if (_usesTobacco == true && _tobaccoType == null) return false;
        return true;
      case 2: // duration + frequency both required
        return _duration != null && _frequency != null;
      case 3: // symptoms optional; visit type required
        if (_visitType == null) return false;
        if (_visitType == 'Returning' && _patientIdController.text.isEmpty) {
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _next() {
    // Age guard — intercept before leaving page 1
    if (_pageIndex == 0) {
      final age = int.tryParse(_ageController.text);
      if (age != null && age < 18) {
        _showUnderageWarning();
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
    } else {
      _submit();
    }
  }

  void _showUnderageWarning() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 30,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Patient too young',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This screening is for adults aged 18 and over. If you have concerns about this patient, please refer them to a qualified healthcare provider.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: kTextBody),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // exit intake screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _back() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    final id = _visitType == 'Returning' && _foundPatient != null
        ? _foundPatient!.id
        : IdGenerator.newPatientId();

    final patient = Patient(
      id: id,
      age: int.parse(_ageController.text),
      gender: _gender!,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      usesTobacco: _usesTobacco ?? false,
      tobaccoType: _tobaccoType,
      duration: _duration,
      frequency: _frequency,
      symptoms: _symptoms.toList(),
      visitType: _visitType!,
      existingPatientId: _visitType == 'Returning' ? _foundPatient?.id : null,
      createdAt: DateTime.now(),
    );

    Navigator.pushNamed(context, '/image-capture', arguments: patient);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentPage),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                    child: _buildCurrentPage(),
                  ),
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
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
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Intake',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: kAccent,
                ),
              ),
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: TextStyle(fontSize: 13, color: kTextMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    final progress = (_currentPage + 1) / _totalPages;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 3,
          backgroundColor: kBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
        ),
      ),
    );
  }

  // ── Page router ───────────────────────────────────────────────────────────
  Widget _buildCurrentPage() {
    switch (_pageIndex) {
      case 0:
        return _buildPage1();
      case 1:
        return _buildPage2();
      case 2:
        return _buildPage3();
      case 3:
        return _buildPage4();
      default:
        return const SizedBox();
    }
  }

  // ── Page 1: Age, Gender, Phone ────────────────────────────────────────────
  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle('About the\npatient.'),
        const SizedBox(height: 32),

        // Age
        _SectionLabel('How old is the patient?'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. 35',
              hintStyle: TextStyle(color: kTextMuted, fontSize: 15),
              suffixText: _ageController.text.isNotEmpty ? 'yrs' : '',
              suffixStyle: TextStyle(
                fontSize: 15,
                color: kTextMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: const TextStyle(fontSize: 15, color: kPrimary),
          ),
        ),

        const SizedBox(height: 28),

        // Gender
        _SectionLabel('Gender'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BigChoiceButton(
                label: 'Male',
                icon: Icons.male_rounded,
                selected: _gender == 'Male',
                onTap: () => setState(() => _gender = 'Male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigChoiceButton(
                label: 'Female',
                icon: Icons.female_rounded,
                selected: _gender == 'Female',
                onTap: () => setState(() => _gender = 'Female'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Phone (optional)
        _SectionLabel('Phone number  ·  optional'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. 03001234567',
              hintStyle: TextStyle(color: kTextMuted, fontSize: 15),
            ),
            style: const TextStyle(fontSize: 15, color: kPrimary),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Page 2: Tobacco use + type ────────────────────────────────────────────
  Widget _buildPage2() {
    final types = ['Gutka', 'Paan', 'Naswar', 'Cigarettes', 'Multiple'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle('Tobacco\nuse.'),
        const SizedBox(height: 32),

        _SectionLabel('Does the patient use tobacco?'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BigChoiceButton(
                label: 'Yes',
                selected: _usesTobacco == true,
                onTap: () => setState(() => _usesTobacco = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigChoiceButton(
                label: 'No',
                selected: _usesTobacco == false,
                onTap: () => setState(() {
                  _usesTobacco = false;
                  _tobaccoType = null;
                  _duration = null;
                  _frequency = null;
                }),
              ),
            ),
          ],
        ),

        // Tobacco type — only shown if Yes
        if (_usesTobacco == true) ...[
          const SizedBox(height: 28),
          _SectionLabel('Which type of tobacco?'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: types
                .map(
                  (t) => _ChipButton(
                    label: t,
                    selected: _tobaccoType == t,
                    onTap: () => setState(() => _tobaccoType = t),
                  ),
                )
                .toList(),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Page 3: Duration + Frequency ─────────────────────────────────────────
  Widget _buildPage3() {
    final durations = [
      '< 1 year',
      '1–5 years',
      '5–10 years',
      '10+ years',
      'Intermittent',
    ];
    final frequencies = [
      'Occasionally',
      'A few times a week',
      'Daily',
      'Multiple times a day',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle('Tobacco\nhistory.'),
        const SizedBox(height: 32),

        _SectionLabel('How long have they used it?'),
        const SizedBox(height: 10),
        ...durations.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RowChoiceButton(
              label: o,
              selected: _duration == o,
              onTap: () => setState(() => _duration = o),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _SectionLabel('How many times per day?'),
        const SizedBox(height: 10),
        ...frequencies.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RowChoiceButton(
              label: o,
              selected: _frequency == o,
              onTap: () => setState(() => _frequency = o),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Page 4: Symptoms + Visit type ────────────────────────────────────────
  Widget _buildPage4() {
    final symptoms = [
      {'label': 'Pain', 'icon': Icons.sentiment_very_dissatisfied_rounded},
      {'label': 'Difficulty swallowing', 'icon': Icons.water_drop_outlined},
      {'label': 'White or red patches', 'icon': Icons.blur_circular_rounded},
      {'label': 'Numbness', 'icon': Icons.close},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle('Symptoms &\nvisit type.'),
        const SizedBox(height: 32),

        _SectionLabel('Any symptoms right now?  ·  optional'),
        const SizedBox(height: 10),
        ...symptoms.map((s) {
          final label = s['label'] as String;
          final icon = s['icon'] as IconData;
          final selected = _symptoms.contains(label);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() {
                selected ? _symptoms.remove(label) : _symptoms.add(label);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: selected ? kAccent.withValues(alpha: 0.08) : kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? kAccent : kBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? kAccent : kTextMuted,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected ? kPrimary : kTextBody,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? kAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected ? kAccent : kBorder,
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 24),

        _SectionLabel('First visit or returning patient?'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BigChoiceButton(
                label: 'New Patient',
                selected: _visitType == 'New',
                onTap: () => setState(() => _visitType = 'New'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigChoiceButton(
                label: 'Returning',
                selected: _visitType == 'Returning',
                onTap: () => setState(() => _visitType = 'Returning'),
              ),
            ),
          ],
        ),

        if (_visitType == 'Returning') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: TextField(
              controller: _patientIdController,
              onChanged: (val) async {
                setState(() {});
                if (val.length >= 4) {
                  final match = await DatabaseHelper.instance.searchPatients(
                    val,
                  );
                  setState(
                    () => _foundPatient = match.isNotEmpty ? match.first : null,
                  );
                } else {
                  setState(() => _foundPatient = null);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter patient ID',
                hintStyle: TextStyle(color: kTextMuted, fontSize: 15),
                prefixIcon: Icon(Icons.search, color: kTextMuted, size: 20),
              ),
              style: const TextStyle(fontSize: 15, color: kPrimary),
            ),
          ),
        ],

        if (_foundPatient != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccent),
            ),
            child: Text(
              'Found: ${_foundPatient!.id}  ·  Age ${_foundPatient!.age}  ·  ${_foundPatient!.gender}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final isLast = _currentPage == _totalPages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _canAdvance ? _next : null,
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
          child: Text(
            isLast ? 'Begin Screening →' : 'Next',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  final String text;
  const _PageTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 36,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: kPrimary,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
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
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _BigChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 100,
        decoration: BoxDecoration(
          color: selected ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: selected ? Colors.white : kTextMuted),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : kTextBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RowChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 0 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kTextBody,
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kTextBody,
          ),
        ),
      ),
    );
  }
}
