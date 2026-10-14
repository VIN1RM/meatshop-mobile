class CheckoutSummaryModel {
  final String addressId;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String paymentMethod;
  final double? changeFor;
  final double? expectedTotal;
  final String? quoteToken;
  final Map<String, String> unitPaymentMethods;
  final Map<String, String> coupons;

  const CheckoutSummaryModel({
    required this.addressId,
    required this.isScheduled,
    this.scheduledDate,
    this.scheduledTime,
    required this.paymentMethod,
    this.changeFor,
    this.expectedTotal,
    this.quoteToken,
    this.unitPaymentMethods = const {},
    this.coupons = const {},
  });

  CheckoutSummaryModel withExpectedTotal(double total, {String? token}) =>
      copyWith(total: total, token: token);

  CheckoutSummaryModel copyWith({
    double? total,
    String? token,
    Map<String, String>? methods,
    Map<String, String>? couponCodes,
    String? defaultMethod,
  }) => CheckoutSummaryModel(
    addressId: addressId,
    isScheduled: isScheduled,
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
    paymentMethod: defaultMethod ?? paymentMethod,
    changeFor: changeFor,
    expectedTotal: total ?? expectedTotal,
    quoteToken: token ?? quoteToken,
    unitPaymentMethods: methods ?? unitPaymentMethods,
    coupons: couponCodes ?? coupons,
  );
}
