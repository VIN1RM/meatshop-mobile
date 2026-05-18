class UserModel {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final String photoUrl;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.photoUrl,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      cpf: data['cpf'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'cpf': cpf,
    'phone': phone,
    'photo_url': photoUrl,
  };

  UserModel copyWith({
    String? name,
    String? email,
    String? cpf,
    String? phone,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
