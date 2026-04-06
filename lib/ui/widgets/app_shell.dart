import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/home/home_screen.dart';
import 'package:meatshop_mobile/ui/screens/cart/cart_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _currentIndex = args;
    }
  }

  static const List<Widget> _tabs = [
    HomeBody(),
    CartScreen(),
    _PlaceholderTab(icon: Icons.receipt_long_outlined, label: 'Pedidos'),
    _PlaceholderTab(icon: Icons.person_outline, label: 'Minha conta'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const Color _red = Color(0xFFC0392B);

  static const _items = [
    _NavItem('Início', Icons.home_outlined, Icons.home),
    _NavItem('Carrinho', Icons.shopping_cart_outlined, Icons.shopping_cart),
    _NavItem('Pedidos', Icons.receipt_long_outlined, Icons.receipt_long),
    _NavItem('Minha conta', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        border: Border(top: BorderSide(color: Color(0xFF555555), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = currentIndex == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? _red : Colors.white54,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive ? _red : Colors.white54,
                          fontSize: 10.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.label, this.icon, this.activeIcon);
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 56),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Em breve',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
