import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/screens/cart/payment_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);

  late TabController _tabController;

  int _selectedAddressIndex = 0;
  final List<Map<String, String>> _savedAddresses = const [
    {
      'label': 'Casa',
      'street': 'Avenida Rodovanio Rodovalho, Nº 17',
      'complement': 'Casa cinza',
      'district': 'Bairro Eldorado',
      'city': 'Anápolis, Goiás',
    },
    {
      'label': 'Trabalho',
      'street': 'Rua das Flores, Nº 200',
      'complement': 'Sala 302',
      'district': 'Centro',
      'city': 'Anápolis, Goiás',
    },
  ];

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

  String _fmt(double valor) {
    final s = valor.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }

  bool get _canProceed {
    if (_tabController.index == 0) return true;
    return _selectedDate != null && _selectedTime != null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
          color: _surface,
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
          unselectedLabelColor: Colors.white54,
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Selecione o endereço de entrega'),
          const SizedBox(height: 14),
          ..._savedAddresses.asMap().entries.map(
            (e) => _buildAddressCard(e.key, e.value),
          ),
          const SizedBox(height: 12),
          _buildAddNewAddress(),
          const SizedBox(height: 20),
          _buildEstimateCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAddressCard(int index, Map<String, String> address) {
    final selected = _selectedAddressIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: selected ? _red.withOpacity(0.10) : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _red : const Color(0xFF555555),
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
                color: selected ? _red : Colors.transparent,
                border: Border.all(
                  color: selected ? _red : Colors.white38,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: _white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? _red : const Color(0xFF555555),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          address['label']!,
                          style: const TextStyle(
                            color: _white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address['street']!,
                    style: TextStyle(
                      color: selected ? _white : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((address['complement'] ?? '').isNotEmpty)
                    Text(
                      address['complement']!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    '${address['district']} · ${address['city']}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.white38,
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
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF555555),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_location_alt_outlined,
              color: Colors.white38,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Adicionar novo endereço',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Column(
        children: [
          _estimateRow(
            Icons.timer_outlined,
            'Tempo estimado',
            '30 – 50 min',
            Colors.white70,
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF4A4A4A), height: 1),
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
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Selecione o endereço de entrega'),
          const SizedBox(height: 14),
          ..._savedAddresses.asMap().entries.map(
            (e) => _buildAddressCard(e.key, e.value),
          ),
          _buildAddNewAddress(),
          const SizedBox(height: 24),
          _sectionLabel('Escolha a data'),
          const SizedBox(height: 14),
          _buildDatePickerButton(),
          const SizedBox(height: 24),
          _sectionLabel('Escolha o horário'),
          const SizedBox(height: 14),
          _buildTimeSlots(),
          if (_selectedDate != null && _selectedTime != null) ...[
            const SizedBox(height: 20),
            _buildScheduleSummary(),
          ],
          const SizedBox(height: 24),
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
          color: _selectedDate != null
              ? _red.withValues(alpha: 0.10)
              : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedDate != null ? _red : const Color(0xFF555555),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: _selectedDate != null ? _red : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedDate == null
                  ? const Text(
                      'Toque para selecionar uma data',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
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
                        const Text(
                          'Toque para alterar',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
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
                child: const Icon(Icons.close, color: Colors.white38, size: 18),
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
                  : const Color(0xFF333333),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? _red
                    : enabled
                    ? const Color(0xFF555555)
                    : const Color(0xFF444444),
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
                      ? Colors.white54
                      : Colors.white24,
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: TextStyle(
                    color: selected
                        ? _white
                        : enabled
                        ? Colors.white70
                        : Colors.white24,
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

  Widget _buildScheduleSummary() {
    final weekdays = [
      '',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
    ];
    final months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    final d = _selectedDate!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: _red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${weekdays[d.weekday]}, ${d.day} de ${months[d.month]} · $_selectedTime',
              style: const TextStyle(
                color: _white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
              'Ir para pagamento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${_fmt(widget.total)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
        color: _red,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}
