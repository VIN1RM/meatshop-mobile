import '../../core/network/cancellation_token.dart';

abstract interface class BackendConnectionRepository {
  Future<void> checkPublicHealth({CancellationToken? cancellationToken});

  Future<void> checkAuthenticatedSession({
    CancellationToken? cancellationToken,
  });
}
