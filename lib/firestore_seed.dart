/// firestore_seed.dart
///
/// Script de seed estrutural do Firestore para o MeatShop.
/// Cria todas as coleções e subcoleções com documentos template
/// (campos com valores nulos/vazios para documentar a estrutura).
///
/// Como usar:
///   1. Adicione este arquivo em scripts/ ou test/ do seu projeto
///   2. Chame seedFirestore() uma vez (ex: botão debug ou main isolado)
///   3. Remova ou proteja com flag de ambiente antes de subir para produção
///
/// Dependências necessárias no pubspec.yaml:
///   cloud_firestore: ^5.x.x
///   firebase_core: ^3.x.x

import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;

Future<void> seedFirestore() async {
  await Future.wait([
    _seedUsers(),
    _seedUnits(),
    _seedProducts(),
    _seedOrders(),
    _seedDeliveryPersons(),
    _seedCarts(),
    _seedPromotions(),
    _seedCoupons(),
    _seedNotifications(),
    _seedChats(),
    _seedReviews(),
    _seedDeliveryReviews(),
    _seedSupportTickets(),
    _seedAuditLogs(),
  ]);

  // ignore: avoid_print
  print('[MeatShop Seed] Firestore estruturado com sucesso.');
}

// ─────────────────────────────────────────────
// USERS
// Subcoleções: addresses, saved_payment_methods, user_units
// ─────────────────────────────────────────────
Future<void> _seedUsers() async {
  const userId = 'template_user';
  final ref = _db.collection('users').doc(userId);

  await ref.set({
    'name': '',
    'email': '',
    'cpf': '',
    'phone': '',
    'password_hash': '',
    'global_role': 'USER', // SUPER_ADMIN | USER
    'app_profile': 'CLIENT', // CLIENT | DELIVERY | BOTH
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: addresses
  await ref.collection('addresses').doc('template_address').set({
    'street': '',
    'number': '',
    'complement': '',
    'neighborhood': '',
    'city': '',
    'state': '',
    'zip_code': '',
    'label': 'Casa', // Casa | Trabalho | Outro
    'is_default': false,
  });

  // Subcoleção: saved_payment_methods
  await ref.collection('saved_payment_methods').doc('template_card').set({
    'mp_card_id': '',
    'mp_customer_id': '',
    'brand': '', // visa | mastercard | elo | hipercard | amex
    'last_four': '',
    'holder_name': '',
    'expiration_month': '',
    'expiration_year': '',
    'is_default': false,
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: user_units (vínculos do usuário com unidades)
  await ref.collection('user_units').doc('template_user_unit').set({
    'unit_id': '',
    'unit_ref': null, // DocumentReference para units/{id}
    'local_role': 'MEMBER', // ADMIN | MEMBER | DELIVERY
    'status': 'ACTIVE',
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// UNITS (Açougues)
// Subcoleções: categories, business_hours
// ─────────────────────────────────────────────
Future<void> _seedUnits() async {
  const unitId = 'template_unit';
  final ref = _db.collection('units').doc(unitId);

  await ref.set({
    'name': '',
    'city': '',
    'zip_code': '',
    'state': '',
    'admin_id': '', // ref para users/{id}
    'admin_ref': null, // DocumentReference
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: categories
  await ref.collection('categories').doc('template_category').set({
    'name': '',
    'description': '',
    'active': true,
    'unit_id': unitId,
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: business_hours
  // Um documento por dia da semana
  final weekdays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  for (final day in weekdays) {
    await ref.collection('business_hours').doc(day).set({
      'weekday': day,
      'opening_time': '08:00',
      'closing_time': '18:00',
      'is_open': day != 'sunday',
    });
  }
}

// ─────────────────────────────────────────────
// PRODUCTS
// Stock embutido no documento (evita leitura extra)
// ─────────────────────────────────────────────
Future<void> _seedProducts() async {
  await _db.collection('products').doc('template_product').set({
    'name': '',
    'description': '',
    'price': 0.0,
    'unit_of_measure': '', // kg | g | un | cx
    'active': true,
    'brand': '',
    'image_url': '',
    'unit_id': '', // ref para units/{id}
    'unit_ref': null, // DocumentReference
    'category_id': '', // ref para units/{id}/categories/{id}
    'category_ref': null, // DocumentReference
    'created_at': FieldValue.serverTimestamp(),
    // Stock embutido — evita leitura extra para exibição no catálogo
    'stock': {'quantity': 0, 'updated_at': FieldValue.serverTimestamp()},
  });
}

// ─────────────────────────────────────────────
// ORDERS
// Subcoleções: items, status_history, delivery_tracking
// ─────────────────────────────────────────────
Future<void> _seedOrders() async {
  const orderId = 'template_order';
  final ref = _db.collection('orders').doc(orderId);

  await ref.set({
    'client_id': '',
    'client_ref': null, // DocumentReference para users/{id}
    'unit_id': '',
    'unit_ref': null, // DocumentReference para units/{id}
    'delivery_person_id': null,
    'delivery_person_ref': null,
    'address_id': '',
    'address_ref': null,
    'coupon_id': null,
    'coupon_ref': null,
    'order_date': FieldValue.serverTimestamp(),
    'scheduled_delivery_date': null,
    'is_scheduled': false,
    'delivery_type': 'DELIVERY', // DELIVERY | PICKUP
    'status': 'PENDING',
    // PENDING | CONFIRMED | PREPARING | READY |
    // OUT_FOR_DELIVERY | DELIVERED | CANCELLED
    'delivery_status': 'WAITING_DELIVERY_PERSON',
    // WAITING_DELIVERY_PERSON | PICKUP | ON_THE_WAY | DELIVERED
    'delivery_step': null, // PICKUP | DELIVERING
    'payment_status': 'PENDING', // PENDING | PAID | FAILED | REFUNDED
    'subtotal': 0.0,
    'delivery_fee': 0.0,
    'discount_amount': 0.0,
    'total_amount': 0.0,
    'cancellation_reason': null,
    'cancelled_at': null,
    'cancelled_by': null, // CLIENT | UNIT | SYSTEM
  });

  // Subcoleção: items (OrderItem)
  await ref.collection('items').doc('template_item').set({
    'product_id': '',
    'product_ref': null, // DocumentReference
    // Snapshot dos dados do produto no momento do pedido
    'product_snapshot': {'name': '', 'unit_of_measure': '', 'image_url': ''},
    'quantity': 0,
    'unit_price': 0.0,
  });

  // Subcoleção: status_history
  await ref.collection('status_history').doc('template_history').set({
    'status': 'PENDING',
    'updated_by': '', // user_id
    'updated_by_ref': null, // DocumentReference
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: delivery_tracking
  await ref.collection('delivery_tracking').doc('template_tracking').set({
    'latitude': 0.0,
    'longitude': 0.0,
    'created_at': FieldValue.serverTimestamp(),
  });

  // Coleção raiz: payments (separada pois pode ter lógica própria)
  await _db.collection('payments').doc('template_payment').set({
    'order_id': orderId,
    'order_ref': null, // DocumentReference
    'method': '', // PIX | CREDIT_CARD | DEBIT_CARD | CASH
    'status': 'PENDING', // PENDING | APPROVED | REJECTED | REFUNDED
    'payment_date': null,
    'transaction_id': '',
    'mp_payment_id': null, // ID retornado pelo Mercado Pago
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// DELIVERY PERSONS
// Subcoleção: vehicles
// ─────────────────────────────────────────────
Future<void> _seedDeliveryPersons() async {
  const dpId = 'template_delivery_person';
  final ref = _db.collection('delivery_persons').doc(dpId);

  await ref.set({
    'user_id': '',
    'user_ref': null, // DocumentReference para users/{id}
    'status': 'PENDING', // PENDING | ACTIVE | INACTIVE
    'average_rating': 0.0,
    'created_at': FieldValue.serverTimestamp(),
  });

  // Subcoleção: vehicles
  await ref.collection('vehicles').doc('template_vehicle').set({
    'type': 'MOTORCYCLE', // MOTORCYCLE | BIKE | CAR | SCOOTER
    'model': '',
    'plate': '',
    'color': '',
    'year': '',
    'is_active': false, // veículo principal
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// CARTS
// Subcoleção: items
// Regra: 1 cart por usuário (user_id == cart_id)
// ─────────────────────────────────────────────
Future<void> _seedCarts() async {
  const cartId = 'template_user'; // mesmo ID do user
  final ref = _db.collection('carts').doc(cartId);

  await ref.set({
    'user_id': cartId,
    'user_ref': null, // DocumentReference
    'unit_id': '', // carrinho é por unidade
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });

  await ref.collection('items').doc('template_cart_item').set({
    'product_id': '',
    'product_ref': null, // DocumentReference
    'product_snapshot': {'name': '', 'image_url': '', 'unit_of_measure': ''},
    'quantity': 0,
    'unit_price': 0.0,
    'added_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// PROMOTIONS
// ─────────────────────────────────────────────
Future<void> _seedPromotions() async {
  await _db.collection('promotions').doc('template_promotion').set({
    'unit_id': '',
    'unit_ref': null,
    'product_id': '',
    'product_ref': null,
    'title': '',
    'description': '',
    'discount_percentage': 0.0,
    'promotional_price': 0.0,
    'starts_at': FieldValue.serverTimestamp(),
    'ends_at': FieldValue.serverTimestamp(),
    'active': false,
    'created_by': '', // user_id
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// COUPONS
// ─────────────────────────────────────────────
Future<void> _seedCoupons() async {
  await _db.collection('coupons').doc('template_coupon').set({
    'code': '',
    'discount_percentage': 0.0,
    'discount_value': 0.0,
    'expires_at': FieldValue.serverTimestamp(),
    'active': false,
    'usage_limit': null, // null = ilimitado
    'usage_count': 0,
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// NOTIFICATIONS
// ─────────────────────────────────────────────
Future<void> _seedNotifications() async {
  await _db.collection('notifications').doc('template_notification').set({
    'user_id': '',
    'user_ref': null,
    'message': '',
    'type': 'SYSTEM', // ORDER | DELIVERY | PROMOTION | SYSTEM
    'read': false,
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// CHATS
// ─────────────────────────────────────────────
Future<void> _seedChats() async {
  await _db.collection('chats').doc('template_chat').set({
    'order_id': '',
    'order_ref': null,
    'sender_id': '',
    'sender_ref': null,
    'receiver_id': '',
    'receiver_ref': null,
    'participant_type': '', // CLIENT | UNIT | DELIVERY
    'message': '',
    'sent_at': FieldValue.serverTimestamp(),
    'read': false,
  });
}

// ─────────────────────────────────────────────
// REVIEWS (avaliação do açougue/produto)
// ─────────────────────────────────────────────
Future<void> _seedReviews() async {
  await _db.collection('reviews').doc('template_review').set({
    'order_id': '',
    'order_ref': null,
    'client_id': '',
    'client_ref': null,
    'unit_id': '',
    'unit_ref': null,
    'product_id': null, // opcional
    'product_ref': null,
    'rating': 0, // 1 a 5
    'comment': '',
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// DELIVERY REVIEWS (avaliação do entregador)
// ─────────────────────────────────────────────
Future<void> _seedDeliveryReviews() async {
  await _db.collection('delivery_reviews').doc('template_delivery_review').set({
    'order_id': '',
    'order_ref': null,
    'client_id': '',
    'client_ref': null,
    'delivery_person_id': '',
    'delivery_person_ref': null,
    'rating': 0, // 1 a 5
    'comment': '',
    'created_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// SUPPORT TICKETS
// ─────────────────────────────────────────────
Future<void> _seedSupportTickets() async {
  await _db.collection('support_tickets').doc('template_ticket').set({
    'user_id': '',
    'user_ref': null,
    'subject': '',
    'description': '',
    'status': 'OPEN', // OPEN | IN_PROGRESS | RESOLVED | CLOSED
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────
// AUDIT LOGS
// ─────────────────────────────────────────────
Future<void> _seedAuditLogs() async {
  await _db.collection('audit_logs').doc('template_audit_log').set({
    'user_id': '',
    'user_ref': null,
    'action': '', // CREATE | UPDATE | DELETE | LOGIN | LOGOUT
    'entity': '', // ex: 'products', 'orders'
    'entity_id': '',
    'old_data': null, // Map com dados anteriores
    'new_data': null, // Map com dados novos
    'created_at': FieldValue.serverTimestamp(),
  });
}
