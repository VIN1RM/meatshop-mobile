// import 'package:flutter/material.dart';
// import 'package:meatshop_mobile/services/delivery_rating_service.dart';

// class DeliveryRatingWidget extends StatelessWidget {
//   final double averageRating;
//   final int reviewCount;
//   final VoidCallback? onViewAll;

//   const DeliveryRatingWidget({
//     super.key,
//     required this.averageRating,
//     required this.reviewCount,
//     this.onViewAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onViewAll,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F5F5),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Icon(
//                   Icons.star_rounded,
//                   color: Color(0xFFFFC107),
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${averageRating.toStringAsFixed(1)} de 5',
//                       style: const TextStyle(
//                         color: Color(0xFF1A1A1A),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     Text(
//                       '$reviewCount ${reviewCount == 1 ? 'avaliação' : 'avaliações'}',
//                       style: const TextStyle(
//                         color: Color(0xFF888888),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RatingDistributionWidget extends StatelessWidget {
//   final Map<String, dynamic> stats;

//   const RatingDistributionWidget({super.key, required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     final distribution = stats['distribution'] as Map<int, int>? ?? {};
//     final percentages = stats['percentages'] as Map<int, dynamic>? ?? {};
//     final total = stats['total'] as int? ?? 0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 12),
//           child: Text(
//             'Distribuição de avaliações',
//             style: TextStyle(
//               color: Color(0xFF1A1A1A),
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         ...List.generate(5, (index) {
//           final stars = 5 - index;
//           final count = distribution[stars] ?? 0;
//           final percentage =
//               double.tryParse(percentages[stars]?.toString() ?? '0') ?? 0.0;

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 40,
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: '$stars ',
//                           style: const TextStyle(
//                             color: Color(0xFF1A1A1A),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         WidgetSpan(
//                           child: Icon(
//                             Icons.star_rounded,
//                             size: 12,
//                             color: _getStarColor(stars),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     height: 6,
//                     margin: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE0E0E0),
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                     child: FractionallySizedBox(
//                       widthFactor: total > 0 ? (count / total) : 0,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: _getStarColor(stars),
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 50,
//                   child: Text(
//                     '$count (${percentage.toStringAsFixed(0)}%)',
//                     style: const TextStyle(
//                       color: Color(0xFF888888),
//                       fontSize: 11,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Color _getStarColor(int stars) {
//     return switch (stars) {
//       5 => const Color(0xFF4CAF50),
//       4 => const Color(0xFF8BC34A),
//       3 => const Color(0xFFFFC107),
//       2 => const Color(0xFFFF9800),
//       1 => const Color(0xFFF44336),
//       _ => const Color(0xFFE0E0E0),
//     };
//   }
// }

// class ReviewCardWidget extends StatelessWidget {
//   final DeliveryReview review;
//   final String? clientName;

//   const ReviewCardWidget({super.key, required this.review, this.clientName});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   clientName ?? 'Cliente',
//                   style: const TextStyle(
//                     color: Color(0xFF1A1A1A),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(
//                   5,
//                   (index) => Icon(
//                     Icons.star_rounded,
//                     size: 14,
//                     color: index < review.rating
//                         ? const Color(0xFFFFC107)
//                         : const Color(0xFFE0E0E0),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (review.comment.isNotEmpty)
//             Text(
//               review.comment,
//               style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//           if (review.comment.isNotEmpty) const SizedBox(height: 8),
//           Text(
//             _formatDate(review.createdAt),
//             style: const TextStyle(color: Color(0xFFAAAAAAA), fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final diff = now.difference(date);

//     if (diff.inDays == 0) {
//       if (diff.inHours == 0) {
//         return 'há ${diff.inMinutes} minutos';
//       }
//       return 'há ${diff.inHours} horas';
//     } else if (diff.inDays == 1) {
//       return 'ontem';
//     } else if (diff.inDays < 7) {
//       return 'há ${diff.inDays} dias';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }

// class ReviewsBottomSheet extends StatelessWidget {
//   final Future<List<DeliveryReview>> reviewsFuture;

//   const ReviewsBottomSheet({super.key, required this.reviewsFuture});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 12, bottom: 16),
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE0E0E0),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<DeliveryReview>>(
//               future: reviewsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Color(0xFFC0392B)),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       'Erro ao carregar avaliações: ${snapshot.error}',
//                     ),
//                   );
//                 }

//                 final reviews = snapshot.data ?? [];

//                 if (reviews.isEmpty) {
//                   return const Center(child: Text('Nenhuma avaliação ainda'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: reviews.length,
//                   itemBuilder: (context, index) =>
//                       ReviewCardWidget(review: reviews[index]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
