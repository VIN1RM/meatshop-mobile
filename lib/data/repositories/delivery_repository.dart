import '../../models/delivery_earnings_model.dart';
import '../../models/delivery_goal_model.dart';
import '../../models/delivery_order_model.dart';

abstract interface class DeliveryRepository {
  Future<Map<String, Object?>> profile();
  Future<Map<String, Object?>> register(String vehicle);
  Future<void> setAvailability(bool online);
  Future<List<Map<String, Object?>>> vehicles();
  Future<Map<String, Object?>> createVehicle(Map<String, Object?> data);
  Future<Map<String, Object?>> updateVehicle(int id, Map<String, Object?> data);
  Future<void> activateVehicle(int id);
  Future<void> deleteVehicle(int id);
  Future<List<DeliveryOrder>> availableOrders();
  Future<DeliveryOrder?> activeOrder();
  Future<List<DeliveryOrder>> history();
  Future<String> accept(int orderId);
  Future<void> reject(int orderId, List<String> reasons);
  Future<void> finish(int orderId, String code);
  Future<void> sendLocation(
    int orderId,
    double latitude,
    double longitude, {
    double? accuracy,
  });
  Future<List<DeliveryEarningModel>> earnings();
  Future<List<DeliveryGoalModel>> goals();
  Future<DeliveryGoalModel> updateGoal(GoalPeriod period, double target);
  Future<List<Map<String, Object?>>> reviews(int deliveryPersonId);
}
