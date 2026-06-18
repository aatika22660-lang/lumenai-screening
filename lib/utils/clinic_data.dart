import '../models/clinic_model.dart';

class ClinicData {
  ClinicData._();

  static const List<Clinic> all = [
    // ── Lyari ─────────────────────────────────────────────────────────────
    Clinic(
      name: 'Lyari General Hospital',
      area: 'Lyari',
      address: 'Lyari Expressway, Lyari, Karachi',
      phone: '021-32312241',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Patel Para MCH Centre',
      area: 'Lyari',
      address: 'Patel Para, Lyari, Karachi',
      phone: '021-32315060',
      type: 'Mother & Child Health Centre',
    ),

    // ── Landhi ────────────────────────────────────────────────────────────
    Clinic(
      name: 'Landhi Civil Hospital',
      area: 'Landhi',
      address: 'Landhi Industrial Area, Landhi, Karachi',
      phone: '021-35081001',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'JPMC Landhi Outreach Clinic',
      area: 'Landhi',
      address: 'Sector 5, Landhi Town, Karachi',
      phone: '021-35080301',
      type: 'Outreach Clinic',
    ),

    // ── Korangi ───────────────────────────────────────────────────────────
    Clinic(
      name: 'Korangi Civil Hospital',
      area: 'Korangi',
      address: 'Korangi Industrial Area, Korangi, Karachi',
      phone: '021-35112052',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Indus Hospital — Korangi Campus',
      area: 'Korangi',
      address: 'Plot C-76, Sector 31/5, Korangi Industrial Area, Karachi',
      phone: '021-35112709',
      type: 'NGO Hospital',
    ),

    // ── Saddar ────────────────────────────────────────────────────────────
    Clinic(
      name: 'Jinnah Postgraduate Medical Centre (JPMC)',
      area: 'Saddar',
      address: 'Rafiqui Shaheed Road, Karachi',
      phone: '021-99201300',
      type: 'Public Teaching Hospital',
    ),
    Clinic(
      name: 'Civil Hospital Karachi',
      area: 'Saddar',
      address: 'Baba-e-Urdu Road, Saddar, Karachi',
      phone: '021-99214747',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Sindh Institute of Urology & Transplantation (SIUT)',
      area: 'Saddar',
      address: 'Dow University of Health Sciences, Karachi',
      phone: '021-99215740',
      type: 'Specialist Hospital',
    ),

    // ── Orangi ────────────────────────────────────────────────────────────
    Clinic(
      name: 'Abbasi Shaheed Hospital',
      area: 'Orangi',
      address: 'SITE Area, near Orangi Town, Karachi',
      phone: '021-32570001',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Orangi Pilot Project — Health Unit',
      area: 'Orangi',
      address: 'Sector 2, Orangi Town, Karachi',
      phone: '021-36656061',
      type: 'NGO Health Unit',
    ),

    // ── Gulshan-e-Iqbal ───────────────────────────────────────────────────
    Clinic(
      name: 'Aga Khan Hospital — Gulshan Clinic',
      area: 'Gulshan-e-Iqbal',
      address: 'Block 7, Gulshan-e-Iqbal, Karachi',
      phone: '021-34930051',
      type: 'Private Hospital',
    ),
    Clinic(
      name: 'Shaukat Khanum Cancer Screening Camp (Periodic)',
      area: 'Gulshan-e-Iqbal',
      address: 'Gulshan-e-Iqbal Community Centre, Karachi',
      phone: '0800-02678',
      type: 'Cancer Screening Center',
    ),

    // ── Malir ─────────────────────────────────────────────────────────────
    Clinic(
      name: 'Malir Civil Hospital',
      area: 'Malir',
      address: 'Malir Halt, Malir, Karachi',
      phone: '021-34512031',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Sina Health, Education & Welfare Trust — Malir',
      area: 'Malir',
      address: 'Malir Colony, Karachi',
      phone: '021-34610110',
      type: 'NGO Health Unit',
    ),

    // ── Keamari ───────────────────────────────────────────────────────────
    Clinic(
      name: 'Keamari Hospital',
      area: 'Keamari',
      address: 'Keamari Town, Karachi',
      phone: '021-32851244',
      type: 'Public Hospital',
    ),
    Clinic(
      name: 'Marie Adelaide Leprosy Centre — Keamari',
      area: 'Keamari',
      address: 'Banaras Colony, Keamari, Karachi',
      phone: '021-32851156',
      type: 'NGO Health Unit',
    ),
  ];

  /// Returns all clinics in the given [area].
  /// Matching is case-insensitive and trims whitespace.
  static List<Clinic> getClinicsByArea(String area) {
    final query = area.trim().toLowerCase();
    return all.where((c) => c.area.toLowerCase() == query).toList();
  }

  /// Returns a deduplicated list of all area names in insertion order.
  static List<String> get areas {
    final seen = <String>{};
    return all.map((c) => c.area).where(seen.add).toList();
  }
}
