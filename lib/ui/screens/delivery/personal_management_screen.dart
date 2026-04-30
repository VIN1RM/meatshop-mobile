import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/bar_data.dart';
import 'package:meatshop_mobile/models/earning_entry.dart';
import 'package:meatshop_mobile/models/goal_model.dart';
import 'package:meatshop_mobile/ui/components/tabs/earnings_tab.dart';
import 'package:meatshop_mobile/ui/components/tabs/reports_tab.dart';

class PersonalManagementScreen extends StatefulWidget {
  const PersonalManagementScreen({super.key});

  @override
  State<PersonalManagementScreen> createState() =>
      _PersonalManagementScreenState();
}

class _PersonalManagementScreenState extends State<PersonalManagementScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  late TabController _tabController;

  final List<GoalModel> _goals = [
    GoalModel(label: 'Meta diária', target: 150.0, current: 87.50),
    GoalModel(label: 'Meta semanal', target: 800.0, current: 423.75),
    GoalModel(label: 'Meta mensal', target: 3000.0, current: 1640.00),
  ];

  String _reportPeriod = 'Semanal';

  final List<EarningEntry> _recentEarnings = [
    EarningEntry(
      label: 'Pedido #4821',
      amount: 18.50,
      time: '14:32',
      isNew: true,
    ),
    EarningEntry(label: 'Pedido #4818', amount: 22.00, time: '13:10'),
    EarningEntry(label: 'Pedido #4815', amount: 15.75, time: '11:47'),
    EarningEntry(label: 'Pedido #4810', amount: 31.00, time: '10:05'),
    EarningEntry(label: 'Pedido #4802', amount: 12.25, time: 'Ontem'),
    EarningEntry(label: 'Pedido #4799', amount: 19.00, time: 'Ontem'),
    EarningEntry(label: 'Pedido #4795', amount: 27.50, time: 'Ontem'),
  ];

  final List<BarData> _weekBars = [
    BarData(day: 'S', value: 45),
    BarData(day: 'T', value: 90),
    BarData(day: 'Q', value: 72),
    BarData(day: 'Q', value: 110),
    BarData(day: 'S', value: 63),
    BarData(day: 'S', value: 88),
    BarData(day: 'D', value: 42),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openGoalEditor(GoalModel goal) {
    final controller = TextEditingController(
      text: goal.target.toStringAsFixed(0),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Editar ${goal.label}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(
                    color: _red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '0,00',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(
                      controller.text.replaceAll(',', '.'),
                    );
                    if (val != null && val > 0) {
                      setState(() => goal.target = val);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: _white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar meta',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get _todayTotal => _recentEarnings
      .where((e) => e.time != 'Ontem')
      .fold(0.0, (sum, e) => sum + e.amount);

  int get _todayDeliveries =>
      _recentEarnings.where((e) => e.time != 'Ontem').length;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _white,
      child: Stack(
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
                Container(
                  color: _white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _red,
                    unselectedLabelColor: const Color(0xFF888888),
                    indicatorColor: _red,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'GANHOS & METAS'),
                      Tab(text: 'RELATÓRIOS'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      EarningsTab(
                        goals: _goals,
                        recentEarnings: _recentEarnings,
                        weekBars: _weekBars,
                        onEditGoal: _openGoalEditor,
                        todayTotal: _todayTotal,
                        todayDeliveries: _todayDeliveries,
                      ),
                      ReportsTab(
                        period: _reportPeriod,
                        onPeriodChanged: (v) =>
                            setState(() => _reportPeriod = v),
                        recentEarnings: _recentEarnings,
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: _white, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: _white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}
