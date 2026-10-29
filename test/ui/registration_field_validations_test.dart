import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/legal_repository.dart';
import 'package:meatshop_mobile/models/legal_document.dart';
import 'package:meatshop_mobile/ui/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

class _Legal extends Fake implements LegalRepository {
  @override
  Future<LegalCatalog> catalog() async =>
      const LegalCatalog(enforced: false, documents: []);
}

void main() {
  testWidgets(
    'registration rejects invalid documents and contacts before submission',
    (tester) async {
      await tester.pumpWidget(
        Provider<LegalRepository>.value(
          value: _Legal(),
          child: const MaterialApp(home: RegisterPage()),
        ),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'João Silva');
      await tester.enterText(fields.at(1), 'joao@');
      await tester.enterText(fields.at(2), '11111111111');
      await tester.enterText(fields.at(3), '11887654321');
      await tester.enterText(fields.at(4), 'Abc123!x');
      await tester.enterText(fields.at(5), 'Abc123!x');
      expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
      await tester.pump();
      expect(find.text('CPF inválido'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Celular inválido'), findsOneWidget);
      await tester.enterText(fields.at(1), 'joao+compras@example.com');
      await tester.enterText(fields.at(2), '52998224725');
      await tester.enterText(fields.at(3), '+55 (11) 98765-4321');
      expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
      await tester.pump();
      expect(find.text('CPF inválido'), findsNothing);
      expect(find.text('E-mail inválido'), findsNothing);
      expect(find.text('Celular inválido'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
