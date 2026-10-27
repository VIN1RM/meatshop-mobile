import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/core/utils/business_clock.dart';

class EarningsFake extends Fake implements DeliveryRepository {
  bool fail = true;
  int loads = 0;
  @override
  Future<List<DeliveryEarningModel>> earnings() async {
    loads++;
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
  testWidgets(
    'updates earnings on events, reconnection and resume without polling',
    (tester) async {
      final repository = EarningsFake()..fail = false;
      final realtime = _Realtime();
      final provider = DeliveryEarningsProvider(
        repository: repository,
        realtime: realtime,
      );
      provider.startUpdates();
      await tester.pump();
      expect(repository.loads, 1);
      await tester.pump(const Duration(seconds: 31));
      expect(repository.loads, 1);
      realtime.events.add({'orderId': 1});
      await tester.pump();
      expect(repository.loads, 2);
      realtime.connections.add(RealtimeConnectionState.connected);
      await tester.pump();
      expect(repository.loads, 3);
      provider.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      expect(repository.loads, 4);
      provider.dispose();
      await realtime.events.close();
      await realtime.connections.close();
    },
  );

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

class _Realtime extends Fake implements RealtimeRepository {
  final events = StreamController<Map<String, Object?>>.broadcast();
  final connections = StreamController<RealtimeConnectionState>.broadcast();
  @override
  Stream<Map<String, Object?>> get statuses => events.stream;
  @override
  Stream<RealtimeConnectionState> get connection => connections.stream;
  @override
  Future<void> connect() async {}
}
