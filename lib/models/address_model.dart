class AddressModel {
  final int id;
  final String label;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

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
  });

  AddressModel copyWith({
    int? id,
    String? label,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
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
    );
  }

  String get fullAddress =>
      '$street, $number'
      '${complement.isNotEmpty ? ', $complement' : ''}'
      ' — $neighborhood, $city/$state';

  String get formattedZip => 'CEP: $zipCode';

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] as int,
    label: json['label'] as String,
    street: json['street'] as String,
    number: json['number'] as String,
    complement: json['complement'] as String? ?? '',
    neighborhood: json['neighborhood'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    zipCode: json['zip_code'] as String,
    isDefault: json['is_default'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'street': street,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'is_default': isDefault,
  };
}
