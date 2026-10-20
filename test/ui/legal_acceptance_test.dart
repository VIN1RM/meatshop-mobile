import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/legal_repository.dart';
import 'package:meatshop_mobile/models/legal_document.dart';
import 'package:meatshop_mobile/ui/widgets/legal_registration.dart';
import 'package:meatshop_mobile/ui/screens/account/legal_screen.dart';
import 'package:meatshop_mobile/ui/widgets/legal_section.dart';

void main() {
  testWidgets('reading a document does not grant acceptance', (tester) async {
    final repository = _LegalRepository();
    List<int>? accepted;
    await tester.pumpWidget(
      Provider<LegalRepository>.value(
        value: repository,
        child: MaterialApp(
          home: Scaffold(
            body: LegalRegistration(onChanged: (ids) => accepted = ids),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(accepted, isNull);
    await tester.tap(find.text('Terms · v1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Versioned terms'), findsOneWidget);
    expect(accepted, isNull);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(accepted, [1, 2]);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(accepted, isNull);
  });

  testWidgets(
    'submits only the versions explicitly presented after confirmation',
    (tester) async {
      final repository = _LegalRepository();
      await tester.pumpWidget(
        Provider<LegalRepository>.value(
          value: repository,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<bool>(
                      builder: (_) =>
                          const LegalScreen(requiredAcceptance: true),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aceitar e continuar'), 160);
      expect(
        tester
            .widget<LegalActionButton>(find.byType(LegalActionButton))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Aceitar e continuar'));
      await tester.tap(find.text('Aceitar e continuar'));
      await tester.pumpAndSettle();
      expect(repository.accepted, [1, 2]);
      expect(find.text('Open'), findsOneWidget);
    },
  );
  testWidgets(
    'acceptance remains accessible on a small screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        Provider<LegalRepository>.value(
          value: _LegalRepository(),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const LegalScreen(requiredAcceptance: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byType(Checkbox), 120);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Aceitar e continuar'), 100);
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<LegalActionButton>(find.byType(LegalActionButton))
            .onPressed,
        isNotNull,
      );
    },
  );
}

final class _LegalRepository implements LegalRepository {
  List<int>? accepted;
  final _catalog = const LegalCatalog(
    enforced: true,
    documents: [
      LegalDocument(
        id: 1,
        title: 'Terms',
        version: 'v1',
        content: 'Versioned terms',
      ),
      LegalDocument(
        id: 2,
        title: 'Privacy',
        version: 'v1',
        content: 'Privacy notice',
      ),
    ],
  );

  @override
  Future<LegalCatalog> catalog() async => _catalog;
  @override
  Future<LegalCatalog> pending() async => _catalog;
  @override
  Future<void> accept(List<int> documentIds) async {
    accepted = documentIds;
  }

  @override
  Future<List<LegalAcceptanceRecord>> history() async => [];
  @override
  Future<LegalDocument> document(int id) async =>
      _catalog.documents.firstWhere((document) => document.id == id);
}
