class DeliveryPersonInfoModel {
  final String deliveryPersonId;
  final String name;
  final String photoUrl;
  final String vehicleType;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;
  final List<String> vehiclePhotoUrls;

  const DeliveryPersonInfoModel({
    required this.deliveryPersonId,
    required this.name,
    required this.photoUrl,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
    required this.vehiclePhotoUrls,
  });
}
