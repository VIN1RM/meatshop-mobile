import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));
  testWidgets('review shows only the first name and a generic person icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewCard(
            review: ReviewModel(
              id: '1',
              orderId: '1',
              clientId: '8',
              clientName: '  Ana   Maria Silva ',
              unitId: '2',
              rating: 5,
              comment: 'Muito bom',
              createdAt: DateTime(2026, 10, 15),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Ana'), findsOneWidget);
    expect(find.textContaining('Maria'), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
