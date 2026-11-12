import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/data/repositories/support_repository.dart';
import 'package:meatshop_mobile/models/support_ticket_model.dart';
import 'package:meatshop_mobile/ui/screens/account/support_ticket_screen.dart';

Future<void> _render(
  WidgetTester tester,
  _Support repository, {
  Size size = const Size(600, 1400),
  double scale = 1,
  double keyboard = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    Provider<SupportRepository>.value(
      value: repository,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: const SupportTicketScreen(id: 8),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'shows readable ticket information and distinguishes customer and team messages',
    (tester) async {
      final repository = _Support();
      await _render(tester, repository);
      expect(
        tester.widget<Text>(find.text(repository.subject)).style?.color,
        Colors.white,
      );
      expect(find.text('Aberto'), findsOneWidget);
      expect(find.text('Você'), findsOneWidget);
      expect(find.text('Equipe MeatShop'), findsOneWidget);
      expect(find.textContaining('14:35'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Enviar resposta'),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps the reply on failure, sends it on retry and allows closing and reopening',
    (tester) async {
      final repository = _Support()..failSend = true;
      await _render(tester, repository);
      await tester.enterText(find.byType(TextField), 'Preciso de ajuda');
      await tester.pump();
      await tester.ensureVisible(find.text('Enviar resposta'));
      await tester.tap(find.text('Enviar resposta'));
      await tester.pumpAndSettle();
      expect(find.text('Envio indisponível no momento.'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Preciso de ajuda',
      );
      repository.failSend = false;
      await tester.ensureVisible(find.text('Enviar resposta'));
      await tester.tap(find.text('Enviar resposta'));
      await tester.pumpAndSettle();
      expect(repository.sent, ['Preciso de ajuda']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.scrollUntilVisible(
        find.text('Encerrar chamado'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Encerrar chamado'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Reabrir chamado'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Reabrir chamado'));
      await tester.pumpAndSettle();
      expect(repository.status, 'OPEN');
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long subjects and contacts fit with large text and the keyboard open',
    (tester) async {
      final repository = _Support()
        ..subject =
            'Preciso de ajuda para entender todos os detalhes do meu pedido agendado';
      await _render(
        tester,
        repository,
        size: const Size(320, 640),
        scale: 1.6,
        keyboard: 200,
      );
      await tester.scrollUntilVisible(
        find.byType(TextField),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'Minha mensagem');
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Enviar resposta'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    },
  );

  test('decodes sender and ticket ownership from the API response', () {
    final ticket = SupportTicketModel.fromJson({
      'id': 8,
      'user_id': 63,
      'subject': 'Ajuda',
      'status': 'OPEN',
      'messages': [
        {
          'message': 'Olá',
          'sender_id': 63,
          'sender': {'name': 'Cliente'},
          'created_at': '2026-11-12T14:35:00Z',
        },
      ],
    });
    expect(ticket.userId, 63);
    expect(ticket.messages.single.senderId, 63);
    expect(ticket.messages.single.senderName, 'Cliente');
  });
}

class _Support implements SupportRepository {
  String subject = 'Ajuda com meu pedido';
  String status = 'OPEN';
  bool failSend = false;
  final sent = <String>[];
  @override
  Future<SupportTicketModel> get(int id) async => SupportTicketModel(
    id: id,
    userId: 63,
    subject: subject,
    status: status,
    contact: 'cliente@exemplo.com.br',
    messages: [
      SupportMessageModel(
        text: 'Preciso confirmar o horário.',
        createdAt: DateTime(2026, 11, 12, 14, 35),
        senderId: 63,
        senderName: 'Cliente',
      ),
      SupportMessageModel(
        text: 'Vamos verificar para você.',
        createdAt: DateTime(2026, 11, 12, 14, 40),
        senderId: 1,
        senderName: 'Equipe MeatShop',
      ),
      for (final text in sent)
        SupportMessageModel(
          text: text,
          createdAt: DateTime(2026, 11, 12, 14, 45),
          senderId: 63,
        ),
    ],
  );
  @override
  Future<void> send(int id, String text) async {
    if (failSend) {
      throw const ApiFailure(
        kind: ApiFailureKind.network,
        message: 'Envio indisponível no momento.',
      );
    }
    sent.add(text);
  }

  @override
  Future<void> close(int id) async {
    status = 'CLOSED';
  }

  @override
  Future<void> reopen(int id) async {
    status = 'OPEN';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
