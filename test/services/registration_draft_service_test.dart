import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meatshop_mobile/services/registration_draft_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'retains registration details for the same identity only and clears after completion',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      await RegistrationDraftService.save('user-a', {
        'name': 'Ana',
        'cpf': '12345678901',
        'phone': '11999999999',
        'profile': 'client',
      });
      expect((await RegistrationDraftService.read('user-a'))?['name'], 'Ana');
      expect(await RegistrationDraftService.read('user-b'), isNull);
      await RegistrationDraftService.clear('user-a');
      expect(await RegistrationDraftService.read('user-a'), isNull);
    },
  );
  test(
    'expires abandoned registration drafts without blocking login',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'registration.draft.v1.user-a': '{"savedAt":"2020-01-01T00:00:00Z"}',
      });
      expect(await RegistrationDraftService.read('user-a'), isNull);
    },
  );
}
