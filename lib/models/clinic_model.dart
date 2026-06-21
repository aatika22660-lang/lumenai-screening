class Clinic {
  final String name;
  final String area;
  final String address;
  final String phone;
  final String type;

  const Clinic({
    required this.name,
    required this.area,
    required this.address,
    required this.phone,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'area': area,
    'address': address,
    'phone': phone,
    'type': type,
  };

  factory Clinic.fromMap(Map<String, dynamic> map) {
    return Clinic(
      name: map['name'] as String,
      area: map['area'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      type: map['type'] as String,
    );
  }
}
