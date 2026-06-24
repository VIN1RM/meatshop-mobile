import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/services/review_service.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';

class UnitReviewsScreen extends StatefulWidget {
  const UnitReviewsScreen({super.key});

  @override
  State<UnitReviewsScreen> createState() => _UnitReviewsScreenState();
}

class _UnitReviewsScreenState extends State<UnitReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _unitId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (_unitId != null) return;

    try {
      _unitId = ModalRoute.of(context)!.settings.arguments as String;

      final stream = _reviewService.watchUnitReviews(_unitId!);
      final reviews = await stream.first;

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar reviews: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Avaliações do Açougue'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFBE2C1B)),
            )
          : _reviews.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma avaliação ainda.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(review: _reviews[index]);
              },
            ),
    );
  }
}
