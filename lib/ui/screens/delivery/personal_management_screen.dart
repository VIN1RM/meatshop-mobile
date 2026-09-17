import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/ui/components/tabs/earnings_tab.dart';
import 'package:meatshop_mobile/ui/components/tabs/reports_tab.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';

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
  String _reportPeriod = 'Semanal';

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

  void _openGoalEditor(DeliveryGoalModel goal, DeliveryEarningsProvider ep) {
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
            color: Color(0xFF2C2C2C),
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
                  color: Colors.white,
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
                  fillColor: const Color(0xFF3A3A3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '0,00',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                      ep.updateGoalTarget(goal, val);
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2E2E2E),
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
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Container(
                  color: const Color(0xFF2E2E2E),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _red,
                    unselectedLabelColor: Colors.white,
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
                  child: Consumer<DeliveryEarningsProvider>(
                    builder: (context, ep, _) {
                      if (ep.loading) {
                        return const Center(
                          child: CircularProgressIndicator(color: _red),
                        );
                      }
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          EarningsTab(
                            goals: ep.goals,
                            earnings: ep.earnings,
                            weekBarValues: ep.weeklyBarValues,
                            earningsProvider: ep,
                            onEditGoal: (goal) => _openGoalEditor(goal, ep),
                            todayTotal: ep.todayTotal,
                            todayDeliveries: ep.todayDeliveries,
                          ),
                          ReportsTab(
                            period: _reportPeriod,
                            onPeriodChanged: (v) =>
                                setState(() => _reportPeriod = v),
                            earningsProvider: ep,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
