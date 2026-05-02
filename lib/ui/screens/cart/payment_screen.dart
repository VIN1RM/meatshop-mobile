import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/cart/review_order_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);

  late TabController _tabController;

  int _onlineMethodIndex = 0;
  int _selectedSavedCardIndex = -1;
  bool _saveCard = false;
  int _deliveryMethodIndex = 0;
  bool _needsChange = false;
  final TextEditingController _changeController = TextEditingController();
  int _selectedBrandIndex = -1;

  final List<Map<String, dynamic>> _savedCards = const [
    {
      'brand': 'Visa',
      'lastFour': '4321',
      'holder': 'JOÃO P SILVA',
      'expiry': '08/27',
      'icon': Icons.credit_card,
    },
    {
      'brand': 'Mastercard',
      'lastFour': '9876',
      'holder': 'JOÃO P SILVA',
      'expiry': '03/26',
      'icon': Icons.credit_card,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  String _fmt(double valor) {
    final s = valor.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: [
                const AppHeader(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _pageTitle(),
                      const SizedBox(height: 20),
                      _buildTabs(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [_buildOnlineTab(), _buildDeliveryTab()],
                        ),
                      ),
                      _buildTotalAndButton(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'PAGAMENTO',
        style: TextStyle(
          color: _white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
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
                  Icon(Icons.smartphone, size: 18),
                  SizedBox(width: 8),
                  Text('Pagar online'),
                ],
              ),
            ),
            Tab(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining, size: 18),
                  SizedBox(width: 8),
                  Text('Na entrega'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Escolha a forma de pagamento'),
          const SizedBox(height: 14),
          _buildOnlineMethods(),
          const SizedBox(height: 24),
          if (_onlineMethodIndex == 0) ...[
            _buildPixInfo(),
          ] else ...[
            if (_savedCards.isNotEmpty) ...[
              _sectionLabel('Cartões salvos'),
              const SizedBox(height: 12),
              ..._savedCards.asMap().entries.map(
                (e) => _buildSavedCard(e.key, e.value),
              ),
              const SizedBox(height: 4),
              _dividerOr(),
              const SizedBox(height: 12),
            ],
            _sectionLabel('Novo cartão'),
            const SizedBox(height: 12),
            _buildNewCardForm(),
            const SizedBox(height: 16),
            _buildSaveCardToggle(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOnlineMethods() {
    final methods = [
      {'icon': Icons.pix, 'label': 'Pix'},
      {'icon': Icons.credit_card, 'label': 'Crédito'},
      {'icon': Icons.credit_card_outlined, 'label': 'Débito'},
    ];

    return Row(
      children: methods.asMap().entries.map((e) {
        final i = e.key;
        final m = e.value;
        final selected = _onlineMethodIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < methods.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() {
                _onlineMethodIndex = i;
                _selectedSavedCardIndex = -1;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? _red : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _red : const Color(0xFF555555),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      color: selected ? _white : Colors.white54,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m['label'] as String,
                      style: TextStyle(
                        color: selected ? _white : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPixInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5A5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pix,
                  color: Color(0xFF00B5A5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pagamento via Pix',
                      style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aprovação instantânea',
                      style: TextStyle(
                        color: Color(0xFF00B5A5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF4A4A4A)),
          const SizedBox(height: 12),
          _pixInfoRow(Icons.qr_code_2, 'QR Code gerado após confirmar'),
          const SizedBox(height: 10),
          _pixInfoRow(Icons.timer_outlined, 'Válido por 30 minutos'),
          const SizedBox(height: 10),
          _pixInfoRow(
            Icons.check_circle_outline,
            'Pedido confirmado automaticamente',
          ),
        ],
      ),
    );
  }

  Widget _pixInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildSavedCard(int index, Map<String, dynamic> card) {
    final selected = _selectedSavedCardIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSavedCardIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _red.withOpacity(0.12) : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _red : const Color(0xFF555555),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              card['icon'] as IconData,
              color: selected ? _red : Colors.white54,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card['brand']} •••• ${card['lastFour']}',
                    style: TextStyle(
                      color: selected ? _white : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${card['holder']} · ${card['expiry']}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
          ],
        ),
      ),
    );
  }

  Widget _dividerOr() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF4A4A4A))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou adicione novo',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF4A4A4A))),
      ],
    );
  }

  Widget _buildNewCardForm() {
    const fieldDecoration = InputDecoration(
      filled: true,
      fillColor: Color(0xFF3A3A3A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF555555)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF555555)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFC0392B), width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
      labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

    return Column(
      children: [
        TextFormField(
          style: const TextStyle(color: _white, fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: fieldDecoration.copyWith(
            labelText: 'Número do cartão',
            hintText: '0000 0000 0000 0000',
            prefixIcon: const Icon(
              Icons.credit_card,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          style: const TextStyle(color: _white, fontSize: 14),
          decoration: fieldDecoration.copyWith(
            labelText: 'Nome no cartão',
            hintText: 'Como está no cartão',
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                style: const TextStyle(color: _white, fontSize: 14),
                keyboardType: TextInputType.datetime,
                decoration: fieldDecoration.copyWith(
                  labelText: 'Validade',
                  hintText: 'MM/AA',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                style: const TextStyle(color: _white, fontSize: 14),
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: fieldDecoration.copyWith(
                  labelText: 'CVV',
                  hintText: '•••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white38,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_onlineMethodIndex == 1) ...[
          const SizedBox(height: 12),
          TextFormField(
            style: const TextStyle(color: _white, fontSize: 14),
            keyboardType: TextInputType.number,
            decoration: fieldDecoration.copyWith(
              labelText: 'Parcelas',
              hintText: '1x sem juros',
              prefixIcon: const Icon(
                Icons.splitscreen,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveCardToggle() {
    return GestureDetector(
      onTap: () => setState(() => _saveCard = !_saveCard),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _saveCard ? _red : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _saveCard ? _red : Colors.white38,
                width: 2,
              ),
            ),
            child: _saveCard
                ? const Icon(Icons.check, color: _white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          const Text(
            'Salvar cartão para próximas compras',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTab() {
    final methods = [
      {'icon': Icons.money, 'label': 'Dinheiro'},
      {'icon': Icons.credit_card_outlined, 'label': 'Débito'},
      {'icon': Icons.credit_card, 'label': 'Crédito'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Como prefere pagar na entrega?'),
          const SizedBox(height: 14),
          Row(
            children: methods.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              final selected = _deliveryMethodIndex == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < methods.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _deliveryMethodIndex = i;
                      if (i != 0) _needsChange = false;
                      _selectedBrandIndex = -1;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? _red : _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _red : const Color(0xFF555555),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            m['icon'] as IconData,
                            color: selected ? _white : Colors.white54,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m['label'] as String,
                            style: TextStyle(
                              color: selected ? _white : Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (_deliveryMethodIndex == 0) ...[
            _buildCashInfo(),
          ] else ...[
            _buildMachineInfo(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCashInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF555555)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _needsChange = !_needsChange),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _needsChange ? _red : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _needsChange ? _red : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: _needsChange
                          ? const Icon(Icons.check, color: _white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Preciso de troco',
                      style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_needsChange) ...[
                const SizedBox(height: 14),
                const Divider(color: Color(0xFF4A4A4A)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _changeController,
                  style: const TextStyle(color: _white, fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2E2E2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFF555555)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFF555555)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color(0xFFC0392B),
                        width: 1.5,
                      ),
                    ),
                    labelText: 'Troco para quanto?',
                    hintText: 'Ex: R\$ 100,00',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.money,
                      color: Colors.white38,
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildDeliveryInfoNote(
          Icons.info_outline,
          'Tenha o valor exato se possível. O entregador pode não ter troco disponível.',
        ),
      ],
    );
  }

  Widget _buildMachineInfo() {
    final brands = [
      {
        'label': 'Visa',
        'color': const Color(0xFF1A1F71),
        'textColor': Colors.white,
        'icon': Icons.credit_card,
      },
      {
        'label': 'Mastercard',
        'color': const Color(0xFFEB001B),
        'textColor': Colors.white,
        'icon': Icons.credit_card,
      },
      {
        'label': 'Elo',
        'color': const Color(0xFFFFD700),
        'textColor': const Color(0xFF1A1A1A),
        'icon': Icons.credit_card,
      },
      {
        'label': 'Hipercard',
        'color': const Color(0xFFB71C1C),
        'textColor': Colors.white,
        'icon': Icons.credit_card,
      },
      {
        'label': 'Amex',
        'color': const Color(0xFF007BC1),
        'textColor': Colors.white,
        'icon': Icons.credit_card,
      },
      {
        'label': 'Cabal',
        'color': const Color(0xFF2E7D32),
        'textColor': Colors.white,
        'icon': Icons.credit_card,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF555555)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.point_of_sale, color: _red, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maquininha na entrega',
                      style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O entregador levará a maquininha',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _sectionLabel('Selecione a bandeira do cartão'),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: brands.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, i) {
            final brand = brands[i];
            final selected = _selectedBrandIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedBrandIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? (brand['color'] as Color) : _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? (brand['color'] as Color)
                        : const Color(0xFF555555),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_circle,
                          color: brand['textColor'] as Color,
                          size: 13,
                        ),
                      ),
                    Text(
                      brand['label'] as String,
                      style: TextStyle(
                        color: selected
                            ? (brand['textColor'] as Color)
                            : Colors.white54,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_selectedBrandIndex >= 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (brands[_selectedBrandIndex]['color'] as Color)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (brands[_selectedBrandIndex]['color'] as Color)
                    .withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: brands[_selectedBrandIndex]['color'] as Color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Cartão ${brands[_selectedBrandIndex]['label']} selecionado',
                  style: TextStyle(
                    color: (brands[_selectedBrandIndex]['color'] as Color),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        _buildDeliveryInfoNote(
          Icons.warning_amber_outlined,
          'A disponibilidade da maquininha depende do entregador. Em caso de dúvida, escolha dinheiro.',
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoNote(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3020),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7A6030).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFB800), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFDDA060),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _fmt(widget.total),
                style: const TextStyle(
                  color: _white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewOrderScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
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
                  'Confirmar e pagar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  '· ${_fmt(widget.total)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
