import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/legal_document.dart';
import 'package:meatshop_mobile/ui/widgets/legal_document_list.dart';

void main() {
  for (final size in [const Size(320, 480), const Size(800, 1000)]) {
    testWidgets('document scrolls with accessible controls at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final content = List.generate(
        25,
        (index) =>
            '${index + 1}. Seção de privacidade\nInformações do documento para leitura.',
      ).join('\n\n');
      final document = LegalDocument(
        id: 1,
        title: 'Termos para Estabelecimentos',
        version: '2026-10-18',
        content: content,
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => LegalDocumentList.open(context, document),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('DOCUMENTO LEGAL'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final footerBefore = tester.getRect(find.text('Fechar'));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Fechar')), footerBefore);
      expect(find.text('Termos para Estabelecimentos'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });
  }
}
