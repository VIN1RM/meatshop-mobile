import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/unit/butcher_provider.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';

class UnitReviewsScreen extends StatelessWidget {
  const UnitReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unitId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Avaliações do Açougue'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Consumer<ButcherProvider>(
        builder: (context, provider, _) {
          final reviews = provider.reviews; 

          if (reviews.isEmpty) {
            return const Center(child: Text('Nenhuma avaliação ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return ReviewCard(review: reviews[index]);
            },
          );
        },
      ),
    );
  }
}