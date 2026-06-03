import 'package:meatshop_mobile/core/enums/chat_enums.dart';

class ChatArgs {
  final String conversationId;

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
  }) : conversationId = _buildId(currentUserId, otherUserId);

  static String _buildId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
