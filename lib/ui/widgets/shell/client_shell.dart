import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/ui/screens/home/home_screen.dart';
import 'package:meatshop_mobile/ui/screens/cart/cart_screen.dart';
import 'package:meatshop_mobile/ui/screens/orders/orders_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/account_screen.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_screen.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:meatshop_mobile/core/utils/pending_profile_checker.dart';
import 'package:meatshop_mobile/ui/dialogs/pending_profile_dialog.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _checkedPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _currentIndex = args;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingProfile());
  }

  Future<void> _checkPendingProfile() async {
    if (_checkedPending || !mounted) return;
    _checkedPending = true;

    final authProvider = context.read<AuthProvider>();
    final user = context.read<UserProvider>().user;
    final uid = authProvider.currentUser?.uid;
    if (uid == null) return;

    final addressProvider = context.read<AddressProvider>();
    if (addressProvider.addresses.isEmpty) {
      await addressProvider.load(uid);
    }
    if (!mounted) return;

    final addresses = addressProvider.addresses;
    final existingAddress = addresses.isEmpty
        ? null
        : addresses.firstWhere(
            (address) => address.isDefault,
            orElse: () => addresses.first,
          );

    Map<String, dynamic>? existingVehicle;
    var hasVehicle = true;
    if (authProvider.appProfile == AppProfile.both) {
      final vehicleProvider = context.read<VehicleProvider>();
      if (vehicleProvider.vehicles.isEmpty) {
        await vehicleProvider.loadVehicle(uid);
      }
      if (!mounted) return;
      hasVehicle = vehicleProvider.vehicles.isNotEmpty;
      if (hasVehicle) {
        existingVehicle = Map<String, dynamic>.from(
          vehicleProvider.vehicleInfo,
        );
      }
    }

    final missing = PendingProfileChecker.check(
      user: user,
      profile: authProvider.appProfile,
      hasAddress: addresses.isNotEmpty,
      hasVehicle: hasVehicle,
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

  static const List<Widget> _tabs = [
    HomeBody(),
    RecipeTipsScreen(),
    CartScreen(),
    OrdersScreen(),
    AccountScreen(),
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
    _NavItem('Receitas', Icons.menu_book_outlined, Icons.menu_book),
    _NavItem('Carrinho', Icons.shopping_cart_outlined, Icons.shopping_cart),
    _NavItem('Pedidos', Icons.receipt_long_outlined, Icons.receipt_long),
    _NavItem('Minha Conta', Icons.person_outline, Icons.person),
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
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? _red : Colors.white54,
                            size: 24,
                          ),
                          if (i == 2)
                            Consumer<CartProvider>(
                              builder: (context, cart, child) {
                                if (cart.items.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  top: -6,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: _red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      cart.items.length > 9
                                          ? '9+'
                                          : '${cart.items.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive ? _red : Colors.white54,
                          fontSize: 10,
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
