import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryRatingService {
  DeliveryRatingService._();
  static final DeliveryRatingService instance = DeliveryRatingService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> calculateAverageRating(
    String deliveryPersonId,
  ) async {
    try {
      final snapshot = await _db
          .collection('delivery_reviews')
          .where('delivery_person_id', isEqualTo: deliveryPersonId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {'rating': 0.0, 'count': 0, 'formattedRating': '0,0'};
      }

      double sum = 0;
      for (final doc in snapshot.docs) {
        final rating = doc['rating'] as int? ?? 0;
        sum += rating;
      }

      final average = sum / snapshot.docs.length;
      final rounded = double.parse(average.toStringAsFixed(1));

      return {
        'rating': rounded,
        'count': snapshot.docs.length,
        'formattedRating': rounded.toString().replaceAll('.', ','),
      };
    } catch (e) {
      debugPrint('Erro ao calcular média de avaliações: $e');
      return {'rating': 0.0, 'count': 0, 'formattedRating': '0,0'};
    }
  }

  Stream<double> watchAverageRating(String deliveryPersonId) {
    return _db
        .collection('delivery_reviews')
        .where('delivery_person_id', isEqualTo: deliveryPersonId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0.0;

          double sum = 0;
          for (final doc in snapshot.docs) {
            final rating = doc['rating'] as int? ?? 0;
            sum += rating;
          }

          final average = sum / snapshot.docs.length;
          return double.parse(average.toStringAsFixed(1));
        });
  }

  Future<List<DeliveryReview>> getDeliveryReviews(
    String deliveryPersonId,
  ) async {
    try {
      final snapshot = await _db
          .collection('delivery_reviews')
          .where('delivery_person_id', isEqualTo: deliveryPersonId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DeliveryReview.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar avaliações: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDetailedRatingStats(
    String deliveryPersonId,
  ) async {
    try {
      final snapshot = await _db
          .collection('delivery_reviews')
          .where('delivery_person_id', isEqualTo: deliveryPersonId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'average': 0.0,
          'total': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          'percentages': {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0},
        };
      }

      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      double sum = 0;

      for (final doc in snapshot.docs) {
        final rating = doc['rating'] as int? ?? 0;
        if (rating >= 1 && rating <= 5) {
          distribution[rating] = (distribution[rating] ?? 0) + 1;
          sum += rating;
        }
      }

      final total = snapshot.docs.length;
      final average = sum / total;
      final percentages = {
        1: (distribution[1]! / total * 100).toStringAsFixed(1),
        2: (distribution[2]! / total * 100).toStringAsFixed(1),
        3: (distribution[3]! / total * 100).toStringAsFixed(1),
        4: (distribution[4]! / total * 100).toStringAsFixed(1),
        5: (distribution[5]! / total * 100).toStringAsFixed(1),
      };

      return {
        'average': double.parse(average.toStringAsFixed(1)),
        'total': total,
        'distribution': distribution,
        'percentages': percentages,
      };
    } catch (e) {
      debugPrint('Erro ao calcular estatísticas: $e');
      return {
        'average': 0.0,
        'total': 0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'percentages': {1: '0.0', 2: '0.0', 3: '0.0', 4: '0.0', 5: '0.0'},
      };
    }
  }
}

class DeliveryReview {
  final String id;
  final String orderId;
  final String clientId;
  final String deliveryPersonId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  DeliveryReview({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.deliveryPersonId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory DeliveryReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DeliveryReview(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      clientId: data['client_id'] ?? '',
      deliveryPersonId: data['delivery_person_id'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'order_id': orderId,
    'client_id': clientId,
    'delivery_person_id': deliveryPersonId,
    'rating': rating,
    'comment': comment,
    'created_at': Timestamp.fromDate(createdAt),
  };
}
