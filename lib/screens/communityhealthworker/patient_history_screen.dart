import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/database_helper.dart';
import '../../models/screening_model.dart';

const kBackground = Color(0xFFF5F3EE);
const kSurface = Color(0xFFFFFFFF);
const kPrimary = Color(0xFF1C1C1A);
const kAccent = Color(0xFF6B8F71);
const kTextMuted = Color(0xFF9A9A8E);
const kTextBody = Color(0xFF3D3D38);
const kBorder = Color(0xFFE2DFD8);
const kAmber = Color(0xFFB8860B);

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Screening> _allScreenings = [];
  List<Screening> _filtered = [];
  int _totalCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final screenings = await DatabaseHelper.instance.getAllScreenings();
    final count = await DatabaseHelper.instance.getScreeningCount();
    setState(() {
      _allScreenings = screenings;
      _filtered = screenings;
      _totalCount = count;
      _loading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allScreenings
          : _allScreenings
                .where((s) => s.patientId.toLowerCase().contains(q))
                .toList();
    });
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
  }

  Color _verdictColor(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return const Color(0xFF4A7C59);
      case ScreeningVerdict.suspicious:
        return const Color(0xFFB8860B);
      case ScreeningVerdict.highRisk:
        return const Color(0xFF9B3A3A);
    }
  }

  String _verdictLabel(ScreeningVerdict v) {
    switch (v) {
      case ScreeningVerdict.normal:
        return 'Normal';
      case ScreeningVerdict.suspicious:
        return 'Suspicious';
      case ScreeningVerdict.highRisk:
        return 'High Risk';
    }
  }

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PATIENT HISTORY',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: kAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _loading
                            ? '— screenings'
                            : '$_totalCount screening${_totalCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: kTextMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(fontSize: 14, color: kPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search by patient ID',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: kTextMuted,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: kBorder),

            // ── Body ───────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kBorder.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded, size: 28, color: kTextMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No screenings recorded yet.',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: kTextMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Completed screenings will appear here.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: kTextMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: _filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = _filtered[i];
        final color = _verdictColor(s.verdict);
        return Dismissible(
          key: ValueKey(s.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFCC4444),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: kSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Delete screening?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                    content: Text(
                      'This will permanently remove the screening record for ${s.patientId}.',
                      style: const TextStyle(fontSize: 14, color: kTextBody),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: kTextMuted),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFCC4444),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) async {
            await DatabaseHelper.instance.deleteScreening(s.id);
            setState(() {
              _allScreenings.removeWhere((r) => r.id == s.id);
              _filtered.removeWhere((r) => r.id == s.id);
              _totalCount = _allScreenings.length;
            });
          },
          child: GestureDetector(
            onTap: () async {
              final itemContext = context;
              final patient = await DatabaseHelper.instance.getPatient(
                s.patientId,
              );
              if (patient == null) return;
              if (!mounted) return; // guard State.context usage
              if (!itemContext.mounted) return; // guard the local BuildContext
              Navigator.pushNamed(
                itemContext,
                '/results',
                arguments: {
                  'patient': patient,
                  'patientId': s.patientId,
                  'location': s.location,
                  'images': s.images,
                  'verdict': s.verdict,
                  'findings': s.findings,
                  'summary': s.summary,
                  'keyPoints': s.keyPoints,
                  'symmetryAnalysis': s.symmetryAnalysis,
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.patientId,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_formatDate(s.screenedAt)}  ·  ${s.location}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _verdictLabel(s.verdict),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: kTextMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
