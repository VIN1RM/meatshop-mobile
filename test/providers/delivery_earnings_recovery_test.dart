import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/core/utils/business_clock.dart';

class EarningsFake extends Fake implements DeliveryRepository {
  bool fail = true;
  @override
  Future<List<DeliveryEarningModel>> earnings() async {
    if (fail) throw StateError('offline');
    return [
      DeliveryEarningModel(
        id: '1',
        deliveryPersonId: '1',
        orderId: '1',
        label: 'Entrega',
        amount: 10,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<DeliveryGoalModel>> goals() async => [];
}

void main() {
  test(
    'reports load errors and retries without presenting an empty successful report',
    () async {
      final repository = EarningsFake();
      final provider = DeliveryEarningsProvider(repository: repository);
      await provider.load();
      expect(provider.error, isNotNull);
      expect(provider.loading, false);
      repository.fail = false;
      await provider.load();
      expect(provider.error, isNull);
      expect(provider.todayTotal, 10);
      expect(provider.weeklyBarValues.last, 10);
      const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
      expect(
        DeliveryEarningsProvider.weekDayLabels.last,
        labels[BusinessClock.now().weekday - 1],
      );
      provider.dispose();
    },
  );
}
