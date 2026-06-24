import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DeliveryFeeService {
  DeliveryFeeService._();
  static final DeliveryFeeService instance = DeliveryFeeService._();

  final _db = FirebaseFirestore.instance;

  static const double _baseFee = 3.20;
  static const double _perKmRate = 1.10;
  static const double _longDistanceSurcharge = 2.00;
  static const double _longDistanceThresholdKm = 8.0;
  static const double _peakMultiplier = 1.3;

  bool _isPeakHour(DateTime now) {
    final weekday = now.weekday; 
    final isWeekend = weekday >= 5; 
    final hour = now.hour;
    final isLunch = hour >= 11 && hour < 14;
    final isDinner = hour >= 18 && hour < 21;
    return isWeekend && (isLunch || isDinner);
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  double calculate({
    required double unitLat,
    required double unitLng,
    required double destLat,
    required double destLng,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final distKm = _distanceKm(unitLat, unitLng, destLat, destLng);

    double fee = _baseFee + distKm * _perKmRate;

    if (distKm > _longDistanceThresholdKm) {
      fee += _longDistanceSurcharge;
    }

    if (_isPeakHour(now)) {
      fee *= _peakMultiplier;
    }

    return double.parse(fee.toStringAsFixed(2));
  }

  Future<double> applyToOrder({
    required String firestoreId,
    required double unitLat,
    required double unitLng,
    required double destLat,
    required double destLng,
  }) async {
    final fee = calculate(
      unitLat: unitLat,
      unitLng: unitLng,
      destLat: destLat,
      destLng: destLng,
    );

    await _db.collection('orders').doc(firestoreId).update({
      'delivery_fee': fee,
    });

    debugPrint('💰 delivery_fee calculado: R\$ $fee (pedido $firestoreId)');
    return fee;
  }
}