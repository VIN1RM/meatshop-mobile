import '../../data/repositories/support_repository.dart';
import '../../models/support_ticket_model.dart';
import '../http/api_client.dart';

class HttpSupportRepository
    implements SupportRepository, PaginatedSupportRepository {
  HttpSupportRepository(this.client);
  final ApiClient client;
  @override
  Future<List<SupportTicketModel>> list({int page = 1}) => client.get(
    '/support-tickets/search',
    query: {'page': page, 'limit': 30},
    decode: (json) => ((json as Map)['data'] as List)
        .map(
          (row) => SupportTicketModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(),
  );
  @override
  Future<SupportTicketModel> get(int id) => client.get(
    '/support-tickets/$id',
    decode: (json) =>
        SupportTicketModel.fromJson(Map<String, dynamic>.from(json as Map)),
  );
  @override
  Future<SupportTicketModel> create(
    String subject,
    String description,
    String category, {
    String? contact,
  }) => client.post(
    '/support-tickets',
    body: {
      'subject': subject.trim(),
      'description': description.trim(),
      'category': category,
      if (contact != null && contact.trim().isNotEmpty)
        'contact': contact.trim(),
    },
    decode: (json) =>
        SupportTicketModel.fromJson(Map<String, dynamic>.from(json as Map)),
  );
  @override
  Future<SupportMessagesPage> messages(int id, {required int beforeId}) =>
      client.get(
        '/support-tickets/$id/messages',
        query: {'before_id': beforeId, 'limit': 30},
        decode: (json) {
          final data = Map<String, dynamic>.from(json as Map);
          return SupportMessagesPage(
            (data['items'] as List)
                .map(
                  (item) => SupportMessageModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(),
            hasMore: data['has_more'] == true,
            nextBeforeId: (data['next_before_id'] as num?)?.toInt(),
          );
        },
      );
  @override
  Future<void> send(int id, String message) => client.post(
    '/support-tickets/$id/messages',
    body: {'message': message.trim()},
    decode: (_) {},
  );
  @override
  Future<void> close(int id) =>
      client.patch('/support-tickets/$id/close', decode: (_) {});
  @override
  Future<void> reopen(int id) =>
      client.patch('/support-tickets/$id/reopen', decode: (_) {});
}
