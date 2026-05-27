class UnitModel {
  final String id;
  final String name;
  final String cnpj; 
  final String city;
  final String zipCode;
  final String state;
  final String adminId;
  final String imageUrl;
  final DateTime createdAt;

  UnitModel({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.city,
    required this.zipCode,
    required this.state,
    required this.adminId,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cnpj': cnpj,
      'city': city,
      'zip_code': zipCode,
      'state': state,
      'admin_id': adminId,
      'admin_ref': null,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }

  factory UnitModel.fromMap(String id, Map<String, dynamic> map) {
    return UnitModel(
      id: id,
      name: map['name'] ?? '',
      cnpj: map['cnpj'] ?? '',
      city: map['city'] ?? '',
      zipCode: map['zip_code'] ?? '',
      state: map['state'] ?? '',
      adminId: map['admin_id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}