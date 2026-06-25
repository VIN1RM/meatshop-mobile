import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/services/review_service.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';

class UnitReviewsScreen extends StatefulWidget {
  const UnitReviewsScreen({super.key});

  @override
  State<UnitReviewsScreen> createState() => _UnitReviewsScreenState();
}

class _UnitReviewsScreenState extends State<UnitReviewsScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color.fromARGB(255, 58, 58, 58);

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
      final reviews = await _reviewService.watchUnitReviews(_unitId!).first;

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar reviews: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 130,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _red),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(showBack: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Avaliações dos Clientes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFBE2C1B)),
      );
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma avaliação ainda.',
          style: TextStyle(color: Colors.white38, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (_, i) => ReviewCard(review: _reviews[i], darkMode: false),
    );
  }
}
