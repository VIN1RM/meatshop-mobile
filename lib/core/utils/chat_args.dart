import 'package:meatshop_mobile/core/enums/chat_enums.dart';

/// Argumentos passados para a tela de chat via Navigator.
/// Contém tudo que os providers precisam para inicializar.
class ChatArgs {
  /// ID da conversa (pode ser pré-calculado com ChatConversation.buildId)
  final String conversationId;

  /// ID do usuário atual (quem está logado)
  final String currentUserId;
  final String currentUserName;
  final ChatParticipantType currentUserType;
  final String? currentUserPhoto;

  /// ID do outro participante
  final String otherUserId;
  final String otherUserName;
  final ChatParticipantType otherUserType;
  final String? otherUserPhoto;

  /// Asset ou URL para o avatar exibido no header
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
