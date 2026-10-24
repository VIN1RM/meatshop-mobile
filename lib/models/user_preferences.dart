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

  factory UserPreferences.fromApi(Map<String, Object?> json) => UserPreferences(
    notifOrders: json['orders_enabled'] as bool? ?? true,
    notifDelivery: json['delivery_enabled'] as bool? ?? true,
    notifPromotions: json['promotions_enabled'] as bool? ?? true,
    notifSystem: json['system_enabled'] as bool? ?? true,
  );

  Map<String, Object?> toApi() => {
    'orders_enabled': notifOrders,
    'delivery_enabled': notifDelivery,
    'promotions_enabled': notifPromotions,
    'system_enabled': notifSystem,
  };

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
