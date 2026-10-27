class CheckoutSummaryModel {
  final String addressId;
  final Map<String, String> unitDeliveryTypes;
  bool get pickupOnly =>
      unitDeliveryTypes.isNotEmpty &&
      unitDeliveryTypes.values.every((value) => value == 'PICKUP');
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
    this.unitDeliveryTypes = const {},
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
    bool clearChange = false,
  }) => CheckoutSummaryModel(
    addressId: addressId,
    unitDeliveryTypes: unitDeliveryTypes,
    isScheduled: isScheduled,
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
    paymentMethod: defaultMethod ?? paymentMethod,
    changeFor: clearChange ? null : changeFor,
    expectedTotal: total ?? expectedTotal,
    quoteToken: token ?? quoteToken,
    unitPaymentMethods: methods ?? unitPaymentMethods,
    coupons: couponCodes ?? coupons,
  );
}
