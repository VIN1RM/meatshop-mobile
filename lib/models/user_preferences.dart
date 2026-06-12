class UserPreferences {
  final bool notifOrders;
  final bool notifDelivery;
  final bool notifPromotions;
  final bool notifSystem;

  const UserPreferences({
    this.notifOrders = true,
    this.notifDelivery = true,
    this.notifPromotions = true,
    this.notifSystem = true,
  });

  UserPreferences copyWith({
    bool? notifOrders,
    bool? notifDelivery,
    bool? notifPromotions,
    bool? notifSystem,
  }) {
    return UserPreferences(
      notifOrders: notifOrders ?? this.notifOrders,
      notifDelivery: notifDelivery ?? this.notifDelivery,
      notifPromotions: notifPromotions ?? this.notifPromotions,
      notifSystem: notifSystem ?? this.notifSystem,
    );
  }
}
