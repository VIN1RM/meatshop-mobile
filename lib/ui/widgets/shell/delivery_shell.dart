import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/ui/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/models/address_model.dart';
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
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';

class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _currentIndex = 0;
  bool _ready = false;
  bool _loading = true;
  bool _missingRegistration = false;
  late final DeliveryProvider _deliveryProvider;
  late final DeliveryEarningsProvider _earnings;

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
    _earnings = context.read<DeliveryEarningsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    final repository = context.read<VehicleProvider>().repository;
    try {
      _missingRegistration = false;
      try {
        await repository.profile();
        _missingRegistration = (await repository.vehicles()).isEmpty;
      } on ApiFailure catch (failure) {
        if (failure.kind != ApiFailureKind.notFound) rethrow;
        _missingRegistration = true;
      }
      if (!mounted) return;
      if (_missingRegistration) {
        await _checkPendingProfile();
        if (!mounted) return;
        await repository.profile();
        if ((await repository.vehicles()).isEmpty) return;
      }
      if (!mounted) return;
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      await context.read<VehicleProvider>().loadVehicle(uid);
      if (!mounted) return;
      _deliveryProvider.startListeningOrders(uid);
      _earnings.startUpdates();
      setState(() => _ready = true);
    } catch (_) {
      // Keep the recovery action available; never mount delivery tabs early.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
      if (vehicleProvider.error != null && !_missingRegistration) return;
    }
    if (!mounted) return;

    final existingVehicle = vehicleProvider.vehicles.isEmpty
        ? null
        : Map<String, dynamic>.from(vehicleProvider.vehicleInfo);

    AddressModel? existingAddress;
    var hasAddress = true;
    if (authProvider.appProfile == AppProfile.both) {
      final addressProvider = context.read<AddressProvider>();
      if (addressProvider.addresses.isEmpty) {
        await addressProvider.load(uid);
      }
      if (!mounted) return;
      final addresses = addressProvider.addresses;
      hasAddress = addresses.isNotEmpty;
      if (hasAddress) {
        existingAddress = addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => addresses.first,
        );
      }
    }

    final missing = PendingProfileChecker.check(
      user: user,
      profile: authProvider.appProfile,
      hasVehicle: vehicleProvider.vehicles.isNotEmpty,
      hasAddress: hasAddress,
    );

    if (missing.hasPending && mounted) {
      final confirmed = await PendingProfileDialog.show(context);
      if (confirmed == true && mounted) {
        final updated = await Navigator.of(context).pushNamed(
          AppRoutes.completeProfile,
          arguments: CompleteProfileArgs(
            lockedProfile: authProvider.appProfile,
            existingUser: user,
            existingAddress: existingAddress,
            existingVehicle: existingVehicle,
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
    _earnings.stopUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: const Color(0xFF2E2E2E),
        body: SafeArea(
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(color: Color(0xFFC0392B))
                : AppEmptyState(
                    icon: Icons.delivery_dining_outlined,
                    title: _missingRegistration
                        ? 'Conclua seu cadastro de entregador'
                        : 'Não foi possível verificar seu cadastro',
                    description: _missingRegistration
                        ? 'Cadastre seu veículo para acessar suas entregas e ficar online.'
                        : 'Confira sua conexão e tente novamente.',
                    actionLabel: _missingRegistration
                        ? 'Concluir cadastro'
                        : 'Tentar novamente',
                    onAction: () {
                      _checkedPending = false;
                      _initialize();
                    },
                  ),
          ),
        ),
      );
    }
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
