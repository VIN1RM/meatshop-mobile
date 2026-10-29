import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/firebase_options.dart';
import 'package:meatshop_mobile/infra/auth/backend_session_refresher.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';
import 'package:meatshop_mobile/infra/repositories/http_address_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_cart_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_chat_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_delivery_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_federated_auth_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_legal_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_marketplace_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_order_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_profile_repository.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/legal_document.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/services/firebase_identity_service.dart';

class _SessionStore implements SessionStore {
  SessionTokens? tokens;
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens value) async {
    tokens = value;
  }

  @override
  Future<void> clear() async {
    tokens = null;
  }
}

class _Actor {
  _Actor(this.config) {
    transport = JsonHttpTransport(config: config);
    session = SessionCoordinator(
      store: _SessionStore(),
      refresher: BackendSessionRefresher(transport),
    );
    client = ApiClient(transport: transport, session: session);
    auth = HttpFederatedAuthRepository(
      transport: transport,
      client: client,
      session: session,
    );
  }
  final ApiConfig config;
  late final JsonHttpTransport transport;
  late final SessionCoordinator session;
  late final ApiClient client;
  late final HttpFederatedAuthRepository auth;
  Future<void> login(String email, String password) async {
    AuthService.instance.configure(client);
    await AuthService.instance.login(email: email, password: password);
    final token = await AuthService.instance.currentUser!.getIdToken(true);
    await auth.exchangeFirebaseToken(token!);
    final legal = HttpLegalRepository(client);
    final pending = await legal.pending();
    if (pending.enforced && pending.documents.isNotEmpty) {
      await legal.accept(
        pending.documents.map((document) => document.id).toList(),
      );
    }
    expect(
      (await HttpProfileRepository(client, config).getProfile()).email,
      email,
    );
  }

