
enum AppProfile {
  client,
  delivery,
  both;

  static AppProfile fromString(String value) {
    return switch (value.toUpperCase()) {
      'CLIENT' => AppProfile.client,
      'DELIVERY' => AppProfile.delivery,
      'BOTH' => AppProfile.both,
      _ => AppProfile.client,
    };
  }
}