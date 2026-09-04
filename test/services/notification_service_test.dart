import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/services/notification_service.dart';

void main() {
  test('creates visible content for a data-only push', () {
    final message = RemoteMessage(
      messageId: 'message-1',
      data: const {
        'title': 'Pedido em rota',
        'body': 'Seu pedido saiu para entrega.',
      },
    );

    expect(NotificationService.notificationContent(message), (
      title: 'Pedido em rota',
      body: 'Seu pedido saiu para entrega.',
    ));
  });
}
