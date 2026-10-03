import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/review_repository.dart';
import 'package:meatshop_mobile/models/product_review_model.dart';
import 'package:meatshop_mobile/providers/product_review_provider.dart';
import 'package:meatshop_mobile/providers/review_provider.dart';

void main() {
  test(
    'unit review is unique per order and concurrent submits are blocked',
    () async {
      final repo = _Reviews();
      final provider = ReviewProvider(repository: repo);
      Future<bool> submit(String order) => provider.submit(
        orderId: order,
        unitId: '1',
        unitRating: 5,
        unitComment: '',
      );
      repo.gate = Completer<void>();
      final first = submit('1');
      expect(await submit('1'), isFalse);
      repo.gate!.complete();
      expect(await first, isTrue);
      expect(await submit('1'), isTrue);
      expect(await submit('2'), isTrue);
      expect(repo.unitCalls, ['1', '2']);
    },
  );
  test(
    'retry after delivery failure does not resubmit the unit review',
    () async {
      final repo = _Reviews()..failDelivery = true;
      final provider = ReviewProvider(repository: repo);
      Future<bool> submit() => provider.submit(
        orderId: '1',
        unitId: '1',
        unitRating: 5,
        unitComment: '',
        deliveryPersonId: '2',
        deliveryRating: 5,
      );
      expect(await submit(), isFalse);
      repo.failDelivery = false;
      expect(await submit(), isTrue);
      expect(repo.unitCalls, ['1']);
      expect(repo.deliveries, {'1'});
    },
  );
  test(
    'partial product batch retries only unsaved products, scoped by order',
    () async {
      final repo = _Reviews()..failProduct = 'b';
      final provider = ProductReviewProvider(repository: repo);
      final batch = [_review('1', 'a'), _review('1', 'a'), _review('1', 'b')];
      expect(await provider.submitMultiple(batch), isFalse);
      repo.failProduct = null;
      expect(await provider.submitMultiple(batch), isTrue);
      expect(await provider.submitMultiple([_review('2', 'a')]), isTrue);
      expect(repo.productCalls, ['1/a', '1/b', '2/a']);
    },
  );
}

ProductReviewModel _review(String order, String product) => ProductReviewModel(
  id: '',
  orderId: order,
  clientId: '1',
  productId: product,
  productName: product,
  productImageUrl: '',
  unitId: '1',
  rating: 5,
  comment: '',
  createdAt: DateTime(2026),
);

class _Reviews implements ReviewRepository {
  final units = <String>{};
  final deliveries = <String>{};
  final products = <String, Set<String>>{};
  final unitCalls = <String>[];
  final productCalls = <String>[];
  Completer<void>? gate;
  bool failDelivery = false;
  String? failProduct;
  @override
  Future<OrderReviewStatus> getOrderStatus(String orderId) async {
    if (gate != null) await gate!.future;
    return OrderReviewStatus(
      unitReviewed: units.contains(orderId),
      deliveryReviewed: deliveries.contains(orderId),
      reviewedProductIds: Set.of(products[orderId] ?? {}),
    );
  }

  @override
  Future<void> reviewUnit(String orderId, int rating, String comment) async {
    unitCalls.add(orderId);
    units.add(orderId);
  }

  @override
  Future<void> reviewDelivery(
    String orderId,
    int rating,
    String comment,
  ) async {
    if (failDelivery) throw StateError('offline');
    deliveries.add(orderId);
  }

  @override
  Future<void> reviewProduct(
    String orderId,
    String productId,
    int rating,
    String comment,
  ) async {
    if (failProduct == productId) throw StateError('offline');
    productCalls.add('$orderId/$productId');
    (products[orderId] ??= {}).add(productId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
