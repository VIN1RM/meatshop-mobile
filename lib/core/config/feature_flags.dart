final class FeatureFlags {
  const FeatureFlags({
    required this.backendAuth,
    required this.backendMarketplace,
  });

  factory FeatureFlags.fromEnvironment() {
    return const FeatureFlags(
      backendAuth: bool.fromEnvironment('FEATURE_BACKEND_AUTH'),
      backendMarketplace: bool.fromEnvironment('FEATURE_BACKEND_MARKETPLACE'),
    );
  }

  final bool backendAuth;
  final bool backendMarketplace;
}
