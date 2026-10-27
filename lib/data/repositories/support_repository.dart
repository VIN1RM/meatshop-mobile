import '../../models/support_ticket_model.dart';

abstract interface class SupportRepository {
  Future<List<SupportTicketModel>> list({int page = 1});
  Future<SupportTicketModel> get(int id);
  Future<SupportTicketModel> create(
    String subject,
    String description,
    String category, {
    String? contact,
  });
  Future<void> send(int id, String message);
  Future<void> close(int id);
  Future<void> reopen(int id);
}
