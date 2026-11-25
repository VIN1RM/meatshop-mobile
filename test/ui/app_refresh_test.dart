import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/widgets/app_refresh.dart';

void main() {
  testWidgets('pulls an empty state and waits for the actual request', (
    tester,
  ) async {
    final request = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppRefresh(
            scrollable: false,
            onRefresh: () {
              calls++;
              return request.future;
            },
            child: const Center(child: Text('Empty catalog')),
          ),
        ),
      ),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 600));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);
    expect(find.text('Empty catalog'), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    request.complete();
    await tester.pumpAndSettle();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'coalesces requests and retries failures without clearing content',
    (tester) async {
      var calls = 0;
      var fail = true;
      final request = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppRefresh(
              onRefresh: () async {
                calls++;
                await request.future;
                if (fail) throw StateError('offline');
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [Text('Existing data')],
              ),
            ),
          ),
        ),
      );
      final indicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      final first = indicator.onRefresh();
      final second = indicator.onRefresh();
      expect(calls, 1);
      request.complete();
      await Future.wait([first, second]);
      await tester.pumpAndSettle();
      expect(find.text('Existing data'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'handles short content, large text and disposal during a refresh',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final request = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: AppRefresh(
              scrollable: false,
              onRefresh: () => request.future,
              child: const Center(child: Text('Nenhum resultado encontrado.')),
            ),
          ),
        ),
      );
      final pending = tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpWidget(const SizedBox());
      request.completeError(StateError('offline'));
      await pending;
      expect(tester.takeException(), isNull);
    },
  );
}
