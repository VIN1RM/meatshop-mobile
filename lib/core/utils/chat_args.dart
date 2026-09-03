import 'package:meatshop_mobile/core/enums/chat_enums.dart';

class ChatArgs {
  final String conversationId;
  final int? orderId;
  final ChatChannel channel;
  final bool closed;

  final String currentUserId;
  final String currentUserName;
  final ChatParticipantType currentUserType;
  final String? currentUserPhoto;

  final String otherUserId;
  final String otherUserName;
  final ChatParticipantType otherUserType;
  final String? otherUserPhoto;

  final String? logoAsset;

  ChatArgs({
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserType,
    this.currentUserPhoto,
    this.otherUserPhoto,
    this.logoAsset,
    this.orderId,
    ChatChannel? channel,
    this.closed = false,
  }) : channel = channel ?? ChatChannel.between(currentUserType, otherUserType),
       conversationId = orderId == null
           ? _buildId(currentUserId, otherUserId)
           : '$orderId:${(channel ?? ChatChannel.between(currentUserType, otherUserType)).apiValue}';

  static String _buildId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
