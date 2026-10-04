import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// The image_picker plugin exposes this platform interface for test doubles.
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meatshop_mobile/ui/components/sheets/avatar_picker_sheet.dart';

void main() {
  late ImagePickerPlatform previous;
  late _Picker picker;
  setUp(() {
    previous = ImagePickerPlatform.instance;
    picker = _Picker();
    ImagePickerPlatform.instance = picker;
  });
  tearDown(() {
    ImagePickerPlatform.instance = previous;
  });
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AvatarPickerSheet.show(
                context,
                hasPhoto: false,
                onRemove: () {},
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('rapid taps start one picker and cancellation allows retry', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Galeria'));
    await tester.tap(find.text('Tirar foto'));
    expect(picker.calls, 1);
    picker.result.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Foto de perfil'), findsOneWidget);
    picker.result = Completer<XFile?>();
    await tester.tap(find.text('Galeria'));
    expect(picker.calls, 2);
    picker.result.complete(null);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('already_active is handled and a later selection succeeds', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Galeria'));
    picker.result.completeError(PlatformException(code: 'already_active'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Foto de perfil'), findsOneWidget);
    picker.result = Completer<XFile?>();
    await tester.tap(find.text('Galeria'));
    picker.result.complete(XFile('/tmp/photo.jpg'));
    await tester.pumpAndSettle();
    expect(find.text('Foto de perfil'), findsNothing);
    expect(picker.calls, 2);
  });
}

class _Picker extends ImagePickerPlatform {
  int calls = 0;
  late Completer<XFile?> result;
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) {
    calls++;
    result = Completer<XFile?>();
    return result.future;
  }
}
