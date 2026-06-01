import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/screens/cart/payment_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:meatshop_mobile/ui/components/sheets/address_form_sheet.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';

class AddressScheduleScreen extends StatefulWidget {
  final double total;
  const AddressScheduleScreen({super.key, required this.total});

  @override
  State<AddressScheduleScreen> createState() => _AddressScheduleScreenState();
}

class _AddressScheduleScreenState extends State<AddressScheduleScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _bg = Color(0xFF2E2E2E);

  late TabController _tabController;

  String? _selectedAddressId;

  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _timeSlots = const [
    '08:00 – 10:00',
    '10:00 – 12:00',
    '12:00 – 14:00',
    '14:00 – 16:00',
    '16:00 – 18:00',
    '18:00 – 20:00',
  ];

  bool get _canProceed {
    if (_selectedAddressId == null) return false;
    if (_tabController.index == 0) return true;
    return _selectedDate != null && _selectedTime != null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final provider = context.read<AddressProvider>();
        provider.load(uid).then((_) {
          final addresses = provider.addresses;
          if (addresses.isNotEmpty && _selectedAddressId == null) {
            setState(() {
              _selectedAddressId = addresses
                  .firstWhere((a) => a.isDefault, orElse: () => addresses.first)
                  .id;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(total: widget.total)),
    );
  }

  String? get _uid => context.read<AuthProvider>().currentUser?.uid;

  void _openAddressSheet({AddressModel? address}) {
    if (_uid == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddressFormSheet(
        address: address,
        onSave: (newAddress) async {
          if (address != null) {
            await context.read<AddressProvider>().update(_uid!, newAddress);

            if (mounted) {
              setState(() => _selectedAddressId = newAddress.id);
            }
          } else {
            final created = await context.read<AddressProvider>().add(
              _uid!,
              newAddress,
            );

            if (mounted) {
              setState(() => _selectedAddressId = created.id);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('pt', 'BR'),
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Scaffold(
        backgroundColor: _bg,
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
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A1A)),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  const SizedBox(height: 20),
                  _pageTitle(),
                  const SizedBox(height: 20),
                  _buildTabs(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [_buildNowTab(), _buildScheduleTab()],
                    ),
                  ),
                  _buildBottomBar(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'ENTREGA',
        style: TextStyle(
          color: _white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: _white,
          unselectedLabelColor: const Color(0xFF666666),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining, size: 18),
                  SizedBox(width: 8),
                  Text('Pedir agora'),
                ],
              ),
            ),
            Tab(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Agendar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowTab() {
    final provider = context.watch<AddressProvider>();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Selecione o endereço de entrega'),
          const SizedBox(height: 14),
          if (provider.loading)
            const Center(child: CircularProgressIndicator(color: _red))
          else if (provider.error != null)
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.redAccent),
            )
          else if (provider.addresses.isEmpty)
            _buildEmptyAddresses()
          else
            ...provider.addresses.map((a) => _buildAddressCard(a)),
          const SizedBox(height: 12),
          _buildAddNewAddress(),
          const SizedBox(height: 20),
          _buildEstimateCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    final selected = _selectedAddressId == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = address.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: selected ? _red : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _red : const Color(0xFFBDBDBD),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _white : Colors.transparent,
                border: Border.all(
                  color: selected ? _white : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: selected ? Icon(Icons.check, color: _red, size: 12) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? _white.withOpacity(0.25)
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.label,
                      style: TextStyle(
                        color: selected ? _white : const Color(0xFF555555),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${address.street}, ${address.number}',
                    style: TextStyle(
                      color: selected ? _white : const Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (address.complement.isNotEmpty)
                    Text(
                      address.complement,
                      style: TextStyle(
                        color: selected
                            ? _white.withOpacity(0.75)
                            : const Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    '${address.neighborhood} · ${address.city}, ${address.state}',
                    style: TextStyle(
                      color: selected
                          ? _white.withOpacity(0.75)
                          : const Color(0xFF777777),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _openAddressSheet(address: address),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.edit_outlined,
                  color: selected
                      ? _white.withOpacity(0.6)
                      : const Color(0xFFBDBDBD),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return GestureDetector(
      onTap: _openAddressSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location_alt_outlined,
              color: _red.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Adicionar novo endereço',
              style: TextStyle(
                color: _red.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddresses() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_outlined,
            color: Colors.white24,
            size: 48,
          ),
          const SizedBox(height: 10),
          const Text(
            'Nenhum endereço salvo.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Adicione um endereço para continuar.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _estimateRow(
            Icons.timer_outlined,
            'Tempo estimado',
            '30 – 50 min',
            const Color(0xFF1A1A1A),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          const SizedBox(height: 10),
          _estimateRow(
            Icons.delivery_dining,
            'Taxa de entrega',
            'Calculada no checkout',
            const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _estimateRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFBDBDBD), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    final provider = context.watch<AddressProvider>();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Selecione o endereço de entrega'),
          const SizedBox(height: 14),
          if (provider.loading)
            const Center(child: CircularProgressIndicator(color: _red))
          else if (provider.error != null)
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.redAccent),
            )
          else if (provider.addresses.isEmpty)
            _buildEmptyAddresses()
          else
            ...provider.addresses.map((a) => _buildAddressCard(a)),
          _buildAddNewAddress(),
          const SizedBox(height: 24),
          _sectionLabel('Escolha a data'),
          const SizedBox(height: 14),
          _buildDatePickerButton(),
          const SizedBox(height: 24),
          _sectionLabel('Escolha uma faixa de horários'),
          const SizedBox(height: 14),
          _buildTimeSlots(),
          if (_selectedDate != null && _selectedTime != null)
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton() {
    final months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final weekdays = [
      '',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now.add(const Duration(days: 1)),
          firstDate: now.add(const Duration(days: 1)),
          lastDate: now.add(const Duration(days: 60)),
          builder: (context, child) {
            return Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFC0392B),
                    onPrimary: Colors.white,
                    surface: Color(0xFF3A3A3A),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: const Color(0xFF2E2E2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                child: child!,
              ),
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _selectedTime = null;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: _selectedDate != null ? _red : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedDate != null ? _red : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: _selectedDate != null ? _white : const Color(0xFFBDBDBD),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedDate == null
                  ? const Text(
                      'Toque para selecionar uma data',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weekdays[_selectedDate!.weekday]}, '
                          '${_selectedDate!.day} de '
                          '${months[_selectedDate!.month]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Toque para alterar',
                          style: TextStyle(
                            color: _white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = null;
                  _selectedTime = null;
                }),
                child: Icon(
                  Icons.close,
                  color: _white.withOpacity(0.7),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _timeSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.4,
      ),
      itemBuilder: (context, i) {
        final slot = _timeSlots[i];
        final selected = _selectedTime == slot;
        final enabled = _selectedDate != null;
        return GestureDetector(
          onTap: enabled ? () => setState(() => _selectedTime = slot) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? _red
                  : enabled
                  ? _surface
                  : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? _red
                    : enabled
                    ? const Color(0xFFDDDDDD)
                    : const Color(0xFFE8E8E8),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: selected
                      ? _white
                      : enabled
                      ? const Color(0xFF555555)
                      : const Color(0xFFBDBDBD),
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: TextStyle(
                    color: selected
                        ? _white
                        : enabled
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFBDBDBD),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final canGo = _canProceed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ElevatedButton(
        onPressed: canGo ? _proceed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          disabledBackgroundColor: _red.withOpacity(0.4),
          foregroundColor: _white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Confirmar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}
