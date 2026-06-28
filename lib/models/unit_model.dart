import 'package:geolocator/geolocator.dart';

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
  final double averageRating;
  final double? latitude;
  final double? longitude;

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
    this.averageRating = 0.0,
    this.latitude,
    this.longitude,
  });

  String get formattedAddress =>
      '$street, $number${complement.isNotEmpty ? ' - $complement' : ''}, $neighborhood, $city - $state';

  double? distanceTo(double userLat, double userLng) {
    if (latitude == null || longitude == null) return null;
    return Geolocator.distanceBetween(userLat, userLng, latitude!, longitude!) /
        1000;
  }

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
      'average_rating': averageRating,
      'latitude': latitude,
      'longitude': longitude,
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
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0.0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  UnitModel copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? adminId,
    String? imageUrl,
    String? coverUrl,
    DateTime? createdAt,
    double? averageRating,
    double? latitude,
    double? longitude,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      adminId: adminId ?? this.adminId,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      averageRating: averageRating ?? this.averageRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
