import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/support_repository.dart';
import 'package:meatshop_mobile/models/support_ticket_model.dart';
import 'package:meatshop_mobile/ui/screens/account/support_screen.dart';

class _Support implements SupportRepository {
  bool fail = true;
  String? savedSubject;
  @override
  Future<List<SupportTicketModel>> list({int page = 1}) async => [];
  @override
  Future<SupportTicketModel> create(
    String subject,
    String description,
    String category,
  ) async {
    if (fail) throw Exception('network');
    savedSubject = subject;
    return const SupportTicketModel(id: 1, subject: 'Teste', status: 'OPEN');
  }

  @override
  Future<SupportTicketModel> get(int id) async =>
      const SupportTicketModel(id: 1, subject: 'Teste', status: 'OPEN');
  @override
  Future<void> send(int id, String message) async {}
  @override
  Future<void> close(int id) async {}
  @override
  Future<void> reopen(int id) async {}
}

void main() {
  testWidgets('Support form remains accessible with large text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      Provider<SupportRepository>.value(
        value: _Support(),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.8),
              viewInsets: const EdgeInsets.only(bottom: 240),
            ),
            child: child!,
          ),
          home: const SupportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Novo chamado'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Enviar chamado'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'preserves support draft after network failure and allows retry',
    (tester) async {
      final repository = _Support();
      await tester.pumpWidget(
        Provider<SupportRepository>.value(
          value: repository,
          child: const MaterialApp(home: SupportScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Novo chamado'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Pedido atrasado',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Preciso de ajuda para acompanhar meu pedido.',
      );
      await tester.ensureVisible(find.text('Enviar chamado'));
      await tester.tap(find.text('Enviar chamado'));
      await tester.pumpAndSettle();
      expect(find.text('Pedido atrasado'), findsOneWidget);
      expect(find.textContaining('Seu texto foi preservado'), findsOneWidget);
      repository.fail = false;
      await tester.ensureVisible(find.text('Enviar chamado'));
      await tester.tap(find.text('Enviar chamado'));
      await tester.pumpAndSettle();
      expect(repository.savedSubject, 'Pedido atrasado');
      expect(find.text('Meus chamados'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
