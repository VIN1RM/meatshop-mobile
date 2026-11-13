import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/ui/widgets/chat_participant_avatar.dart';

void main() {
  testWidgets(
    'renders inline profile pictures instead of treating them as network URLs',
    (tester) async {
      const image =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatParticipantAvatar(
              photoUrl: image,
              type: ChatParticipantType.client,
            ),
          ),
        ),
      );
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
      expect(find.byIcon(Icons.person_outline), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'uses the matching role icon when no photo exists or inline data is invalid',
    (tester) async {
      for (final source in [null, '', 'data:image/png;base64,%%%']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatParticipantAvatar(
                photoUrl: source,
                type: ChatParticipantType.delivery,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byIcon(Icons.delivery_dining), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
