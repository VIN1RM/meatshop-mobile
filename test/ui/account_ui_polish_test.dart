import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/dialogs/delivery_code_dialog.dart';
import 'package:meatshop_mobile/ui/dialogs/personal_data_export_dialog.dart';
import 'package:meatshop_mobile/ui/screens/account/image_gallery_screen.dart';

void main() {
  testWidgets(
    'export formats are informational and do not require a repository',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PersonalDataExportDialog())),
      );
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(
        find.textContaining('ainda não estão disponíveis'),
        findsOneWidget,
      );
      expect(
        find
            .byType(ListTile)
            .evaluate()
            .every((element) => (element.widget as ListTile).onTap == null),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
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
