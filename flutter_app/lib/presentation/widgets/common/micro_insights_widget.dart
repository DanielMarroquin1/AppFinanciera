import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/micro_insight.dart';
import '../../providers/ai_insights_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/ad_service.dart';
import '../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET PRINCIPAL: SECCIÓN DE MICRO-INSIGHTS EN EL DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class MicroInsightsSection extends ConsumerWidget {
  const MicroInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insightsState = ref.watch(aiInsightsProvider);
    final insights = insightsState.insights;
    final isLoading = insightsState.isLoadingInsights;

    if (isLoading) {
      return _InsightsSkeleton(isDark: isDark);
    }

    if (insights.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'Insights de Zent AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(aiInsightsProvider.notifier).refresh(),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        // Carrusel horizontal de tarjetas
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _InsightCard(
                insight: insights[index],
                isDark: isDark,
                onDismiss: () => ref.read(aiInsightsProvider.notifier).dismissInsight(index),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        AdBannerWidget(isPremium: ref.watch(authProvider).user?.isPremium ?? false),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA INDIVIDUAL DE INSIGHT
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final MicroInsight insight;
  final bool isDark;
  final VoidCallback onDismiss;

  const _InsightCard({
    required this.insight,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _insightColors(insight.type, isDark);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['border']!, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors['shadow']!,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: emoji + dismiss
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insight.emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 14, color: colors['textSecondary']),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Título
          Text(
            insight.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors['textPrimary'],
            ),
          ),
          const SizedBox(height: 4),
          // Cuerpo
          Expanded(
            child: Text(
              insight.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: colors['textSecondary'],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color?> _insightColors(InsightType type, bool isDark) {
    switch (type) {
      case InsightType.positive:
        return {
          'background': isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4),
          'border': isDark ? const Color(0xFF166534) : const Color(0xBBBBFBBB),
          'shadow': const Color(0xFF10B981).withOpacity(0.12),
          'textPrimary': isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
          'textSecondary': isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        };
      case InsightType.warning:
        return {
          'background': isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED),
          'border': isDark ? const Color(0xFF9A3412) : const Color(0xFFFFD7B5),
          'shadow': const Color(0xFFF97316).withOpacity(0.12),
          'textPrimary': isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412),
          'textSecondary': isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C),
        };
      case InsightType.tip:
        return {
          'background': isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF5F3FF),
          'border': isDark ? const Color(0xFF3730A3) : const Color(0xFFDDD6FE),
          'shadow': const Color(0xFF8B5CF6).withOpacity(0.12),
          'textPrimary': isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B21B6),
          'textSecondary': isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        };
      case InsightType.info:
      default:
        return {
          'background': isDark ? const Color(0xFF0C1A2E) : const Color(0xFFEFF6FF),
          'border': isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBFDBFE),
          'shadow': const Color(0xFF3B82F6).withOpacity(0.12),
          'textPrimary': isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
          'textSecondary': isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
        };
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADER
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsSkeleton extends StatefulWidget {
  final bool isDark;
  const _InsightsSkeleton({required this.isDark});

  @override
  State<_InsightsSkeleton> createState() => _InsightsSkeletonState();
}

class _InsightsSkeletonState extends State<_InsightsSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _shimmerBox(widget.isDark, 140, 16),
        ),
        SizedBox(
          height: 110,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Row(
              children: [
                _skeletonCard(widget.isDark),
                const SizedBox(width: 12),
                _skeletonCard(widget.isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _skeletonCard(bool isDark) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 220,
        height: 110,
        decoration: BoxDecoration(
          color: isDark
              ? Color.lerp(const Color(0xFF1E293B), const Color(0xFF334155), _anim.value)
              : Color.lerp(const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), _anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(isDark, 24, 24),
            const SizedBox(height: 8),
            _shimmerBox(isDark, 120, 12),
            const SizedBox(height: 6),
            _shimmerBox(isDark, 180, 10),
            const SizedBox(height: 4),
            _shimmerBox(isDark, 160, 10),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(bool isDark, double width, double height) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark
              ? Color.lerp(const Color(0xFF334155), const Color(0xFF475569), _anim.value)
              : Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), _anim.value),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: CARD DE CASH FLOW FORECAST (FIN DE MES)
// ─────────────────────────────────────────────────────────────────────────────

class CashFlowForecastCard extends ConsumerStatefulWidget {
  final String currencySymbol;
  const CashFlowForecastCard({super.key, required this.currencySymbol});

  @override
  ConsumerState<CashFlowForecastCard> createState() => _CashFlowForecastCardState();
}

class _CashFlowForecastCardState extends ConsumerState<CashFlowForecastCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forecast = ref.watch(cashFlowForecastProvider);

    if (forecast == null) return const SizedBox.shrink();

    final sym = widget.currencySymbol;
    final riskColors = _riskColors(forecast.riskLevel, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColors['border']!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: riskColors['shadow']!,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: riskColors['accent']!.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.query_stats_rounded,
                        color: riskColors['accent'],
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proyección Fin de Mes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${forecast.daysRemaining} días restantes',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Saldo proyectado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$sym${forecast.projectedEndBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: riskColors['accent'],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColors['accent']!.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _riskLabel(forecast.riskLevel),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: riskColors['accent'],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
                // Detalle expandible
                if (_expanded) ...[
                  const SizedBox(height: 14),
                  Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  _forecastRow('💰 Ingresos del mes', '$sym${forecast.currentMonthIncome.toStringAsFixed(2)}', isDark, isPositive: true),
                  const SizedBox(height: 6),
                  _forecastRow('💸 Gastos registrados', '-$sym${forecast.currentMonthExpense.toStringAsFixed(2)}', isDark),
                  const SizedBox(height: 6),
                  _forecastRow('🔒 Gastos fijos pendientes', '-$sym${forecast.projectedRemainingFixed.toStringAsFixed(2)}', isDark),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: riskColors['accent']!.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 Saldo proyectado',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '$sym${forecast.projectedEndBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: riskColors['accent'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _forecastRow(String label, String value, bool isDark, {bool isPositive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPositive
                ? Colors.green[400]
                : (isDark ? Colors.grey[300] : Colors.black87),
          ),
        ),
      ],
    );
  }

  Map<String, Color?> _riskColors(String riskLevel, bool isDark) {
    switch (riskLevel) {
      case 'low':
        return {'accent': const Color(0xFF10B981), 'border': const Color(0xFF10B981).withOpacity(0.3), 'shadow': const Color(0xFF10B981).withOpacity(0.1)};
      case 'medium':
        return {'accent': const Color(0xFFF59E0B), 'border': const Color(0xFFF59E0B).withOpacity(0.3), 'shadow': const Color(0xFFF59E0B).withOpacity(0.1)};
      case 'high':
        return {'accent': const Color(0xFFF97316), 'border': const Color(0xFFF97316).withOpacity(0.3), 'shadow': const Color(0xFFF97316).withOpacity(0.1)};
      case 'critical':
      default:
        return {'accent': const Color(0xFFEF4444), 'border': const Color(0xFFEF4444).withOpacity(0.3), 'shadow': const Color(0xFFEF4444).withOpacity(0.1)};
    }
  }

  String _riskLabel(String riskLevel) {
    switch (riskLevel) {
      case 'low':     return '✅ Estable';
      case 'medium':  return '⚡ Ajustado';
      case 'high':    return '⚠️ En riesgo';
      case 'critical':return '🚨 Crítico';
      default:        return '';
    }
  }
}
