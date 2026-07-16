import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debts_provider.dart';
import '../providers/chat_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';

class WhatIfScreen extends ConsumerStatefulWidget {
  const WhatIfScreen({super.key});

  @override
  ConsumerState<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends ConsumerState<WhatIfScreen> with SingleTickerProviderStateMixin {
  double expenseDelta = 0; // % increase in expenses
  double incomeDelta = 0;  // % decrease in income
  double newDebtPayment = 0; // monthly debt installment payment

  String aiResponse = 'Ajusta los controles de simulación arriba y presiona "Solicitar Diagnóstico a Zent AI" para evaluar tu escenario financiero hipotético.';
  bool aiLoading = false;

  // Custom scenario fields
  final TextEditingController _scenarioController = TextEditingController();
  String _customAiResponse = '';
  bool _customAiLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final transactions = ref.watch(transactionsProvider).value ?? [];
    final debts = ref.watch(debtsProvider).value ?? [];
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final loc = ref.watch(localizationProvider);

    // Baseline stats
    final totalIncomes = transactions.where((t) => t.type == 'income').fold(0.0, (sum, item) => sum + item.amount);
    final totalExpenses = transactions.where((t) => t.type == 'expense').fold(0.0, (sum, item) => sum + item.amount);
    
    // Simulated values
    final simulatedIncome = (totalIncomes * (1 - incomeDelta / 100)).clamp(0.0, double.infinity);
    final simulatedExpenses = totalExpenses * (1 + expenseDelta / 100) + newDebtPayment;
    final cashFlow = simulatedIncome - simulatedExpenses;

    // Financial Health score logic (0 to 100)
    double healthScore = 100;
    if (simulatedIncome > 0) {
      final ratio = simulatedExpenses / simulatedIncome;
      if (ratio > 1.0) {
        healthScore = (100 - (ratio - 1.0) * 100).clamp(0.0, 40.0);
      } else {
        healthScore = (100 - ratio * 80).clamp(10.0, 100.0);
      }
    } else {
      healthScore = 0.0;
    }

    // Risk Level definition
    String riskLevel = loc.get('what_if_risk_low');
    Color riskColor = Colors.green;
    if (healthScore < 40) {
      riskLevel = loc.get('what_if_risk_critical');
      riskColor = Colors.red;
    } else if (healthScore < 70) {
      riskLevel = loc.get('what_if_risk_moderate');
      riskColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(loc.get('what_if_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              padding: const EdgeInsets.all(4),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.sliders, size: 16),
                      const SizedBox(width: 6),
                      Text(loc.get('what_if_tab_controls')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.messageSquare, size: 16),
                      const SizedBox(width: 6),
                      Text(loc.get('what_if_tab_free')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Slider-based simulation (existing)
                _buildSliderTab(isDark, sym, healthScore, riskLevel, riskColor, cashFlow, simulatedIncome, simulatedExpenses),
                // TAB 2: Free-form scenario
                _buildScenarioTab(isDark, sym, totalIncomes, totalExpenses),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 1: Original slider-based simulation
  Widget _buildSliderTab(bool isDark, String sym, double healthScore, String riskLevel, Color riskColor, double cashFlow, double simulatedIncome, double simulatedExpenses) {
    final loc = ref.read(localizationProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score and Risk indicators
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(loc.get('financial_health'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(
                        '${healthScore.toStringAsFixed(0)}/100',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: riskColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(loc.get('risk_level'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(
                        riskLevel,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: riskColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Projections Chart
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.get('what_if_chart_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(6, (i) {
                            // Compound projection simulation
                            final cash = cashFlow * (i + 1);
                            return FlSpot(i.toDouble(), cash);
                          }),
                          isCurved: true,
                          color: cashFlow >= 0 ? Colors.green : Colors.red,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: (cashFlow >= 0 ? Colors.green : Colors.red).withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Simulation Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.get('what_if_panel_title'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 16),

                // Expense Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.get('what_if_additional_expense'), style: const TextStyle(fontSize: 13)),
                    Text('+$expenseDelta%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                Slider(
                  value: expenseDelta,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: Colors.redAccent,
                  onChanged: (v) => setState(() => expenseDelta = v),
                ),
                const SizedBox(height: 12),

                // Income Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.get('what_if_income_reduction'), style: const TextStyle(fontSize: 13)),
                    Text('-$incomeDelta%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  ],
                ),
                Slider(
                  value: incomeDelta,
                  min: 0,
                  max: 80,
                  divisions: 16,
                  activeColor: Colors.orangeAccent,
                  onChanged: (v) => setState(() => incomeDelta = v),
                ),
                const SizedBox(height: 12),

                // Debt installment slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.get('what_if_new_debt_payment'), style: const TextStyle(fontSize: 13)),
                    Text('$sym${newDebtPayment.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                  ],
                ),
                Slider(
                  value: newDebtPayment,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  activeColor: Colors.purpleAccent,
                  onChanged: (v) => setState(() => newDebtPayment = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // AI Diagnostic Action & Panel
          ElevatedButton.icon(
            onPressed: aiLoading ? null : _requestAiDiagnosis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: aiLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.cpu, size: 20),
            label: Text(loc.get('what_if_request_diagnosis'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    const Icon(LucideIcons.bot, color: Color(0xFF6366F1), size: 22),
                    const SizedBox(width: 8),
                    Text(loc.get('what_if_diagnosis_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF6366F1))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aiResponse == 'Ajusta los controles de simulación arriba y presiona "Solicitar Diagnóstico a Zent AI" para evaluar tu escenario financiero hipotético.'
                      ? loc.get('what_if_initial_desc')
                      : aiResponse,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 2: Free-form custom scenario simulation
  Widget _buildScenarioTab(bool isDark, String sym, double totalIncomes, double totalExpenses) {
    final loc = ref.read(localizationProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF4338CA).withOpacity(0.3) : const Color(0xFFC7D2FE),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 36,
                  color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.get('what_if_desc_title'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.get('what_if_desc_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick scenario chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildScenarioChip(isDark, '💻', loc.get('what_if_chip_laptop_title'), loc.get('what_if_chip_laptop_query')),
              _buildScenarioChip(isDark, '🚗', loc.get('what_if_chip_car_title'), loc.get('what_if_chip_car_query')),
              _buildScenarioChip(isDark, '📈', loc.get('what_if_chip_salary_title'), loc.get('what_if_chip_salary_query')),
              _buildScenarioChip(isDark, '🏠', loc.get('what_if_chip_rent_title'), loc.get('what_if_chip_rent_query')),
              _buildScenarioChip(isDark, '💰', loc.get('what_if_chip_save_title'), loc.get('what_if_chip_save_query')),
              _buildScenarioChip(isDark, '📱', loc.get('what_if_chip_phone_title'), loc.get('what_if_chip_phone_query')),
              _buildScenarioChip(isDark, '🎓', loc.get('what_if_chip_masters_title'), loc.get('what_if_chip_masters_query')),
              _buildScenarioChip(isDark, '💼', loc.get('what_if_chip_job_title'), loc.get('what_if_chip_job_query')),
            ],
          ),
          const SizedBox(height: 20),

          // Text input area
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.penTool, size: 16, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text(
                        loc.get('what_if_describe_scenario'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _scenarioController,
                    maxLines: 4,
                    minLines: 3,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.get('what_if_placeholder'),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.get('what_if_input_hint'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ),
                      if (_scenarioController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _scenarioController.clear()),
                          child: Icon(LucideIcons.x, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Analyze button
          ElevatedButton.icon(
            onPressed: (_customAiLoading || _scenarioController.text.trim().isEmpty) ? null : _requestCustomScenarioAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              disabledBackgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: _scenarioController.text.trim().isNotEmpty ? 4 : 0,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
            ),
            icon: _customAiLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.sparkles, size: 20),
            label: Text(
              _customAiLoading ? loc.get('what_if_analyzing') : loc.get('what_if_analyze_btn'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          // AI Response panel
          if (_customAiResponse.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.brain, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.get('what_if_analysis_result'), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF6366F1)),
                        ),
                      ),
                      // Copy/clear button
                      GestureDetector(
                        onTap: () => setState(() => _customAiResponse = ''),
                        child: Icon(LucideIcons.x, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _customAiResponse,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          
          if (_customAiResponse.isEmpty && !_customAiLoading)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.helpCircle, size: 40, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    loc.get('what_if_empty_state'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Build a quick scenario chip
  Widget _buildScenarioChip(bool isDark, String emoji, String label, String prompt) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _scenarioController.text = prompt;
        });
        // Auto-switch to scenario tab if not already there
        if (_tabController.index != 1) {
          _tabController.animateTo(1);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build financial context string for AI prompts
  String _buildFinancialContext() {
    final user = ref.read(authProvider).user;
    final transactions = ref.read(transactionsProvider).value ?? [];
    final debts = ref.read(debtsProvider).value ?? [];
    final sym = CurrencyFormatter.getSymbol(user?.currency);

    final expensesList = transactions.where((t) => t.type == 'expense').toList();
    final incomesList = transactions.where((t) => t.type == 'income').toList();
    
    final totalExpenses = expensesList.fold(0.0, (sum, item) => sum + item.amount);
    final totalIncomes = incomesList.fold(0.0, (sum, item) => sum + item.amount);
    
    // Monthly averages (approximate)
    final now = DateTime.now();
    final currentMonthExpenses = expensesList
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
    final currentMonthIncomes = incomesList
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);

    // Category breakdown
    final Map<String, double> expensesByCategory = {};
    for (var exp in expensesList.where((t) => t.date.month == now.month && t.date.year == now.year)) {
      expensesByCategory[exp.category] = (expensesByCategory[exp.category] ?? 0.0) + exp.amount;
    }
    String categoryBreakdown = expensesByCategory.entries
        .map((e) => "  - ${e.key}: $sym${e.value.toStringAsFixed(2)}")
        .join("\n");
    if (categoryBreakdown.isEmpty) categoryBreakdown = "  - Sin gastos registrados este mes";

    // Debts
    final totalDebtRemaining = debts.fold(0.0, (sum, item) {
      final remaining = item.totalInstallments - item.paidInstallments;
      return sum + (item.installmentAmount * remaining);
    });
    final monthlyDebtPayments = debts.fold(0.0, (sum, item) {
      if (item.paidInstallments < item.totalInstallments) {
        return sum + item.installmentAmount;
      }
      return sum;
    });
    String debtsDetail = debts.isEmpty 
        ? "  - Sin deudas registradas"
        : debts.map((d) {
            final remaining = d.totalInstallments - d.paidInstallments;
            return "  - ${d.name}: $sym${d.installmentAmount.toStringAsFixed(2)}/mes, quedan $remaining cuotas (Total restante: $sym${(d.installmentAmount * remaining).toStringAsFixed(2)})";
          }).join("\n");

    final salary = user?.salary ?? 'No especificado';
    final currency = user?.currency ?? 'GTQ';

    return '''
Perfil financiero REAL del usuario (datos actuales de su cuenta):
- Moneda: $currency ($sym)
- Salario declarado: $salary

Estado financiero del mes actual (${_getMonthName(now.month)} ${now.year}):
- Ingresos este mes: $sym${currentMonthIncomes.toStringAsFixed(2)}
- Gastos este mes: $sym${currentMonthExpenses.toStringAsFixed(2)}
- Flujo de caja mensual: $sym${(currentMonthIncomes - currentMonthExpenses).toStringAsFixed(2)}
- Disponible después de gastos: $sym${(currentMonthIncomes - currentMonthExpenses).toStringAsFixed(2)}

Desglose de gastos del mes por categoría:
$categoryBreakdown

Deudas actuales:
$debtsDetail
- Total restante en deudas: $sym${totalDebtRemaining.toStringAsFixed(2)}
- Pago mensual total de deudas: $sym${monthlyDebtPayments.toStringAsFixed(2)}

Totales históricos:
- Ingresos totales registrados: $sym${totalIncomes.toStringAsFixed(2)}
- Gastos totales registrados: $sym${totalExpenses.toStringAsFixed(2)}
''';
  }

  String _getMonthName(int month) {
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month];
  }

  /// Request AI analysis for the custom free-form scenario
  Future<void> _requestCustomScenarioAnalysis() async {
    final loc = ref.read(localizationProvider);
    final scenario = _scenarioController.text.trim();
    if (scenario.isEmpty) return;

    final user = ref.read(authProvider).user;
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final String currentLang = user?.language ?? 'Español';
    final lower = currentLang.toLowerCase();

    final financialContext = _buildFinancialContext();

    String systemInstructions = '''
--- INSTRUCCIONES ---
Analiza el escenario del usuario considerando sus datos financieros reales. Tu respuesta debe incluir:

1. 📊 IMPACTO FINANCIERO: Calcula numéricamente cómo afectaría este escenario sus finanzas. Usa la moneda del usuario ($sym). Muestra los números concretos (cuánto pagaría al mes, cuánto le quedaría disponible, etc.)

2. ✅ VIABILIDAD: ¿Puede permitírselo con su situación actual? Sé honesto. Si no puede, dilo claramente.

3. ⚠️ RIESGOS: ¿Qué riesgos conlleva? ¿Quedaría muy ajustado? ¿Tendría margen para emergencias?

4. 💡 RECOMENDACIÓN: Da tu veredicto final y alternativas si aplica. Si es viable, da tips para hacerlo bien. Si no es viable, sugiere ajustes (menor monto, más plazo, ahorrar antes, etc.)

5. 📅 PROYECCIÓN: Si aplica, muestra una tabla o resumen de cómo se verían sus finanzas mes a mes durante el plazo del escenario.

Responde en el idioma del usuario (idioma configurado: $currentLang), de forma clara, concisa y con emojis para hacerlo visual. Usa los datos REALES del usuario, no inventes números.
''';

    if (lower == 'english' || lower == 'en') {
      systemInstructions = '''
--- INSTRUCTIONS ---
Analyze the user's scenario considering their real financial data. Your response must include:

1. 📊 FINANCIAL IMPACT: Numerically calculate how this scenario would affect their finances. Use the user's currency ($sym). Show concrete numbers (how much they would pay per month, how much they would have left over, etc.)

2. ✅ VIABILITY: Can they afford it with their current situation? Be honest. If they cannot, say so clearly.

3. ⚠️ RISKS: What risks does it entail? Would they be left too tight? Would they have room for emergencies?

4. 💡 RECOMMENDATION: Give your final verdict and alternatives if applicable. If viable, give tips to do it right. If not viable, suggest adjustments (lower amount, longer term, save first, etc.)

5. 📅 PROJECTION: If applicable, show a table or summary of how their finances would look month by month during the period of the scenario.

Respond in the user's language (configured language: $currentLang), clearly, concisely and with emojis to make it visual. Use the user's REAL data, do not invent numbers.
''';
    } else if (lower == 'português' || lower == 'pt') {
      systemInstructions = '''
--- INSTRUÇÕES ---
Analise o cenário do usuário considerando seus dados financeiros reais. Sua resposta deve incluir:

1. 📊 IMPACTO FINANCEIRO: Calcule numericamente como este cenário afetaria suas finanças. Use a moeda do usuário ($sym). Mostre números concretos (quanto pagaria por mês, quanto teria disponível de sobra, etc.)

2. ✅ VIABILIDADE: Eles podem pagar com sua situação atual? Seja sincero. Se não puderem, diga claramente.

3. ⚠️ RISCOS: Quais riscos isso acarreta? Eles ficariam muito apertados? Teriam margem para emergências?

4. 💡 RECOMENDAÇÃO: Dê seu veredicto final e alternativas se aplicável. Se for viável, dê dicas para fazer certo. Se não for viável, sugira ajustes (valor menor, prazo maior, economizar antes, etc.)

5. 📅 PROJEÇÃO: Se aplicável, mostre uma tabela ou resumo de como ficariam suas finanças mês a mês durante o período do cenário.

Responda no idioma do usuário (idioma configurado: $currentLang), de forma clara, concisa e com emojis para torná-lo visual. Use os dados REAIS do usuário, não invente números.
''';
    } else if (lower == 'français' || lower == 'fr') {
      systemInstructions = '''
--- INSTRUCTIONS ---
Analysez le scénario de l'utilisateur en tenant compte de ses données financières réelles. Votre réponse doit inclure :

1. 📊 IMPACT FINANCIER : Calculez numériquement comment ce scénario affecterait ses finances. Utilisez la devise de l'utilisateur ($sym). Montrez des chiffres concrets (combien il paierait par mois, combien il lui resterait, etc.)

2. ✅ VIABILITÉ : Peut-il se le permettre compte tenu de sa situation actuelle ? Soyez honnête. Si ce n'est pas le cas, dites-le clairement.

3. ⚠️ RISQUES : Quels risques cela comporte-t-il ? Serait-il trop juste ? Aurait-il une marge pour les urgences ?

4. 💡 RECOMMANDATION : Donnez votre verdict final et des alternatives le cas échéant. Si c'est viable, donnez des conseils pour bien faire. Si ce n'est pas viable, suggérez des ajustements (montant inférieur, durée plus longue, épargner d'abord, etc.)

5. 📅 PROJECTION : Le cas échéant, montrez un tableau ou un résumé de la situation de ses finances mois par mois pendant la durée du scénario.

Répondez dans la langue de l'utilisateur (langue configurée : $currentLang), de manière claire, concise et avec des émoticônes pour rendre le tout visuel. Utilisez les données RÉELLES de l'utilisateur, n'inventez pas de chiffres.
''';
    } else if (lower == 'italiano' || lower == 'it') {
      systemInstructions = '''
--- ISTRUZIONI ---
Analizza lo scenario dell'utente considerando i suoi dati finanziari reali. La tua risposta deve includere:

1. 📊 IMPATTO FINANZIARIO: Calcola numericamente come questo scenario influenzerebbe le sue finanze. Usa la valuta dell'utente ($sym). Mostra numeri concreti (quanto pagherebbe al mese, quanto gli rimarrebbe disponibile, ecc.)

2. ✅ FATTIBILITÀ: Può permetterselo con la sua situazione attuale? Sii onesto. Se non può, dillo chiaramente.

3. ⚠️ RISCHI: Quali rischi comporta? Rimarrebbe troppo stretto? Avrebbe un margine per le emergenze?

4. 💡 RACCOMANDAZIONE: Dai il tuo verdetto finale e alternative se applicabile. Se è praticabile, dai consigli per farlo bene. Se non è praticabile, suggerisci modifiche (importo inferiore, durata maggiore, risparmiare prima, ecc.)

5. 📅 PROIEZIONE: Se applicabile, mostra una tabella o un riepilogo di come si presenterebbero le sue finanze mese per mese durante il periodo dello scenario.

Rispondi nella lingua dell'utente (lingua configurata: $currentLang), in modo chiaro, conciso e con emoji per renderlo visivo. Usa i dati REALI dell'utente, non inventare numeri.
''';
    }

    final prompt = '''
El usuario está simulando un escenario hipotético libre en su aplicación financiera:
"$scenario"

$financialContext

$systemInstructions
''';

    setState(() {
      _customAiLoading = true;
      _customAiResponse = '';
    });
    
    try {
      final repository = ref.read(aiRepositoryProvider);
      final stream = repository.sendMessage(prompt, []);
      await for (final chunk in stream) {
        if (mounted) {
          setState(() {
            _customAiResponse += chunk;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customAiResponse = '${loc.get('error_analyzing_scenario')}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _customAiLoading = false;
        });
      }
    }
  }

  Future<void> _requestAiDiagnosis() async {
    final user = ref.read(authProvider).user;
    final loc = ref.read(localizationProvider);
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final String currentLang = user?.language ?? 'Español';
    final lower = currentLang.toLowerCase();

    String diagnosisPrompt = 'Diagnóstico "What If" de Simulación:\n'
        'El usuario ha simulado los siguientes cambios financieros:\n'
        '- Incremento de gastos mensuales en: ${expenseDelta.toStringAsFixed(0)}%\n'
        '- Reducción de ingresos mensuales en: ${incomeDelta.toStringAsFixed(0)}%\n'
        '- Nueva cuota de deuda mensual de: $sym${newDebtPayment.toStringAsFixed(0)}\n\n'
        'Por favor, genera un plan de diagnóstico financiero rápido y conciso (en el idioma configurado del usuario: $currentLang, de 2 o 3 párrafos) '
        'analizando su impacto en su salud financiera, su nivel de riesgo y recomendando alternativas de mitigación '
        'y optimización de dinero.';

    if (lower == 'english' || lower == 'en') {
      diagnosisPrompt = 'Simulation "What If" Diagnosis:\n'
          'The user has simulated the following financial changes:\n'
          '- Monthly expenses increase by: ${expenseDelta.toStringAsFixed(0)}%\n'
          '- Monthly income reduction by: ${incomeDelta.toStringAsFixed(0)}%\n'
          '- New monthly debt installment: $sym${newDebtPayment.toStringAsFixed(0)}\n\n'
          'Please generate a quick and concise financial diagnosis plan (in the user\'s configured language: $currentLang, of 2 or 3 paragraphs) '
          'analyzing its impact on their financial health, risk level and recommending mitigation and money optimization alternatives.';
    } else if (lower == 'português' || lower == 'pt') {
      diagnosisPrompt = 'Diagnóstico "What If" de Simulação:\n'
          'O usuário simulou as seguintes alterações financeiras:\n'
          '- Aumento de despesas mensais de: ${expenseDelta.toStringAsFixed(0)}%\n'
          '- Redução de receita mensal de: ${incomeDelta.toStringAsFixed(0)}%\n'
          '- Nova parcela mensal de dívida: $sym${newDebtPayment.toStringAsFixed(0)}\n\n'
          'Por favor, gere um plano de diagnóstico financeiro rápido e conciso (no idioma configurado do usuário: $currentLang, de 2 ou 3 parágrafos) '
          'analisando seu impacto na sua saúde financeira, nível de risco e recomendando alternativas de mitigação e otimização de dinheiro.';
    } else if (lower == 'français' || lower == 'fr') {
      diagnosisPrompt = 'Diagnostic de Simulation "What If" :\n'
          'L\'utilisateur a simulé les changements financiers suivants :\n'
          '- Augmentation des dépenses mensuelles de : ${expenseDelta.toStringAsFixed(0)}%\n'
          '- Réduction des revenus mensuels de : ${incomeDelta.toStringAsFixed(0)}%\n'
          '- Nouvelle échéance mensuelle de dette : $sym${newDebtPayment.toStringAsFixed(0)}\n\n'
          'Veuillez générer un plan de diagnostic financier rapide et concis (dans la langue configurée de l\'utilisateur : $currentLang, de 2 ou 3 paragraphes) '
          'analysant son impact sur sa santé financière, son niveau de risque et recommandant des alternatives de mitigation et d\'optimisation de l\'argent.';
    } else if (lower == 'italiano' || lower == 'it') {
      diagnosisPrompt = 'Diagnosi di Simulazione "What If":\n'
          'L\'utente ha simulato le seguenti variazioni finanziarie:\n'
          '- Aumento delle spese mensili del: ${expenseDelta.toStringAsFixed(0)}%\n'
          '- Riduzione delle entrate mensili del: ${incomeDelta.toStringAsFixed(0)}%\n'
          '- Nuova rata mensile del debito: $sym${newDebtPayment.toStringAsFixed(0)}\n\n'
          'Si prega di generare un piano di diagnosi finanziaria rapido e conciso (nella lingua configurata dell\'utente: $currentLang, di 2 o 3 paragrafi) '
          'analizzando il suo impatto sulla salute finanziaria, sul livello di rischio e consigliando alternative di mitigazione e ottimizzazione del denaro.';
    }

    setState(() {
      aiLoading = true;
      aiResponse = '';
    });
    
    try {
      final repository = ref.read(aiRepositoryProvider);
      final stream = repository.sendMessage(diagnosisPrompt, []);
      await for (final chunk in stream) {
        if (mounted) {
          setState(() {
            aiResponse += chunk;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          aiResponse = '${loc.get('error_obtaining_diagnosis')}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          aiLoading = false;
        });
      }
    }
  }
}
