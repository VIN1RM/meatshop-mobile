import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meatshop_mobile/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool darkMode;

  const ReviewCard({super.key, required this.review, this.darkMode = false});

  static const Color _red = Color(0xFFBE2C1B);
  static const Color _amber = Color(0xFFFFB800);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final bg = darkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textPrimary = darkMode ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = darkMode ? Colors.white70 : const Color(0xFF555555);
    final textMuted = darkMode ? Colors.white38 : const Color(0xFF9E9E9E);
    final dividerColor = darkMode ? Colors.white12 : const Color(0xFFEEEEEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(darkMode ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(textPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _buildStars(review.rating),
                  ],
                ),
              ),
              Text(
                dateFormat.format(review.createdAt),
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            Divider(height: 20, color: dividerColor),
            Text(
              review.comment,
              style: TextStyle(fontSize: 13, height: 1.5, color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Color textColor) {
    final initials = review.clientName.isNotEmpty
        ? review.clientName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _red.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _red.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: _red,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < rating ? _amber : const Color(0xFFCCCCCC),
          size: 14,
        );
      }),
    );
  }
}
