import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/utils/promotion_pricing.dart';
import 'package:meatshop_mobile/models/promotion_model.dart';

void main() {
  test(
    'matches server cents, including fractions, rounding and free prices',
    () {
      expect(PromotionPricing.price(80, 12.5, null), 70);
      expect(PromotionPricing.price(33.33, 10, null), 30);
      expect(PromotionPricing.price(2.01, 50, null), 1.01);
      expect(PromotionPricing.price(80, 0, 0), 0);
      expect(PromotionPricing.price(80, 100, null), 0);
      expect(PromotionPricing.price(80, 0, 99), 80);
    },
  );
  test(
    'displays fractional percentages without changing the advertised discount',
    () {
      final promotion = PromotionModel(
        id: '1',
        unitId: '1',
        productId: '1',
        title: 'Oferta',
        description: '',
        discountPercentage: 12.5,
        promotionalPrice: 1234.56,
        startsAt: DateTime(2026),
        endsAt: DateTime(2027),
        active: true,
      );
      expect(promotion.descontoLabel, '12,5% OFF');
      expect(promotion.formattedPrice, contains('1.234,56'));
      expect(promotion.copyWith(unitName: 'Loja').descontoLabel, '12,5% OFF');
    },
  );
}
