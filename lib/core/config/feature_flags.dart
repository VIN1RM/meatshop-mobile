final class FeatureFlags {
  const FeatureFlags({
    required this.backendAuth,
    required this.backendMarketplace,
    required this.backendProfileCart,
  });

  factory FeatureFlags.fromEnvironment() {
    return const FeatureFlags(
      backendAuth: bool.fromEnvironment('FEATURE_BACKEND_AUTH'),
      backendMarketplace: bool.fromEnvironment('FEATURE_BACKEND_MARKETPLACE'),
      backendProfileCart: bool.fromEnvironment('FEATURE_BACKEND_PROFILE_CART'),
    );
  }

  final bool backendAuth;
  final bool backendMarketplace;
  final bool backendProfileCart;
}
