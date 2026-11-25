import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/data/repositories/ai_assistant_repository.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_assistant_screen.dart';
import 'package:meatshop_mobile/ui/widgets/message_composer.dart';

class _Assistant implements AiAssistantRepository {
  String? sent;
  @override
  Future<List<AiConversationMessage>> loadHistory() async => [];
  @override
  Future<void> clearHistory() async {}
  @override
  Future<AiChatReply> send(
    String message, {
    CancellationToken? cancellationToken,
  }) async {
    sent = message;
    return const AiChatReply(text: 'Prepare a carne com ervas.');
  }
}

void main() {
  testWidgets(
    'assistant sends through the shared composer and fits above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final assistant = _Assistant();
      await tester.pumpWidget(
        Provider<AiAssistantRepository>.value(
          value: assistant,
          child: const MaterialApp(home: RecipeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Como preparar alcatra?');
      await tester.pump();
      await tester.tap(find.byTooltip('Enviar mensagem'));
      await tester.pumpAndSettle();
      expect(assistant.sent, 'Como preparar alcatra?');
      expect(find.text('Prepare a carne com ervas.'), findsOneWidget);
      expect(
        tester.getBottomRight(find.byType(MessageComposer)).dy,
        lessThanOrEqualTo(260),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
