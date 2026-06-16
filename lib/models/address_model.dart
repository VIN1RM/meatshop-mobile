class AddressModel {
  final String id;
  final String label;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;
  final double? lat;
  final double? lng;

  const AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isDefault,
    this.lat,
    this.lng,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
    double? lat,
    double? lng,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  String get fullAddress =>
      '$street, $number'
      '${complement.isNotEmpty ? ', $complement' : ''}'
      ' — $neighborhood, $city/$state';

  String get formattedZip => 'CEP: $zipCode';

  factory AddressModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return AddressModel(
      id: docId,
      label: data['label'] as String? ?? '',
      street: data['street'] as String? ?? '',
      number: data['number'] as String? ?? '',
      complement: data['complement'] as String? ?? '',
      neighborhood: data['neighborhood'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      zipCode: data['zip_code'] as String? ?? '',
      isDefault: data['is_default'] as bool? ?? false,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      street: map['street'] as String? ?? '',
      number: map['number'] as String? ?? '',
      complement: map['complement'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      zipCode: map['zip_code'] as String? ?? '',
      isDefault: map['is_default'] as bool? ?? false,
      lat: (map['lat'] as num?)?.toDouble(), 
      lng: (map['lng'] as num?)?.toDouble(), 
    );
  }

  Map<String, dynamic> toFirestore() => {
    'label': label,
    'street': street,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'is_default': isDefault,
    if (lat != null) 'lat': lat, 
    if (lng != null) 'lng': lng, 
  };
}
