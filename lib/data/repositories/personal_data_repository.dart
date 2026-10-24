abstract interface class PersonalDataRepository {
  Future<String> export();
  Future<Map<String, dynamic>> retentionPolicy();
}
