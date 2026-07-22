import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/models/micro_insight.dart';

/// Servicio de análisis financiero inteligente que encapsula todas las
/// funcionalidades de IA más allá del chat: anomalías, forecast, insights y
/// categorización semántica automática.
class AIAnalysisService {
  static GenerativeModel? _model;

  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.apiKey,
    );
    return _model!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. DETECCIÓN INTELIGENTE DE ANOMALÍAS
  // ─────────────────────────────────────────────────────────────────────────

  /// Analiza si una transacción es atípicamente alta respecto al historial.
  /// Retorna un [AnomalyResult] con la evaluación y mensaje para el usuario.
  static AnomalyResult detectAnomaly({
    required TransactionModel newTransaction,
    required List<TransactionModel> historicalTransactions,
  }) {
    if (newTransaction.type != 'expense') {
      return const AnomalyResult(
        isAnomalous: false,
        categoryAverage: 0,
        deviationFactor: 1,
        message: '',
      );
    }

    final category = newTransaction.category.split('_')[0];

    // Obtener transacciones históricas de la misma categoría (excluyendo la nueva)
    final historicalSame = historicalTransactions.where((t) =>
        t.type == 'expense' &&
        t.category.split('_')[0] == category &&
        t.id != newTransaction.id).toList();

    if (historicalSame.length < 3) {
      // Insuficiente historial para detectar anomalías
      return const AnomalyResult(
        isAnomalous: false,
        categoryAverage: 0,
        deviationFactor: 1,
        message: '',
      );
    }

    final amounts = historicalSame.map((t) => t.amount).toList();
    final average = amounts.reduce((a, b) => a + b) / amounts.length;

    // Calcular desviación estándar para un análisis más robusto
    final variance = amounts.map((a) => (a - average) * (a - average)).reduce((a, b) => a + b) / amounts.length;
    final stdDev = variance > 0 ? variance : 1.0;

    final deviationFactor = average > 0 ? newTransaction.amount / average : 1.0;
    final zScore = stdDev > 0 ? (newTransaction.amount - average) / stdDev : 0.0;

    // Umbral: >2.5x el promedio O z-score > 2 se considera anómalo
    final isAnomalous = deviationFactor > 2.5 || zScore > 2.0;

    if (!isAnomalous) {
      return AnomalyResult(
        isAnomalous: false,
        categoryAverage: average,
        deviationFactor: deviationFactor,
        message: '',
      );
    }

    final categoryLabel = _categoryLabel(category);
    return AnomalyResult(
      isAnomalous: true,
      categoryAverage: average,
      deviationFactor: deviationFactor,
      message: '⚠️ Este gasto en $categoryLabel (${deviationFactor.toStringAsFixed(1)}x tu promedio de \$${average.toStringAsFixed(2)}) es inusualmente alto.',
    );
  }

  /// Verifica si hay cobros recurrentes duplicados en el mismo período.
  static List<TransactionModel> detectDuplicateRecurring({
    required List<TransactionModel> transactions,
    int lookbackDays = 7,
  }) {
    final now = DateTime.now();
    final recentWindow = transactions.where((t) =>
        t.type == 'expense' &&
        now.difference(t.date).inDays <= lookbackDays).toList();

    // Agrupar por descripción normalizada
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in recentWindow) {
      final key = '${tx.description.toLowerCase().trim()}_${tx.amount.toStringAsFixed(0)}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final duplicates = <TransactionModel>[];
    for (final group in grouped.values) {
      if (group.length > 1) {
        duplicates.addAll(group.skip(1)); // Reportar duplicados (el primero es el original)
      }
    }
    return duplicates;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. PROYECCIÓN PREDICTIVA DE SALDO (END-OF-MONTH CASH FLOW FORECAST)
  // ─────────────────────────────────────────────────────────────────────────

  /// Calcula la proyección de saldo al cierre del mes actual basándose en
  /// patrones de gastos e ingresos del usuario.
  static CashFlowForecast calculateEoMForecast({
    required List<TransactionModel> transactions,
    required String? salary,
  }) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = totalDaysInMonth - now.day;
    final daysPassed = now.day;

    // Ingresos y gastos del mes actual
    final currentMonthTx = transactions.where((t) =>
        t.date.year == now.year && t.date.month == now.month).toList();

    final currentIncome = currentMonthTx
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final currentExpense = currentMonthTx
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    // Gastos fijos pendientes (gastos recurrentes no cobrados este mes aún)
    final fixedPendingExpenses = transactions.where((t) =>
        t.type == 'expense' &&
        t.isFixed &&
        t.recurrenceType == 'monthly' &&
        t.recurrenceDay != null &&
        t.recurrenceDay! > now.day).toList();

    final projectedRemainingFixed = fixedPendingExpenses.fold(0.0, (sum, t) => sum + t.amount);

    // Proyectar gastos variables: tasa diaria × días restantes
    final dailyVariableRate = daysPassed > 0
        ? currentExpense / daysPassed
        : 0.0;
    final projectedVariableRemaining = dailyVariableRate * daysRemaining;

    // Ingresos pendientes del mes (salario declarado si no se ha registrado aún)
    double pendingIncome = 0.0;
    if (currentIncome == 0 && salary != null) {
      final salaryAmount = double.tryParse(salary.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      pendingIncome = salaryAmount;
    }

    final projectedEndBalance = currentIncome + pendingIncome
        - currentExpense
        - projectedRemainingFixed
        - projectedVariableRemaining;

    final savingsCapacity = projectedEndBalance;

    // Nivel de riesgo basado en el saldo proyectado
    String riskLevel;
    if (projectedEndBalance > (currentIncome * 0.2)) {
      riskLevel = 'low';
    } else if (projectedEndBalance > 0) {
      riskLevel = 'medium';
    } else if (projectedEndBalance > -(currentIncome * 0.2)) {
      riskLevel = 'high';
    } else {
      riskLevel = 'critical';
    }

    return CashFlowForecast(
      projectedEndBalance: projectedEndBalance,
      currentMonthIncome: currentIncome + pendingIncome,
      currentMonthExpense: currentExpense,
      projectedRemainingFixed: projectedRemainingFixed,
      savingsCapacity: savingsCapacity,
      daysRemaining: daysRemaining,
      riskLevel: riskLevel,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. CATEGORIZACIÓN SEMÁNTICA AUTOMÁTICA
  // ─────────────────────────────────────────────────────────────────────────

  /// Dada la descripción de una transacción, usa IA para sugerir la categoría
  /// más apropiada. Devuelve el ID de categoría (food, transport, bills, etc.)
  static Future<String> suggestCategory(String description) async {
    if (description.trim().isEmpty) return 'other';

    // Intentar categorización local primero (heurística rápida)
    final localCategory = _localCategorize(description.toLowerCase());
    if (localCategory != null) return localCategory;

    // Si la heurística no resuelve, usar IA
    try {
      final model = _getModel();
      final prompt = '''
Categoriza esta transacción financiera en UNA de las siguientes categorías:
food, transport, bills, shopping, entertainment, health, home, education, salary, freelance, investments, other

Transacción: "$description"

Responde SOLO con el nombre de la categoría en minúsculas, sin explicación adicional.
Ejemplos:
- "Uber" -> transport
- "Spotify" -> entertainment
- "Farmacia ABC" -> health
- "Rappi Pizza" -> food
''';

      final response = await model.generateContent(
        [Content.text(prompt)],
      ).timeout(const Duration(seconds: AIConfig.apiTimeoutSeconds));

      final suggested = response.text?.trim().toLowerCase() ?? 'other';
      final validCategories = ['food', 'transport', 'bills', 'shopping', 'entertainment', 'health', 'home', 'education', 'salary', 'freelance', 'investments', 'other'];
      return validCategories.contains(suggested) ? suggested : 'other';
    } catch (_) {
      return 'other';
    }
  }

  // Heurística local para categorización sin IA (más rápida)
  static String? _localCategorize(String desc) {
    final rules = {
      'food': ['pizza', 'burger', 'taco', 'comida', 'restaurante', 'sushi', 'rappi', 'uber eats', 'doordash', 'grubhub', 'mcdonalds', 'kfc', 'subway', 'dominos', 'starbucks', 'café', 'cafe', 'coffee', 'panadería', 'panaderia', 'supermercado', 'super', 'walmart', 'chedraui', 'soriana', 'mercado'],
      'transport': ['uber', 'lyft', 'taxi', 'gasolinera', 'gasolina', 'gas station', 'metro', 'autobus', 'autobús', 'bus', 'parkimetro', 'estacionamiento', 'parking', 'peaje', 'toll', 'transporte'],
      'bills': ['telmex', 'totalplay', 'megacable', 'izzi', 'telcel', 'at&t', 'movistar', 'cfe', 'conagua', 'electricidad', 'internet', 'renta', 'renta mensual', 'netflix', 'spotify', 'amazon prime', 'disney', 'youtube premium'],
      'shopping': ['amazon', 'mercado libre', 'shein', 'zara', 'h&m', 'liverpool', 'sears', 'falabella', 'tienda', 'compra', 'ropa'],
      'health': ['farmacia', 'pharmacy', 'doctor', 'médico', 'medico', 'hospital', 'clínica', 'clinica', 'dentista', 'laboratorio', 'ginecólogo', 'optometría', 'gym', 'gimnasio'],
      'entertainment': ['cine', 'cinema', 'teatro', 'concierto', 'videojuego', 'xbox', 'playstation', 'steam', 'twitch', 'bar', 'antro', 'discoteca', 'fiesta', 'tickets'],
      'home': ['ikea', 'home depot', 'ferretería', 'ferreteria', 'decoración', 'decoracion', 'plomero', 'electricista', 'mantenimiento'],
      'education': ['colegio', 'escuela', 'universidad', 'curso', 'udemy', 'coursera', 'libros', 'librerías', 'libreria', 'tutoría'],
    };

    for (final entry in rules.entries) {
      for (final keyword in entry.value) {
        if (desc.contains(keyword)) return entry.key;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. ASISTENTE DE AJUSTE DE METAS DINÁMICO
  // ─────────────────────────────────────────────────────────────────────────

  /// Analiza el progreso de las metas de ahorro y genera recomendaciones
  /// de ajuste si el usuario está retrasado.
  static Future<List<Map<String, dynamic>>> analyzeSavingsGoalProgress({
    required List<SavingGoal> goals,
    required double monthlySavingsCapacity,
    required String currency,
  }) async {
    if (goals.isEmpty || monthlySavingsCapacity <= 0) return [];

    final recommendations = <Map<String, dynamic>>[];

    for (final goal in goals) {
      final remaining = goal.targetAmount - goal.currentAmount;
      if (remaining <= 0) continue; // Meta ya completada

      // Calcular cuota mensual sugerida con capacidad de ahorro actual
      final suggestedMonthly = (monthlySavingsCapacity * 0.3).clamp(0.0, remaining);
      final monthsNeeded = suggestedMonthly > 0 ? (remaining / suggestedMonthly).ceil() : null;

      recommendations.add({
        'goalId': goal.id,
        'goalName': goal.name,
        'remaining': remaining,
        'suggestedMonthly': suggestedMonthly,
        'monthsToComplete': monthsNeeded,
        'progressPercent': goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount * 100).clamp(0.0, 100.0) : 0.0,
        'status': goal.currentAmount / goal.targetAmount < 0.1 ? 'critical' : 'on_track',
      });
    }

    return recommendations;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. GENERACIÓN DE MICRO-INSIGHTS DIARIOS/SEMANALES
  // ─────────────────────────────────────────────────────────────────────────

  /// Genera micro-insights personalizados basados en el comportamiento
  /// financiero del usuario de la semana actual vs. la semana anterior.
  static Future<List<MicroInsight>> generateMicroInsights({
    required List<TransactionModel> transactions,
    required String language,
    required String currency,
  }) async {
    // Primero generar insights locales (rápidos, sin IA)
    final localInsights = _generateLocalInsights(transactions, currency);

    // Luego enriquecer con IA si hay suficiente historial
    if (transactions.length < 5 || AIConfig.apiKey.isEmpty) {
      return localInsights;
    }

    try {
      final insights = await _generateAIInsights(
        transactions: transactions,
        language: language,
        currency: currency,
      );
      // Combinar: máximo 4 insights (2 locales + 2 IA)
      final combined = [...insights, ...localInsights].take(4).toList();
      return combined.isEmpty ? localInsights : combined;
    } catch (_) {
      return localInsights; // Fallback a insights locales
    }
  }

  /// Insights generados localmente (instantáneos, sin llamada a API)
  static List<MicroInsight> _generateLocalInsights(
    List<TransactionModel> transactions,
    String currency,
  ) {
    final now = DateTime.now();
    final insights = <MicroInsight>[];

    // Semana actual (últimos 7 días) vs semana anterior (8-14 días atrás)
    final thisWeek = transactions.where((t) =>
        t.type == 'expense' && now.difference(t.date).inDays < 7).toList();
    final lastWeek = transactions.where((t) =>
        t.type == 'expense' &&
        now.difference(t.date).inDays >= 7 &&
        now.difference(t.date).inDays < 14).toList();

    final thisWeekTotal = thisWeek.fold(0.0, (s, t) => s + t.amount);
    final lastWeekTotal = lastWeek.fold(0.0, (s, t) => s + t.amount);

    // Insight 1: Comparación semanal total
    if (lastWeekTotal > 0 && thisWeekTotal > 0) {
      final pct = ((thisWeekTotal - lastWeekTotal) / lastWeekTotal * 100).abs();
      if (thisWeekTotal < lastWeekTotal) {
        insights.add(MicroInsight(
          emoji: '🎉',
          title: '¡Semana más económica!',
          body: 'Gastaste un ${pct.toStringAsFixed(0)}% menos que la semana pasada. ¡Excelente control!',
          type: InsightType.positive,
          generatedAt: now,
        ));
      } else if (pct > 20) {
        insights.add(MicroInsight(
          emoji: '⚠️',
          title: 'Semana con más gastos',
          body: 'Tus gastos subieron un ${pct.toStringAsFixed(0)}% vs. la semana pasada. Revisa en qué categoría está el aumento.',
          type: InsightType.warning,
          generatedAt: now,
        ));
      }
    }

    // Insight 2: Categoría más costosa de la semana
    if (thisWeek.isNotEmpty) {
      final Map<String, double> byCat = {};
      for (final t in thisWeek) {
        final cat = t.category.split('_')[0];
        byCat[cat] = (byCat[cat] ?? 0) + t.amount;
      }
      if (byCat.isNotEmpty) {
        final topCat = byCat.entries.reduce((a, b) => a.value > b.value ? a : b);
        final label = _categoryLabel(topCat.key);
        insights.add(MicroInsight(
          emoji: _categoryEmoji(topCat.key),
          title: 'Tu mayor gasto: $label',
          body: 'Esta semana gastaste \$${ topCat.value.toStringAsFixed(2)} en $label.',
          type: InsightType.info,
          generatedAt: now,
        ));
      }
    }

    // Insight 3: Racha de días sin gastos
    if (transactions.where((t) => t.type == 'expense').isNotEmpty) {
      final lastExpense = transactions
          .where((t) => t.type == 'expense')
          .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      final daysSince = now.difference(lastExpense.date).inDays;
      if (daysSince >= 2) {
        insights.add(MicroInsight(
          emoji: '🧘',
          title: '$daysSince días sin gastos',
          body: '¡Llevas $daysSince días sin registrar gastos! Tu fondo de ahorro agradece la pausa.',
          type: InsightType.positive,
          generatedAt: now,
        ));
      }
    }

    return insights;
  }

  /// Insights generados por IA (más personalizados y narrativos)
  static Future<List<MicroInsight>> _generateAIInsights({
    required List<TransactionModel> transactions,
    required String language,
    required String currency,
  }) async {
    final now = DateTime.now();

    // Construir contexto compacto para minimizar tokens
    final thisWeek = transactions.where((t) =>
        t.type == 'expense' && now.difference(t.date).inDays < 7).toList();
    final lastWeek = transactions.where((t) =>
        t.type == 'expense' &&
        now.difference(t.date).inDays >= 7 &&
        now.difference(t.date).inDays < 14).toList();

    final Map<String, double> thisWeekByCat = {};
    final Map<String, double> lastWeekByCat = {};
    for (final t in thisWeek) {
      final cat = t.category.split('_')[0];
      thisWeekByCat[cat] = (thisWeekByCat[cat] ?? 0) + t.amount;
    }
    for (final t in lastWeek) {
      final cat = t.category.split('_')[0];
      lastWeekByCat[cat] = (lastWeekByCat[cat] ?? 0) + t.amount;
    }

    final thisWeekSummary = thisWeekByCat.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ');
    final lastWeekSummary = lastWeekByCat.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ');

    final prompt = '''
Genera exactamente 2 micro-insights financieros personalizados para un usuario.
Moneda: $currency
Idioma de respuesta: $language

Datos de esta semana: $thisWeekSummary
Datos de la semana pasada: $lastWeekSummary

Responde SOLO con un JSON array válido con este formato exacto (sin markdown, sin texto extra):
[
  {
    "emoji": "🎯",
    "title": "Título corto (max 40 chars)",
    "body": "Descripción en 1-2 frases con números reales",
    "type": "positive|warning|info|tip"
  }
]

Reglas:
- Usa SIEMPRE datos reales del contexto
- Sé específico y accionable
- type "positive" = logro, "warning" = alerta, "info" = dato, "tip" = consejo
''';

    final model = _getModel();
    final response = await model.generateContent(
      [Content.text(prompt)],
    ).timeout(const Duration(seconds: 15)); // Timeout corto para insights

    final text = response.text?.trim() ?? '[]';

    // Limpiar posible markdown
    final cleaned = text.replaceAll(RegExp(r'```json|```'), '').trim();

    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList.map((item) => MicroInsight.fromJson(item as Map<String, dynamic>)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  static String _categoryLabel(String category) {
    const labels = {
      'food': 'Comida', 'transport': 'Transporte', 'bills': 'Servicios',
      'shopping': 'Compras', 'entertainment': 'Entretenimiento', 'health': 'Salud',
      'home': 'Hogar', 'education': 'Educación', 'other': 'Otros',
      'salary': 'Salario', 'freelance': 'Freelance', 'investments': 'Inversiones',
    };
    return labels[category] ?? category;
  }

  static String _categoryEmoji(String category) {
    const emojis = {
      'food': '🍔', 'transport': '🚗', 'bills': '📱', 'shopping': '🛍️',
      'entertainment': '🎬', 'health': '💊', 'home': '🏠', 'education': '📚',
      'salary': '💰', 'freelance': '💻', 'investments': '📈', 'other': '📌',
    };
    return emojis[category] ?? '💡';
  }
}
