import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/widgets/message_composer.dart';

void main() {
  testWidgets(
    'rejects blank messages and preserves multiline text until send completes',
    (tester) async {
      final controller = TextEditingController();
      var sends = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MessageComposer(
                controller: controller,
                onSend: () => sends++,
              ),
            ),
          ),
        ),
      );
      IconButton button() => tester.widget<IconButton>(find.byType(IconButton));
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.enterText(
        find.byType(TextField),
        'Primeira linha\nSegunda linha',
      );
      await tester.pump();
      expect(button().onPressed, isNotNull);
      await tester.tap(find.byType(IconButton));
      expect(sends, 1);
      expect(controller.text, 'Primeira linha\nSegunda linha');
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 4);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets(
    'keeps assistant cancellation available and exposes retry separately',
    (tester) async {
      final controller = TextEditingController();
      var stops = 0;
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MessageComposer(
                controller: controller,
                onSend: () {},
                busy: true,
                onStop: () => stops++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Interromper resposta'));
      expect(stops, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MessageComposer(
                controller: controller,
                onSend: () {},
                onRetry: () => retries++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tentar novamente'));
      expect(retries, 1);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets(
    'fits a small keyboard viewport with large text and bounds the composer height',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final controller = TextEditingController(
        text: List.filled(12, 'Mensagem longa').join('\n'),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                MessageComposer(controller: controller, onSend: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byType(MessageComposer)).dy,
        lessThanOrEqualTo(260),
      );
      expect(
        tester.getSize(find.byType(IconButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('closed conversations disable editing and sending', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Draft');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: MessageComposer(
              controller: controller,
              onSend: () {},
              enabled: false,
              hint: 'Conversa encerrada',
            ),
          ),
        ),
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
