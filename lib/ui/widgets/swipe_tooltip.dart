import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeTooltip extends StatefulWidget {
  final Widget child;
  static const String _prefKey = 'swipe_tooltip_count';
  static const int _maxShows = 3;

  const SwipeTooltip({super.key, required this.child});

  @override
  State<SwipeTooltip> createState() => _SwipeTooltipState();
}

class _SwipeTooltipState extends State<SwipeTooltip>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkAndShow();
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(SwipeTooltip._prefKey) ?? 0;
    if (count >= SwipeTooltip._maxShows) return;

    await prefs.setInt(SwipeTooltip._prefKey, count + 1);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _visible = true);
    _controller.forward();

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await _controller.reverse();
    setState(() => _visible = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_visible)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_left_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Deslize para remover',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
