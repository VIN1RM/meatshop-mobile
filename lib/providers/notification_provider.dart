import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/notification_model.dart';
import 'package:meatshop_mobile/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final String userId;

  NotificationProvider({required this.userId}) {
    _init();
  }

  List<NotificationModel> _notifications = [];
  bool _loading = true;
  StreamSubscription<List<NotificationModel>>? _sub;

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get hasUnread => unreadCount > 0;

  void _init() {
    _sub = NotificationService.instance
        .notificationsStream(userId)
        .listen(
          (list) {
            _notifications = list;
            _loading = false;
            notifyListeners();
          },
          onError: (_) {
            _loading = false;
            notifyListeners();
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    await NotificationService.instance.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await NotificationService.instance.markAllAsRead(userId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
