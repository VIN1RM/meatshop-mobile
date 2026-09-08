final class FeatureFlags {
  const FeatureFlags({
    required this.backendAuth,
    required this.backendMarketplace,
    required this.backendProfileCart,
    required this.backendCheckout,
    required this.backendDelivery,
    required this.backendRealtime,
    required this.backendFirebaseServices,
  });

  factory FeatureFlags.fromEnvironment() {
    return const FeatureFlags(
      backendAuth: true,
      backendMarketplace: true,
      backendProfileCart: true,
      backendCheckout: true,
      backendDelivery: true,
      backendRealtime: true,
      backendFirebaseServices: true,
    );
  }

  final bool backendAuth;
  final bool backendMarketplace;
  final bool backendProfileCart;
  final bool backendCheckout;
  final bool backendDelivery;
  final bool backendRealtime;
  final bool backendFirebaseServices;
}
