class UnitModel {
  final String id;
  final String name;
  final String cnpj;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String adminId;
  final String imageUrl;
  final String coverUrl;
  final DateTime createdAt;

  UnitModel({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.street,
    required this.number,
    this.complement = '',
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.adminId,
    required this.imageUrl,
    this.coverUrl = '',
    required this.createdAt,
  });

  String get formattedAddress =>
      '$street, $number${complement.isNotEmpty ? ' - $complement' : ''}, $neighborhood, $city - $state';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cnpj': cnpj,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'admin_id': adminId,
      'admin_ref': null,
      'image_url': imageUrl,
      'cover_url': coverUrl,
      'created_at': createdAt,
    };
  }

  factory UnitModel.fromMap(String id, Map<String, dynamic> map) {
    return UnitModel(
      id: id,
      name: map['name'] ?? '',
      cnpj: map['cnpj'] ?? '',
      street: map['street'] ?? '',
      number: map['number'] ?? '',
      complement: map['complement'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zip_code'] ?? '',
      adminId: map['admin_id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      coverUrl: map['cover_url'] ?? '',
      createdAt: (map['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
