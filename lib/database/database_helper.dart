import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> deleteScreening(String id) async {
    final db = await database;
    await db.delete('screenings', where: 'id = ?', whereArgs: [id]);
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'oral_cancer_screening.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Fresh install: create both tables with all columns ────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id                   TEXT PRIMARY KEY,
        age                  INTEGER NOT NULL,
        gender               TEXT NOT NULL,
        phone                TEXT,
        uses_tobacco         INTEGER NOT NULL,
        tobacco_type         TEXT,
        duration             TEXT,
        frequency            TEXT,
        symptoms             TEXT,
        visit_type           TEXT NOT NULL,
        existing_patient_id  TEXT,
        created_at           TEXT NOT NULL
      )

    ''');

    await db.execute('''
      CREATE TABLE screenings (
        id                 TEXT PRIMARY KEY,
        patient_id         TEXT NOT NULL,
        location           TEXT NOT NULL,
        screened_at        TEXT NOT NULL,
        images             TEXT NOT NULL,
        verdict            TEXT NOT NULL,
        findings           TEXT NOT NULL,
        summary            TEXT NOT NULL DEFAULT '',
        key_points         TEXT NOT NULL DEFAULT '[]',
        symmetry_analysis  TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
        UNIQUE(patient_id, screened_at)  -- or whatever makes a record unique

      )
    ''');
  }

  // ── Existing install: add the three new columns if upgrading from v1 ──────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // SQLite does not support adding multiple columns in one ALTER TABLE —
      // each must be a separate statement.
      await db.execute(
        "ALTER TABLE screenings ADD COLUMN summary TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE screenings ADD COLUMN key_points TEXT NOT NULL DEFAULT '[]'",
      );
      await db.execute(
        'ALTER TABLE screenings ADD COLUMN symmetry_analysis TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        DELETE FROM screenings WHERE id IN (
          SELECT min(id) FROM screenings GROUP BY patient_id, screened_at
      )
      ''');
    }
  }

  // ── Save functions ────────────────────────────────────────────────────────

  Future<void> savePatient(Patient patient) async {
    final db = await database;
    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveScreening(Screening screening) async {
    final db = await database;
    await db.insert(
      'screenings',
      screening.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> savePatientAndScreening({
    required Patient patient,
    required Screening screening,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'patients',
        patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'screenings',
        screening.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // ── Read functions ────────────────────────────────────────────────────────

  Future<List<Screening>> getAllScreenings() async {
    final db = await database;
    final rows = await db.query('screenings', orderBy: 'screened_at DESC');
    return rows.map((r) => Screening.fromMap(r)).toList();
  }

  Future<List<Screening>> getScreeningsForPatient(String patientId) async {
    final db = await database;
    final rows = await db.query(
      'screenings',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'screened_at DESC',
    );
    return rows.map((r) => Screening.fromMap(r)).toList();
  }

  Future<List<Screening>> getScreeningsByPatientAndLocation({
    required String patientId,
    required String location,
  }) async {
    final db = await database;
    final rows = await db.query(
      'screenings',
      where: 'patient_id = ? AND location = ?',
      whereArgs: [patientId, location],
      orderBy: 'screened_at ASC',
    );
    return rows.map((r) => Screening.fromMap(r)).toList();
  }

  Future<Patient?> getPatient(String patientId) async {
    final db = await database;
    final rows = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [patientId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Patient.fromMap(rows.first);
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await database;
    final rows = await db.query(
      'patients',
      where: 'id LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Patient.fromMap(r)).toList();
  }

  Future<int> getScreeningCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM screenings');
    return Squint.firstIntOf(result);
  }
}

// ── Small helper to safely extract COUNT(*) ───────────────────────────────────
class Squint {
  static int firstIntOf(List<Map<String, dynamic>> result) {
    if (result.isEmpty) return 0;
    final val = result.first.values.first;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}