  Future<void> close() async {
    try {
      await auth.logout();
    } finally {
      await client.legalRequirements.close();
      transport.close();
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const enabled = bool.fromEnvironment('MEATSHOP_LOCAL_E2E');
  const password = String.fromEnvironment('MEATSHOP_E2E_PASSWORD');
  const emulatorHost = String.fromEnvironment(
    'MEATSHOP_AUTH_EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  const emulatorPort = int.fromEnvironment(
    'MEATSHOP_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );

  testWidgets(
    'real local registration, authentication, checkout, chat, payment and delivery',
    (tester) async {
      final config = ApiConfig.fromEnvironment();
      expect(config.environment, AppEnvironment.development);
      expect(config.baseUrl.host, isIn(['10.0.2.2', '127.0.0.1', 'localhost']));
      expect(config.baseUrl.port, 3101);
      expect(password, isNotEmpty);
      expect(emulatorHost, isIn(['10.0.2.2', '127.0.0.1', 'localhost']));
      final options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: options.apiKey,
          appId: options.appId,
          messagingSenderId: options.messagingSenderId,
          projectId: 'demo-meatshop-e2e',
        ),
      );
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, emulatorPort);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Integração local'))),
      );
      final actors = List.generate(4, (_) => _Actor(config));
      final registration = actors[0];
      final client = actors[1];
      final owner = actors[2];
      final courier = actors[3];
      addTearDown(() async {
        for (final actor in actors) {
          await actor.close();
        }
        await FirebaseAuth.instance.signOut();
      });

      await tester.runAsync(() async {
        final email =
            'registration-${DateTime.now().microsecondsSinceEpoch}@meatshop.local';
        await AuthService.instance.registerFirebaseIdentity(
          name: 'Integration Customer',
          email: email,
          password: password,
        );
        final emulator = Uri.parse(
          'http://$emulatorHost:$emulatorPort/emulator/v1/projects/demo-meatshop-e2e/oobCodes',
        );
        final response = await http.get(emulator);
        expect(response.statusCode, 200);
        final codes = (jsonDecode(response.body) as Map)['oobCodes'] as List;
        final verification = codes.cast<Map>().lastWhere(
          (code) =>
              code['email'] == email && code['requestType'] == 'VERIFY_EMAIL',
        );
        await FirebaseAuth.instance.applyActionCode(
          verification['oobCode'] as String,
        );
        await AuthService.instance.currentUser!.reload();
        await registration.login(email, password);
        final registered = await registration.auth.completeProfile(
          name: 'Integration Customer',
          cpf: '39053344705',
          phone: '62999998888',
          appProfile: AppProfile.client,
        );
        expect(registered.profileComplete, isTrue);
        await registration.session.refresh();
        expect(
          (await registration.auth.restore(
            (await AuthService.instance.currentUser!.getIdToken(true))!,
          )).id,
          registered.id,
        );

        await client.login('client@meatshop.local', password);
        await owner.login('owner@meatshop.local', password);
        await courier.login('delivery@meatshop.local', password);
        final marketplace = HttpMarketplaceRepository(client.client, config);
        final units = await marketplace.listUnits();
        final unit = units.items.singleWhere(
          (value) => value.name == 'Demo Butcher Shop',
        );
        final products = await marketplace.listProducts(unitId: unit.id);
        final product = products.items.firstWhere(
          (value) => value.stockQuantity > 0,
        );
        final addresses = await HttpAddressRepository(client.client).list();
        final cartRepository = HttpCartRepository(client.client);
        expect(await cartRepository.getCart(), isEmpty);
        await cartRepository.addItem(product.id, 1);
        final cart = CartProvider(uid: 'local-e2e', repository: cartRepository);
        final ordersRepository = HttpOrderRepository(client.client);
        final orders = OrderProvider(repository: ordersRepository);
        try {
          await cart.loadCart();
          expect(cart.items, hasLength(1));
          final summary = CheckoutSummaryModel(
            addressId: addresses.first.id,
            isScheduled: false,
            paymentMethod: 'cash',
          );
          await HttpAddressRepository(client.client).update(
            addresses.first.copyWith(
              lat: -16.6869,
              lng: -49.2648,
              coordinateSource: 'USER_PIN',
            ),
          );
          final establishmentTerms = await owner.client.get(
            '/legal/documents',
            authenticated: false,
            query: {'audience': 'establishment'},
            decode: LegalCatalog.fromJson,
          );
          await owner.client.post(
            '/legal/acceptances',
            body: {
              'unit_id': int.parse(unit.id),
              'accepted': true,
              'authorized_representative': true,
              'channel': 'web',
              'document_ids': establishmentTerms.documents
                  .map((document) => document.id)
                  .toList(),
            },
            decode: (_) {},
          );
          await owner.client.patch(
            '/units/${unit.id}',
            body: {'latitude': -16.6869, 'longitude': -49.2648},
            decode: (_) {},
          );
          final quote = await orders.quote(summary);
          expect(quote!.totalAmount, greaterThan(0));
          expect(
            await orders.placeOrder(
              summary: summary,
              items: cart.items,
              total: quote.totalAmount,
              cartProvider: cart,
              quoteToken: quote.token,
            ),
            isTrue,
            reason: orders.error,
          );
          final orderId = orders.lastOrderId!;
          expect(cart.items, isEmpty);
          expect(
            (await ordersRepository.get(orderId)).paymentStatus,
            'PENDING',
          );
          final chat = HttpChatRepository(client.client);
          final sent = await chat.send(
            int.parse(orderId),
            ChatChannel.unit,
            'Pedido sintético de integração',
          );
          expect(
            (await chat.history(
              int.parse(orderId),
              ChatChannel.unit,
              currentUserId: int.parse(client.client.accountId!),
            )).any((message) => message.id == sent.id),
            isTrue,
          );
          await owner.client.patch('/orders/$orderId/confirm', decode: (_) {});
          for (final status in ['PREPARING', 'READY']) {
            await owner.client.patch(
              '/orders/$orderId/status',
              body: {'status': status},
              decode: (_) {},
            );
          }
          final delivery = HttpDeliveryRepository(courier.client, config);
          await delivery.setAvailability(true);
          expect(
            (await delivery.availableOrders()).any(
              (order) => '${order.id}' == orderId,
            ),
            isTrue,
          );
          final pickupCode = await delivery.accept(int.parse(orderId));
          await owner.client.post(
            '/delivery/units/${unit.id}/orders/$orderId/verify-pickup',
            body: {'code': pickupCode},
            decode: (_) {},
          );
          expect(
            (await ordersRepository.get(orderId)).status,
            'OUT_FOR_DELIVERY',
          );
          final deliveryCode = await HttpDeliveryRepository(
            client.client,
            config,
          ).regenerateCode(int.parse(orderId), pickup: false);
          await delivery.finish(int.parse(orderId), deliveryCode);
          await owner.client.post(
            '/payments/orders/$orderId/receipt',
            body: {
              'amount': quote.totalAmount,
              'reference': 'local-e2e-$orderId',
            },
            decode: (_) {},
          );
          final completed = await ordersRepository.get(orderId);
          expect(completed.status, 'DELIVERED');
          expect(completed.paymentStatus, 'PAID');
          expect(
            (await orders.historyPage(
              0,
            )).orders.any((order) => order.id == orderId),
            isTrue,
          );
          expect(
            (await delivery.history()).any((order) => '${order.id}' == orderId),
            isTrue,
          );
          expect(await delivery.activeOrder(), isNull);
          await delivery.setAvailability(false);
        } finally {
          orders.dispose();
          cart.dispose();
        }
      });
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
