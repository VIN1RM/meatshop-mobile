import 'package:flutter/material.dart';
import '../../core/enums/chat_enums.dart';

class ChatParticipantAvatar extends StatelessWidget {
  const ChatParticipantAvatar({
    super.key,
    this.photoUrl,
    required this.type,
    this.size = 48,
    this.assetFallback,
  });
  final String? photoUrl;
  final ChatParticipantType type;
  final double size;
  final String? assetFallback;

  @override
  Widget build(BuildContext context) {
    final source = photoUrl?.trim();
    Widget fallback() => ColoredBox(
      color: const Color(0xFFE0E0E0),
      child: Center(
        child: Icon(
          type == ChatParticipantType.unit
              ? Icons.storefront_outlined
              : type == ChatParticipantType.delivery
              ? Icons.delivery_dining
              : Icons.person_outline,
          size: size * .5,
          color: const Color(0xFF888888),
        ),
      ),
    );
    Widget picture;
    if (source != null && source.isNotEmpty) {
      if (source.startsWith('data:image/')) {
        try {
          picture = Image.memory(
            UriData.parse(source).contentAsBytes(),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback(),
          );
        } on FormatException {
          picture = fallback();
        }
      } else {
        picture = Image.network(
          source,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        );
      }
    } else if (assetFallback != null) {
      picture = Image.asset(
        assetFallback!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else {
      picture = fallback();
    }
    return SizedBox.square(
      dimension: size,
      child: ClipOval(child: picture),
    );
  }
}
