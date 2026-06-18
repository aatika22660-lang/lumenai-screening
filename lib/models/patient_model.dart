import 'dart:convert';

class Patient {
  final String id;
  final int age;
  final String gender;
  final String? phone;
  final bool usesTobacco;
  final String? tobaccoType;
  final String? duration;
  final String? frequency;
  final List<String> symptoms;
  final String visitType;
  final String? existingPatientId;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.age,
    required this.gender,
    this.phone,
    required this.usesTobacco,
    this.tobaccoType,
    this.duration,
    this.frequency,
    required this.symptoms,
    required this.visitType,
    this.existingPatientId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'gender': gender,
      'phone': phone,
      'uses_tobacco': usesTobacco ? 1 : 0,
      'tobacco_type': tobaccoType,
      'duration': duration,
      'frequency': frequency,
      'symptoms': jsonEncode(symptoms),
      'visit_type': visitType,
      'existing_patient_id': existingPatientId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      phone: map['phone'] as String?,
      usesTobacco: (map['uses_tobacco'] as int) == 1,
      tobaccoType: map['tobacco_type'] as String?,
      duration: map['duration'] as String?,
      frequency: map['frequency'] as String?,
      symptoms: map['symptoms'] != null
          ? List<String>.from(jsonDecode(map['symptoms'] as String))
          : [],

      visitType: map['visit_type'] as String,
      existingPatientId: map['existing_patient_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
