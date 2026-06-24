import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/promotion_model.dart';
import 'package:meatshop_mobile/services/product_service.dart';
import 'package:meatshop_mobile/services/promotion_service.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/services/review_service.dart';

class ButcherProvider extends ChangeNotifier {
  final ProductService _productService;
  final PromotionService _promotionService;
  final ReviewService _reviewService;
  final String unitId;
  BusinessHoursModel? _todayHours;
  BusinessHoursModel? get todayHours => _todayHours;
  bool get isOpenNow => _todayHours?.isOpenNow ?? true;
  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;
  final BusinessHoursService _hoursService;

  ButcherProvider({
    required this.unitId,
    ProductService? productService,
    ReviewService? reviewService,
    PromotionService? promotionService,
    BusinessHoursService? hoursService,
  }) : _productService = productService ?? ProductService(),
       _promotionService = promotionService ?? PromotionService(),
       _hoursService = hoursService ?? BusinessHoursService(),
       _reviewService = reviewService ?? ReviewService();

  List<ProductModel> _items = [];
  List<ProductModel> get items => _items;

  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.fetchByUnitId(unitId: unitId),
        _promotionService.fetchActivePromotionsByUnit(unitId: unitId),
        _hoursService.fetchToday(unitId),
        _reviewService.watchUnitReviews(unitId, limit: 3).first,
      ]);

      _items = (results[0] as dynamic).items ?? [];
      _promotions = results[1] as List<PromotionModel>;
      _todayHours = results[2] as BusinessHoursModel?;
      _reviews = results[3] as List<ReviewModel>;
    } catch (e) {
      _error = 'Não foi possível carregar os produtos.';
      debugPrint('[ButcherProvider] erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
