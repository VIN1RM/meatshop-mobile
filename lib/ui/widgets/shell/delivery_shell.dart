import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/delivery/deliveries_screen.dart';
import 'package:meatshop_mobile/ui/screens/delivery/delivery_history_screen.dart';
import 'package:meatshop_mobile/ui/screens/delivery/personal_management_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/delivery_account_screen.dart';

class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DeliveriesTab(),
    DeliveryHistoryScreen(),
    PersonalManagementScreen(),
    DeliveryAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _DeliveryBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _DeliveryBottomNav extends StatelessWidget {
  const _DeliveryBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFC0392B),
        unselectedItemColor: Colors.white38,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: 'Entregas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Gestão',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Minha conta',
          ),
        ],
      ),
    );
  }
}
