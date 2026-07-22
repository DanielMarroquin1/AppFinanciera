/// Tipos de micro-insight para coloración y iconografía contextual
enum InsightType {
  positive,  // Logro o tendencia positiva (verde)
  warning,   // Alerta de gasto elevado (naranja)
  info,      // Dato informativo neutro (azul)
  tip,       // Consejo accionable (violeta)
}

/// Representa una tarjeta de micro-insight personalizada generada por la IA
/// para mostrar en el Dashboard del usuario.
class MicroInsight {
  final String emoji;
  final String title;
  final String body;
  final InsightType type;
  final DateTime generatedAt;

  const MicroInsight({
    required this.emoji,
    required this.title,
    required this.body,
    required this.type,
    required this.generatedAt,
  });

  /// Construye un MicroInsight desde un mapa JSON (respuesta de la IA)
  factory MicroInsight.fromJson(Map<String, dynamic> json) {
    InsightType parseType(String? t) {
      switch (t) {
        case 'positive': return InsightType.positive;
        case 'warning':  return InsightType.warning;
        case 'tip':      return InsightType.tip;
        default:         return InsightType.info;
      }
    }

    return MicroInsight(
      emoji: json['emoji'] as String? ?? '💡',
      title: json['title'] as String? ?? '',
      body:  json['body']  as String? ?? '',
      type:  parseType(json['type'] as String?),
      generatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'title': title,
    'body': body,
    'type': type.name,
    'generatedAt': generatedAt.toIso8601String(),
  };
}

/// Proyección del flujo de caja al cierre del mes actual
class CashFlowForecast {
  final double projectedEndBalance;    // Saldo estimado al cierre del mes
  final double currentMonthIncome;     // Ingresos confirmados este mes
  final double currentMonthExpense;    // Gastos registrados este mes
  final double projectedRemainingFixed;// Gastos fijos pendientes hasta fin de mes
  final double savingsCapacity;        // Margen de ahorro proyectado
  final int daysRemaining;             // Días restantes del mes
  final String riskLevel;              // 'low', 'medium', 'high', 'critical'

  const CashFlowForecast({
    required this.projectedEndBalance,
    required this.currentMonthIncome,
    required this.currentMonthExpense,
    required this.projectedRemainingFixed,
    required this.savingsCapacity,
    required this.daysRemaining,
    required this.riskLevel,
  });
}

/// Resultado de la detección de anomalías en una transacción
class AnomalyResult {
  final bool isAnomalous;
  final double categoryAverage;        // Promedio histórico de la categoría
  final double deviationFactor;        // Cuántas veces supera la media
  final String message;                // Mensaje explicativo para el usuario

  const AnomalyResult({
    required this.isAnomalous,
    required this.categoryAverage,
    required this.deviationFactor,
    required this.message,
  });
}
