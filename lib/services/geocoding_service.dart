import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  Future<({double lat, double lng})?> geocode({
    required String street,
    required String number,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    try {
      final query = Uri.encodeComponent(
        '$street $number, $city, $state, $zipCode, Brasil',
      );

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$query&format=json&limit=1&countrycodes=br',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'MeatShopMobile/1.0',
              'Accept-Language': 'pt-BR',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final List<dynamic> results = jsonDecode(response.body);
      if (results.isEmpty) return null;

      final lat = double.tryParse(results[0]['lat'] as String? ?? '');
      final lng = double.tryParse(results[0]['lon'] as String? ?? '');

      if (lat == null || lng == null) return null;

      return (lat: lat, lng: lng);
    } catch (e) {
      debugPrint('GeocodingService erro: $e');
      return null;
    }
  }
}
