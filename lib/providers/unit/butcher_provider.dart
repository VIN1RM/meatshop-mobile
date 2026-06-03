import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/promotion_model.dart';
import 'package:meatshop_mobile/services/product_service.dart';
import 'package:meatshop_mobile/services/promotion_service.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';

class ButcherProvider extends ChangeNotifier {
  final ProductService _productService;
  final PromotionService _promotionService;
  final String unitId;
  BusinessHoursModel? _todayHours;
  BusinessHoursModel? get todayHours => _todayHours;
  bool get isOpenNow => _todayHours?.isOpenNow ?? true;

  final BusinessHoursService _hoursService;

  ButcherProvider({
    required this.unitId,
    ProductService? productService,
    PromotionService? promotionService,
    BusinessHoursService? hoursService,
  }) : _productService = productService ?? ProductService(),
       _promotionService = promotionService ?? PromotionService(),
       _hoursService = hoursService ?? BusinessHoursService();

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
      ]);

      _items = (results[0] as ProductPage).items;
      _promotions = results[1] as List<PromotionModel>;
      _todayHours = results[2] as BusinessHoursModel?;
    } catch (e) {
      _error = 'Não foi possível carregar os produtos.';
      debugPrint('[ButcherProvider] erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
