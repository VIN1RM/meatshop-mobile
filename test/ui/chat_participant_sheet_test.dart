import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/data/repositories/chat_repository.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/ui/components/sheets/chat_participant_sheet.dart';

class _Repository extends Fake implements ChatRepository {
  final channels = <ChatChannel>[];
  @override
  Future<ChatParticipant> participant(int orderId, ChatChannel channel) async {
    expect(orderId, 42);
    channels.add(channel);
    return ChatParticipant(
      userId: '2',
      name: channel == ChatChannel.unitDeliveryPerson
          ? 'Açougue atual'
          : 'Cliente atual',
      type: channel == ChatChannel.unitDeliveryPerson
          ? ChatParticipantType.unit
          : ChatParticipantType.client,
      photoUrl:
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
  }
}

void main() {
  testWidgets(
    'delivery contact selector resolves unit and customer profile pictures from their authorized channels',
    (tester) async {
      final repository = _Repository();
      ChatParticipantType? selected;
      await tester.pumpWidget(
        Provider.value(
          value: BackendRealtimeAccess(chat: repository),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    selected = await ChatParticipantDialog.show(
                      context: context,
                      orderId: 42,
                      currentUserType: ChatParticipantType.delivery,
                      unitName: 'Nome anterior',
                      secondaryName: 'Cliente anterior',
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(repository.channels, [
        ChatChannel.unitDeliveryPerson,
        ChatChannel.deliveryPerson,
      ]);
      expect(find.text('Açougue atual'), findsOneWidget);
      expect(find.text('Cliente atual'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        expect(image.image, isA<MemoryImage>());
      }
      await tester.tap(find.text('Cliente atual'));
      await tester.pumpAndSettle();
      expect(selected, ChatParticipantType.client);
      expect(tester.takeException(), isNull);
    },
  );
}
