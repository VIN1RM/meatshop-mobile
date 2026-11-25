import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/ui/screens/orders/order_tracking_screen.dart';

class Tiles extends TileProvider {
  @override
  ImageProvider getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) => MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  );
}

class Orders extends Fake implements OrderRepository {
  String status = 'OUT_FOR_DELIVERY';
  @override
  Future<OrderModel> get(String id) async => OrderModel.fromApi({
    'id': 138,
    'unit_id': 1,
    'unit_name': 'Loja',
    'delivery_type': 'DELIVERY',
    'delivery_person_id': 7,
    'status': status,
    'payment_status': 'PAID',
    'total_amount': 30,
    'delivery_code': '123456',
    'items': <Object?>[],
    'destination': {'latitude': -16.68, 'longitude': -49.26},
  });
}

class Deliveries extends Fake implements DeliveryRepository {
  DeliveryTrackingPoint? point;
  @override
  Future<DeliveryTrackingPoint?> latestTracking(int orderId) async => point;
}

class Marketplace extends Fake implements MarketplaceRepository {
  final Completer<UnitModel> unit = Completer<UnitModel>();
  @override
  Future<UnitModel> getUnit(String id) => unit.future;
}

class Realtime extends Fake implements RealtimeRepository {
  final positions = StreamController<Map<String, Object?>>.broadcast();
  final changes = StreamController<Map<String, Object?>>.broadcast();
  @override
  Stream<Map<String, Object?>> get deliveryLocations => positions.stream;
  @override
  Stream<Map<String, Object?>> get statuses => changes.stream;
  @override
  Stream<RealtimeConnectionState> get connection => const Stream.empty();
  @override
  Future<void> subscribeDelivery(int orderId) async {}
  @override
  void unsubscribeDelivery(int orderId) {}
  void position(double latitude, int seconds) => positions.add({
    'orderId': 138,
    'deliveryPersonId': 7,
    'latitude': latitude,
    'longitude': -49.25,
    'capturedAt': DateTime.now()
        .add(Duration(seconds: seconds))
        .toIso8601String(),
  });
}

void main() {
  late Orders orders;
  late Deliveries deliveries;
  late Marketplace marketplace;
  late Realtime realtime;
  setUp(() {
    orders = Orders();
    deliveries = Deliveries();
    marketplace = Marketplace();
    realtime = Realtime();
  });
  tearDown(() async {
    await realtime.positions.close();
    await realtime.changes.close();
  });
  Future<void> open(WidgetTester tester, {double scale = 1}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<OrderRepository>.value(value: orders),
          Provider<DeliveryRepository>.value(value: deliveries),
          Provider<MarketplaceContext>.value(
            value: MarketplaceContext(marketplace),
          ),
          Provider<BackendRealtimeAccess>.value(
            value: BackendRealtimeAccess(realtime: realtime),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: OrderTrackingScreen(orderId: 138, tileProvider: Tiles()),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows the full map and compact controls without code, contacts or refresh',
    (tester) async {
      await open(tester);
      expect(find.text('Entrega #138'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(
        tester.getSize(find.byType(FlutterMap)),
        tester.getSize(find.byType(Scaffold)),
      );
      expect(find.text('123456'), findsNothing);
      expect(find.textContaining('Código de entrega'), findsNothing);
      expect(find.textContaining('Falar com'), findsNothing);
      expect(find.byIcon(Icons.refresh_rounded), findsNothing);
      final follow = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(follow.onPressed, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'follows new positions, respects exploration and resumes via the follow button',
    (tester) async {
      await open(tester);
      realtime.position(-16.67, 1);
      await tester.pump();
      await tester.pumpAndSettle();
      final mapWidget = tester.widget<FlutterMap>(find.byType(FlutterMap));
      final map = mapWidget.mapController!;
      expect(map.camera.center.latitude, closeTo(-16.67, .00001));
      expect(map.camera.zoom, 16);
      expect(find.text('Seguindo entregador'), findsOneWidget);
      // Loading the unit later must not override the camera following the courier.
      marketplace.unit.complete(
        UnitModel(
          id: '1',
          name: 'Loja',
          cnpj: '',
          street: '',
          number: '',
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
          adminId: '1',
          imageUrl: '',
          createdAt: DateTime(2026),
          latitude: -16.8,
          longitude: -49.3,
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(map.camera.center.latitude, closeTo(-16.67, .00001));
      mapWidget.options.onPositionChanged!(map.camera, true);
      await tester.pump();
      realtime.position(-16.66, 2);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(map.camera.center.latitude, closeTo(-16.67, .00001));
      await tester.tap(find.text('Seguir entregador'));
      await tester.pumpAndSettle();
      expect(map.camera.center.latitude, closeTo(-16.66, .00001));
      realtime.position(-16.65, 3);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(map.camera.center.latitude, closeTo(-16.65, .00001));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('fits a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester, scale: 1.6);
    expect(find.text('Entrega #138'), findsOneWidget);
    expect(find.text('Seguir entregador'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'refreshes the map automatically when a position becomes available',
    (tester) async {
      await open(tester);
      deliveries.point = DeliveryTrackingPoint(
        orderId: 138,
        latitude: -16.64,
        longitude: -49.24,
        recordedAt: DateTime.now(),
      );
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      final map = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      expect(map.camera.center.latitude, closeTo(-16.64, .00001));
      expect(find.text('Seguindo entregador'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('stops showing courier location when the order ends', (
    tester,
  ) async {
    await open(tester);
    realtime.position(-16.67, 1);
    await tester.pump();
    await tester.pumpAndSettle();
    orders.status = 'DELIVERED';
    realtime.changes.add({'orderId': 138});
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Entrega encerrada'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byTooltip('Entregador'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
