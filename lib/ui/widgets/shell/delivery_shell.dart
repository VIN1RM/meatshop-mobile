import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/deliveries_screen.dart';
import 'package:meatshop_mobile/ui/screens/delivery/delivery_history_screen.dart';
import 'package:meatshop_mobile/ui/screens/delivery/personal_management_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/delivery_account_screen.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:meatshop_mobile/core/utils/pending_profile_checker.dart';
import 'package:meatshop_mobile/ui/dialogs/pending_profile_dialog.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';

class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _currentIndex = 0;
  late final DeliveryProvider _deliveryProvider;

  static const List<Widget> _screens = [
    DeliveriesTab(),
    DeliveryHistoryScreen(),
    PersonalManagementScreen(),
    DeliveryAccountScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _deliveryProvider = context.read<DeliveryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      _deliveryProvider.startListeningOrders(uid);
      _checkPendingProfile();
    });
  }

  bool _checkedPending = false;
  Future<void> _checkPendingProfile() async {
    if (_checkedPending || !mounted) return;
    _checkedPending = true;

    final authProvider = context.read<AuthProvider>();
    final user = context.read<UserProvider>().user;
    final uid = authProvider.currentUser?.uid;
    if (uid == null) return;

    final vehicleProvider = context.read<VehicleProvider>();
    if (vehicleProvider.vehicles.isEmpty) {
      await vehicleProvider.loadVehicle(uid);
    }
    if (!mounted) return;

    final missing = PendingProfileChecker.check(
      user: user,
      profile: authProvider.appProfile,
      hasVehicle: vehicleProvider.vehicles.isNotEmpty,
    );

    if (missing.hasPending && mounted) {
      final confirmed = await PendingProfileDialog.show(context);
      if (confirmed == true && mounted) {
        final updated = await Navigator.of(context).pushNamed(
          AppRoutes.completeProfile,
          arguments: CompleteProfileArgs(
            lockedProfile: authProvider.appProfile,
            existingUser: user,
          ),
        );
        if (updated == true && mounted) {
          await context.read<UserProvider>().loadUser(uid);
        }
      }
    }
  }

  @override
  void dispose() {
    _deliveryProvider.stopListeningOrders();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
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
        color: const Color(0xFF3A3A3A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
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
      ),
    );
  }
}
