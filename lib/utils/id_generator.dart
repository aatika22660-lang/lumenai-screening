import 'dart:math';

class IdGenerator {
  static String newPatientId() {
    final now = DateTime.now();
    final date =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final rand = Random().nextInt(9000) + 1000; // always 4 digits, 1000–9999
    return 'OC-$date-$rand';
  }

  static String newScreeningId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'SCR-$ms';
  }
}
