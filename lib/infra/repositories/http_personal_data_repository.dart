import '../../data/repositories/personal_data_repository.dart';
import '../http/api_client.dart';

class HttpPersonalDataRepository implements PersonalDataRepository {
  HttpPersonalDataRepository(this.client);
  final ApiClient client;
  @override
  Future<Map<String, dynamic>> retentionPolicy() => client.get(
    '/users/me/retention-policy',
    decode: (json) => Map<String, dynamic>.from(json as Map),
  );
}
