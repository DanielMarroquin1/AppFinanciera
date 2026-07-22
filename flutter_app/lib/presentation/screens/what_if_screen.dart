import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debts_provider.dart';
import '../providers/saving_goals_provider.dart';
import '../providers/chat_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';
import '../widgets/modals/premium_modal.dart';

class WhatIfScreen extends ConsumerStatefulWidget {
  const WhatIfScreen({super.key});

  @override
  ConsumerState<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends ConsumerState<WhatIfScreen> with SingleTickerProviderStateMixin {
  // ── Tab 0: Simulador básico ──────────────────────────────────────────────
  double expenseDelta = 0;
  double incomeDelta = 0;
  double newDebtPayment = 0;
  String aiResponse = '';
  bool aiLoading = false;

  // ── Tab 1: Compras/Deudas ────────────────────────────────────────────────
  double _purchaseAmount = 5000;
  int _purchaseMonths = 12;
  double _purchaseInterestRate = 0; // % anual

  // ── Tab 2: Emergencia / Runway ───────────────────────────────────────────
  double _incomeReductionPct = 50;
  double _emergencyFund = 0;

  // ── Tab 3: Micro-Ahorro ──────────────────────────────────────────────────
  String _microSavingCategory = 'food';
  double _microSavingPct = 20;
  double _investmentReturnPct = 5;

  // ── Tab 4: IA Libre ──────────────────────────────────────────────────────
  final TextEditingController _scenarioController = TextEditingController();
  String _customAiResponse = '';
  bool _customAiLoading = false;

  late TabController _tabController;

  final List<String> _categories = [
    'food', 'transport', 'bills', 'shopping', 'entertainment', 'health', 'home', 'education'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    final isPremium = user?.isPremium ?? false;

    if (!isPremium) {
      return _buildPremiumGate(isDark);
    }

    final transactions = ref.watch(transactionsProvider).value ?? [];
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final loc = ref.watch(localizationProvider);

    final totalIncomes = transactions.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
    final totalExpenses = transactions.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);

    final simulatedIncome = (totalIncomes * (1 - incomeDelta / 100)).clamp(0.0, double.infinity);
    final simulatedExpenses = totalExpenses * (1 + expenseDelta / 100) + newDebtPayment;
    final cashFlow = simulatedIncome - simulatedExpenses;

    double healthScore = 100;
    if (simulatedIncome > 0) {
      final ratio = simulatedExpenses / simulatedIncome;
      healthScore = ratio > 1.0
          ? (100 - (ratio - 1.0) * 100).clamp(0.0, 40.0)
          : (100 - ratio * 80).clamp(10.0, 100.0);
    } else {
      healthScore = 0.0;
    }

    String riskLevel = loc.get('what_if_risk_low');
    Color riskColor = Colors.green;
    if (healthScore < 40) { riskLevel = loc.get('what_if_risk_critical'); riskColor = Colors.red; }
    else if (healthScore < 70) { riskLevel = loc.get('what_if_risk_moderate'); riskColor = Colors.orange; }

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
          // ── Tab Bar ──────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
              padding: const EdgeInsets.all(4),
              isScrollable: false,
              tabs: [
                _buildTab(LucideIcons.sliders, '🎛️', 'Básico'),
                _buildTab(LucideIcons.creditCard, '💳', 'Compras'),
                _buildTab(LucideIcons.shieldAlert, '🆘', 'Emergencia'),
                _buildTab(LucideIcons.scissors, '✂️', 'Micro-Ahorro'),
                _buildTab(LucideIcons.sparkles, '💬', 'IA Libre'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Tab Views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSliderTab(isDark, sym, healthScore, riskLevel, riskColor, cashFlow, simulatedIncome, simulatedExpenses),
                _buildPurchaseDebtTab(isDark, sym, totalIncomes, totalExpenses),
                _buildEmergencyTab(isDark, sym, totalIncomes, totalExpenses),
                _buildMicroSavingTab(isDark, sym, totalExpenses),
                _buildFreeScenarioTab(isDark, sym, totalIncomes, totalExpenses),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM GATE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPremiumGate(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('What If?'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 64),
              const SizedBox(height: 24),
              Text('Función Premium Exclusiva 👑',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'El Simulador AI "What If?" con 5 escenarios interactivos está disponible para usuarios Premium.',
                style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => PremiumModal.show(context),
                  icon: const Icon(LucideIcons.crown, color: Colors.white),
                  label: const Text('Actualizar a Premium VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 0: SIMULADOR BÁSICO (mejorado con fixes UI)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSliderTab(bool isDark, String sym, double healthScore, String riskLevel, Color riskColor, double cashFlow, double simulatedIncome, double simulatedExpenses) {
    final loc = ref.read(localizationProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score cards
          Row(
            children: [
              Expanded(child: _infoCard(isDark, loc.get('financial_health'), '${healthScore.toStringAsFixed(0)}/100', riskColor)),
              const SizedBox(width: 12),
              Expanded(child: _infoCard(isDark, loc.get('risk_level'), riskLevel, riskColor, smallText: true)),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          _buildProjectionChart(isDark, cashFlow),
          const SizedBox(height: 20),
          // Controls
          _buildControlCard(isDark, sym, loc),
          const SizedBox(height: 20),
          // AI Diagnosis Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: aiLoading ? null : _requestAiDiagnosis,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: aiLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(LucideIcons.cpu, size: 20),
              label: Text(loc.get('what_if_request_diagnosis'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
          // AI Response
          _buildAIResponseCard(isDark,
            title: loc.get('what_if_diagnosis_title'),
            content: aiResponse.isEmpty ? loc.get('what_if_initial_desc') : aiResponse,
            isPlaceholder: aiResponse.isEmpty,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: SIMULADOR DE COMPRAS / DEUDAS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPurchaseDebtTab(bool isDark, String sym, double totalIncomes, double totalExpenses) {
    // Cálculo de cuota mensual con interés (fórmula de amortización)
    final monthlyRate = _purchaseInterestRate / 100 / 12;
    final double monthlyPayment = monthlyRate > 0
        ? _purchaseAmount * (monthlyRate * math.pow(1 + monthlyRate, _purchaseMonths)) / (math.pow(1 + monthlyRate, _purchaseMonths) - 1)
        : _purchaseAmount / _purchaseMonths;
    final totalPaid = monthlyPayment * _purchaseMonths;
    final totalInterest = totalPaid - _purchaseAmount;

    final now = DateTime.now();
    final currentMonthIncome = ref.read(transactionsProvider).value
        ?.where((t) => t.type == 'income' && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount) ?? 0.0;
    final currentMonthExpense = ref.read(transactionsProvider).value
        ?.where((t) => t.type == 'expense' && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount) ?? 0.0;

    final currentCashFlow = currentMonthIncome - currentMonthExpense;
    final newCashFlow = currentCashFlow - monthlyPayment;
    final canAfford = newCashFlow >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _sectionHeader(isDark, '💳', 'Simulador de Compra / Deuda',
              'Calcula el impacto de financiar una compra o adquirir un crédito.'),
          const SizedBox(height: 20),

          // Controls card
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '⚙️ Parámetros del Financiamiento'),
              const SizedBox(height: 16),
              _sliderControl(isDark, 'Monto a financiar', '$sym${_purchaseAmount.toStringAsFixed(0)}',
                  _purchaseAmount, 500, 100000, 199, const Color(0xFF6366F1),
                  (v) => setState(() => _purchaseAmount = v)),
              const SizedBox(height: 12),
              _sliderControl(isDark, 'Plazo (meses)', '$_purchaseMonths meses',
                  _purchaseMonths.toDouble(), 1, 60, 59, const Color(0xFFF59E0B),
                  (v) => setState(() => _purchaseMonths = v.round())),
              const SizedBox(height: 12),
              _sliderControl(isDark, 'Tasa de interés anual', '${_purchaseInterestRate.toStringAsFixed(0)}%',
                  _purchaseInterestRate, 0, 60, 60, const Color(0xFFEF4444),
                  (v) => setState(() => _purchaseInterestRate = v)),
            ],
          )),
          const SizedBox(height: 16),

          // Results cards
          Row(
            children: [
              Expanded(child: _infoCard(isDark, 'Cuota mensual', '$sym${monthlyPayment.toStringAsFixed(2)}', const Color(0xFF6366F1))),
              const SizedBox(width: 12),
              Expanded(child: _infoCard(isDark, 'Intereses totales', '$sym${totalInterest.toStringAsFixed(2)}', const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 12),

          // Impacto en flujo de caja
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '📊 Impacto en tu Flujo Mensual'),
              const SizedBox(height: 12),
              _impactRow(isDark, '💰 Ingresos del mes', '$sym${currentMonthIncome.toStringAsFixed(2)}', Colors.green),
              const SizedBox(height: 6),
              _impactRow(isDark, '💸 Gastos actuales', '-$sym${currentMonthExpense.toStringAsFixed(2)}', Colors.orange),
              const SizedBox(height: 6),
              _impactRow(isDark, '🔴 Nueva cuota', '-$sym${monthlyPayment.toStringAsFixed(2)}', Colors.red),
              Divider(height: 20, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              _impactRow(isDark, '📈 Disponible resultante',
                  '$sym${newCashFlow.toStringAsFixed(2)}',
                  canAfford ? Colors.green : Colors.red,
                  bold: true),
              const SizedBox(height: 12),
              // Veredicto visual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: (canAfford ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (canAfford ? Colors.green : Colors.red).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(canAfford ? LucideIcons.checkCircle : LucideIcons.xCircle,
                        color: canAfford ? Colors.green : Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        canAfford
                            ? '✅ Tu flujo de caja puede absorber esta cuota. ¡Mantendrás saldo positivo!'
                            : '⚠️ Esta cuota supera tu disponible mensual actual. Considera un plazo mayor o monto menor.',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: canAfford ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
          const SizedBox(height: 16),

          // Gráfico de deuda restante
          if (_purchaseMonths > 0 && monthlyPayment > 0)
            _cardContainer(isDark, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(isDark, '📉 Amortización de la Deuda'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(_buildDebtAmortizationChart(monthlyPayment, monthlyRate)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(const Color(0xFF6366F1)), const SizedBox(width: 4),
                    Text('Deuda restante', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(width: 16),
                    _legendDot(const Color(0xFF10B981)), const SizedBox(width: 4),
                    Text('Ahorro perdido', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ],
            )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: EMERGENCIA / RUNWAY CALCULATOR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmergencyTab(bool isDark, String sym, double totalIncomes, double totalExpenses) {
    final transactions = ref.read(transactionsProvider).value ?? [];
    final now = DateTime.now();

    // Gastos fijos mensuales
    final fixedMonthlyExpenses = transactions
        .where((t) => t.type == 'expense' && t.isFixed)
        .fold(0.0, (s, t) => s + t.amount);

    // Ingresos con la reducción aplicada
    final reducedMonthlyIncome = totalIncomes > 0
        ? (totalIncomes / 12) * (1 - _incomeReductionPct / 100)
        : 0.0;

    // Gastos mensuales promedio
    final avgMonthlyExpense = totalExpenses > 0 ? totalExpenses / 12 : fixedMonthlyExpenses;
    final effectiveFixedExpenses = fixedMonthlyExpenses > 0 ? fixedMonthlyExpenses : avgMonthlyExpense;

    // Runway con fondo de emergencia
    final monthlyDeficit = effectiveFixedExpenses - reducedMonthlyIncome;
    final runwayMonths = monthlyDeficit > 0 && _emergencyFund > 0
        ? (_emergencyFund / monthlyDeficit)
        : (monthlyDeficit <= 0 ? 999.0 : 0.0); // 999 = indefinido

    // Nivel de riesgo
    Color runwayColor;
    String runwayLabel;
    if (runwayMonths >= 6) { runwayColor = Colors.green; runwayLabel = '✅ Resiliente'; }
    else if (runwayMonths >= 3) { runwayColor = Colors.orange; runwayLabel = '⚡ Vulnerable'; }
    else if (runwayMonths > 0) { runwayColor = Colors.red; runwayLabel = '🚨 En riesgo'; }
    else { runwayColor = Colors.red[900]!; runwayLabel = '💀 Crítico'; }

    final idealEmergencyFund = effectiveFixedExpenses * 6;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(isDark, '🆘', 'Simulador de Emergencia Financiera',
              '¿Qué pasaría si perdés el empleo o tus ingresos caen bruscamente?'),
          const SizedBox(height: 20),

          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '⚙️ Variables de la Emergencia'),
              const SizedBox(height: 16),
              _sliderControl(isDark, 'Reducción de ingresos', '-${_incomeReductionPct.toStringAsFixed(0)}%',
                  _incomeReductionPct, 0, 100, 20, Colors.orange,
                  (v) => setState(() => _incomeReductionPct = v)),
              const SizedBox(height: 12),
              _sliderControl(isDark, 'Fondo de emergencia disponible', '$sym${_emergencyFund.toStringAsFixed(0)}',
                  _emergencyFund, 0, 50000, 100, Colors.blue,
                  (v) => setState(() => _emergencyFund = v)),
            ],
          )),
          const SizedBox(height: 16),

          // Resultado principal: Runway
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [runwayColor.withOpacity(0.15), runwayColor.withOpacity(0.05)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: runwayColor.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              children: [
                Text('Meses de Supervivencia', style: TextStyle(fontSize: 13, color: runwayColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  runwayMonths >= 100 ? '∞' : runwayMonths.toStringAsFixed(1),
                  style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: runwayColor),
                ),
                Text('meses', style: TextStyle(fontSize: 14, color: runwayColor.withOpacity(0.7))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: runwayColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(runwayLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: runwayColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Desglose financiero
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '📊 Desglose del Escenario'),
              const SizedBox(height: 12),
              _impactRow(isDark, '💰 Ingresos actuales/mes', '$sym${totalIncomes > 0 ? (totalIncomes / 12).toStringAsFixed(2) : "0.00"}', Colors.green),
              const SizedBox(height: 6),
              _impactRow(isDark, '📉 Ingresos reducidos/mes', '$sym${reducedMonthlyIncome.toStringAsFixed(2)}', Colors.orange),
              const SizedBox(height: 6),
              _impactRow(isDark, '🔒 Gastos fijos/mes', '$sym${effectiveFixedExpenses.toStringAsFixed(2)}', Colors.red),
              const SizedBox(height: 6),
              _impactRow(isDark, '💳 Déficit mensual', monthlyDeficit > 0 ? '-$sym${monthlyDeficit.toStringAsFixed(2)}' : '✅ Sin déficit',
                  monthlyDeficit > 0 ? Colors.red : Colors.green, bold: true),
            ],
          )),
          const SizedBox(height: 16),

          // Meta del fondo de emergencia
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '🎯 Meta de Fondo de Emergencia Ideal'),
              const SizedBox(height: 12),
              Text(
                'Para estar protegido 6 meses, necesitas:',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '$sym${idealEmergencyFund.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
              const SizedBox(height: 8),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: idealEmergencyFund > 0 ? (_emergencyFund / idealEmergencyFund).clamp(0.0, 1.0) : 0,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _emergencyFund >= idealEmergencyFund ? Colors.green : const Color(0xFF6366F1),
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu fondo actual: $sym${_emergencyFund.toStringAsFixed(2)} (${idealEmergencyFund > 0 ? (_emergencyFund / idealEmergencyFund * 100).clamp(0, 100).toStringAsFixed(0) : "0"}%)',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500]),
              ),
            ],
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3: MICRO-AHORRO
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMicroSavingTab(bool isDark, String sym, double totalExpenses) {
    final transactions = ref.read(transactionsProvider).value ?? [];
    final now = DateTime.now();

    // Gasto actual de la categoría seleccionada (este mes)
    final categorySpend = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.category.split('_')[0] == _microSavingCategory &&
            t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);

    final monthlySaving = categorySpend * (_microSavingPct / 100);
    final annualSaving = monthlySaving * 12;

    // Proyección con rendimiento compuesto
    double _compoundProject(double monthly, double annualRate, int years) {
      if (monthly <= 0) return 0;
      final monthlyRate = annualRate / 100 / 12;
      final months = years * 12;
      if (monthlyRate == 0) return monthly * months;
      return monthly * ((math.pow(1 + monthlyRate, months) - 1) / monthlyRate);
    }

    final proj6m = _compoundProject(monthlySaving, _investmentReturnPct, 0) + monthlySaving * 6;
    final proj1y = _compoundProject(monthlySaving, _investmentReturnPct, 1);
    final proj5y = _compoundProject(monthlySaving, _investmentReturnPct, 5);

    final categoryLabel = _catLabel(_microSavingCategory);
    final categoryEmoji = _catEmoji(_microSavingCategory);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(isDark, '✂️', 'Optimización de Micro-Gastos',
              'Descubre cuánto puedes acumular reduciendo solo una categoría de gasto.'),
          const SizedBox(height: 20),

          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '⚙️ Parámetros de Reducción'),
              const SizedBox(height: 16),

              // Selector de categoría
              Text('Categoría a reducir:', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = cat == _microSavingCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _microSavingCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6366F1)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_catEmoji(cat), style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              _catLabel(cat),
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _sliderControl(isDark, 'Reducción en $categoryLabel', '-${_microSavingPct.toStringAsFixed(0)}%',
                  _microSavingPct, 5, 80, 15, const Color(0xFF10B981),
                  (v) => setState(() => _microSavingPct = v)),
              const SizedBox(height: 12),
              _sliderControl(isDark, 'Rendimiento anual estimado', '${_investmentReturnPct.toStringAsFixed(0)}%',
                  _investmentReturnPct, 0, 15, 15, const Color(0xFF3B82F6),
                  (v) => setState(() => _investmentReturnPct = v)),
            ],
          )),
          const SizedBox(height: 16),

          // Gasto actual
          _cardContainer(isDark, child: Row(
            children: [
              Text('$categoryEmoji', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gasto actual en $categoryLabel (mes)', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    Text('$sym${categorySpend.toStringAsFixed(2)}/mes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Ahorro mensual', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  Text('+$sym${monthlySaving.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
            ],
          )),
          const SizedBox(height: 16),

          // Proyecciones
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(isDark, '📈 Proyección con Inversión (${_investmentReturnPct.toStringAsFixed(0)}% anual)'),
              const SizedBox(height: 16),
              _projectionRow(isDark, sym, '6 meses', proj6m, const Color(0xFF3B82F6)),
              const SizedBox(height: 12),
              _projectionRow(isDark, sym, '1 año', proj1y, const Color(0xFF8B5CF6)),
              const SizedBox(height: 12),
              _projectionRow(isDark, sym, '5 años', proj5y, const Color(0xFF10B981)),
              const SizedBox(height: 16),

              // Gráfico de barras comparativo
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: proj5y > 0 ? proj5y * 1.15 : 1,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                        final labels = ['6m', '1a', '5a'];
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Text(labels[i], style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]));
                      })),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: proj6m > 0 ? proj6m : 0.01, color: const Color(0xFF3B82F6), width: 36, borderRadius: BorderRadius.circular(8))]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: proj1y > 0 ? proj1y : 0.01, color: const Color(0xFF8B5CF6), width: 36, borderRadius: BorderRadius.circular(8))]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: proj5y > 0 ? proj5y : 0.01, color: const Color(0xFF10B981), width: 36, borderRadius: BorderRadius.circular(8))]),
                    ],
                  ),
                ),
              ),
            ],
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 4: IA LIBRE (mejorado)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFreeScenarioTab(bool isDark, String sym, double totalIncomes, double totalExpenses) {
    final loc = ref.read(localizationProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF4338CA).withOpacity(0.3) : const Color(0xFFC7D2FE)),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.sparkles, size: 36, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1)),
                const SizedBox(height: 12),
                Text(
                  loc.get('what_if_desc_title'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1B4B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.get('what_if_desc_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick chips
          Wrap(
            spacing: 8, runSpacing: 8,
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
          const SizedBox(height: 16),

          // Text area
          _cardContainer(isDark, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.penTool, size: 16, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.get('what_if_describe_scenario'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _scenarioController,
                maxLines: 4, minLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText: loc.get('what_if_placeholder'),
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_scenarioController.text.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _scenarioController.clear()),
                    child: Icon(LucideIcons.x, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                ),
            ],
          )),
          const SizedBox(height: 12),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: (_customAiLoading || _scenarioController.text.trim().isEmpty) ? null : _requestCustomScenarioAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                disabledBackgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _customAiLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(LucideIcons.sparkles, size: 20),
              label: Text(
                _customAiLoading ? loc.get('what_if_analyzing') : loc.get('what_if_analyze_btn'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_customAiResponse.isNotEmpty)
            _buildAIResponseCard(isDark,
              title: loc.get('what_if_analysis_result'),
              content: _customAiResponse,
              onClear: () => setState(() => _customAiResponse = ''),
            ),

          if (_customAiResponse.isEmpty && !_customAiLoading)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.helpCircle, size: 40, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    loc.get('what_if_empty_state'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[600] : Colors.grey[400], height: 1.4),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS DE UI
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTab(IconData icon, String emoji, String label) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 9), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _cardContainer(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  Widget _cardTitle(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _infoCard(bool isDark, String label, String value, Color color, {bool smallText = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: smallText ? 18 : 26, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(bool isDark, String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderControl(bool isDark, String label, String valueStr, double value, double min, double max, int divisions, Color color, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text(valueStr, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            overlayColor: color.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _impactRow(bool isDark, String label, String value, Color valueColor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: valueColor)),
      ],
    );
  }

  Widget _projectionRow(bool isDark, String sym, String period, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
          Text('$sym${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProjectionChart(bool isDark, double cashFlow) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.read(localizationProvider).get('what_if_chart_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(6, (i) => FlSpot(i.toDouble(), cashFlow * (i + 1))),
                  isCurved: true,
                  color: cashFlow >= 0 ? Colors.green : Colors.red,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: (cashFlow >= 0 ? Colors.green : Colors.red).withOpacity(0.12)),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(bool isDark, String sym, dynamic loc) {
    return _cardContainer(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle(isDark, loc.get('what_if_panel_title')),
        const SizedBox(height: 16),
        _sliderControl(isDark, loc.get('what_if_additional_expense'), '+${expenseDelta.toStringAsFixed(0)}%', expenseDelta, 0, 100, 20, Colors.redAccent, (v) => setState(() => expenseDelta = v)),
        const SizedBox(height: 8),
        _sliderControl(isDark, loc.get('what_if_income_reduction'), '-${incomeDelta.toStringAsFixed(0)}%', incomeDelta, 0, 80, 16, Colors.orangeAccent, (v) => setState(() => incomeDelta = v)),
        const SizedBox(height: 8),
        _sliderControl(isDark, loc.get('what_if_new_debt_payment'), '$sym${newDebtPayment.toStringAsFixed(0)}', newDebtPayment, 0, 1000, 20, Colors.purpleAccent, (v) => setState(() => newDebtPayment = v)),
      ],
    ));
  }

  Widget _buildAIResponseCard(bool isDark, {required String title, required String content, bool isPlaceholder = false, VoidCallback? onClear}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bot, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6366F1)), overflow: TextOverflow.ellipsis),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(LucideIcons.x, size: 16, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 13, color: isPlaceholder ? (isDark ? Colors.grey[500] : Colors.grey[400]) : (isDark ? Colors.grey[300] : Colors.grey[700]), height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(bool isDark, String emoji, String label, String prompt) {
    return GestureDetector(
      onTap: () {
        setState(() => _scenarioController.text = prompt);
        if (_tabController.index != 4) _tabController.animateTo(4);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[300] : Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  LineChartData _buildDebtAmortizationChart(double monthlyPayment, double monthlyRate) {
    double balance = _purchaseAmount;
    double totalSavingsLost = 0;
    final spots1 = <FlSpot>[];
    final spots2 = <FlSpot>[];

    for (int i = 0; i <= _purchaseMonths; i++) {
      spots1.add(FlSpot(i.toDouble(), balance));
      totalSavingsLost += monthlyPayment;
      spots2.add(FlSpot(i.toDouble(), totalSavingsLost));
      if (i < _purchaseMonths) {
        final interest = balance * monthlyRate;
        balance = (balance - (monthlyPayment - interest)).clamp(0, double.infinity);
      }
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(spots: spots1, isCurved: true, color: const Color(0xFF6366F1), barWidth: 2.5, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF6366F1).withOpacity(0.1))),
        LineChartBarData(spots: spots2, isCurved: true, color: const Color(0xFF10B981), barWidth: 2.5, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withOpacity(0.1))),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS DE DATOS
  // ─────────────────────────────────────────────────────────────────────────

  String _catLabel(String cat) {
    const m = {'food': 'Comida', 'transport': 'Transporte', 'bills': 'Servicios', 'shopping': 'Compras', 'entertainment': 'Entretenimiento', 'health': 'Salud', 'home': 'Hogar', 'education': 'Educación'};
    return m[cat] ?? cat;
  }

  String _catEmoji(String cat) {
    const m = {'food': '🍔', 'transport': '🚗', 'bills': '📱', 'shopping': '🛍️', 'entertainment': '🎬', 'health': '💊', 'home': '🏠', 'education': '📚'};
    return m[cat] ?? '💡';
  }

  String _buildFinancialContext() {
    final user = ref.read(authProvider).user;
    final transactions = ref.read(transactionsProvider).value ?? [];
    final debts = ref.read(debtsProvider).value ?? [];
    final sym = CurrencyFormatter.getSymbol(user?.currency);

    final now = DateTime.now();
    final expenses = transactions.where((t) => t.type == 'expense');
    final incomes = transactions.where((t) => t.type == 'income');

    final monthlyExpenses = expenses.where((t) => t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);
    final monthlyIncomes = incomes.where((t) => t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);

    final Map<String, double> byCat = {};
    for (var t in expenses.where((t) => t.date.month == now.month && t.date.year == now.year)) {
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
    }
    final catBreakdown = byCat.entries.map((e) => '  - ${e.key}: $sym${e.value.toStringAsFixed(2)}').join('\n');
    final monthlyDebtPayments = debts.where((d) => d.paidInstallments < d.totalInstallments).fold(0.0, (s, d) => s + d.installmentAmount);

    return '''
Perfil: ${user?.name ?? 'Usuario'} | Moneda: ${user?.currency ?? 'GTQ'} ($sym) | Salario: ${user?.salary ?? 'N/A'}
Mes actual: Ingresos $sym${monthlyIncomes.toStringAsFixed(2)} | Gastos $sym${monthlyExpenses.toStringAsFixed(2)} | Flujo: $sym${(monthlyIncomes - monthlyExpenses).toStringAsFixed(2)}
Gastos por categoría: ${catBreakdown.isEmpty ? 'Sin datos' : catBreakdown}
Deudas activas: ${debts.isEmpty ? 'Sin deudas' : 'Pago mensual $sym${monthlyDebtPayments.toStringAsFixed(2)}'}
''';
  }

  String _getMonthName(int month) {
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AI CALLS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _requestAiDiagnosis() async {
    final user = ref.read(authProvider).user;
    final loc = ref.read(localizationProvider);
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final lang = user?.language ?? 'Español';

    final context = _buildFinancialContext();
    final prompt = '''
Diagnóstico financiero "What If" — responde en $lang.

El usuario ha simulado estos cambios:
- Incremento de gastos: +${expenseDelta.toStringAsFixed(0)}%
- Reducción de ingresos: -${incomeDelta.toStringAsFixed(0)}%
- Nueva cuota de deuda: $sym${newDebtPayment.toStringAsFixed(0)}/mes

Contexto financiero real:
$context

Genera un diagnóstico conciso (3-4 párrafos) con: impacto en salud financiera, nivel de riesgo y 2-3 recomendaciones concretas de mitigación.
''';

    setState(() { aiLoading = true; aiResponse = ''; });
    try {
      final stream = ref.read(aiRepositoryProvider).sendMessage(prompt, []);
      await for (final chunk in stream) {
        if (mounted) setState(() => aiResponse += chunk);
      }
    } catch (e) {
      if (mounted) setState(() => aiResponse = '${loc.get('error_obtaining_diagnosis')}: $e');
    } finally {
      if (mounted) setState(() => aiLoading = false);
    }
  }

  Future<void> _requestCustomScenarioAnalysis() async {
    final user = ref.read(authProvider).user;
    final loc = ref.read(localizationProvider);
    final sym = CurrencyFormatter.getSymbol(user?.currency);
    final lang = user?.language ?? 'Español';
    final scenario = _scenarioController.text.trim();
    if (scenario.isEmpty) return;

    final financialContext = _buildFinancialContext();
    final prompt = '''
El usuario simula este escenario hipotético (responde en $lang):
"$scenario"

Datos financieros reales:
$financialContext

Analiza con estructura:
1. 📊 IMPACTO FINANCIERO (números reales en $sym)
2. ✅ VIABILIDAD (sé honesto)
3. ⚠️ RIESGOS
4. 💡 RECOMENDACIÓN
5. 📅 PROYECCIÓN (si aplica, tabla mes a mes)
''';

    setState(() { _customAiLoading = true; _customAiResponse = ''; });
    try {
      final stream = ref.read(aiRepositoryProvider).sendMessage(prompt, []);
      await for (final chunk in stream) {
        if (mounted) setState(() => _customAiResponse += chunk);
      }
    } catch (e) {
      if (mounted) setState(() => _customAiResponse = '${loc.get('error_analyzing_scenario')}: $e');
    } finally {
      if (mounted) setState(() => _customAiLoading = false);
    }
  }
}
