import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = OnboardingService();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a fresh installation needs the introduction', () async {
    expect(await service.shouldShowIntroduction(), isTrue);
  });

  test(
    'completion survives a new service instance and keeps legacy state',
    () async {
      await service.completeIntroduction();
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingService.legacyKey), isTrue);
      expect(
        prefs.getInt(OnboardingService.versionKey),
        OnboardingService.currentVersion,
      );
    },
  );

  test(
    'existing users are not forced through the introduction again',
    () async {
      SharedPreferences.setMockInitialValues({
        OnboardingService.legacyKey: true,
      });
      expect(await service.shouldShowIntroduction(), isFalse);
    },
  );

  test(
    'an explicitly older version can receive an updated introduction',
    () async {
      SharedPreferences.setMockInitialValues({
        OnboardingService.legacyKey: true,
        OnboardingService.versionKey: OnboardingService.currentVersion - 1,
      });
      expect(await service.shouldShowIntroduction(), isTrue);
    },
  );

  test(
    'profile guides are independent from each other and authentication',
    () async {
      await service.completeGuide('client');
      expect(await service.shouldShowGuide('client'), isFalse);
      expect(await service.shouldShowGuide('delivery'), isTrue);
      expect(await service.shouldShowIntroduction(), isTrue);
    },
  );
}
