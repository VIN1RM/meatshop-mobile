class CheckoutSummaryModel {
  final String addressId;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String paymentMethod;
  final double? changeFor;
  final double? expectedTotal;

  const CheckoutSummaryModel({
    required this.addressId,
    required this.isScheduled,
    this.scheduledDate,
    this.scheduledTime,
    required this.paymentMethod,
    this.changeFor,
    this.expectedTotal,
  });
  CheckoutSummaryModel withExpectedTotal(double total) => CheckoutSummaryModel(
    addressId: addressId,
    isScheduled: isScheduled,
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
    paymentMethod: paymentMethod,
    changeFor: changeFor,
    expectedTotal: total,
  );
}
