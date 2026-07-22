import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../domain/models/micro_insight.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_provider.dart';
import 'auth_provider.dart';
import 'saving_goals_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DEL PROVIDER DE INSIGHTS
// ─────────────────────────────────────────────────────────────────────────────

class AIInsightsState {
  final List<MicroInsight> insights;
  final bool isLoadingInsights;
  final CashFlowForecast? forecast;
  final List<Map<String, dynamic>> goalRecommendations;
  final String? errorMessage;

  const AIInsightsState({
    this.insights = const [],
    this.isLoadingInsights = false,
    this.forecast,
    this.goalRecommendations = const [],
    this.errorMessage,
  });

  AIInsightsState copyWith({
    List<MicroInsight>? insights,
    bool? isLoadingInsights,
    CashFlowForecast? forecast,
    List<Map<String, dynamic>>? goalRecommendations,
    String? errorMessage,
  }) {
    return AIInsightsState(
      insights: insights ?? this.insights,
      isLoadingInsights: isLoadingInsights ?? this.isLoadingInsights,
      forecast: forecast ?? this.forecast,
      goalRecommendations: goalRecommendations ?? this.goalRecommendations,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class AIInsightsNotifier extends Notifier<AIInsightsState> {
  @override
  AIInsightsState build() {
    return const AIInsightsState();
  }

  /// Carga los micro-insights y el forecast de fin de mes.
  /// Se llama desde el Dashboard al inicializar.
  Future<void> loadInsightsAndForecast() async {
    if (state.isLoadingInsights) return;

    state = state.copyWith(isLoadingInsights: true, errorMessage: null);

    try {
      final transactions = ref.read(transactionsProvider).value ?? [];
      final user = ref.read(authProvider).user;
      final goals = ref.read(savingGoalsProvider).value ?? [];

      // Calcular forecast localmente (rápido, sin IA)
      final forecast = AIAnalysisService.calculateEoMForecast(
        transactions: transactions,
        salary: user?.salary,
      );

      // Generar micro-insights (IA + local)
      final insights = await AIAnalysisService.generateMicroInsights(
        transactions: transactions,
        language: user?.language ?? 'Español',
        currency: user?.currency ?? 'USD',
      );

      // Análisis de metas
      final goalRecs = await AIAnalysisService.analyzeSavingsGoalProgress(
        goals: goals,
        monthlySavingsCapacity: forecast.savingsCapacity,
        currency: user?.currency ?? 'USD',
      );

      state = state.copyWith(
        insights: insights,
        forecast: forecast,
        goalRecommendations: goalRecs,
        isLoadingInsights: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInsights: false,
        errorMessage: 'No se pudieron cargar los insights: ${e.toString()}',
      );
    }
  }

  /// Analiza si una transacción nueva es anómala y retorna el resultado.
  AnomalyResult checkAnomaly(TransactionModel newTransaction) {
    final transactions = ref.read(transactionsProvider).value ?? [];
    return AIAnalysisService.detectAnomaly(
      newTransaction: newTransaction,
      historicalTransactions: transactions,
    );
  }

  /// Busca posibles cobros duplicados recientes.
  List<TransactionModel> checkDuplicates() {
    final transactions = ref.read(transactionsProvider).value ?? [];
    return AIAnalysisService.detectDuplicateRecurring(transactions: transactions);
  }

  /// Sugiere una categoría para una transacción dado su descripción.
  Future<String> suggestCategory(String description) async {
    return AIAnalysisService.suggestCategory(description);
  }

  /// Descarta un insight por índice (el usuario lo cierra).
  void dismissInsight(int index) {
    final updated = List<MicroInsight>.from(state.insights);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(insights: updated);
    }
  }

  /// Fuerza recarga de insights (útil para pull-to-refresh).
  Future<void> refresh() => loadInsightsAndForecast();
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS PÚBLICOS
// ─────────────────────────────────────────────────────────────────────────────

final aiInsightsProvider = NotifierProvider<AIInsightsNotifier, AIInsightsState>(() {
  return AIInsightsNotifier();
});

/// Provider derivado — solo el forecast de fin de mes
final cashFlowForecastProvider = Provider<CashFlowForecast?>((ref) {
  return ref.watch(aiInsightsProvider).forecast;
});

/// Provider derivado — solo los micro-insights
final microInsightsProvider = Provider<List<MicroInsight>>((ref) {
  return ref.watch(aiInsightsProvider).insights;
});

/// Provider derivado — estado de carga de insights
final insightsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(aiInsightsProvider).isLoadingInsights;
});
