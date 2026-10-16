import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';

const address = AddressModel(
  id: '1',
  label: 'Casa',
  street: 'Rua',
  number: '1',
  complement: '',
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: 'SP',
  zipCode: '01001000',
  isDefault: true,
);

class DeliveryFake extends Fake implements DeliveryRepository {
  bool fail = false;
  @override
  Future<List<DeliveryOrder>> availableOrders() async => [];
  @override
  Future<Map<String, Object?>> profile() async => {'id': 1, 'is_online': true};
  @override
  Future<DeliveryOrder?> activeOrder() async => DeliveryOrder(
    id: 42,
    clientName: 'Cliente',
    unitName: 'Unidade',
    address: address,
    unitAddress: address,
    items: '1 item',
    total: 10,
    status: DeliveryOrderStatus.onTheWay,
  );
  @override
  Future<String> regenerateCode(int id, {required bool pickup}) async {
    if (fail) throw StateError('offline');
    expect(id, 42);
    expect(pickup, true);
    return '123456';
  }
}

void main() {
  testWidgets(
    'restores an assigned delivery and requests a fresh pickup code explicitly',
    (tester) async {
      final repository = DeliveryFake();
      final provider = DeliveryProvider(repository: repository);
      provider.startListeningOrders('user');
      await tester.pump();
      expect(provider.activeOrder?.id, 42);
      expect(provider.pickupCode, isNull);
      await provider.regeneratePickupCode();
      expect(provider.pickupCode, '123456');
      repository.fail = true;
      await expectLater(provider.regeneratePickupCode(), throwsStateError);
      expect(provider.isLoading, false);
      expect(provider.lastError, isNotNull);
      expect(provider.pickupCode, '123456');
      provider.dispose();
    },
  );
}
