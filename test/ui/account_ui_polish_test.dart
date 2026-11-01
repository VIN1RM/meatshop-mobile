import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/dialogs/delivery_code_dialog.dart';
import 'package:meatshop_mobile/ui/dialogs/delivery_export/delivery_export_dialog.dart';
import 'package:meatshop_mobile/models/delivery_export_model.dart';
import '../helpers/delivery_export_fakes.dart';
import 'package:meatshop_mobile/ui/screens/account/image_gallery_screen.dart';

void main() {
  testWidgets('personal exports fit a narrow viewport with working formats', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryExportDialog(
            repository: FakeDeliveryExportRepository(),
            isAllowed: () => true,
            report: DeliveryReportType.personal,
          ),
        ),
      ),
    );
    expect(find.text('Excel (.xlsx)'), findsOneWidget);
    expect(find.textContaining('JSON'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'delivery confirmation validates the code before dismissing the branded dialog',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await DeliveryCodeDialog.show(context);
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '12');
      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.byType(DeliveryCodeDialog), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();
      expect(result, '123456');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'gallery merges extra images, preserves the selected photo and swipes between pages',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageGalleryScreen(
            images: const ['https://example.com/first.png'],
            title: 'Fotos',
            loadImages: () async => [
              'https://example.com/first.png',
              'https://example.com/second.png',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1 de 2'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 de 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('gallery supports retry after a failed image list request', (
    tester,
  ) async {
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: ImageGalleryScreen(
          images: const [],
          title: 'Fotos',
          loadImages: () async {
            if (fail) throw Exception('offline');
            return ['https://example.com/retry.png'];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Tentar novamente'), findsOneWidget);
    fail = false;
    await tester.tap(find.textContaining('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 de 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
