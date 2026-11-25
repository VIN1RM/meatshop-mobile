abstract final class PromotionPricing {
  static double price(
    double basePrice,
    double percentage,
    double? explicitPrice,
  ) {
    if (!basePrice.isFinite || basePrice < 0) return 0;
    final baseCents = (basePrice * 100).round();
    final rate = percentage.isFinite ? percentage.clamp(0, 100) : 0;
    final cents = explicitPrice != null && explicitPrice.isFinite
        ? (explicitPrice * 100).round()
        : (baseCents * (10000 - (rate * 100).round()) / 10000).round();
    return cents.clamp(0, baseCents) / 100;
  }
}
