import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class _CartItem {
  final String nome;
  final String preco;
  final String imagemAsset;
  int quantidade;

  _CartItem({
    required this.nome,
    required this.preco,
    required this.imagemAsset,
    this.quantidade = 1,
  });

  double get precoNumerico {
    final cleaned = preco
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  double get subtotal => precoNumerico * quantidade;
}

class _AcougueCarrinho {
  final String nome;
  final double rating;
  final String logoAsset;
  final List<_CartItem> itens;
  final bool entregaGratis;

  const _AcougueCarrinho({
    required this.nome,
    required this.rating,
    required this.logoAsset,
    required this.itens,
    this.entregaGratis = false,
  });

  double get subtotal => itens.fold(0, (sum, i) => sum + i.subtotal);
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _white = Colors.white;

  String _endereco =
      'Avenida Rodovanio Rodovalho, Nº 17, Casa cinza\nBairro Eldorado - Anápolis, Goiás';

  late final List<_AcougueCarrinho> _acougues;

  @override
  void initState() {
    super.initState();
    _acougues = [
      _AcougueCarrinho(
        nome: 'Master Carnes',
        rating: 5,
        logoAsset: 'assets/images/logo_master.png',
        entregaGratis: true,
        itens: [
          _CartItem(
            nome: 'Picanha angus',
            preco: 'R\$150,00',
            imagemAsset: 'assets/images/picanha.png',
          ),
          _CartItem(
            nome: 'Lombo suíno',
            preco: 'R\$35,98',
            imagemAsset: 'assets/images/lombo.png',
            quantidade: 2,
          ),
        ],
      ),
      _AcougueCarrinho(
        nome: 'Frigorífico Goiás',
        rating: 4,
        logoAsset: 'assets/images/logo_frigorifico.png',
        itens: [
          _CartItem(
            nome: 'Filé de Tilápia',
            preco: 'R\$73,48',
            imagemAsset: 'assets/images/peixe.png',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
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
                _buildHeader(context),
                _buildSearchBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _sectionTitle('CARRINHO'),
                        const SizedBox(height: 16),
                        _buildEndereco(),
                        const SizedBox(height: 20),
                        ..._acougues.map(_buildAcougueSection),
                        const SizedBox(height: 24),
                        _buildFinalizarButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: _white, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: _white, size: 20),
          ),
        ],
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();

  Widget _buildSearchBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _white, fontSize: 14),
              cursorColor: _red,
              decoration: InputDecoration(
                hintText: 'Procure por produto ou corte',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEndereco() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Endereço de entrega',
            style: TextStyle(
              color: _white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _endereco,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _editarEndereco,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit_outlined, color: _red, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Editar',
                    style: TextStyle(
                      color: _red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editarEndereco() {}

  Widget _buildAcougueSection(_AcougueCarrinho acougue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF555555),
                    border: Border.all(color: _red, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      acougue.logoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.storefront_outlined,
                        color: Colors.white38,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    acougue.nome,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildStars(acougue.rating),
              ],
            ),
          ),

          const Divider(color: Color(0xFF555555), height: 1),

          ...acougue.itens.map((item) => _buildCartItem(item, acougue)),

          const Divider(color: Color(0xFF555555), height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.delivery_dining,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          acougue.entregaGratis
                              ? 'Entrega Grátis'
                              : 'Taxa de entrega',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      acougue.entregaGratis ? 'R\$0,00' : 'R\$5,99',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      _formatPreco(acougue.subtotal),
                      style: const TextStyle(
                        color: _white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(_CartItem item, _AcougueCarrinho acougue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item.imagemAsset,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white24,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item.preco,
                            style: const TextStyle(
                              color: _red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: '/kg',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 66),

              _QtyButton(
                icon: Icons.remove,
                onTap: () {
                  setState(() {
                    if (item.quantidade > 1) item.quantidade--;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantidade}',
                  style: const TextStyle(
                    color: _white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'KG',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 8),

              _QtyButton(
                icon: Icons.add,
                onTap: () {
                  setState(() => item.quantidade++);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFinalizarButton() {
    final total = _acougues.fold<double>(0, (s, a) => s + a.subtotal);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.reviewOrder),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC0392B),
          foregroundColor: Colors.white,
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
              'Revisar Pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${_formatPreco(total)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half
              ? Icons.star_half_rounded
              : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
          color: const Color(0xFFFFB800),
          size: 18,
        );
      }),
    );
  }

  String _formatPreco(double valor) {
    final s = valor.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
